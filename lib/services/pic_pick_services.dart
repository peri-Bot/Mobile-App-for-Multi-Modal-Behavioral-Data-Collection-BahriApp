import 'dart:math';

class TapDataCollectionService {
  double calculateSwipePathStraightness(
      double initialX, double initialY, double endX, double endY) {
    double straightDistance =
        sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
    double actualDistance = (endX - initialX).abs() + (endY - initialY).abs();
    return straightDistance / actualDistance;
  }

  double calculateSwipeAngle(
      double initialX, double initialY, double endX, double endY) {
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

  double calculateSwipeDistance(
      double initialX, double initialY, double endX, double endY) {
    return sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
  }

  double calculateSwipeDuration(int startTime, int endTime) {
    return (endTime - startTime) / 1000.0; // convert milliseconds to seconds
  }
}

//  Expanded(
//               child: GestureDetector(
//                 onPanStart: (details) {
//                   _initialX = details.localPosition.dx;
//                   _initialY = details.localPosition.dy;
//                   _startTime = DateTime.now().millisecondsSinceEpoch;
//                 },
//                 onPanEnd: (details) {
//                   int endTime = DateTime.now().millisecondsSinceEpoch;
//                   double endX = details.velocity.pixelsPerSecond.dx;
//                   double endY = details.velocity.pixelsPerSecond.dy;
//                   double distance = _dataCollectionService.calculateSwipeDistance(_initialX!, _initialY!, endX, endY);
//                   double duration = _dataCollectionService.calculateSwipeDuration(_startTime, endTime);
//                   double speed = _dataCollectionService.calculateSwipeSpeed(distance, duration);
//                   double straightness = _dataCollectionService.calculateSwipePathStraightness(_initialX!, _initialY!, endX, endY);
//                   double angle = _dataCollectionService.calculateSwipeAngle(_initialX!, _initialY!, endX, endY);
//                   double acceleration = _dataCollectionService.calculateSwipeAcceleration(speed, duration);
//                   double jerk = _dataCollectionService.calculateSwipeJerk(acceleration, duration);

//                   // Create a map with all the collected data
//                   Map<String, dynamic> swipeData = {
//                     'initialX': _initialX,
//                     'initialY': _initialY,
//                     'endX': endX,
//                     'endY': endY,
//                     'duration': duration,
//                     'distance': distance,
//                     'speed': speed,
//                     'straightness': straightness,
//                     'angle': angle,
//                     'acceleration': acceleration,
//                     'jerk': jerk,
//                   };

