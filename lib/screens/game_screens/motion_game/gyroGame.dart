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
  int score = 0;
  late Timer _timer;
  int currentLevel = 1;
  List<Rect> obstacles = [];
  String? uid;
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        posX = (MediaQuery.of(context).size.width - ballSize) / 2;
        posY = MediaQuery.of(context).size.height -
            ballSize -
            20; // Start above the bottom border
        _setLevel(currentLevel);
      });
    });
    _checkGyroscope();
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

          GyroData gyroData = GyroData();

          gyroData.calculateTiltAngle(gyroX, gyroY, gyroZ);
          gyroData.calculateTiltSpeed(gyroX, gyroY, DateTime.now());
          gyroData.calculateTiltStability(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationDirection(gyroX, DateTime.now());
          gyroData.calculateMicroAdjustments(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationPathStraightness(gyroX, gyroY, gyroZ);
          gyroData.calculateRotationDuration(gyroX, DateTime.now());
          gyroData.printMetrics();
          gyroData.storeDataInFirestore(gyroX, gyroY, gyroZ);

          setState(() {
            double horizontalSensitivity = 20.0;
            double verticalSensitivity = 30.0;

            posX += sensorEvent.data[1] * horizontalSensitivity;
            posY += sensorEvent.data[0] * verticalSensitivity;

            posX =
                posX.clamp(0.0, MediaQuery.of(context).size.width - ballSize);
            posY = posY.clamp(
                0.0,
                MediaQuery.of(context).size.height -
                    ballSize -
                    10); // Adjusted to stay above the bottom border

            if (_checkCollision()) {
              _gameOver();
            }
            if (_checkGoal()) {
              _gameWon();
            }
            print(
                'Gyroscope data: x=${sensorEvent.data[0]}, y=${sensorEvent.data[1]}, z=${sensorEvent.data[2]}');
            print('Ball position: posX=$posX, posY=$posY');
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

  void _gameOver() {
    setState(() {
      isGameOver = true;
      _sensorSubscription.cancel();
      _timer.cancel();
      score = 0; // Reset the score
      currentLevel = 1; // Restart from level 1
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[200],
          title: const Text('Game Over', style: TextStyle(color: Colors.white)),
          content: Text('Your score: $score',
              style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child:
                  const Text('Restart', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _gameWon() {
    setState(() {
      isGameWon = true;
      _sensorSubscription.cancel();
      _timer.cancel();
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.teal[200],
          title: const Text('You Win!', style: TextStyle(color: Colors.white)),
          content: Text('Your score: $score',
              style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _continueToNextLevel();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Next', style: TextStyle(color: Colors.white)),
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

  List<Rect> level1Obstacles = [
    const Rect.fromLTWH(50, 150, 200, 40),
    const Rect.fromLTWH(50, 240, 200, 40),
    const Rect.fromLTWH(50, 320, 200, 40),
    const Rect.fromLTWH(50, 400, 130, 40),
    const Rect.fromLTWH(220, 550, 150, 40),
    const Rect.fromLTWH(220, 650, 150, 40),
  ];
  List<Rect> level2Obstacles = [
    const Rect.fromLTWH(50, 150, 200, 30),
    const Rect.fromLTWH(50, 240, 200, 30),
    const Rect.fromLTWH(150, 500, 200, 30),
    const Rect.fromLTWH(150, 600, 200, 30),
  ];
  List<Rect> level3Obstacles = [
    const Rect.fromLTWH(50, 100, 100, 30),
    const Rect.fromLTWH(100, 200, 100, 30),
    const Rect.fromLTWH(50, 300, 100, 30),
    const Rect.fromLTWH(280, 400, 100, 30),
    const Rect.fromLTWH(180, 500, 100, 30),
    const Rect.fromLTWH(280, 600, 100, 30),
    const Rect.fromLTWH(50, 650, 100, 30),
  ];
  List<Rect> level4Obstacles = [
    const Rect.fromLTWH(50, 100, 100, 25),
    const Rect.fromLTWH(50, 200, 150, 25),
    const Rect.fromLTWH(50, 300, 200, 25),
    const Rect.fromLTWH(50, 400, 250, 25),
    const Rect.fromLTWH(50, 500, 200, 25),
    const Rect.fromLTWH(50, 600, 150, 25),
    const Rect.fromLTWH(50, 700, 100, 25),
  ];
  List<Rect> level5Obstacles = [
    const Rect.fromLTWH(50, 150, 100, 25),
    const Rect.fromLTWH(200, 250, 150, 25),
    const Rect.fromLTWH(50, 350, 100, 25),
    const Rect.fromLTWH(250, 500, 100, 25),
    const Rect.fromLTWH(50, 500, 100, 25),
    const Rect.fromLTWH(200, 680, 150, 25),
  ];

  void _setLevel(int level) {
    setState(() {
      switch (level) {
        case 1:
          obstacles = level1Obstacles;
          break;
        case 2:
          obstacles = level2Obstacles;
          break;
        case 3:
          obstacles = level3Obstacles;
          break;
        case 4:
          obstacles = level4Obstacles;
          break;
        case 5:
          obstacles = level5Obstacles;
          break;
        default:
          obstacles = level1Obstacles;
      }
    });
  }

  void _resetGame() {
    setState(() {
      posX = (MediaQuery.of(context).size.width - ballSize) / 2;
      posY = MediaQuery.of(context).size.height - ballSize - 20;
      isGameOver = false;
      isGameWon = false;
    });
    _initializeSensors();
    _startScoreTimer();
  }

  void _continueToNextLevel() {
    setState(() {
      score += 5;
      posX = (MediaQuery.of(context).size.width - ballSize) / 2;
      posY = MediaQuery.of(context).size.height - ballSize - 20;
      isGameWon = false;
      score = 0;
      currentLevel = (currentLevel % 5) + 1; // Move to the next level
    });
    _setLevel(currentLevel);
    _initializeSensors();
    _startScoreTimer();
  }

  void _checkGyroscope() async {
    bool sensorAvailable =
        await SensorManager().isSensorAvailable(Sensors.GYROSCOPE);
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

  @override
  void dispose() {
    _sensorSubscription.cancel();
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[40],
      body: Stack(
        children: [
          // Border
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 20),
            ),
          ),
          // Ball
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
          // Obstacles
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
          // Goal area
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          if (isGameWon)
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _continueToNextLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('Continue to Next Level'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
