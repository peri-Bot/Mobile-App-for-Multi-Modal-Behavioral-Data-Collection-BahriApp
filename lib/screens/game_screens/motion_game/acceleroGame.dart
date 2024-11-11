import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/accelerometerGame_service.dart';
import 'package:flutter/services.dart'; // For vibration feedback

class AccelerometerGames extends StatefulWidget {
  const AccelerometerGames({super.key});

  @override
  MotionSensorGamePageState createState() => MotionSensorGamePageState();
}

class MotionSensorGamePageState extends State<AccelerometerGames> {
  final StepCounter _stepCounter = StepCounter();
  bool _isSensorAvailable = false;
  int _stepCount = 0;
  bool _isWalking = false;
  bool _isPaused = false;
  bool _isJogging = false;
  bool _isSitting = false;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isActive = false;
  String _currentActivity = '';
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

    _initGame();
  }

  void _initGame() async {}

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
      _stepCounter.stopDataCollection();
    });
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
      _stepCounter.startDataCollection();
    });
  }

  void _showCompletionDialog() {
    String resultMessage;
    int score;

    if (_currentActivity == 'walking') {
      if (_stepCount < 10) {
        resultMessage = "You have taken less than 10 steps while walking. Boo!";
        score = 5;
      } else if (_stepCount < 20) {
        resultMessage =
            "You have taken more than 10 steps while walking. Keep moving!";
        score = 10;
      } else if (_stepCount < 30) {
        resultMessage =
            "You have taken more than 20 steps while walking. More data, more score!";
        score = 15;
      } else {
        resultMessage = "You have taken more than 30 steps while walking!";
        score = 20;
      }
    } else if (_currentActivity == 'jogging') {
      if (_elapsedSeconds < 30) {
        resultMessage = "You jogged for $_elapsedSeconds seconds. Keep going!";
        score = 10;
      } else if (_elapsedSeconds < 60) {
        resultMessage = "You jogged for $_elapsedSeconds seconds. Good job!";
        score = 15;
      } else if (_elapsedSeconds < 90) {
        resultMessage =
            "You jogged for $_elapsedSeconds seconds. You're a pro!";
        score = 20;
      } else {
        resultMessage =
            "You jogged for $_elapsedSeconds seconds. Wow, you're a marathon runner!";
        score = 25;
      }
    } else if (_currentActivity == 'sitting') {
      double sittingStability =
          _stepCount / (_elapsedSeconds > 0 ? _elapsedSeconds : 1);
      if (sittingStability < 0.5) {
        resultMessage =
            "You sat still for $_elapsedSeconds seconds with a stability score of ${sittingStability.toStringAsFixed(2)}. Good job!";
        score = 10;
      } else if (sittingStability < 1) {
        resultMessage =
            "You sat still for $_elapsedSeconds seconds with a stability score of ${sittingStability.toStringAsFixed(2)}. Not bad!";
        score = 5;
      } else {
        resultMessage =
            "You sat still for $_elapsedSeconds seconds with a stability score of ${sittingStability.toStringAsFixed(2)}. Try harder next time!";
        score = 2;
      }
    } else {
      resultMessage = "No activity recorded.";
      score = 0;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('$resultMessage\nYour score is $score points.'),
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
      _isJogging = false;
      _isSitting = false;
      _isPaused = false;
    });
    _stopTimer();
    _stepCounter.reset();
    _initGame();
  }

  void _initSensor() async {
    bool sensorAvailable = await _stepCounter.initSensor(
      onStepDetected: () {
        setState(() {
          _stepCount++;
        });
        HapticFeedback.vibrate(); // Vibration feedback for each step
      },
      currentActivity: _currentActivity, // Pass the current activity
    );
    setState(() {
      _isSensorAvailable = sensorAvailable;
    });
  }

  void _startWalking() {
    setState(() {
      _isActive = true;
      _currentActivity = 'walking';
      _isWalking = true;
      _isJogging = false;
      _isSitting = false;
      _isPaused = false;
    });
    _stepCounter.userId = uid;
    _initSensor();
    _stepCounter.startDataCollection();
    _startTimer();
  }

  void _startJogging() {
    setState(() {
      _isActive = true;
      _currentActivity = 'jogging';
      _isWalking = false;
      _isJogging = true;
      _isSitting = false;
      _isPaused = false;
    });
    _stepCounter.userId = uid;
    _initSensor();
    _stepCounter.startDataCollection();
    _startTimer();
  }

  void _startSitting() {
    setState(() {
      _isActive = true;
      _currentActivity = 'sitting';
      _isWalking = false;
      _isJogging = false;
      _isSitting = true;
      _isPaused = false;
    });
    _stepCounter.userId = uid;
    _initSensor();
    _stepCounter.startDataCollection();
    _startTimer();
  }

  void _stopActivity() {
    _stepCounter.stopDataCollection();
    _stopTimer();
    _showCompletionDialog();
    setState(() {
      _isActive = false;
      _currentActivity = '';
      _isWalking = false;
      _isJogging = false;
      _isSitting = false;
      _isPaused = false;
    });
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
        title: const Text('Accelerometer Game'),
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
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'choose an activity to do; Walk, jog, or sit while holding your phone, '
                'press stop when you are done.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            const Text(
              "Choose an Activity",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 25),
            const SizedBox(
              height: 20,
            ),
            // Walking button
            Visibility(
              visible: !_isWalking && !_isJogging && !_isSitting,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.teal,
                ),
                onPressed: _startWalking,
                child: const Text('Start Walking'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Jogging button
            Visibility(
              visible: !_isWalking && !_isJogging && !_isSitting,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.teal,
                ),
                onPressed: _startJogging,
                child: const Text('Start Jogging'),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Sitting button
            Visibility(
              visible: !_isWalking && !_isJogging && !_isSitting,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.white70,
                  foregroundColor: Colors.teal,
                ),
                onPressed: _startSitting,
                child: const Text('Start Sitting'),
              ),
            ),

            const SizedBox(height: 20),

            // Stop button - visible only when an activity is active
            if (_isWalking || _isJogging || _isSitting)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _stopActivity,
                child: const Text('Stop Activity'),
              ),

            const SizedBox(height: 20),

            // Pause/Resume button
            if (_isWalking || _isJogging || _isSitting)
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
