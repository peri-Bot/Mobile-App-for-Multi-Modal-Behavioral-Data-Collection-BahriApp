import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart'; // For debug prints
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

class GyroData {
  double? lastGyroX, lastGyroY, lastGyroZ;
  DateTime? lastTimestamp;

  final double movementThreshold = 10;
  final double speedThreshold = 10;
  final double accelerationThreshold = 10;
  final Duration delayBetweenSaves = const Duration(milliseconds: 200);

  double roll = 0.0;
  double pitch = 0.0;

  double tiltSpeed = 0.0;
  double tiltAcceleration = 0.0;
  double jerk = 0.0;
  double? lastTiltSpeed;
  double? lastTiltAcceleration;
  double? lastRotationDirection;

  double rotationDuration = 0.0;
  double rotationDirectionConsistency = 0.0;
  int consistentRotations = 0;
  int totalRotations = 0;
  double cumulativeRotation = 0.0;
  DateTime? rotationStartTime;

  bool isEventActive = false;
  Duration eventCooldown = const Duration(seconds: 1);
  DateTime? lastEventTime;
  String? _sessionId;
  String? _userId;
  bool _isSessionActive = false;
  List<Map<String, dynamic>> _sessionData = [];

  Timer? _debounceTimer;
  DateTime lastSentTime = DateTime.now();

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
    roll = _handleNaN(atan2(gyroY, gyroZ) * 180 / pi);
    pitch = _handleNaN(atan2(-gyroX, sqrt(gyroY * gyroY + gyroZ * gyroZ)) *
        180 /
        pi);
  }

  void calculateTiltSpeed(double gyroX, double gyroY, DateTime currentTime) {
    if (lastTimestamp != null) {
      double deltaTime = _handleNaN(
          currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0);
      if (deltaTime > 0) {
        double currentTiltSpeed =
        _handleNaN(sqrt(gyroX * gyroX + gyroY * gyroY));
        tiltSpeed = currentTiltSpeed;

        if (lastTiltSpeed != null) {
          tiltAcceleration =
              _handleNaN((currentTiltSpeed - lastTiltSpeed!) / deltaTime);

          if (lastTiltAcceleration != null) {
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

      rotationDirectionConsistency = totalRotations > 0
          ? _handleNaN((consistentRotations / totalRotations) * 100.0)
          : 0.0;
    }

    if (lastRotationDirection != currentDirection) {
      rotationStartTime = currentTime;
    }

    lastRotationDirection = currentDirection;
  }

  double calculateMicroAdjustments(double gyroX, double gyroY, double gyroZ) {
    return _handleNaN(sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ));
  }

  void calculateRotationDuration(double gyroX, DateTime currentTime) {
    const rotationThreshold = 0.1;

    if (gyroX.abs() > rotationThreshold) {
      rotationStartTime ??= currentTime;
      rotationDuration = _handleNaN(
          currentTime.difference(rotationStartTime!).inMilliseconds / 1000.0);

      double deltaTime = lastTimestamp != null
          ? currentTime.difference(lastTimestamp!).inMilliseconds / 1000.0
          : 0.0;
      cumulativeRotation += gyroX * deltaTime;
    } else {
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
    debugPrint('Connectivity Result: $connectivityResult');

    // Additional check for actual internet access
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      try {
        // Attempt to ping a reliable server like Google's DNS
        final result = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 10));
        debugPrint('HTTP Get Result: ${result.statusCode}');

        if (result.statusCode == 200) {
          debugPrint('Internet access confirmed.');
          return true;
        } else {
          debugPrint('No internet access despite connectivity.');
        }
      } catch (e) {
        debugPrint('Error during internet access check: $e');
      }
    }

    debugPrint('Device appears offline.');
    return false;
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
      calculateTiltAngle(gyroX, gyroY, gyroZ);
      calculateTiltSpeed(gyroX, gyroY, now);
      calculateRotationDirection(gyroX, now);
      calculateRotationDuration(gyroX, now);

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

        if (_debounceTimer?.isActive ?? false) return;

        _debounceTimer = Timer(const Duration(seconds: 2), () async {
          await _sendSessionData();
        });
      }
    } catch (e) {
      debugPrint('Error in storeGyroDataDartFrog: $e');
    }
  }

  Future<void> _sendSessionData() async {
    if (_sessionData.isEmpty) return;

    final payload = {
      'userId': _userId,
      'sessionId': _sessionId,
      'gyroData': _sessionData,
    };

    if (!await isConnectedToInternet()) {
      var box = Hive.box('offlineGyroData');
      await box.add(payload);
      debugPrint('Data saved locally (offline).');
      _sessionData.clear();
      return;
    }

    try {
      await sendSessionDataInBackground(payload);
      debugPrint('Successfully sent data.');
      _sessionData.clear();
    } catch (e) {
      var box = Hive.box('offlineGyroData');
      await box.add(payload);
      debugPrint('Failed to send data. Saved locally: $e');
      _sessionData.clear();
    }
  }

  Future<void> sendSessionDataInBackground(Map<String, dynamic> payload) async {
    await compute(_sendDataToServer, payload);
  }

  static Future<void> _sendDataToServer(Map<String, dynamic> payload) async {
    final url = Uri.parse('http://15.184.243.127:8080/collect_gyro_data');

    try {
      final response = await http.post(
        url,
        body: jsonEncode(payload),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Data sent successfully.');
      } else {
        debugPrint('Server error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Network error: $e');
    }
  }

  double _handleNaN(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0.0;
    }
    return value;
  }
}

