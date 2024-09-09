import 'dart:async';
import 'dart:math';
import 'package:flutter_sensors/flutter_sensors.dart';

class MotionDataCollector {
  StreamSubscription<SensorEvent>? _subscription;
  double _totalMagnitude = 0;
  double _maxAcceleration = 0;
  int _movementEpisodes = 0;
  int _totalMovementTime = 0;
  bool _isMoving = false;
  final double _movementThreshold = 0.5;

  Future<bool> initSensor({required Function onDataCollected}) async {
    bool sensorAvailable = await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);

    if (sensorAvailable) {
      final stream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 100),
      );

      _subscription = stream.listen((SensorEvent event) {
        _processAccelerometerData(event.data, onDataCollected);
      });
    }
    return sensorAvailable;
  }

  void _processAccelerometerData(List<double> data, Function onDataCollected) {
    double x = data[0], y = data[1], z = data[2];
    double magnitude = sqrt(x * x + y * y + z * z);


    _totalMagnitude += magnitude;

    if (magnitude > _maxAcceleration) {
      _maxAcceleration = magnitude;
    }

    if (magnitude > _movementThreshold) {
      if (!_isMoving) {
        _movementEpisodes++;
        _isMoving = true;
      }
      _totalMovementTime += 100;
    } else {
      _isMoving = false;
    }
    onDataCollected();
  }

  double getAverageMovementIntensity(int elapsedTime) {
    return _totalMagnitude / elapsedTime;
  }

  double getMaxAcceleration() {
    return _maxAcceleration;
  }

  int getMovementEpisodes() {
    return _movementEpisodes;
  }

  int getTotalMovementTime() {
    return _totalMovementTime;
  }

  void reset() {
    _totalMagnitude = 0;
    _maxAcceleration = 0;
    _movementEpisodes = 0;
    _totalMovementTime = 0;
    _isMoving = false;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
