import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';

class StepCounter {
  StreamSubscription<SensorEvent>? _subscription;
  double _lastMagnitude = 0;
  final double _stepThreshold = 0.5;
  final double _lowPassFilterFactor = 0.3;
  bool _isMovingUp = false;

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

    if (_lastMagnitude != 0) {
      double delta = magnitude - _lastMagnitude;
      if (!_isMovingUp && delta > _stepThreshold) {
        _isMovingUp = true;
      } else if (_isMovingUp && delta < -_stepThreshold) {
        _isMovingUp = false;
        onStepDetected();
      }
    }

    _lastMagnitude = magnitude;
  }

  void reset() {
    _lastMagnitude = 0;
    _isMovingUp = false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
