import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/slide_game_services.dart';


class GameScreen extends StatefulWidget {
  final int level;
  final Function(int score) onLevelComplete;

  const GameScreen({super.key, required this.level, required this.onLevelComplete});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 10;
  Timer? _timer;
  final List<Map<String, dynamic>> _biometricData = [];

  late AnimationController _animationController;
  double? _initialX;
  double? _initialY;
  late int _startTime;

  final FirebaseService _firebaseService = FirebaseService();
  final DataCollectionService _dataCollectionService = DataCollectionService();

  @override
  void initState() {
    super.initState();
    _loadQuestionsForLevel(widget.level);
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeLeft),
    );
    _animationController.forward();
  }

  void _loadQuestionsForLevel(int level) {
    if (level == 1) {
      _questions = [
        {'image': 'assets/slide_game/dog.jpg', 'questionType': 'mammal', 'answer': true},
        {'image': 'assets/slide_game/fox.jpg', 'questionType': 'mammal', 'answer': false},
        {'image': 'assets/slide_game/mole.jpg', 'questionType': 'mammal', 'answer': true},
      ];
    } else if (level == 2) {
      _questions = [
        {'image': 'assets/meerkat.jpg', 'questionType': 'flag', 'answer': true},
        {'image': 'assets/brazil.png', 'questionType': 'flag', 'answer': false},
        {'image': 'assets/kenya.png', 'questionType': 'flag', 'answer': true},
      ];
    } else if (level == 3) {
      _questions = [
        {'image': 'assets/apple.jpg', 'questionType': 'fruit', 'answer': true},
        {'image': 'assets/carrot.jpg', 'questionType': 'fruit', 'answer': false},
        {'image': 'assets/banana.jpg', 'questionType': 'fruit', 'answer': true},
      ];
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          _animationController.value = _timeLeft / 10.0;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _nextQuestion() {
    _stopTimer();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _timeLeft = 10;
        _animationController.value = 1.0;
        _animationController.duration = Duration(seconds: _timeLeft);
        _startTimer();
      });
    } else {
      _stopTimer();
      _firebaseService.storeBiometricData(widget.level, _score, _biometricData); // Store data at the end of the game
      widget.onLevelComplete(_score); // Notify Level Complete
      _showGameOverDialog();
    }
  }

  void _checkAnswer(bool answer) {
    if (answer == _questions[_currentQuestionIndex]['answer']) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score is $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to level selection
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white, backgroundColor: Colors.black,
              minimumSize: const Size(100, 40),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String questionText = '';
    if (_questions[_currentQuestionIndex]['questionType'] == 'mammal') {
      questionText = 'Is this animal a mammal?';
    } else if (_questions[_currentQuestionIndex]['questionType'] == 'flag') {
      questionText = 'Is this flag from Africa?';
    } else if (_questions[_currentQuestionIndex]['questionType'] == 'fruit') {
      questionText = 'Is this a fruit?';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.lightBlue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 5),
                SizedBox(
                  width: 200,
                  height: 20,
                  child: LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.blue[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onPanStart: (details) {
                  _initialX = details.localPosition.dx;
                  _initialY = details.localPosition.dy;
                  _startTime = DateTime.now().millisecondsSinceEpoch;
                },
                onPanEnd: (details) {
                  int endTime = DateTime.now().millisecondsSinceEpoch;
                  double endX = details.velocity.pixelsPerSecond.dx;
                  double endY = details.velocity.pixelsPerSecond.dy;
                  double distance = _dataCollectionService.calculateSwipeDistance(_initialX!, _initialY!, endX, endY);
                  double duration = _dataCollectionService.calculateSwipeDuration(_startTime, endTime);
                  double speed = _dataCollectionService.calculateSwipeSpeed(distance, duration);
                  double straightness = _dataCollectionService.calculateSwipePathStraightness(_initialX!, _initialY!, endX, endY);
                  double angle = _dataCollectionService.calculateSwipeAngle(_initialX!, _initialY!, endX, endY);
                  double acceleration = _dataCollectionService.calculateSwipeAcceleration(speed, duration);
                  double jerk = _dataCollectionService.calculateSwipeJerk(acceleration, duration);

                  // Create a map with all the collected data
                  Map<String, dynamic> swipeData = {
                    'initialX': _initialX,
                    'initialY': _initialY,
                    'endX': endX,
                    'endY': endY,
                    'duration': duration,
                    'distance': distance,
                    'speed': speed,
                    'straightness': straightness,
                    'angle': angle,
                    'acceleration': acceleration,
                    'jerk': jerk,
                  };

                  // Add the data point to the list
                  _biometricData.add(swipeData);

                  _checkAnswer(details.velocity.pixelsPerSecond.dx > 0); // Swiped right (True) or left (False)
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2), // Reduced the border width
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(_questions[_currentQuestionIndex]['image']),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        questionText,
                        style: const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.swipe, size: 40, color: Colors.white),
                      const Text(
                        "Swipe Left or Right",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
