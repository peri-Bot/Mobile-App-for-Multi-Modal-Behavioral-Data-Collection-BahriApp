import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:math';
import './../widgets/keyboard/utils/types.dart';
import 'package:http/http.dart' as http;

class FreeTextService {
  List<Map<String, dynamic>> keystrokeData = [];
  DateTime? lastReleaseTime;
  DateTime? typingStartTime;
  Map<String, dynamic>? currentKeystroke;
  double totalCharactersTyped = 0;
  Map<String, double> averageKeyStrokeMetrics = {};
  String? uid;
  Future<void> fetchUserId() async {
    uid = await getUserId();
    debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
  }

  void onKeyTapDown(TapDownDetails details) {
    final now = DateTime.now();

    typingStartTime ??= now;

    currentKeystroke = {
      'pressTime': now.millisecondsSinceEpoch,
    };

    if (lastReleaseTime != null) {
      currentKeystroke!['flightTime'] =
          now.difference(lastReleaseTime!).inMilliseconds;
    }
  }

  void onButtonPressed(String keyText, KeyTypes keyType) {
    if (currentKeystroke != null) {
      currentKeystroke!['keyText'] = keyText;
      currentKeystroke!['keyType'] = keyType.toString();
      currentKeystroke!['TimeStamp'] = DateTime.now().toIso8601String();

      keystrokeData.add(currentKeystroke!);
      if (keyType == KeyTypes.textKey) {
        totalCharactersTyped++;
      }
    }
  }

  void onKeyTapUp(TapUpDetails details) {
    if (currentKeystroke != null) {
      final releaseTime = DateTime.now();
      currentKeystroke!['releaseTime'] = releaseTime.millisecondsSinceEpoch;
      lastReleaseTime = releaseTime;

      // Calculate hold time
      int pressTime = currentKeystroke!['pressTime'];
      currentKeystroke!['holdTime'] =
          releaseTime.millisecondsSinceEpoch - pressTime;

      // Calculate interkey time if there's a previous keystroke
      if (keystrokeData.length > 1) {
        int previousReleaseTime =
            keystrokeData[keystrokeData.length - 2]['releaseTime'];
        currentKeystroke!['interKeyTime'] = pressTime - previousReleaseTime;
      }
    }
  }

  void reset() {
    keystrokeData.clear();
    lastReleaseTime = null;
    typingStartTime = null;
    currentKeystroke = null;
  }

  List<Map<String, dynamic>> getKeystrokeData() {
    return keystrokeData;
  }

  // Metric calculation methods (unchanged)
  double calculateTypingSpeed() {
    if (typingStartTime == null || keystrokeData.isEmpty) return 0;
    Duration totalDuration = Duration(
        milliseconds: keystrokeData.last['releaseTime'] -
            typingStartTime!.millisecondsSinceEpoch);
    double durationInMinutes = totalDuration.inMilliseconds / 60000;
    return totalCharactersTyped / durationInMinutes; // Characters per minute
  }

  double calculateHFR() {
    List<double> ratios = [];
    for (var keystroke in keystrokeData) {
      if (keystroke.containsKey('holdTime') &&
          keystroke.containsKey('flightTime')) {
        double holdTime = keystroke['holdTime'].toDouble();
        double flightTime = keystroke['flightTime'].toDouble();
        if (flightTime > 0) {
          ratios.add(holdTime / flightTime);
        }
      }
    }
    return _calculateAverageDouble(ratios);
  }

  double calculateFHR() {
    List<double> ratios = [];
    for (var keystroke in keystrokeData) {
      if (keystroke.containsKey('holdTime') &&
          keystroke.containsKey('flightTime')) {
        double holdTime = keystroke['holdTime'].toDouble();
        double flightTime = keystroke['flightTime'].toDouble();
        if (holdTime > 0) {
          ratios.add(flightTime / holdTime);
        }
      }
    }
    return _calculateAverageDouble(ratios);
  }

  double calculateAKPD() {
    List<int> holdTimes =
        keystrokeData.map((k) => k['holdTime'] as int).toList();
    return _calculateAverage(holdTimes);
  }

  double calculateAKRD() {
    List<int> releaseDurations = [];
    for (int i = 1; i < keystrokeData.length; i++) {
      releaseDurations.add(
          keystrokeData[i]['pressTime'] - keystrokeData[i - 1]['releaseTime']);
    }
    return _calculateAverage(releaseDurations);
  }

  double calculateKPV() {
    List<int> holdTimes =
        keystrokeData.map((k) => k['holdTime'] as int).toList();
    return _calculateVariability(holdTimes);
  }

  double calculateKRV() {
    List<int> releaseDurations = [];
    for (int i = 1; i < keystrokeData.length; i++) {
      releaseDurations.add(
          keystrokeData[i]['pressTime'] - keystrokeData[i - 1]['releaseTime']);
    }
    return _calculateVariability(releaseDurations);
  }

  double calculateAIT() {
    List<int> interKeyTimes = keystrokeData
        .where((k) => k.containsKey('interKeyTime'))
        .map((k) => k['interKeyTime'] as int)
        .toList();
    return _calculateAverage(interKeyTimes);
  }

