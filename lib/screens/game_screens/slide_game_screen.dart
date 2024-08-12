import 'package:flutter/material.dart';
import 'dart:async';

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
  late AnimationController _animationController;

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
        {'image': 'assets/slide_game/fox.jpg', 'questionType': 'mammal', 'answer': true},
        {'image': 'assets/slide_game/mole.jpg', 'questionType': 'mammal', 'answer': true},
      ];
    } else if (level == 2) {
      _questions = [
        {'image': 'assets/slide_game/meerkat.jpg', 'questionType': 'flag', 'answer': true},
        {'image': 'assets/slide_game/brazil.png', 'questionType': 'flag', 'answer': true},
        {'image': 'assets/slide_game/kenya.png', 'questionType': 'flag', 'answer': true},
      ];
    } else if (level == 3) {
      _questions = [
        {'image': 'assets/apple.jpg', 'questionType': 'fruit', 'answer': true},
        {'image': 'assets/carrot.jpg', 'questionType': 'fruit', 'answer': true},
        {'image': 'assets/banana.jpg', 'questionType': 'fruit', 'answer': true},
      ];
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
        _animationController.value = (_timeLeft / 10);
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
        _animationController.reset();
        _animationController.forward();
        _startTimer();
      });
    } else {
      _stopTimer();
      widget.onLevelComplete(_score);
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
        content: Text('SCORE : $_score',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold

          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'GO BACk',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
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
        backgroundColor: Colors.black12,
        elevation: 0,

      ),
      body: Container(
        color: Colors.brown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer Row with Icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.purple, size: 30),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _animationController.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.purple),
                      minHeight: 15,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Image Container with Padding
            Expanded(
              child: GestureDetector(
                onPanEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 0) {
                    _checkAnswer(true); // Swiped right (True)
                  } else {
                    _checkAnswer(false); // Swiped left (False)
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blueAccent, width: 4),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
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
            // Slide Indicator
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 30, color: Colors.grey),
                Text('Swipe', style: TextStyle(fontSize: 20, color: Colors.grey)),
                Icon(Icons.arrow_forward, size: 30, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 20),
            // Decorated Score Text
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
