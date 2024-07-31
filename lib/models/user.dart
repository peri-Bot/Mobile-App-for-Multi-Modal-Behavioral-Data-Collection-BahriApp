// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ffi';

class User {
  late double id;
  late String firstName;
  late String lastName;
  late DateTime dOB;
  late Char gender;
  late String email;
  late String password;
  late double progress;
  late double? teamId;
  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dOB,
    required this.gender,
    required this.email,
    required this.password,
    required this.progress,
    this.teamId,
  });

  User copyWith({
    double? id,
    String? firstName,
    String? lastName,
    DateTime? dOB,
    Char? gender,
    String? email,
    String? password,
    double? progress,
    double? teamId,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dOB: dOB ?? this.dOB,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      password: password ?? this.password,
      progress: progress ?? this.progress,
      teamId: teamId ?? this.teamId,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, dOB: $dOB, gender: $gender, email: $email, password: $password, progress: $progress, teamId: $teamId)';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.dOB == dOB &&
        other.gender == gender &&
        other.email == email &&
        other.password == password &&
        other.progress == progress &&
        other.teamId == teamId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        firstName.hashCode ^
        lastName.hashCode ^
        dOB.hashCode ^
        gender.hashCode ^
        email.hashCode ^
        password.hashCode ^
        progress.hashCode ^
        teamId.hashCode;
  }
}
