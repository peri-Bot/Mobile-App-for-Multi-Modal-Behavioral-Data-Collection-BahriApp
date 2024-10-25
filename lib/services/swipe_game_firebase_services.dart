import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as htp;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

  void storeSwipeData(String userId, int level, int score,
      List<Map<String, dynamic>> swipeData) {
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    _firestore.collection('users').doc(userId).set({
      'swipeData': {
        sessionId: {
          'level': level,
          'score': score,
          'startTime': Timestamp.now(),
          'endTime': null, // this update later yes yes yes
          'Swipe data': swipeData,
        }
      }
    }, SetOptions(merge: true)).then((_) {
      print('Swipe data stored successfully in Firestore!');
    }).catchError((error) {
      print('Failed to store swipe data in Firestore: $error');
    });
  }

  Future<void> storeSwipeDataDartFrog(
    String userId,
    int level,
    int score,
    List<Map<String, dynamic>> swipeData,
  ) async {
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final url = Uri.parse('http://15.184.243.127:8080/collect_swipe_data');

    final body = jsonEncode({
      'userId': userId,
      'sessionId': sessionId,
      'level': level,
      'score': score,
      'startTime': DateTime.now().toIso8601String(),
      'swipeData': swipeData,
    });

    try {
      // Call http.post, which ensures that the import is used
      final response = await htp.post(
        url,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Swipe data sent to server successfully!');
      } else {
        print('Failed to send swipe data: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while sending swipe data: $e');
    }
  }

  // Update the session end time
  void updateSessionEndTime(String userId, String sessionId) {
    _firestore.collection('users').doc(userId).set({
      'swipeData': {
        sessionId: {
          'endTime': Timestamp.now(),
        }
      }
    }, SetOptions(merge: true)).then((_) {
      print('Session end time updated successfully in Firestore!');
    }).catchError((error) {
      print('Failed to update session end time in Firestore: $error');
    });
  }
}
