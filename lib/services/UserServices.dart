import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:bahri_app/models/user.dart';

import 'firestore.dart';

class UserServices {
  late final User newUser;
  final _secureStorage = const FlutterSecureStorage();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    } else if (value.length < 4) {
      return 'Emmail must be at least 4 characters long';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters long';
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
    required String email,
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
      email: email,
      skillLevel: skillLevel,
      password: password,
      progress: progress,
      teamId: teamId,
    );
  }

  Future<void> registerUser() async {
    FirestoreService firestoreService = FirestoreService();
    firestoreService.addUser(
        newUser.firstName,
        newUser.lastName,
        newUser.dOB,
        newUser.gender,
        newUser.userName,
        newUser.email,
        newUser.skillLevel,
        newUser.password);
  }

  Future<String> registerUserDartFrog(BuildContext context) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail';
    final url = Uri.parse(
        'http://15.184.243.127:8080/register_user'); // Use your Dart Frog server address
    print("ipgiven");

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
          'email': newUser.email,
          'skillLevel': newUser.skillLevel,
          'password': newUser.password,
          'created_at': DateTime.timestamp().toIso8601String(),
        }),
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

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  Future<String> loginDartFrog(String email, String password) async {
    bool isOnline = await isConnectedToInternet();
    if (!isOnline) return 'fail';
    print("User is online: sending data");

    try {
      final response = await http.post(
        Uri.parse('http://15.184.243.127:8080/login'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        String token = responseBody['idToken'];
        String uid = responseBody['uid'];

        // Store the token securely using flutter_secure_storage
        await _secureStorage.write(key: 'authToken', value: token);
        await _secureStorage.write(key: 'uid', value: uid);

        print("Login Successful: Token stored securely");
        return 'sucess';
      } else {
        return 'fail;';
      }
    } catch (e) {
      print("Error during login: $e");
      return 'fail';
    }
  }

  // Method to validate user input fields
  String validateUserInput({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? rePassword,
    String? birthdate,
    String? gender = "-1",
    String? skillLevle = "-1",
  }) {
    String error = "";
    if (email != null) {
      if (email.isEmpty) {
        error = 'Email cannot be empty';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        error = 'Invalid email format';
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
      } else if (password.length < 8) {
        error = 'Password must be at least 8 characters long';
      } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
        error = 'Password must contain at least one uppercase letter';
      } else if (password.contains(' ')) {
        error = 'Password cannot contain spaces';
      } else if (!RegExp(r'[a-z]').hasMatch(password)) {
        error = 'Password must contain at least one lowercase letter';
      } else if (!RegExp(r'[0-9]').hasMatch(password)) {
        error = 'Password must contain at least one number';
      } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        error = 'Password must contain at least one special character';
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
    await _secureStorage.delete(key: 'authToken');
    await _secureStorage.delete(key: 'uid');

    print("User logged out: Token deleted");
  }
}
