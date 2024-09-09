import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeMotionData(Map<String, dynamic> gyroData) async {
    try {
      await _firestore.collection('users').doc('1').collection('motion_data').add(gyroData);
      print('Data stored successfully!');
    } catch (e) {
      print('Error storing data: $e');
    }
  }
}

