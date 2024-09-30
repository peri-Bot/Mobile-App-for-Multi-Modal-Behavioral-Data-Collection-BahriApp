// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:bahri_app/models/user.dart';

import 'firestore.dart';

class TeamsServices {
  final _secureStorage = const FlutterSecureStorage();
  final String? teamName;
  final String? teamDescription;
  final String? adminUid;
  TeamsServices({
    this.teamName,
    this.teamDescription,
    this.adminUid,
  });

  Future<String> createTeamDartFrog(BuildContext context) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail';
    final url = Uri.parse(
        'http://15.184.243.127:8080/create_team'); // Use your Dart Frog server address
    // debugPrint("ipgiven");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamAdminID': adminUid,
          'teamName': teamName,
          'teamDescription': teamDescription,
          'created_at': DateTime.timestamp().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        debugPrint('Team Created successfully');
        return 'sucess';
      } else {
        // Handle error
        debugPrint('Failed to create team: ${response.body}');
        return 'fail';
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
      return 'fail';
    }
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
}
