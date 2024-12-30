import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // For debug prints
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

class GyroData {
  double? lastGyroX, lastGyroY, lastGyroZ;
  DateTime? lastTimestamp;

  final double movementThreshold =
      2.5; // Adjust this threshold to control sensitivity
  final double speedThreshold = 2.5; // Threshold for tilt speed
  final double accelerationThreshold = 2.5; // Threshold for tilt acceleration
  final Duration delayBetweenSaves =
      const Duration(milliseconds: 200); // Optional: Add a delay between saves

  double roll = 0.0;
  double pitch = 0.0;

  double tiltSpeed = 0.0;
  double tiltAcceleration = 0.0;
  double tiltDeceleration = 0.0;
  double jerk = 0.0;
  double? lastTiltSpeed;
  double? lastTiltAcceleration; // Added for jerk calculation
  double? lastRotationDirection;

  double rotationDuration = 0.0;
  double rotationDirectionConsistency = 0.0;
  int consistentRotations = 0;
  int totalRotations = 0;
  double cumulativeRotation = 0.0; // Added to track total rotation
  DateTime? rotationStartTime;

  bool isEventActive = false;
  Duration eventCooldown = const Duration(
      seconds: 1); // Time window after an event where data will still be stored
  DateTime? lastEventTime;
  String? _sessionId;
  String? _userId;
  bool _isSessionActive = false;
  List<Map<String, dynamic>> _sessionData = [];

  Future<void> startNewSession(String userId) async {
    _userId = userId;
    _sessionId = _generateSessionId();
    _isSessionActive = true;
    _sessionData = [];
    debugPrint('Started new session: $_sessionId for user: $_userId');
  }

  Future<void> endSession() async {
    if (_isSessionActive) {
      await _sendSessionData();
      _isSessionActive = false;
      _sessionData = [];
      debugPrint('Ended session: $_sessionId');
    }
  }

  String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void calculateTiltAngle(double gyroX, double gyroY, double gyroZ) {
    roll = _handleNaN(atan2(gyroY, gyroZ) * 180 / pi); // Rotation around x-axis
    pitch = _handleNaN(atan2(-gyroX, sqrt(gyroY * gyroY + gyroZ * gyroZ)) *
        180 /
        pi); // Rotation around y-axis
  }

  void calculateTiltSpeed(double gyroX, double gyroY, DateTime currentTime) {
    if (lastTimestamp != null) {
      double deltaTime = _handleNaN(
          currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0);
      if (deltaTime > 0) {
        // Prevent division by zero
        // Calculate magnitude of angular velocity
        double currentTiltSpeed =
            _handleNaN(sqrt(gyroX * gyroX + gyroY * gyroY));
        tiltSpeed = currentTiltSpeed;

        if (lastTiltSpeed != null) {
          // Calculate acceleration (change in speed over time)
          tiltAcceleration =
              _handleNaN((currentTiltSpeed - lastTiltSpeed!) / deltaTime);

          if (lastTiltAcceleration != null) {
            // Calculate jerk (change in acceleration over time)
            jerk = _handleNaN(
                (tiltAcceleration - lastTiltAcceleration!) / deltaTime);
          }

          lastTiltAcceleration = tiltAcceleration;
        }

        lastTiltSpeed = currentTiltSpeed;
      }
    }
    lastTimestamp = currentTime;
  }

  double calculateTiltStability(double gyroX, double gyroY, double gyroZ) {
    if (lastGyroX != null && lastGyroY != null && lastGyroZ != null) {
      double deltaX = _handleNaN((gyroX - lastGyroX!).abs());
      double deltaY = _handleNaN((gyroY - lastGyroY!).abs());
      double deltaZ = _handleNaN((gyroZ - lastGyroZ!).abs());

      double stability = _handleNaN(deltaX + deltaY + deltaZ);
      return stability;
    }
    lastGyroX = gyroX;
    lastGyroY = gyroY;
    lastGyroZ = gyroZ;
    return 0.0;
  }

