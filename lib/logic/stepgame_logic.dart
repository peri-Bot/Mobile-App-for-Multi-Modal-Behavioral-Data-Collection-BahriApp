import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StepCounter {
  StreamSubscription<SensorEvent>? _subscription;
  double _lastMagnitude = 0;
  final double _stepThreshold = 0.5;
  final double _lowPassFilterFactor = 0.3;
  bool _isMovingUp = false;
  final List<double> _accelerationData = [];
  double _peakAcceleration = 0;
  double _minAcceleration = double.infinity;

  Future<bool> initSensor({required Function onStepDetected}) async {
    bool sensorAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);

    if (sensorAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 100),
      );

      _subscription = stream.listen((SensorEvent event) {
        _processAccelerometerData(event.data, onStepDetected);
      });
    }
    return sensorAvailable;
  }

  double _applyLowPassFilter(double newValue, double lastValue) {
    return lastValue + _lowPassFilterFactor * (newValue - lastValue);
  }

  void _processAccelerometerData(List<double> data, Function onStepDetected) {
    double x = data[0], y = data[1], z = data[2];
    double magnitude = sqrt(x * x + y * y + z * z);

    magnitude = _applyLowPassFilter(magnitude, _lastMagnitude);

    _accelerationData.add(magnitude);
    _peakAcceleration = max(_peakAcceleration, magnitude);
    _minAcceleration = min(_minAcceleration, magnitude);

    if (_lastMagnitude != 0) {
      double delta = magnitude - _lastMagnitude;
      if (!_isMovingUp && delta > _stepThreshold) {
        _isMovingUp = true;
      } else if (_isMovingUp && delta < -_stepThreshold) {
        _isMovingUp = false;
        onStepDetected();
        _storeDataInFirestore();
      }
    }

    _lastMagnitude = magnitude;
  }

  void _storeDataInFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc('1').collection('accelerometerData').add({
        'timestamp': FieldValue.serverTimestamp(),
        'averageAcceleration': getAverageAcceleration(),
        'peakAcceleration': _peakAcceleration,
        'minAcceleration': _minAcceleration,
        'standardDeviation': getStandardDeviation(),
      });
      print("Data stored successfully");
    } catch (e) {
      print("Error storing data: $e");
    }
  }

  double getAverageAcceleration() {
    return _accelerationData.reduce((a, b) => a + b) / _accelerationData.length;
  }

  double getStandardDeviation() {
    double mean = getAverageAcceleration();
    num sumSquaredDiffs = _accelerationData.map((value) => pow(value - mean, 2)).reduce((a, b) => a + b);
    return sqrt(sumSquaredDiffs / _accelerationData.length);
  }

  void reset() {
    _lastMagnitude = 0;
    _isMovingUp = false;
    _accelerationData.clear();
    _peakAcceleration = 0;
    _minAcceleration = double.infinity;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
