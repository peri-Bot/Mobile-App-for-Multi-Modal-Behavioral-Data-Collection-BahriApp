import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

class StepCounter {
  // Fields for step counting and sensor data
  StreamSubscription<SensorEvent>? _accelerometerSubscription;
  StreamSubscription<SensorEvent>? _magnetometerSubscription;
  double _lastMagnitude = 0;
  final double _stepThreshold = 0.5;
  final double _lowPassFilterFactor = 0.3;
  bool _isMovingUp = false;
  bool _isDataCollectionEnabled = false;
  final List<double> _accelerationData = [];
  final List<double> _magnetometerData = [];
  double _peakAcceleration = 0;
  double _minAcceleration = double.infinity;
  String? _currentActivity;
  String? userId;

  // New fields
  DateTime? _lastStepTime;
  final List<double> _verticalOscillationData = [];
  final List<double> _stepDurations = [];
  int _totalSteps = 0;
  //final Uuid _uuid = Uuid();
  String? _sessionId;

  // Firestore session-based fields
  void updateCurrentActivity(String newActivity) {
    _currentActivity = newActivity;
  }

  // Initialize the sensor with accelerometer and magnetometer
  Future<bool> initSensor({
    required Function onStepDetected,
    required String currentActivity,
  }) async {
    _currentActivity = currentActivity;
    bool accelerometerAvailable =
        await SensorManager().isSensorAvailable(Sensors.ACCELEROMETER);
    bool magnetometerAvailable =
        await SensorManager().isSensorAvailable(Sensors.MAGNETIC_FIELD);

    if (accelerometerAvailable && magnetometerAvailable) {
      final accelerometerStream = await SensorManager().sensorUpdates(
        sensorId: Sensors.ACCELEROMETER,
        interval: const Duration(milliseconds: 100),
      );
      final magnetometerStream = await SensorManager().sensorUpdates(
        sensorId: Sensors.MAGNETIC_FIELD,
        interval: const Duration(milliseconds: 100),
      );

      _accelerometerSubscription =
          accelerometerStream.listen((SensorEvent event) {
        if (_isDataCollectionEnabled) {
          _processAccelerometerData(
              event.data, onStepDetected, currentActivity);
        }
      });

      _magnetometerSubscription =
          magnetometerStream.listen((SensorEvent event) {
        if (_isDataCollectionEnabled) {
          _processMagnetometerData(event.data);
        }
      });

      // Initialize session ID
      initializeSession();
    }

    return accelerometerAvailable && magnetometerAvailable;
  }

  // Apply low-pass filter to smooth out accelerometer data
  double _applyLowPassFilter(double newValue, double lastValue) {
    return lastValue + _lowPassFilterFactor * (newValue - lastValue);
  }

  // Process the accelerometer data and detect steps
  void _processAccelerometerData(
      List<double> data, Function onStepDetected, String currentActivity) {
    double x = data[0], y = data[1], z = data[2];
    double magnitude = sqrt(x * x + y * y + z * z);
    magnitude = _applyLowPassFilter(magnitude, _lastMagnitude);

    _accelerationData.add(magnitude);
    _peakAcceleration = max(_peakAcceleration, magnitude);
    _minAcceleration = min(_minAcceleration, magnitude);

    // Collect vertical oscillation data (Z-axis for vertical movement)
    _verticalOscillationData.add(z);

    if (_lastMagnitude != 0) {
      double delta = magnitude - _lastMagnitude;
      if (!_isMovingUp && delta > _stepThreshold) {
        _isMovingUp = true;
      } else if (_isMovingUp && delta < -_stepThreshold) {
        _isMovingUp = false;
        _totalSteps++; // Increment step count
        onStepDetected();
        _sendDataToDartFrogServer(userId!);
        _logStepDuration(); // Log step duration
      }
    }

    _lastMagnitude = magnitude;
  }

  // Process magnetometer data
  void _processMagnetometerData(List<double> data) {
    _magnetometerData.addAll(data);
  }

  // Start data collection
  void startDataCollection() {
    _isDataCollectionEnabled = true;
  }

  // Stop data collection
  void stopDataCollection() {
    _isDataCollectionEnabled = false;
  }

  // Initialize session ID
  void initializeSession() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Send the data to Dart Frog server
  Future<String> _sendDataToDartFrogServer(String userId) async {
    final url =
        Uri.parse('http://15.184.243.127:8080/collect_accelerometer_data');
    bool isOnline = await isConnectedToInternet();

    if (userId.isEmpty || !_isDataCollectionEnabled) {
      debugPrint(
          "Data cannot be sent. Either user ID is empty or data collection is off.");
      return "Data cannot be sent. Either user ID is empty or data collection is off";
    }
    Map<String, double> orientationData = getOrientation();
    Map<String, dynamic> data = {
      'userId': userId,
      'sessionId': _sessionId,
      'timestamp': DateTime.now().toIso8601String(),
      'averageAcceleration': getAverageAcceleration(),
      'peakAcceleration': _peakAcceleration,
      'minAcceleration': _minAcceleration,
      'standardDeviation': getStandardDeviation(),
      'verticalOscillation': getVerticalOscillation(),
      'jerk': getJerk(_lastMagnitude),
      'stepDuration': _stepDurations.isNotEmpty ? _stepDurations.last : 0,
      'averageStepDuration': getAverageStepDuration(),
      'stepFrequency': getStepFrequency(),
      'activityType': _currentActivity ?? 'unknown',
      //'totalSteps': _totalSteps,
      'orientation_pitch': orientationData['pitch'],
      'orientation_roll': orientationData['roll'],
      'orientation_yaw': orientationData['yaw'], // Add orientation data
    };

    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineAcceloData');
      await box.add(data);
      debugPrint('Data saved locally (offline).');
      return 'saved_locally';
    }

