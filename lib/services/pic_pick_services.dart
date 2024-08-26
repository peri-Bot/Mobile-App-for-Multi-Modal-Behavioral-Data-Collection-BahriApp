import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TapDataCollectionService {
  double calculateTapDuration(double tapPressTime, double tapReleaseTime) {
    return tapReleaseTime - tapPressTime;
  }

  double calculateTapLatency(double screenResponseTime, double tapPressTime) {
    return screenResponseTime - tapPressTime;
  }

  double calculateTapSpeed(double tapPressTime, tapReleaseTime) {
    return 1 / calculateTapDuration(tapPressTime, tapReleaseTime);
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

  Future<String> saveTapData(List<Map<String, dynamic>> tapData) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail';
    final url = Uri.parse(
        'http://15.184.243.127:8080/collect_tap_data'); // Use your Dart Frog server address
    print("ipgiven");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({tapData}),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        print('User registered successfully');
        return 'sucess';
      } else {
        // Handle error
        print('Failed to register user: ${response.body}');
        return 'fail';
      }
    } catch (e) {
      print('Error occurred: $e');
      return 'fail';
    }
  }
}
