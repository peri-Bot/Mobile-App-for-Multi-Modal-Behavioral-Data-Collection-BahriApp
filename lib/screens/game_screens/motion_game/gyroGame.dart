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

          // Use the class-level GyroData instance
          gyroData.calculateTiltAngle(gyroX, gyroY, gyroZ);
          gyroData.calculateTiltSpeed(gyroX, gyroY, DateTime.now());
          gyroData.calculateTiltStability(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationDirection(gyroX, DateTime.now());
          gyroData.calculateMicroAdjustments(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationPathStraightness(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationDuration(gyroX, DateTime.now());
          gyroData.storeGyroDataDartFrog(uid!, gyroX, gyroY, gyroZ);

          setState(() {
            double horizontalSensitivity = 20.0;
            double verticalSensitivity = 30.0;

            posX += sensorEvent.data[1] * horizontalSensitivity;
            posY += sensorEvent.data[0] * verticalSensitivity;

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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue[200]!, Colors.blue[400]!],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Difficulty',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black26,
                    offset: Offset(5.0, 5.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ...['Easy', 'Medium', 'Hard'].map((difficulty) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: difficulty == 'Easy'
                      ? Colors.green
                      : difficulty == 'Medium'
                      ? Colors.orange
                      : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  minimumSize: const Size(200, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                onPressed: () => startGame(difficulty),
                child: Text(
                  difficulty,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose()async {
    await gyroData.endSession();
    _controller.dispose();
    if (isGameStarted) {
      _sensorSubscription.cancel();
      _timer.cancel();
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