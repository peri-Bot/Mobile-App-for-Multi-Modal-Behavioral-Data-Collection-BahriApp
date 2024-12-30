import 'dart:async';
import 'dart:convert';

import 'package:bahri_app/services/enums.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;

import 'package:bahri_app/models/user.dart';

class UserServices {
  late final User newUser;
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username cannot be empty';
    } else if (value.length < 4) {
      return 'Username must be at least 4 characters long';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    } else if (value.length > 12) {
      return 'Username cant be more than 12 characters long';
    }
    return null;
  }

  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }

  // Method to create a new user
  User createUser({
    required double id,
    required String firstName,
    required String lastName,
    required DateTime dOB,
    required String gender,
    required String userName,
    required String skillLevel,
    required String password,
    double? progress,
    double? teamId,
  }) {
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      dOB: dOB,
      gender: gender,
      userName: userName,
      skillLevel: skillLevel,
      password: password,
      progress: progress,
      teamId: teamId,
    );
  }

  Future<String> registerUserDartFrog(BuildContext context) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail';
    final url = Uri.parse(
        'http://15.184.243.127:8080/api/v2/register_user'); // Use your Dart Frog server address
    debugPrint("ipgiven");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': newUser.firstName,
          'lastName': newUser.lastName,
          'dOB': newUser.dOB.toString(),
          'gender': newUser.gender,
          'userName': newUser.userName,
          'skillLevel': newUser.skillLevel,
          'password': newUser.password,
          'created_at': DateTime.timestamp().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        debugPrint('User registered successfully');
        return 'sucess';
      } else {
        // Handle error
        debugPrint('Failed to register user: ${response.body}');
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

  Future<String> loginDartFrog(String username, String password) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail not online';
    debugPrint("User is online: sending data");

    try {
      final response = await http.post(
        Uri.parse('http://15.184.243.127:8080/api/v2/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': username.trim(),
          'password': password.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        String token = responseBody['idToken'];
        String uid = responseBody['uid'];

        // Store the token securely using flutter_secure_storage
        await _secureStorage.write(key: 'authToken', value: token);
        await _secureStorage.write(key: 'uid', value: uid);
        if (responseBody['userProfile'] != null) {
          final userProfileBox = await Hive.openBox('userProfile');

          await userProfileBox.putAll({
            'dateOfBirth': responseBody['userProfile']['dateOfBirth'] ?? '',
            'firstName': responseBody['userProfile']['firstName'] ?? '',
            'gender': responseBody['userProfile']['gender'] ?? '',
            'lastName': responseBody['userProfile']['lastName'] ?? '',
            'skillLevel': responseBody['userProfile']['skillLevel'] ?? '',
            'userName': responseBody['userProfile']['userName'] ?? '',
          });
          await userProfileBox.close();
        }

        debugPrint("Login Successful: Token stored securely");
        return 'sucess';
      } else {
        return 'fail Server Error;';
      }
    } catch (e) {
      debugPrint("Error during login: $e");
      return 'fail unkown error';
    }
  }

  Future<UsernameCheckResult> checkUsernameAvailability(String username) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return UsernameCheckResult.error;

    debugPrint("User is online: checking username availability");

    try {
      final response = await http.post(
        Uri.parse(
            'http://15.184.243.127:8080/api/v2/check_username_availability'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': username.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        bool isTaken = responseBody['isTaken'] as bool;
        debugPrint(
            isTaken ? "Username is already taken." : "Username is available.");
        return isTaken
            ? UsernameCheckResult.usernameTaken
            : UsernameCheckResult.usernameAvailable;
      } else {
        debugPrint(
            "Error: Received status code ${response.statusCode} during username check.");
        return UsernameCheckResult.error;
      }
    } catch (e) {
      debugPrint("Error during username check: $e");
      return UsernameCheckResult.error;
    }
  }

  // Method to validate user input fields
  String validateUserInput({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? rePassword,
    String? birthdate,
    String? gender = "-1",
    String? skillLevle = "-1",
  }) {
    String error = "";
    //  if (username == null || username.isEmpty) {
    //   return 'Username cannot be empty';
    // } else if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(username)) {
    //   return 'Invalid username: Only letters and underscores are allowed';
    // }
    if (username != null) {
      if (username.isEmpty) {
        return 'Username cannot be empty';
      } else if (!RegExp(r'^[a-zA-Z_]+$').hasMatch(username)) {
        return 'Invalid username: Only letters and underscores are allowed';
      } else if (username.length <= 3) {
        error = 'Username must be at least 4 characters long';
      } else if (username.length > 12) {
        error = 'Username cant be more than 12 characters long';
      }
    } else if (firstName != null) {
      if (firstName.isEmpty) {
        error = 'First name cannot be empty';
      } else if (RegExp(r'\d').hasMatch(firstName) ||
          RegExp(r'\s').hasMatch(firstName) ||
          RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(firstName)) {
        error =
            'First name cannot contain a digit, white space or Special Characters';
      } else if (firstName.length <= 2) {
        error = 'First name must be at least 3 characters long';
      }
    } else if (lastName != null) {
      if (lastName.isEmpty) {
        error = 'Last name cannot be empty';
      } else if (RegExp(r'\d').hasMatch(lastName) ||
          RegExp(r'\s').hasMatch(lastName) ||
          RegExp(r'[!@#$%^&*(),.?"=;+:{"}|<>]').hasMatch(lastName)) {
        error =
            'last name cannot contain a digit, white space or Special Characters';
      } else if (lastName.length <= 2) {
        error = 'Last name must be at least 3 characters long';
      }
    } else if (birthdate != null) {
      if (birthdate.isEmpty) {
        error = 'Chose a valid Birthdate';
      }
    } else if (gender != "-1") {
      if (gender == null) {
        error = 'Chose male or female';
      }
    } else if (skillLevle != "-1") {
      if (skillLevle == null) {
        error = 'Chose your skill level';
      }
    } else if (password != null) {
      if (password.isEmpty) {
        error = 'Password cannot be empty';
      } else if (password.length < 6) {
        error = 'Password must be at least 6 characters long';
      } else {
        if (rePassword!.isEmpty) {
          error = 'Confirm Password cannot be empty';
        } else if (password != rePassword) {
          error = "Passwords Don't match";
        }
      }
    }

    return error;
  }

  void logout() async {
    await _secureStorage.deleteAll();
    final box = await Hive.openBox('userProfile');
    await box.clear();
    await box.close();

    debugPrint("User logged out: Token deleted");
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final box = await Hive.openBox('userProfile');

    final profile = {
      'dateOfBirth': box.get('dateOfBirth') ?? '',
      'firstName': box.get('firstName') ?? '',
      'gender': box.get('gender') ?? '',
      'lastName': box.get('lastName') ?? '',
      'skillLevel': box.get('skillLevel') ?? '',
      'userName': box.get('userName') ?? '',
    };

    await box.close();
    return profile;
  }
}
