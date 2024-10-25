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
  String? uid;
  Future<void> fetchUserId() async {
    uid = await getUserId();
    debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
  }

  TeamsServices.empty()
      : teamName = null,
        teamDescription = null,
        adminUid = null;

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
        //final responseBody = json.decode(response.body);

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

  Future<List<Map<String, dynamic>>> getTeams() async {
    try {
      final response = await http.get(Uri.parse(
          'http://15.184.243.127:8080/get_teams_list')); // Adjust endpoint

      if (response.statusCode == 200) {
        // Decode the JSON response
        final jsonResponse = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(jsonResponse['teams']);
      } else {
        throw Exception('Failed to load teams');
      }
    } catch (e) {
      debugPrint('Error fetching teams: $e');
      throw Exception('Failed to fetch teams');
    }
  }

  Future<String> submitJoinRequest(String teamID) async {
    try {
      final response = await http.post(
        Uri.parse('http://15.184.243.127:8080/join_team'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userID': uid,
          'teamID': teamID,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Satuts Code 200 for Join Team');
        return 'sucess';
      } else {
        debugPrint('Satuts Code not 200 for Join Team');

        return 'fail';
      }
    } catch (e) {
      debugPrint('Error Joining teams $e');
      throw Exception('Failed to join team');
    }
  }

  Future<Map<String, dynamic>> checkUserStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://15.184.243.127:8080/check_team_status?uid=$uid'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle possible null values for 'inTeam' and 'pendingRequest'
        final bool inTeam = data['inTeam'] ?? false; // Default to false if null
        final bool pendingRequest =
            data['pendingRequest'] ?? false; // Default to false if null

        if (inTeam) {
          debugPrint("User is in team");
          return {
            'status': 'inTeam',
            'teamID': data['teamID'],
            'isManager': data['isManager'] ?? false,
          };
        } else if (pendingRequest) {
          if (data['pendingJoinRequest']?['status'] == 'rejected') {
            // Handle rejected status
            return {
              'status': 'rejected',
              'teamID': data['pendingJoinRequest']['teamID']
            };
          }
          return {'status': 'pendingRequest'};
        } else {
          return {'status': 'notInATeam'};
        }
      } else {
        return {'status': 'error', 'message': 'Failed to check status'};
      }
    } catch (e) {
      debugPrint('Error checking user status teams $e');
      return {'status': 'error', 'message': 'Failed to check user status'};
    }
  }

  Future<String> rejectJoinRequest(String teamID, String userID) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://15.184.243.127:8080/reject_join_request'), // Adjust to your endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamID': teamID,
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {
        return 'success';
      } else {
        return 'fail';
      }
    } catch (e) {
      debugPrint('Error rejecting join request: $e');
      return 'fail';
    }
  }

  Future<String> acceptJoinRequest(String teamID, String userID) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://15.184.243.127:8080/accept_join_request'), // Adjust to your endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamID': teamID,
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {
        return 'success';
      } else {
        return 'fail';
      }
    } catch (e) {
      debugPrint('Error accepting join request: $e');
      return 'fail';
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String teamID) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://15.184.243.127:8080/get_pending_requests?teamID=$teamID'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pendingRequests =
            List<Map<String, dynamic>>.from(data['pendingRequests']);
        return pendingRequests;
      } else {
        throw Exception('Failed to fetch pending requests');
      }
    } catch (e) {
      debugPrint('Error fetching pending requests: $e');
      throw Exception('Failed to fetch pending requests');
    }
  }

  Future<List<Map<String, dynamic>>> getTeamMembers(String teamID) async {
    try {
      final response = await http.get(
        Uri.parse('http://15.184.243.127:8080/get_team_members?teamID=$teamID'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final members = List<Map<String, dynamic>>.from(data['members']);
        return members;
      } else {
        throw Exception('Failed to fetch team members');
      }
    } catch (e) {
      debugPrint('Error fetching team members: $e');
      throw Exception('Failed to fetch team members');
    }
  }

  Future<String> kickOutMember(String teamID, String userID) async {
    try {
      final response = await http.post(
        Uri.parse('http://15.184.243.127:8080/kick_out_member'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'teamID': teamID,
          'userID': userID,
        }),
      );

      if (response.statusCode == 200) {
        return 'success';
      } else {
        return 'fail';
      }
    } catch (e) {
      debugPrint('Error kicking out member: $e');
      return 'fail';
    }
  }
}
