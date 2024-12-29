import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");
  final DocumentReference idTracker =
      FirebaseFirestore.instance.collection("config").doc("user_id_tracker");

  Future<void> addUser(
    String firstName,
    String lastName,
    DateTime dOB,
    String gender,
    String userName,
    String skillLevel,
    String password,
  ) async {
    // Start a transaction to safely get and increment the last user ID
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the currednt user ID value
      DocumentSnapshot snapshot = await transaction.get(idTracker);

      if (!snapshot.exists) {
        // If the document doesn't exist, create it with an initial value of 0
        transaction.set(idTracker, {"last_user_id": 0});
        snapshot = await transaction.get(idTracker);
      }

      // Increment the last user ID by 1
      int newUserId = snapshot.get("last_user_id") + 1;

      // Update the last_user_id in the database
      transaction.update(idTracker, {"last_user_id": newUserId});

      // Use the newUserId as the document ID for the new user
      String userId = newUserId.toString();

      // Set the new user's data
      transaction.set(users.doc(userId), {
        "id": newUserId,
        "firstName": firstName,
        "lastName": lastName,
        "dateOfBirth": dOB,
        "gender": gender,
        "userName": userName,
        "skillLevel": skillLevel,
        "password": password,
      });
    });
  }
}
