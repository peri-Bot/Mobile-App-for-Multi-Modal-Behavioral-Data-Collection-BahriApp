import 'dart:async';
import 'package:flutter/material.dart';
import '../../../logic/stepgame_logic.dart';
import 'package:flutter/services.dart'; // For vibration feedback

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
  bool _isPaused = false;
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
        HapticFeedback.vibrate();  // Vibration feedback for each step
      },
    );
    setState(() {
      _isSensorAvailable = sensorAvailable;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
  }

  void _showCompletionDialog() {
    String resultMessage;
    int score;

    if (_stepCount < 10) {
      resultMessage = "You have taken less than 10 steps. Boo!";
      score = 5;
    } else if (_stepCount < 20) {
      resultMessage = "You have taken more than 10 steps. Keep moving!";
      score = 10;
    } else if (_stepCount < 30) {
      resultMessage = "You have taken more than 20 steps. More data, more score!";
      score = 15;
    } else {
      resultMessage = "You have taken more than 30 steps!";
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
      _isPaused = false;
    });
    _stopTimer();
    _stepCounter.reset();
  }

  void _startWalking() {
    setState(() {
      _isWalking = true;
      _isPaused = false;
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Step Counter Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
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
            const SizedBox(height: 80),
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
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.teal,
                ),
                onPressed: _startWalking,
                child: const Text('Start Walking'),
              ),
            const SizedBox(height: 20),
            if (_isWalking)
              ElevatedButton(
                onPressed: _isPaused ? _resumeGame : _pauseGame,
                child: Text(_isPaused ? 'Resume' : 'Pause'),
              ),
          ],
        ),
      ),
    );
  }
}
