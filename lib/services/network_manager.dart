import 'dart:convert';
import 'package:flutter/material.dart';
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
    await Hive.openBox('offlineKeystrokeFreeTextData');
    await Hive.openBox('offlineKeystrokePasswordTextData');
    await Hive.openBox('offlineHandwritingData');
    await Hive.openBox('offlineAcceloData');
    await Hive.openBox('offlineGyroData');
    await Hive.openBox('offlineTapData');
    await Hive.openBox('offlineSwipeData');
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
        uploadPendingSwipeData();
        uploadPendingKeystrokeFreeTextData();
        uploadPendingPasswordFreeTextData();
        uploadPendingHandwitingData();
        uploadPendingGyroData();
        uploadPendingAcceloData();
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

  Future<void> uploadPendingGyroData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineGyroData');
    if (box.isEmpty) {
      debugPrint('No pending keystroke data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url = Uri.parse('http://15.184.243.127:8080/collect_gyro_data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending offlineGyroData data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint(
              'Failed to upload pending offlineGyroData data: ${response.body}');
        }
      } catch (e) {
        debugPrint(
            'Error occurred while uploading pending offlineGyroData data: $e');
      }
    }
  }

  Future<void> uploadPendingAcceloData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineAcceloData');
    if (box.isEmpty) {
      debugPrint('No pending offlineAcceloData data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url =
          Uri.parse('http://15.184.243.127:8080/collect_accelerometer_data');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending Accelo data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint('Failed to upload pending Accelo data: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred while uploading pending Accelo data: $e');
      }
    }
  }

  Future<void> uploadPendingKeystrokeFreeTextData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineKeystrokeFreeTextData');
    if (box.isEmpty) {
      debugPrint('No pending keystroke data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url = Uri.parse(
          'http://15.184.243.127:8080/collect_keystroke_freetext_data');
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
              'Failed to upload pending freetext keystroke data: ${response.body}');
        }
      } catch (e) {
        debugPrint(
            'Error occurred while uploading pending freetext keystroke data: $e');
      }
    }
  }

  Future<void> uploadPendingPasswordFreeTextData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineKeystrokePasswordTextData');
    if (box.isEmpty) {
      debugPrint('No pending keystroke data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url = Uri.parse(
          'http://15.184.243.127:8080/collect_keystroke_passwordtext_data');
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
              'Failed to upload pending Password keystroke data: ${response.body}');
        }
      } catch (e) {
        debugPrint(
            'Error occurred while uploading pending Password keystroke data: $e');
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

  Future<void> uploadPendingSwipeData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineSwipeData');
    if (box.isEmpty) {
      debugPrint('No pending Swipe data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url = Uri.parse('http://15.184.243.127:8080/collect_swipe_data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending Swipe data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint('Failed to upload pending Swipe data: ${response.body}');
        }
      } catch (e) {
        debugPrint('Error occurred while uploading pending Swipe data: $e');
      }
    }
  }

  Future<void> uploadPendingHandwitingData() async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return; // No need to proceed if still offline

    var box = Hive.box('offlineHandwritingData');
    if (box.isEmpty) {
      debugPrint('No pending Handwriting data to upload.');
      return;
    }

    for (var key in box.keys) {
      var requestData = box.get(key);
      final url =
          Uri.parse('http://15.184.243.127:8080/collect_Handwriting_data');
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          debugPrint('Pending handwriting data uploaded successfully.');
          await box.delete(key); // Delete local data after successful upload
        } else {
          debugPrint(
              'Failed to upload pending handwriting data: ${response.body}');
        }
      } catch (e) {
        debugPrint(
            'Error occurred while uploading pending handwriting data: $e');
      }
    }
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);
  }
}