    try {
      debugPrint("Prepared Data Payload: ${jsonEncode(data)}");

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        debugPrint("Data sent successfully.");
        return 'success';
      } else {
        debugPrint("Failed to send data. Status: ${response.statusCode}");
        debugPrint('Could not add keyStroke data: ${response.body}');
        var box = Hive.box('offlineAcceloData');
        await box.add(data);
        debugPrint('Data saved locally (offline).');
        return 'saved_locally';
      }
    } catch (e) {
      debugPrint("Error sending data: $e");
      var box = Hive.box('offlineAcceloData');
      await box.add(data);
      debugPrint('Data saved locally (offline).');
      return 'saved_locally';
    }
  }

  // Get average acceleration
  double getAverageAcceleration() {
    return _accelerationData.isEmpty
        ? 0
        : _accelerationData.reduce((a, b) => a + b) / _accelerationData.length;
  }

  // Get standard deviation of acceleration
  double getStandardDeviation() {
    double mean = getAverageAcceleration();
    num sumSquaredDiffs = _accelerationData
        .map((value) => pow(value - mean, 2))
        .reduce((a, b) => a + b);
    return sqrt(sumSquaredDiffs / _accelerationData.length);
  }

  // Get vertical oscillation (average vertical movement)
  double getVerticalOscillation() {
    if (_verticalOscillationData.isEmpty) return 0;
    return _verticalOscillationData.reduce((a, b) => a + b) /
        _verticalOscillationData.length;
  }

  // Calculate jerk (rate of change of acceleration)
  double getJerk(double magnitude) {
    if (_accelerationData.isEmpty) return 0;
    double lastAcceleration = _accelerationData.last;
    double deltaTime = 0.1; // 100ms sample rate
    return (magnitude - lastAcceleration) / deltaTime;
  }

  // Get average step duration
  double getAverageStepDuration() {
    if (_stepDurations.isEmpty) return 0;
    return _stepDurations.reduce((a, b) => a + b) / _stepDurations.length;
  }

  // Get step frequency (steps per minute)
  double getStepFrequency() {
    if (_stepDurations.isEmpty) return 0;
    double totalTime =
        _stepDurations.reduce((a, b) => a + b) / 1000; // in seconds
    return _totalSteps / (totalTime / 60); // steps per minute
  }

  // Get the device orientation (pitch, roll, yaw) using accelerometer and magnetometer
  Map<String, double> getOrientation() {
    if (_magnetometerData.isEmpty) return {'pitch': 0, 'roll': 0, 'yaw': 0};

    double ax = _accelerationData[0];
    double ay = _accelerationData[1];
    double az = _accelerationData[2];

    double mx = _magnetometerData[0];
    double my = _magnetometerData[1];
    double mz = _magnetometerData[2];

    // Normalize accelerometer data (gravity vector)
    double normAccel = sqrt(ax * ax + ay * ay + az * az);
    ax /= normAccel;
    ay /= normAccel;
    az /= normAccel;

    // Normalize magnetometer data (earth magnetic field vector)
    double normMag = sqrt(mx * mx + my * my + mz * mz);
    mx /= normMag;
    my /= normMag;
    mz /= normMag;

    // Calculate pitch and roll
    double pitch = asin(-ax); // Pitch angle (in radians)
    double roll = atan2(ay, az); // Roll angle (in radians)

    // Calculate yaw (compass heading)
    double yaw =
        atan2(my * ax - mx * ay, mx * az - mz * ax); // Yaw angle (in radians)

    // Convert radians to degrees for easier interpretation
    double pitchDeg = pitch * 180.0 / pi;
    double rollDeg = roll * 180.0 / pi;
    double yawDeg = yaw * 180.0 / pi;

    return {'pitch': pitchDeg, 'roll': rollDeg, 'yaw': yawDeg};
  }

  // Log step duration and store it in list
  void _logStepDuration() {
    if (_lastStepTime != null) {
      DateTime now = DateTime.now();
      double stepDuration =
          now.difference(_lastStepTime!).inMilliseconds.toDouble();
      _stepDurations.add(stepDuration);
      print("Step duration: $stepDuration ms");
    }
    _lastStepTime = DateTime.now();
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
    await Hive.openBox('offlineAcceloData');
  }

  // Reset the counters and data
  void reset() {
    _lastMagnitude = 0;
    _isMovingUp = false;
    _accelerationData.clear();
    _magnetometerData.clear();
    _peakAcceleration = 0;
    _minAcceleration = double.infinity;
    _lastStepTime = null;
    _verticalOscillationData.clear();
    _stepDurations.clear();
    _totalSteps = 0;
    _sessionId = null;
  }

  // Cancel the sensor subscriptions
  void dispose() {
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
  }

  // Example method to update session end time in Firestore
  // void updateSessionEndTime() async {
  //   if (_sessionId == null || _lastStepTime == null) return;

  //   try {
  //     await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //       'stepData': {
  //         _sessionId.toString(): {
  //           'endTime': FieldValue.serverTimestamp(),
  //           'sessionDuration': '${DateTime.now().difference(_lastStepTime!).inMilliseconds} ms',
  //         }
  //       }
  //     }, SetOptions(merge: true));
  //     print("Session end time updated successfully");
  //   } catch (e) {
  //     print("Failed to update session end time: $e");
  //   }
  // }
}
