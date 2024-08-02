import 'package:flutter/material.dart';
import 'package:bahri_app/models/user.dart';

class UserServices {
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
      password: password,
      progress: progress,
      teamId: teamId,
    );
  }
}
