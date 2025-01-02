import 'package:bahri_app/services/gyroGame_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'dart:async';

class BallGame extends StatefulWidget {
  const BallGame({super.key});

  @override
  State<BallGame> createState() => _BallGameState();
}

class _BallGameState extends State<BallGame>
    with SingleTickerProviderStateMixin {
  final GyroData gyroData = GyroData();
  double posX = 0.0;
  double posY = 0.0;
  double ballSize = 50.0;
  int gridRows = 10;
  int gridCols = 5;
  double cellWidth = 100.0;
  double cellHeight = 100.0;

  late StreamSubscription _sensorSubscription;
  late AnimationController _controller;
  bool isGameOver = false;
  bool isGameWon = false;
  bool isGameStarted = false;
  int score = 0;
  late Timer _timer;
  String currentDifficulty = '';
  List<Rect> obstacles = [];
  String? uid;

  bool sessionEnded = false;

  DateTime? _lastUpdateTime;
  bool _isMoving = false;

  final Map<String, List<Rect>> difficultyLevels = {
    'Easy': [
      const Rect.fromLTWH(50, 150, 200, 40),
      const Rect.fromLTWH(50, 320, 200, 40),
    ],
    'Medium': [
      const Rect.fromLTWH(50, 150, 200, 30),
      //const Rect.fromLTWH(50, 240, 200, 30),
      const Rect.fromLTWH(150, 500, 200, 30),
    ],
    'Hard': [
      const Rect.fromLTWH(50, 100, 100, 25),
      const Rect.fromLTWH(50, 200, 150, 25),
      const Rect.fromLTWH(50, 300, 200, 25),
      const Rect.fromLTWH(50, 400, 250, 25),
      const Rect.fromLTWH(50, 500, 200, 25),
      // const Rect.fromLTWH(50, 600, 150, 25),
      // const Rect.fromLTWH(50, 700, 100, 25),
    ],
  };

  Future<void> fetchUserId() async {
    uid = await getUserId();
    debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
  }

  @override
  void initState() {
    super.initState();
    fetchUserId();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    gyroData.initHive();
  }

  void startGame(String difficulty) async {
    if (uid == null) {
      await fetchUserId();
    }

    // End any previous session if it exists
    if (!sessionEnded) {
      await gyroData.endSession();
    }
    await gyroData.startNewSession(uid ?? 'anonymous');

    setState(() {
      isGameStarted = true;
      currentDifficulty = difficulty;
      obstacles = difficultyLevels[difficulty]!;
      posX = (MediaQuery.of(context).size.width - ballSize) / 2;
      posY = MediaQuery.of(context).size.height - ballSize - 20;
      isGameOver = false;
      isGameWon = false;
      score = 0;
      sessionEnded = false; // Reset the session end flag
    });
    _initializeSensors();
    _startScoreTimer();
  }

  void _initializeSensors() async {
    if (await SensorManager().isSensorAvailable(Sensors.GYROSCOPE)) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.GYROSCOPE,
        interval: Sensors.SENSOR_DELAY_FASTEST, // Highest frequency available
      );

      _sensorSubscription = stream.listen((sensorEvent) {
        if (!isGameOver && !isGameWon) {
          DateTime currentTime = DateTime.now();
          double gyroX = sensorEvent.data[0];
          double gyroY = sensorEvent.data[1];
          double gyroZ = sensorEvent.data[2];

          if (_lastUpdateTime != null) {
            // Perform calculations here
            gyroData.calculateTiltAngle(gyroX, gyroY, gyroZ);
            gyroData.calculateTiltStability(gyroX, gyroY, gyroZ);
            gyroData.calculateTiltSpeed(gyroX, gyroY, currentTime);
            gyroData.calculateMicroAdjustments(gyroX, gyroY, gyroZ);
            gyroData.calculateRotationDirection(gyroX, currentTime);
            gyroData.calculateRotationDuration(gyroX, currentTime);

            if (gyroData.isSignificantMovement(gyroX, gyroY, gyroZ)) {
              _isMoving = true;
              gyroData
                  .storeGyroDataDartFrog(uid!, gyroX, gyroY, gyroZ)
                  .then((_) {});
            } else {
              if (_isMoving) {
                _isMoving = false;
                gyroData.rotationStartTime = null;
                gyroData.rotationDuration = 0.0;
              }
            }

            // Check collision and goal immediately
            if (_checkCollision()) {
              _gameOver();
            } else if (_checkGoal()) {
              _gameWon();
            } else {
              // Update ball position only if no collision or goal
              setState(() {
                double horizontalSensitivity = 8.0;
                double verticalSensitivity = 7.0;

                posX += gyroY * horizontalSensitivity;
                posY += gyroX * verticalSensitivity;

                posX = posX.clamp(
                    0.0, MediaQuery.of(context).size.width - ballSize);
                posY = posY.clamp(
                    0.0, MediaQuery.of(context).size.height - ballSize - 10);
              });
            }
          }

          _lastUpdateTime = currentTime;
        }
      });
    }
  }

  void _startScoreTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver && !isGameWon) {
        setState(() {
          score++;
        });
      }
    });
  }

  bool _checkCollision() {
    Rect ballRect = Rect.fromLTWH(posX, posY, ballSize, ballSize);
    for (Rect obstacle in obstacles) {
      if (ballRect.overlaps(obstacle)) {
        return true;
      }
    }
    return false;
  }

  bool _checkGoal() {
    Rect goalRect = Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width, 50);
    Rect ballRect = Rect.fromLTWH(posX, posY, ballSize, ballSize);
    return ballRect.overlaps(goalRect);
  }

  void _gameOver() {
    if (!isGameOver && !sessionEnded) {
      sessionEnded = true; // Set the flag
      gyroData.endSession().then((_) {
        setState(() {
          isGameOver = true;
        });
        _sensorSubscription.cancel();
        _timer.cancel();
        _showEnd(); // Separate dialog display logic
      });
    }
  }

  // void _showGameOverDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.teal[200],
  //         title: const Text('Game Over', style: TextStyle(color: Colors.white)),
  //         content: Text('Your score: $score',
  //             style: const TextStyle(color: Colors.white)),
  //         actions: [
  //           TextButton(
  //             onPressed: () {

  //               Navigator.of(context).pop();
  //               setState(() {
  //                 isGameStarted = false;
  //               });
  //             },
  //             style: TextButton.styleFrom(backgroundColor: Colors.teal),
  //             child:
  //                 const Text('GO BACK', style: TextStyle(color: Colors.white)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showEnd() {
    var radius = 10.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Successfully Recorded",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Center(
                      child: Text(
                        'Go back to levels page',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Navigate back
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(radius),
                          bottomRight: Radius.circular(radius),
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 35,
                      width: 250,
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 11,
              ),
            ],
          ),
        );
      },
    );
  }

  void _gameWon() {
    if (!isGameWon && !sessionEnded) {
      debugPrint('Game Won triggered');
      sessionEnded = true; // Set the flag
      gyroData.endSession().then((_) {
        debugPrint('Session ended in _gameWon');
        setState(() {
          isGameWon = true;
        });
        _sensorSubscription.cancel();
        _timer.cancel();
        _showEnd(); // Separate dialog display logic
      });
    }
  }

  // void _showGameWonDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.teal[200],
  //         title: const Text('SUCCESS!GOOD JOB',
  //             style: TextStyle(color: Colors.white)),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               setState(() {
  //                 isGameStarted = false;
  //               });
  //             },
  //             style: TextButton.styleFrom(backgroundColor: Colors.teal),
  //             child: const Text('Choose Level',
  //                 style: TextStyle(color: Colors.white)),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               Navigator.of(context).pop();
  //             },
  //             style: TextButton.styleFrom(backgroundColor: Colors.redAccent),
  //             child: const Text('Quit', style: TextStyle(color: Colors.white)),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  void dispose() async {
    debugPrint('Dispose triggered');
    if (!sessionEnded) {
      sessionEnded = true; // Set the flag
      await gyroData.endSession();
      debugPrint('Session ended in dispose');
    }
    _controller.dispose();
    if (isGameStarted) {
      _sensorSubscription.cancel();
      _timer.cancel();
    }
    super.dispose();
  }

  Widget buildDifficultyMenu() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(5.0, 5.0),
                    blurRadius: 3.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Text(
                'Note: The game will start right when you choose a difficulty',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            _buildLevelButton('Easy', Colors.green),
            const SizedBox(height: 20),
            _buildLevelButton('Medium', Colors.orange),
            const SizedBox(height: 20),
            _buildLevelButton('Hard', Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(String levelName, Color buttonColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: GestureDetector(
        onTap: () => startGame(levelName),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: buttonColor,
              width: 2.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  levelName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isGameStarted) {
      return Scaffold(
        body: buildDifficultyMenu(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue[40],
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 20),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            left: posX,
            top: posY,
            child: Container(
              width: ballSize,
              height: ballSize,
              decoration: BoxDecoration(
                color: isGameOver || isGameWon
                    ? Colors.transparent
                    : Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          for (Rect obstacle in obstacles)
            Positioned(
              left: obstacle.left,
              top: obstacle.top,
              child: Container(
                width: obstacle.width,
                height: obstacle.height,
                color: Colors.blue,
              ),
            ),
          Positioned(
            left: 20,
            right: 20,
            top: 0,
            child: Container(
              width: 200,
              height: 50,
              color: Colors.green[400],
              child: const Center(
                child: Text(
                  'GOAL',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Score display
          // Positioned(
          //   top: 60,
          //   right: 20,
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.black54,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: Text(
          //       'Score: $score',
          //       style: const TextStyle(
          //         color: Colors.white,
          //         fontSize: 20,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ),
          // ),
          // Difficulty display
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Level: $currentDifficulty',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
