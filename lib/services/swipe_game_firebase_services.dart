
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  void storeSwipeData(String userId, int level, int score, List<Map<String, dynamic>> swipeData) {
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    _firestore.collection('users').doc(userId).set({
      'swipeData': {
        sessionId: {
          'level': level,
          'score': score,
          'startTime': Timestamp.now(),
          'endTime': null,  // this update later yes yes yes
          'Swipe data': swipeData,
        }
      }
    }, SetOptions(merge: true)).then((_) {
      print('Swipe data stored successfully in Firestore!');
    }).catchError((error) {
      print('Failed to store swipe data in Firestore: $error');
    });
  }

  // Update the session end time
  void updateSessionEndTime(String userId, String sessionId) {
    _firestore.collection('users').doc(userId).set({
      'swipeData': {
        sessionId: {
          'endTime': Timestamp.now(),
        }
      }
    }, SetOptions(merge: true)).then((_) {
      print('Session end time updated successfully in Firestore!');
    }).catchError((error) {
      print('Failed to update session end time in Firestore: $error');
    });
  }
}