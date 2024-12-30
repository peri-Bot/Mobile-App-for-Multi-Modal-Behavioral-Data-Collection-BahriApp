import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as htp;

class FirestoreService {
  String? uid;
  Future<void> fetchUserId() async {
    uid = await getUserId();
    debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
  }

  get http => null;

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
    await Hive.openBox('offlineSwipeData');
  }

  Future<String> storeSwipeDataDartFrog(
    String userId,
    int level,
    int score,
    List<Map<String, dynamic>> swipeData,
    int correct,
    int wrong,
    DateTime startTime,
  ) async {
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    bool isOnline = await isConnectedToInternet();

    final body = jsonEncode({
      'userId': userId,
      'sessionId': sessionId,
      'level': level,
      'score': score,
      'startTime': startTime.toIso8601String(),
      'endTime': DateTime.now().toIso8601String(),
      'CorrectCount': correct,
      'WrongCount': wrong,
      'swipeData': swipeData,
    });
    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineSwipeData');
      await box.add(body);
      debugPrint('Swipe Data saved locally (offline).');
      return 'Swipe Data saved_locally';
    }
    final url = Uri.parse('http://15.184.243.127:8080/collect_swipe_data');

    try {
      // Call http.post, which ensures that the import is used
      final response = await htp.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        debugPrint('Swipe data sent to server successfully!');
        return ('Swipe data sent to server successfully!');
      } else {
        debugPrint('Failed to send swipe data: ${response.body}');
        var box = Hive.box('offlineSwipeData');
        await box.add(body);
        debugPrint('Swipe Data saved locally (offline).');
        return 'Swipe Data saved_locally';
      }
    } catch (e) {
      debugPrint('Error occurred while sending swipe data: $e');
      var box = Hive.box('offlineSwipeData');
      await box.add(body);
      debugPrint('Swipe Data saved locally (offline).');
      return 'Swipe Data saved_locally';
    }
  }

  // Update the session end time
}
