import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debug prints

class GyroData {
  double? lastGyroX, lastGyroY, lastGyroZ;
  DateTime? lastTimestamp;

  final double movementThreshold = 0.0; // Adjust based on sensitivity you need
  final Duration delayBetweenSaves = const Duration(milliseconds: 200); // Optional: Add a delay between saves

  double roll = 0.0;
  double pitch = 0.0;

  double tiltSpeed = 0.0;
  double tiltAcceleration = 0.0;
  double tiltDeceleration = 0.0;
  double jerk = 0.0;

  double rotationDuration = 0.0;
  double rotationDirectionConsistency = 0.0;
  int consistentRotations = 0;
  int totalRotations = 0;

  double? lastTiltSpeed;
  double? lastRotationDirection;
  DateTime? lastSavedTime;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to calculate tilt angle (roll and pitch)
  void calculateTiltAngle(double gyroX, double gyroY, double gyroZ) {
    roll = atan2(gyroY, gyroZ) * 180 / pi; // Rotation around x-axis
    pitch = atan2(-gyroX, sqrt(gyroY * gyroY + gyroZ * gyroZ)) * 180 / pi; // Rotation around y-axis
  }

  // Function to calculate tilt speed
  void calculateTiltSpeed(double gyroX, double gyroY, DateTime currentTime) {
    if (lastTimestamp != null) {
      double deltaTime = currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0;
      tiltSpeed = sqrt(gyroX * gyroX + gyroY * gyroY) / deltaTime;

      // Calculate acceleration and jerk based on the change in speed
      if (lastTiltSpeed != null) {
        tiltAcceleration = (tiltSpeed - lastTiltSpeed!) / deltaTime;
        jerk = (tiltAcceleration - tiltDeceleration) / deltaTime;
      }

      lastTiltSpeed = tiltSpeed;
    }
    lastTimestamp = currentTime;
  }

  // Function to calculate tilt stability based on sudden changes in gyroscope data
  double calculateTiltStability(double gyroX, double gyroY, double gyroZ) {
    if (lastGyroX != null && lastGyroY != null && lastGyroZ != null) {
      double deltaX = (gyroX - lastGyroX!).abs();
      double deltaY = (gyroY - lastGyroY!).abs();
      double deltaZ = (gyroZ - lastGyroZ!).abs();

      double stability = deltaX + deltaY + deltaZ;
      return stability;
    }
    lastGyroX = gyroX;
    lastGyroY = gyroY;
    lastGyroZ = gyroZ;
    return 0.0;
  }

  // Function to calculate rotation direction consistency
  void calculateRotationDirection(double gyroX, DateTime currentTime) {
    if (lastRotationDirection != null && lastTimestamp != null) {
      double deltaTime = currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0;
      double currentDirection = gyroX > 0 ? 1.0 : -1.0;
      if (currentDirection == lastRotationDirection) {
        consistentRotations++;
      }
      totalRotations++;
      rotationDirectionConsistency = consistentRotations / totalRotations;
    }
    lastRotationDirection = gyroX > 0 ? 1.0 : -1.0;
    lastTimestamp = currentTime;
  }

  // Function to measure micro-adjustments (small, quick changes in tilt)
  double calculateMicroAdjustments(double gyroX, double gyroY, double gyroZ) {
    return sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);
  }

  // Function to measure rotational path straightness (how smooth is the rotation)
  double calculateRotationPathStraightness(double gyroX, double gyroY, double gyroZ) {
    return (gyroX.abs() + gyroY.abs() + gyroZ.abs()) / 3.0;
  }

  // Function to calculate how long the device remains in a specific tilt (rotation duration)
  void calculateRotationDuration(double gyroX, DateTime currentTime) {
    if (lastTimestamp != null) {
      double deltaTime = currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0;
      rotationDuration += deltaTime;
    }
    lastTimestamp = currentTime;
  }

  bool isSignificantMovement(double gyroX, double gyroY, double gyroZ) {
    if (lastGyroX == null || lastGyroY == null || lastGyroZ == null) {
      lastGyroX = gyroX;
      lastGyroY = gyroY;
      lastGyroZ = gyroZ;
      return false; // Skip the first reading since we have no basis for comparison
    }

    double deltaX = (gyroX - lastGyroX!).abs();
    double deltaY = (gyroY - lastGyroY!).abs();
    double deltaZ = (gyroZ - lastGyroZ!).abs();

    // Debug prints
    print('deltaX: $deltaX, deltaY: $deltaY, deltaZ: $deltaZ');
    print('movementThreshold: $movementThreshold');

    // Update the last gyroscope values for future comparisons
    lastGyroX = gyroX;
    lastGyroY = gyroY;
    lastGyroZ = gyroZ;

    // Return true if any axis movement exceeds the threshold
    return deltaX > movementThreshold || deltaY > movementThreshold || deltaZ > movementThreshold;
  }


  Future<void> storeDataInFirestore(double gyroX, double gyroY, double gyroZ) async {
    if (isSignificantMovement(gyroX, gyroY, gyroZ)) {
      DateTime now = DateTime.now();

      try {
        await _firestore.collection('users')
            .doc('1')
            .collection('gyrodata')
            .add({
          'gyroX': gyroX,
          'gyroY': gyroY,
          'gyroZ': gyroZ,
          'roll': roll,
          'pitch': pitch,
          'tiltSpeed': tiltSpeed,
          'tiltAcceleration': tiltAcceleration,
          'jerk': jerk,
          'rotationDuration': rotationDuration,
          'rotationDirectionConsistency': rotationDirectionConsistency,
          'timestamp': now,
        });

        lastSavedTime = now;
        if (kDebugMode) {
          print('Gyroscope data stored successfully under users->1->gyrodata!');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error storing data: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('No significant movement detected, data not stored.');
      }
    }
  }


  void printMetrics() {
    print('Gyroscope Data: X = $lastGyroX, Y = $lastGyroY, Z = $lastGyroZ');
    print('Tilt Angle: Roll = $roll, Pitch = $pitch');
    print('Tilt Speed: $tiltSpeed');
    print('Tilt Acceleration: $tiltAcceleration');
    print('Jerk: $jerk');
    print('Rotation Duration: $rotationDuration');
    print('Rotation Direction Consistency: $rotationDirectionConsistency');
  }
}
