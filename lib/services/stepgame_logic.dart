import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepCounter {
  // Fields for step counting and accelerometer data
  StreamSubscription<SensorEvent>? _subscription;
  double _lastMagnitude = 0;
  final double _stepThreshold = 0.5;
  final double _lowPassFilterFactor = 0.3;
  bool _isMovingUp = false;
  bool _isDataCollectionEnabled = false;
  final List<double> _accelerationData = [];
  double _peakAcceleration = 0;
  double _minAcceleration = double.infinity;

  // New fields
  DateTime? _lastStepTime;
  List<double> _verticalOscillationData = [];
  List<double> _stepDurations = [];
  int _totalSteps = 0;

  // Firestore session-based fields
  String? _sessionId;

  // Initialize the sensor
  Future<bool> initSensor({required Function onStepDetected}) async {
    bool sensorAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);

    if (sensorAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 100),
      );

      _subscription = stream.listen((SensorEvent event) {
        if (_isDataCollectionEnabled) {
          _processAccelerometerData(event.data, onStepDetected);
        }
      });

      _sessionId = DateTime.now().millisecondsSinceEpoch.toString(); // Initialize session ID
    }
    return sensorAvailable;
  }

  // Apply low-pass filter to smooth out data
  double _applyLowPassFilter(double newValue, double lastValue) {
    return lastValue + _lowPassFilterFactor * (newValue - lastValue);
  }

  // Process the accelerometer data and detect steps
  void _processAccelerometerData(List<double> data, Function onStepDetected) {
    double x = data[0], y = data[1], z = data[2];
    double magnitude = sqrt(x * x + y * y + z * z);

    magnitude = _applyLowPassFilter(magnitude, _lastMagnitude);

    _accelerationData.add(magnitude);
    _peakAcceleration = max(_peakAcceleration, magnitude);
    _minAcceleration = min(_minAcceleration, magnitude);

    // Collect vertical oscillation data (Z-axis for vertical movement)
    _verticalOscillationData.add(z);

    if (_lastMagnitude != 0) {
      double delta = magnitude - _lastMagnitude;
      if (!_isMovingUp && delta > _stepThreshold) {
        _isMovingUp = true;
      } else if (_isMovingUp && delta < -_stepThreshold) {
        _isMovingUp = false;
        _totalSteps++; // Increment step count
        onStepDetected();
        _storeDataInFirestore();
        _logStepDuration(); // Calculate and log step duration
      }
    }

    _lastMagnitude = magnitude;
  }
  void startDataCollection() {
    _isDataCollectionEnabled = true;
  }

  void stopDataCollection() {
    _isDataCollectionEnabled = false;
  }
  // Calculate and store metrics in Firestore using session-based approach

  Future<int> _getNextSessionId() async {
    DocumentReference counterRef = FirebaseFirestore.instance.collection('counters').doc('sessionCounter');
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        counterRef.set({'count': 1});
        return 1;
      }

      int newCount = snapshot['count'] + 1;
      transaction.update(counterRef, {'count': newCount});
      return newCount;
    });
  }
  void _storeDataInFirestore() async {
    _sessionId ??= (await _getNextSessionId()) as String?;

    try {
      await FirebaseFirestore.instance.collection('users').doc('1').set({
        'stepData': {
          _sessionId.toString(): {
            'timestamp': FieldValue.serverTimestamp(),
            'averageAcceleration': getAverageAcceleration(),
            'peakAcceleration': _peakAcceleration,
            'minAcceleration': _minAcceleration,
            'standardDeviation': getStandardDeviation(),
            'verticalOscillation': getVerticalOscillation(),
            'jerk': getJerk(_lastMagnitude),
            'stepDuration': _stepDurations.isNotEmpty ? '${_stepDurations.last} ms' : '0 ms',
            'averageStepDuration': '${getAverageStepDuration()} ms',
            'stepFrequency': getStepFrequency(),
            'totalSteps': _totalSteps,
          }
        }
      }, SetOptions(merge: true));
      print("Data stored successfully in Firestore");
    } catch (e) {
      print("Error storing data: $e");
    }
  }

  void updateSessionEndTime() async {
    if (_sessionId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc('1').set({
        'stepData': {
          _sessionId.toString(): {
            'endTime': FieldValue.serverTimestamp(),
            'sessionDuration': '${DateTime.now().difference(_lastStepTime!).inMilliseconds} ms',
          }
        }
      }, SetOptions(merge: true));
      print("Session end time updated successfully");
    } catch (e) {
      print("Failed to update session end time: $e");
    }
  }

  // Detect and return vertical oscillation (average vertical movement)
  double getVerticalOscillation() {
    if (_verticalOscillationData.isEmpty) return 0;
    return _verticalOscillationData.reduce((a, b) => a + b) / _verticalOscillationData.length;
  }

  // Calculate jerk (rate of change of acceleration)
  double getJerk(double magnitude) {
    if (_accelerationData.isEmpty) return 0;
    double lastAcceleration = _accelerationData.last;
    double deltaTime = 0.1; // Sampling every 100ms
    return (magnitude - lastAcceleration) / deltaTime;
  }

  // Calculate and return the average acceleration
  double getAverageAcceleration() {
    return _accelerationData.reduce((a, b) => a + b) / _accelerationData.length;
  }

  // Calculate and return the standard deviation of acceleration
  double getStandardDeviation() {
    double mean = getAverageAcceleration();
    num sumSquaredDiffs = _accelerationData.map((value) => pow(value - mean, 2)).reduce((a, b) => a + b);
    return sqrt(sumSquaredDiffs / _accelerationData.length);
  }

  // Log step duration and store it in list
  void _logStepDuration() {
    if (_lastStepTime != null) {
      DateTime now = DateTime.now();
      double stepDuration = now.difference(_lastStepTime!).inMilliseconds.toDouble();
      _stepDurations.add(stepDuration);
      print("Step duration: $stepDuration ms");
    }
    _lastStepTime = DateTime.now();
  }

  // Calculate the average step duration
  double getAverageStepDuration() {
    if (_stepDurations.isEmpty) return 0;
    return _stepDurations.reduce((a, b) => a + b) / _stepDurations.length;
  }

  // Calculate the step frequency (steps per minute)
  double getStepFrequency() {
    if (_stepDurations.isEmpty) return 0;
    double totalTime = _stepDurations.reduce((a, b) => a + b) / 1000; // Convert to seconds
    return _totalSteps / (totalTime / 60); // Steps per minute
  }

  // Reset the counters and data
  void reset() {
    _lastMagnitude = 0;
    _isMovingUp = false;
    _accelerationData.clear();
    _peakAcceleration = 0;
    _minAcceleration = double.infinity;
    _lastStepTime = null;
    _verticalOscillationData.clear();
    _stepDurations.clear();
    _totalSteps = 0;
    _sessionId = null;
  }

  // Cancel the sensor subscription
  void dispose() {
    _subscription?.cancel();
  }
}