  double calculateKPR() {
    if (typingStartTime == null || keystrokeData.isEmpty) return 0;
    Duration totalDuration = Duration(
        milliseconds: keystrokeData.last['pressTime'] -
            typingStartTime!.millisecondsSinceEpoch);
    return keystrokeData.length / totalDuration.inSeconds;
  }

  double calculateKRR() {
    if (typingStartTime == null || keystrokeData.isEmpty) return 0;
    Duration totalDuration = Duration(
        milliseconds: keystrokeData.last['releaseTime'] -
            typingStartTime!.millisecondsSinceEpoch);
    return keystrokeData.length / totalDuration.inSeconds;
  }

  double calculateAST() {
    List<int> seekTimes = keystrokeData
        .where((k) => k.containsKey('flightTime'))
        .map((k) => k['flightTime'] as int)
        .toList();
    return _calculateAverage(seekTimes);
  }

  // Helper methods (unchanged)

  double _calculateAverage(List<int> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateAverageDouble(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  double _calculateVariability(List<int> values) {
    if (values.isEmpty) return 0;
    double mean = _calculateAverage(values);
    num sumSquaredDiff =
        values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b);
    return sqrt(sumSquaredDiff / values.length) /
        mean; // Coefficient of variation
  }

  // Method to get all metrics (unchanged)
  Map<String, double> getAllMetrics() {
    return {
      'AKPD': calculateAKPD(),
      'AKRD': calculateAKRD(),
      'KPV': calculateKPV(),
      'KRV': calculateKRV(),
      'AIT': calculateAIT(),
      'KPR': calculateKPR(),
      'KRR': calculateKRR(),
      'AST': calculateAST(),
      'TS': calculateTypingSpeed(),
      'HFR': calculateHFR(),
      'FHR': calculateFHR(),
    };
  }

  void calculateAverageKeyStrokeMetrics() {
    averageKeyStrokeMetrics = {
      'AverageKeyPressDuration': calculateAKPD(),
      'AverageKeyReleaseDuration': calculateAKRD(),
      'KeyPressVatiability': calculateKPV(),
      'KeyReleaseVatiability': calculateKRV(),
      'AverageInterkeyTime': calculateAIT(),
      'KeyPressRate': calculateKPR(),
      'KeyReleaseRate': calculateKRR(),
      'AverageSeekTime': calculateAST(),
      'TypingSpeedCharactersPerMinute': calculateTypingSpeed(),
      'HoldFlightRatio': calculateHFR(),
      'FlightHooldRatio': calculateFHR(),
    };
  }

  Map<String, double> getAverageMetrics() {
    calculateAverageKeyStrokeMetrics(); // Ensure metrics are up-to-date
    return averageKeyStrokeMetrics;
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
    await Hive.openBox('offlineKeystrokeFreeTextData');
  }

  Future<String> saveKeyStrokeFreeTextData(
      Map<String, dynamic> gameInfo) async {
    bool isOnline = await isConnectedToInternet();

    gameInfo['uid'] = uid;
    gameInfo['sessionId'] = DateTime.now().millisecondsSinceEpoch.toString();
    if (keystrokeData.isEmpty) {
      return "Data cannot be sent. data collection is empty";
    }
    final Map<String, dynamic> requestData = {
      'gameInfo': gameInfo,
      'keystrokeFreeTextData': keystrokeData,
      'averageKeyStrokeFreeTextMetrics': getAverageMetrics(),
    };
    if ((requestData['keystrokeFreeTextData'] as List<Map<String, dynamic>>)
            .isEmpty ||
        (requestData['averageKeyStrokeFreeTextMetrics']
                as List<Map<String, dynamic>>)
            .isEmpty) {
      return "Data cannot be sent. data collection is empty";
    }

    debugPrint('Request Data:');
    debugPrint('Game Info: ${requestData['gameInfo']}');
    debugPrint(
        'keystroke Data: ${requestData['keystrokekeystrokeFreeTextDataData']}');
    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineKeystrokeFreeTextData');
      await box.add(requestData);
      debugPrint('Data saved locally (offline).');
      return 'saved_locally';
    }

    final url = Uri.parse(
        'http://15.184.243.127:8080/collect_keystroke_freetext_data'); // Use your Dart Frog server address

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        debugPrint('  keyStroke Data added');
        return 'success';
      } else if (response.statusCode == 400) {
        // Client-side error; log the issue but do not save locally
        debugPrint(
            'Server responded with 400: ${response.body}. Data will not be saved locally.');
        return 'error_400';
      } else {
        // Handle error
        debugPrint('Could not add keyStroke data: ${response.body}');
        var box = Hive.box('offlineKeystrokeFreeTextData');
        await box.add(requestData);
        debugPrint('Data saved locally (offline).');
        return 'Server Error: saved_locally';
      }
    } catch (e) {
      debugPrint('Error occurred keyStroke : $e');
      return 'Unhandled Exception';
    }
  }
}