  void calculateRotationDirection(double gyroX, DateTime currentTime) {
    double currentDirection = gyroX > 0 ? 1.0 : -1.0;

    if (lastRotationDirection != null) {
      if (currentDirection == lastRotationDirection) {
        consistentRotations++;
      }
      totalRotations++;

      // Calculate consistency as a percentage
      rotationDirectionConsistency = totalRotations > 0
          ? _handleNaN((consistentRotations / totalRotations) * 100.0)
          : 0.0;
    }

    // Start tracking rotation duration when direction changes
    if (lastRotationDirection != currentDirection) {
      rotationStartTime = currentTime;
    }

    lastRotationDirection = currentDirection;
  }

  double calculateMicroAdjustments(double gyroX, double gyroY, double gyroZ) {
    return _handleNaN(sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ));
  }

  double calculateRotationPathStraightness(
      double gyroX, double gyroY, double gyroZ) {
    return _handleNaN((gyroX.abs() + gyroY.abs() + gyroZ.abs()) / 3.0);
  }

  void calculateRotationDuration(double gyroX, DateTime currentTime) {
    // Only update duration if we're actually rotating (above some minimum threshold)
    const rotationThreshold = 0.1; // Adjust this value based on your needs

    if (gyroX.abs() > rotationThreshold) {
      rotationStartTime ??= currentTime;

      // Calculate duration in seconds
      rotationDuration = _handleNaN(
          currentTime.difference(rotationStartTime!).inMilliseconds / 1000.0);

      // Update cumulative rotation
      double deltaTime = lastTimestamp != null
          ? currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0
          : 0.0;
      cumulativeRotation += gyroX * deltaTime;
    } else {
      // Reset if no significant rotation
      if (rotationStartTime != null) {
        rotationStartTime = null;
        rotationDuration = 0.0;
      }
    }

    lastTimestamp = currentTime;
  }

  bool isSignificantMovement(double gyroX, double gyroY, double gyroZ) {
    double movementMagnitude =
        sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);

    return movementMagnitude > movementThreshold ||
        tiltSpeed > speedThreshold ||
        tiltAcceleration > accelerationThreshold;
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('offlineGyroData');
  }

  Future<void> storeGyroDataDartFrog(
    String userId,
    double gyroX,
    double gyroY,
    double gyroZ,
  ) async {
    try {
      if (!_isSessionActive) {
        await startNewSession(userId);
      }

      DateTime now = DateTime.now();
      // Calculate tilt and rotation data
      calculateTiltAngle(gyroX, gyroY, gyroZ);
      calculateTiltSpeed(gyroX, gyroY, now);
      calculateRotationDirection(gyroX, now);
      calculateRotationDuration(gyroX, now);

      // Only store significant data points
      if (isSignificantMovement(gyroX, gyroY, gyroZ)) {
        Map<String, dynamic> dataPoint = {
          'timestamp': now.toIso8601String(),
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
        };

        _sessionData.add(dataPoint);

        // Send data after a batch size or delay
        if (_sessionData.length >= 7) {
          await _sendSessionData(); // Sends in batches of 4 data points
        }
      }
    } catch (e) {
      debugPrint('Error in storeGyroDataDartFrog: $e');
    }
  }

  Future<String> _sendSessionData() async {
    if (_sessionData.isEmpty) return "Session empty";
    bool isOnline = await isConnectedToInternet();

    final url = Uri.parse('http://15.184.243.127:8080/collect_gyro_data');

    final payload = {
      'userId': _userId,
      'sessionId': _sessionId,
      'gyroData': _sessionData,
    };
    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineGyroData');
      await box.add(payload);
      debugPrint('Data saved locally (offline).');
      return 'saved_locally';
    }
    try {
      debugPrint('Sending data to server: ${jsonEncode(payload)}');

      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        debugPrint(
            'Successfully sent data. Session: $_sessionId, Points: ${_sessionData.length}');
        _sessionData = []; // Clear sent data
        return 'success';
      } else {
        debugPrint(
            'Failed to send data. Status: ${response.statusCode} - Body: ${response.body}');
        var box = Hive.box('offlineGyroData');
        await box.add(payload);
        debugPrint('Data saved locally (offline).');
        _sessionData = [];
        return 'saved_locally';
        //throw Exception('Failed to send  ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending  $e');
      // Keep the data in _sessionData to try sending again later
      var box = Hive.box('offlineGyroData');
      await box.add(payload);
      debugPrint('Data saved locally (offline).');
      _sessionData = [];
      return 'saved_locally';
    }
  }

  double _handleNaN(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }
    return value;
  }
}
