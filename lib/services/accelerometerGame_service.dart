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
  List<double> _recentMagnitudes = []; // New list to store recent magnitudes
  final int _maxHistory = 2; // Keep only the last two magnitudes
  final int _maxDataEntries = 20;

  // New fields
  DateTime? _lastStepTime;
  final List<double> _verticalOscillationData = [];
  final List<double> _stepDurations = [];
  int _totalSteps = 0;

  bool get isDataCollectionEnabled => _isDataCollectionEnabled;
  List<Map<String, dynamic>> _stepsData = [
  ]; // New list to store each step's data


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

  // Other fields...

  void _processAccelerometerData(List<double> data, Function onStepDetected,
      String currentActivity) {
    if (_stepsData.length >= _maxDataEntries) {
      return; // Stop collecting new data if we have reached the limit
    }

    double x = data[0], y = data[1], z = data[2];
    double magnitude = sqrt(x * x + y * y + z * z);
    magnitude = _applyLowPassFilter(magnitude, _lastMagnitude);

    _accelerationData.add(magnitude);
    _peakAcceleration = max(_peakAcceleration, magnitude);
    _minAcceleration = min(_minAcceleration, magnitude);

    // Ensure the vertical (z) component is being added correctly
    _verticalOscillationData.add(z);


    // Store recent magnitudes for jerk calculation
    _recentMagnitudes.add(magnitude);
    if (_recentMagnitudes.length > _maxHistory) {
      _recentMagnitudes.removeAt(0);
    }

    if (_lastMagnitude != 0) {
      double delta = magnitude - _lastMagnitude;
      if (!_isMovingUp && delta > _stepThreshold) {
        _isMovingUp = true;
      } else if (_isMovingUp && delta < -_stepThreshold) {
        _isMovingUp = false;
        _totalSteps++; // Increment step count
        onStepDetected();
        _logStepDuration(); // Log step duration

        double jerk = getJerk(magnitude);
       // double verticalOscillation = getVerticalOscillation();

        // Store data for this step
        Map<String, double> orientationData = getOrientation();
        Map<String, dynamic> stepData = {
          'timestamp': DateTime.now().toIso8601String(),
          'averageAcceleration': getAverageAcceleration(),
          'peakAcceleration': _peakAcceleration,
          'minAcceleration': _minAcceleration,
          'standardDeviation': getStandardDeviation(),
          //'verticalOscillation': verticalOscillation,
          'jerk': jerk,
          'stepDuration': _stepDurations.isNotEmpty ? _stepDurations.last : 0,
          'averageStepDuration': getAverageStepDuration(),
          'stepFrequency': getStepFrequency(),
          'activityType': _currentActivity ?? 'unknown',
          'orientation_pitch': orientationData['pitch'],
          'orientation_roll': orientationData['roll'],
          'orientation_yaw': orientationData['yaw'],
        };
        _stepsData.add(stepData); // Add step data to the list
      }
    }

    _lastMagnitude = magnitude;
  }




  void _processMagnetometerData(List<double> data) {
    _magnetometerData.addAll(data);
  }

  // Start data collection
  void startDataCollection() {
    _isDataCollectionEnabled = true;
    debugPrint("Data collection started");
  }

// Stop data collection
  void stopDataCollection() {
    _isDataCollectionEnabled = false;
    debugPrint("Data collection stopped");
  }


  // Initialize session ID
  void initializeSession() {
    _sessionId = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
  }

  // End the session and send collected data
  Future<String> endSession(String userId) async {
    debugPrint("Ending session for userId: $userId with session ID: $_sessionId and data collection enabled: $_isDataCollectionEnabled");

    // Prepare data payload
    Map<String, dynamic> data = {
      'userId': userId,
      'sessionId': _sessionId,
      'stepsData': _stepsData, // Include all collected steps data
    };

    debugPrint("Prepared Data Payload for session end: $data");
    String result = await _sendDataToDartFrogServer(data);

    // Set data collection to false after sending the data
    _isDataCollectionEnabled = false;
    _stepsData.clear(); // Clear the list after sending

    return result;
  }


  // Send data to Dart Frog server
  Future<String> _sendDataToDartFrogServer(Map<String, dynamic> data) async {
  final url = Uri.parse('http://15.184.243.127:8080/collect_accelerometer_data');
  bool isOnline = await isConnectedToInternet();

  if (data['userId'] == null || (data['userId'] as String).isEmpty || !_isDataCollectionEnabled) {
  debugPrint("Data cannot be sent. Either user ID is empty or data collection is off.");
  debugPrint("userId: ${data['userId']}");
  debugPrint("Data collection enabled: $_isDataCollectionEnabled");
  return "Data cannot be sent. Either user ID is empty or data collection is off";
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
  debugPrint('Could not add accelerometer data: ${response.body}');
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
    if (_verticalOscillationData.isEmpty) return 0.0;
    double sum = _verticalOscillationData.reduce((a, b) => a + b);
    return sum / _verticalOscillationData.length;
  }


  // Calculate the rate of change of acceleration (jerk)
  double getJerk(double magnitude) {
    if (_recentMagnitudes.length < 2) return 0.0;

    double lastMagnitude = _recentMagnitudes[_recentMagnitudes.length - 2];
    double deltaTime = 0.1; // Assuming 100ms sample rate
    return (magnitude - lastMagnitude) / deltaTime;
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
  now
      .difference(_lastStepTime!)
      .inMilliseconds
      .toDouble();
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

  void dispose() async {
  await endSession(userId!);
  _accelerometerSubscription?.cancel();
  _magnetometerSubscription?.cancel();
  }
  }
