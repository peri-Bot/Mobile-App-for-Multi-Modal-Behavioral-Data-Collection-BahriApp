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
}
