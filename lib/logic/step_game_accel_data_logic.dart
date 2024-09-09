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

    // Update total magnitude for overall activity level
    _totalMagnitude += magnitude;

    // Check for max acceleration
    if (magnitude > _maxAcceleration) {
      _maxAcceleration = magnitude;
    }

    // Detect movement episodes
    if (magnitude > _movementThreshold) {
      if (!_isMoving) {
        _movementEpisodes++;
        _isMoving = true;
      }
      _totalMovementTime += 100; // Time in milliseconds
    } else {
      _isMoving = false;
    }

    // Call the callback to notify about data update
    onDataCollected();
  }

  // Method to get total movement intensity (average magnitude)
  double getAverageMovementIntensity(int elapsedTime) {
    return _totalMagnitude / elapsedTime;
  }

  // Method to get the max acceleration detected during the session
  double getMaxAcceleration() {
    return _maxAcceleration;
  }

  // Method to get the number of distinct movement episodes
  int getMovementEpisodes() {
    return _movementEpisodes;
  }

  // Method to get the total active movement time
  int getTotalMovementTime() {
    return _totalMovementTime; // in milliseconds
  }

  // Reset the data collector for a new session
  void reset() {
    _totalMagnitude = 0;
    _maxAcceleration = 0;
    _movementEpisodes = 0;
    _totalMovementTime = 0;
    _isMoving = false;
  }

  // Dispose the subscription when no longer needed
  void dispose() {
    _subscription?.cancel();
  }
}
