import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServive {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");
  Future<void> AddUser(
    double id,
    String firstName,
    String lastName,
    DateTime dOB,
    String gender,
    String userName,
    String email,
    String skillLevel,
    String password,
  ) {
    return users.add({
      "id": id,
      "firstName": firstName,
      "lastName": lastName,
      "dateOfBirth": dOB,
      "gender": gender,
      "userNamae": userName,
      "email": email,
      "skillLevel": skillLevel,
      "password": password,
    });
  }
}
