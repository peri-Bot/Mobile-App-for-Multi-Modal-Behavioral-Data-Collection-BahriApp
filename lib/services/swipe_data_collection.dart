import 'package:flutter/gestures.dart';
import 'dart:math';

class SwipeDataCollector {
  Offset? _initialPosition;
  double? _initialPressure;
  DateTime? _startTime;

  void startCollecting(DragStartDetails details) {
    _initialPosition = details.globalPosition;
    _startTime = DateTime.now();
  }

  void updateCollecting(DragUpdateDetails details) {
    // lets leave this for now yes yes yes yes yes yes
  }

  void endCollecting(DragEndDetails details, Function(Map<String, dynamic>) onComplete) {
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!).inMilliseconds / 1000.0;

    final data = {
      'initialX': _initialPosition!.dx,
      'initialY': _initialPosition!.dy,
      'endX': details.velocity.pixelsPerSecond.dx,
      'endY': details.velocity.pixelsPerSecond.dy,
      'initialPressure': _initialPressure ?? 0.5,
      'duration': duration,
      'distance': sqrt(pow(details.velocity.pixelsPerSecond.dx - _initialPosition!.dx, 2) +
          pow(details.velocity.pixelsPerSecond.dy - _initialPosition!.dy, 2)),
      'speed': details.velocity.pixelsPerSecond.distance / duration,
    };

    onComplete(data);
  }
}



class DataCollectionService {
  double calculateSwipePathStraightness(double initialX, double initialY, double endX, double endY) {
    double straightDistance = sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
    double actualDistance = (endX - initialX).abs() + (endY - initialY).abs();
    return straightDistance / actualDistance;
  }

  double calculateSwipeAngle(double initialX, double initialY, double endX, double endY) {
    return atan2(endY - initialY, endX - initialX) * (180 / pi);
  }

  double calculateSwipeSpeed(double distance, double duration) {
    return distance / duration;
  }

  double calculateSwipeAcceleration(double speed, double duration) {
    return speed / duration;
  }

  double calculateSwipeJerk(double acceleration, double duration) {
    return acceleration / duration;
  }

  double calculateSwipeDistance(double initialX, double initialY, double endX, double endY) {
    return sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
  }

  double calculateSwipeDuration(int startTime, int endTime) {
    return (endTime - startTime) / 1000.0; // convert milliseconds to seconds
  }
}