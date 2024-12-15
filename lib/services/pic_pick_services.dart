import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

class TapDataCollectionService {
  int calculateTapDuration(int tapPressTime, int tapReleaseTime) {
    return tapReleaseTime - tapPressTime;
  }

  int calculateTapLatency(int screenResponseTime, int tapPressTime) {
    return screenResponseTime - tapPressTime;
  }

  int calculateTapSpeed(int tapPressTime, int tapReleaseTime) {
    return 1 ~/ calculateTapDuration(tapPressTime, tapReleaseTime);
  }

  double calculateTapDrift(
      Offset intededTapLocation, Offset actualTapLocation) {
    return sqrt(pow(intededTapLocation.dx - actualTapLocation.dx, 2) +
        pow(intededTapLocation.dx - actualTapLocation.dy, 2));
  }

  double calculateTapDistance(
      Offset globalIntialLocation, Offset globalFinalLocation) {
    return (globalFinalLocation - globalIntialLocation).distance;
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
    await Hive.openBox('offlineTapData');
  }

  Future<String> saveTapData(
      List<Map<String, dynamic>> tapData, Map<String, dynamic> gameInfo) async {
    bool isOnline = await isConnectedToInternet();
    //if (!isOnline) return 'fail';

    final Map<String, dynamic> requestData = {
      'gameInfo': gameInfo,
      'tapData': tapData,
    };

    debugPrint('Request Data:');
    debugPrint('Game Info: ${requestData['gameInfo']}');
    debugPrint('Tap Data: ${requestData['tapData']}');

    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineTapData');
      await box.add(requestData);
      debugPrint('Tap Data saved locally (offline).');
      return 'Tap Data saved_locally';
    }
    final url = Uri.parse(
        'http://15.184.243.127:8080/collect_tap_data'); // Use your Dart Frog server address

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        debugPrint('Tap Data Successfully added');
        return 'success';
      } else {
        // Handle error
        debugPrint('Could not add tap data: ${response.body}');
        var box = Hive.box('offlineTapData');
        await box.add(requestData);
        debugPrint('Tap Data saved locally (offline).');
        return 'Tap Data saved_locally';
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      var box = Hive.box('offlineTapData');
      await box.add(requestData);
      debugPrint('Tap Data saved locally (offline).');
      return 'Tap Data saved_locally';
    }
  }
}
