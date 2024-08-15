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

class _GameScreenState extends State<GameScreen> {
  final List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 10;
  Timer? _timer;
  final List<Map<String, dynamic>> _biometricData = [];

  double? _initialX;
  double? _initialY;
  late int _startTime;

  final FirebaseService _firebaseService = FirebaseService();  // Instantiate the FirebaseService
  final DataCollectionService _dataCollectionService = DataCollectionService();  // Instantiate the DataCollectionService

  @override
  void initState() {
    super.initState();
    _loadQuestionsForLevel(widget.level);
    _startTimer();
  }

  void _loadQuestionsForLevel(int level) {
    // Your question loading logic here...
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
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
        _startTimer();
      });
    } else {
      _stopTimer();
      _firebaseService.storeBiometricData(widget.level, _score, _biometricData);  // Store data at the end of the game
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
    // Your game over dialog code here...
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Time left: $_timeLeft',
            style: const TextStyle(fontSize: 24),
          ),
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
                      padding: const EdgeInsets.fromLTRB(50, 0, 50, 100),
                      child: Image.asset(_questions[_currentQuestionIndex]['image']),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      questionText,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Score: $_score',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

