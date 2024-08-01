import 'dart:ffi';

import 'package:bahri_app/models/user.dart';

class UserServices {
  // Method to create a new user
  User createUser({
    required double id,
    required String firstName,
    required String lastName,
    required DateTime dOB,
    required Char gender,
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

  // Method to validate user input fields
  String validateUserInput({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? birthdate,
    String? gender = "-1",
  }) {
    String error = "";
    if (email != null) {
      if (email.isEmpty) {
        error = 'Email cannot be empty';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        error = 'Invalid email format';
      }
      return error;
    }
    if (firstName != null) {
      if (firstName.isEmpty) {
        error = 'First name cannot be empty';
      } else if (RegExp(r'\d').hasMatch(firstName)) {
        error = 'First name cannot contain a digit';
      } else if (firstName.length <= 2) {
        error = 'First name must be at least 3 characters long';
      }
      return error;
    }
    if (lastName != null) {
      if (lastName.isEmpty) {
        error = 'Last name cannot be empty';
      } else if (RegExp(r'\d').hasMatch(lastName)) {
        error = 'First name cannot contain a digit';
      } else if (lastName.length <= 2) {
        error = 'Last name must be at least 3 characters long';
      }
      return error;
    }
    if (birthdate != null) {
      if (birthdate.isEmpty) {
        error = 'Chose a valid Birthdate';
      }
      return error;
    }
    if (gender != "-1") {
      if (gender == null) {
        error = 'Chose male or female';
      }
      return error;
    }

    if (password != null) {
      if (password.isEmpty) {
        error = 'Password cannot be empty';
      } else if (password.length < 6) {
        error = 'Password must be at least 6 characters long';
      }
      return error;
    }

    return error;
  }
}
