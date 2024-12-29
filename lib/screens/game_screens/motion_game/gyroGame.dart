import 'package:bahri_app/services/gyroGame_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'dart:async';

class BallGame extends StatefulWidget {
  const BallGame({super.key});

  @override
  _BallGameState createState() => _BallGameState();
}

class _BallGameState extends State<BallGame> with SingleTickerProviderStateMixin {
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
  DateTime? _lastUpdateTime;
  double _lastGyroX = 0.0;
  double _lastGyroY = 0.0;
  double _lastGyroZ = 0.0;
  bool _isMoving = false;

  final Map<String, List<Rect>> difficultyLevels = {
    'Easy': [
      const Rect.fromLTWH(50, 150, 200, 40),
      const Rect.fromLTWH(50, 320, 200, 40),
      const Rect.fromLTWH(220, 550, 150, 40),
    ],
    'Medium': [
      const Rect.fromLTWH(50, 150, 200, 30),
      const Rect.fromLTWH(50, 240, 200, 30),
      const Rect.fromLTWH(150, 500, 200, 30),
      const Rect.fromLTWH(150, 600, 200, 30),
    ],
    'Hard': [
      const Rect.fromLTWH(50, 100, 100, 25),
      const Rect.fromLTWH(50, 200, 150, 25),
      const Rect.fromLTWH(50, 300, 200, 25),
      const Rect.fromLTWH(50, 400, 250, 25),
      const Rect.fromLTWH(50, 500, 200, 25),
      const Rect.fromLTWH(50, 600, 150, 25),
      const Rect.fromLTWH(50, 700, 100, 25),
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
  }

  void startGame(String difficulty) async {
    // Ensure UID is set
    if (uid == null) {
      await fetchUserId();
    }

    // Start a new gyro session when game starts
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
    });
    _initializeSensors();
    _startScoreTimer();
  }

  void _initializeSensors() async {
    if (await SensorManager().isSensorAvailable(Sensors.GYROSCOPE)) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.GYROSCOPE,
        interval: Sensors.SENSOR_DELAY_GAME,
      );

      _sensorSubscription = stream.listen((sensorEvent) {
        if (!isGameOver && !isGameWon) {
          DateTime currentTime = DateTime.now();
          double gyroX = sensorEvent.data[0];
          double gyroY = sensorEvent.data[1];
          double gyroZ = sensorEvent.data[2];

          // Debug prints to verify sensor data
          debugPrint('Raw Gyro Data - X: $gyroX, Y: $gyroY, Z: $gyroZ');

          // Calculate time delta
          if (_lastUpdateTime != null) {
            double deltaTime = currentTime.difference(_lastUpdateTime!).inMilliseconds / 1000.0;

            // Calculate all gyro metrics in sequence
            // 1. Basic orientation and stability calculations
            gyroData.calculateTiltAngle(gyroX, gyroY, gyroZ);
            gyroData.calculateTiltStability(gyroX, gyroY, gyroZ);

            // 2. Motion and speed calculations
            gyroData.calculateTiltSpeed(gyroX, gyroY, currentTime);
            gyroData.calculateMicroAdjustments(gyroX, gyroY, gyroZ);

            // 3. Rotation and path calculations
            gyroData.calculateRotationDirection(gyroX, currentTime);
            gyroData.calculateRotationPathStraightness(gyroX, gyroY, gyroZ);
            gyroData.calculateRotationDuration(gyroX, currentTime);

            // Debug prints for all metrics
            debugPrint('''
              Stability: ${gyroData.calculateTiltStability(gyroX, gyroY, gyroZ)}
              MicroAdjustments: ${gyroData.calculateMicroAdjustments(gyroX, gyroY, gyroZ)}
              PathStraightness: ${gyroData.calculateRotationPathStraightness(gyroX, gyroY, gyroZ)}
              TiltSpeed: ${gyroData.tiltSpeed}
              RotationDuration: ${gyroData.rotationDuration}
              DirectionConsistency: ${gyroData.rotationDirectionConsistency}
            ''');

            // Check if movement is significant
            if (gyroData.isSignificantMovement(gyroX, gyroY, gyroZ)) {
              _isMoving = true;

              // Store the gyro data
              gyroData.storeGyroDataDartFrog(uid!, gyroX, gyroY, gyroZ).then((_) {
                debugPrint('Stored gyro data with all metrics');
              });
            } else {
              if (_isMoving) {
                _isMoving = false;
                // Reset rotation tracking when movement stops
                gyroData.rotationStartTime = null;
                gyroData.rotationDuration = 0.0;
              }
            }

            // Update ball position
            setState(() {
              double horizontalSensitivity = 20.0;
              double verticalSensitivity = 30.0;

              posX += gyroY * horizontalSensitivity;
              posY += gyroX * verticalSensitivity;

              // Clamp positions
              posX = posX.clamp(0.0, MediaQuery.of(context).size.width - ballSize);
              posY = posY.clamp(0.0, MediaQuery.of(context).size.height - ballSize - 10);

              if (_checkCollision()) {
                _gameOver();
              }
              if (_checkGoal()) {
                _gameWon();
              }
            });
          }

          // Store current values for next update
          _lastUpdateTime = currentTime;
          _lastGyroX = gyroX;
          _lastGyroY = gyroY;
          _lastGyroZ = gyroZ;
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

  void _gameOver() async {
    await gyroData.endSession();
    setState(() {
      isGameOver = true;
    });
    _sensorSubscription.cancel();
    _timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[200],
          title: const Text('Game Over', style: TextStyle(color: Colors.white)),
          content: Text('Your score: $score', style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isGameStarted = false;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Choose Level', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame(currentDifficulty);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }



void _gameWon() async {
    await gyroData.endSession();
    setState(() {
      isGameWon = true;
    });
    _sensorSubscription.cancel();
    _timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[200],
          title: const Text('Level Complete!', style: TextStyle(color: Colors.white)),
          content: Text('Your score: $score', style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  isGameStarted = false;
                });
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Choose Level', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Quit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _checkGyroscope() async {
    bool sensorAvailable = await SensorManager().isSensorAvailable(Sensors.GYROSCOPE);
    if (!sensorAvailable) {
      _showGyroscopeNotAvailableDialog();
    }
  }

  void _showGyroscopeNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gyroscope Not Available'),
          content: const Text('Your device does not have a gyroscope.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget buildDifficultyMenu() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: true,
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
            _buildLevelButton('Easy', Colors.green, 'HighScore:'),
            const SizedBox(height: 20),
            _buildLevelButton('Medium', Colors.orange, 'HighScore:'),
            const SizedBox(height: 20),
            _buildLevelButton('Hard', Colors.red, 'HighScore:'),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(String levelName, Color buttonColor, String highScoreText) {
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
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                  highScoreText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
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
  void dispose()async {
    await gyroData.endSession();
    if (_isMoving) {
      gyroData.endSession();
    }
    _controller.dispose();
    if (isGameStarted) {
      _sensorSubscription.cancel();
      _timer.cancel();
    }
    if (_isMoving) {
      gyroData.endSession();
    }
    super.dispose();
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
                color: isGameOver || isGameWon ? Colors.transparent : Colors.pinkAccent,
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
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Score: $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
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