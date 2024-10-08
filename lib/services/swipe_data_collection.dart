import 'package:flutter/gestures.dart';
import 'dart:math';

import 'package:flutter/material.dart';

class SwipeDataCollector {
  Offset? _initialPosition;
  double? _initialPressure;
  DateTime? _startTime;
  DateTime? _endTime;

  void startCollecting(DragStartDetails details) {
    _initialPosition = details.globalPosition;
    _startTime = DateTime.now();
    _endTime = null;
  }

  void updateCollecting(DragUpdateDetails details) {
    // lets leave this for now yes yes yes yes yes yes
  }

  void endCollecting(DragEndDetails details, Function(Map<String, dynamic>) onComplete) {
    _endTime = DateTime.now();
    final duration = _endTime!.difference(_startTime!).inMilliseconds / 1000.0;

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
  // Method to calculate the screen diagonal length
  double getScreenDiagonal(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return sqrt(size.width * size.width + size.height * size.height);
  }

  // Method to calculate screen area
  double getScreenArea(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return size.width * size.height;
  }
  //non normalized metrics yes!
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


  double calculateSwipeDeceleration(double speed, double duration) {
  // Assuming the swipe starts at max speed and decelerates to 0
  return speed / duration; // Simplified deceleration calculation
  }

  double calculateSwipeAreaCoverage(double startX, double startY, double endX, double endY, double screenArea) {
  double swipeWidth = (endX - startX).abs();
  double swipeHeight = (endY - startY).abs();
  double swipeArea = swipeWidth * swipeHeight;
  return swipeArea / screenArea;
  }

  double calculateSwipeFingerOrientation(double initialX, double initialY, double endX, double endY) {
  return atan2(endY - initialY, endX - initialX) * (180 / pi);
  }

  double calculateSwipeFingerMovementVariability(double initialX, double initialY, double endX, double endY) {
  // This is a simplified version that assumes variability is the difference between straight and actual path lengths
  double straightDistance = sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
  double actualDistance = (endX - initialX).abs() + (endY - initialY).abs();
  return (actualDistance - straightDistance).abs();
  }

  double calculateTimeOfDayImpact() {
  DateTime now = DateTime.now();
  // Assume some variation based on time; this is highly simplified
  return now.hour + (now.minute / 60.0);
  }
  // Screen-normalized metrics yes!

  double calculateSNSL(double swipeLength, BuildContext context) {
    return swipeLength / getScreenDiagonal(context);
  }

  double calculateSNSS(double swipeSpeed, BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return swipeSpeed / (size.width * size.height);
  }

  double calculateSNSA(double swipeAngle, BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return swipeAngle * (size.height / size.width);
  }

  double calculateSNSD(double swipeDuration, double screenResponseTime) {
    return swipeDuration / screenResponseTime;
  }
   //will do something about pressure later on
  /*double calculateSNSP(double swipePressure, double screenSensitivity) {
    return swipePressure / screenSensitivity;
  }*/

  double calculateSNSPC(double swipePathCurvature, BuildContext context) {
    return swipePathCurvature / getScreenDiagonal(context);
  }

  double calculateSNSPL(double actualSwipePathLength, BuildContext context) {
    return actualSwipePathLength / getScreenDiagonal(context);
  }

  double calculateSNSA_Acceleration(double swipeAcceleration, BuildContext context) {
    return swipeAcceleration / getScreenDiagonal(context);
  }

  double calculateSNSD_Deceleration(double swipeDeceleration, BuildContext context) {
    return swipeDeceleration / getScreenDiagonal(context);
  }

  double calculateSNSJ(double swipeJerk, BuildContext context) {
    return swipeJerk / getScreenDiagonal(context);
  }

  double calculateSPSAC(double swipeArea, BuildContext context) {
    return swipeArea / getScreenArea(context);
  }

  double calculateSNSS_Straightness(double swipeStraightness, BuildContext context) {
    return swipeStraightness / getScreenDiagonal(context);
  }

  double calculateSNSFO(double fingerOrientation, BuildContext context) {
    return fingerOrientation / getScreenDiagonal(context);
  }

  double calculateSNSFMV(double fingerMovementVariability, BuildContext context) {
    return fingerMovementVariability / getScreenDiagonal(context);
  }

  double calculateSNSTDI(double timeOfDaySwipePerformance, double screenPerformanceIndex) {
    return timeOfDaySwipePerformance / screenPerformanceIndex;
  }
}
