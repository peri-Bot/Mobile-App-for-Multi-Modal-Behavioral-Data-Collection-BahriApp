import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bahri_app/models/user.dart';
import 'firestore.dart';

class UserServices {
  late final User newUser;
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
    FirestoreServive firestoreServive = FirestoreServive();
    firestoreServive.AddUser(
        newUser.id,
        newUser.firstName,
        newUser.lastName,
        newUser.dOB,
        newUser.gender,
        newUser.userName,
        newUser.email,
        newUser.skillLevel,
        newUser.password);
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
}
