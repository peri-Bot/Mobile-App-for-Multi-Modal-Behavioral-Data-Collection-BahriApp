import 'dart:async';
import 'package:flutter/material.dart';
import '../../../services/stepgame_logic.dart';


class StepCounterGamePage extends StatefulWidget {
  const StepCounterGamePage({super.key});

  @override
  _StepCounterGamePageState createState() => _StepCounterGamePageState();
}

class _StepCounterGamePageState extends State<StepCounterGamePage> {
  final StepCounter _stepCounter = StepCounter();
  bool _isSensorAvailable = false;
  int _stepCount = 0;
  bool _isWalking = false;
  Timer? _timer;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() async {
    bool sensorAvailable = await _stepCounter.initSensor(
      onStepDetected: () {
        setState(() {
          _stepCount++;
        });
      },
    );
    setState(() {
      _isSensorAvailable = sensorAvailable;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _showCompletionDialog() {
    String resultMessage;
    int score;

    if (_stepCount < 10) {
      resultMessage = "You have taken less than 10 steps.boo!";
      score = 5;
    } else if (_stepCount < 20) {
      resultMessage = "You have taken more than 10 steps.keep moving";
      score = 10;
    } else if (_stepCount < 30) {
      resultMessage = "You have taken more than 20 steps.more data more score";
      score = 15;
    } else {
      resultMessage = "You have taken more than 30 steps.";
      score = 20;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('$resultMessage\nYour score is $score points.\nTime Elapsed: $_elapsedSeconds seconds'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _stepCount = 0;
      _elapsedSeconds = 0;
      _isWalking = false;
    });
    _stopTimer();
    _stepCounter.reset();
  }

  void _startWalking() {
    setState(() {
      _isWalking = true;
    });
    _startTimer();
  }

  void _stopWalking() {
    _stopTimer();
    _showCompletionDialog();
  }

  @override
  void dispose() {
    _stepCounter.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step Counter Game'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.teal],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Time Elapsed: $_elapsedSeconds seconds',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Walk while holding your phone, press stop when you are done walking.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            if (!_isSensorAvailable)
              const Text(
                'Accelerometer not available on this device.',
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 20),
            if (_isWalking)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _stopWalking,
                child: const Text('Stop Walking'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.teal,
                ),
                onPressed: _startWalking,
                child: const Text('Start Walking'),
              ),
          ],
        ),
      ),
    );
  }
}
