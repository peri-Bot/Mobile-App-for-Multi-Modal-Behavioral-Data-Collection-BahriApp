import 'dart:math';
import 'package:flutter/material.dart';

import '../screens/game_screens/slide_game_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LevelButton extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final Function(int score) onLevelComplete;

  const LevelButton({super.key,
    required this.level,
    required this.isUnlocked,
    required this.onLevelComplete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUnlocked
          ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              level: level,
              onLevelComplete: onLevelComplete,
            ),
          ),
        );
      }
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: isUnlocked
              ? Text(
            '$level',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
              : const Icon(Icons.lock, color: Colors.white, size: 40),
        ),
      ),
    );
  }
}




class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> storeBiometricData(int level, int score, List<Map<String, dynamic>> biometricData) async {
    try {
      // Create a new document with a unique ID for each game session
      DocumentReference sessionDoc = _firestore.collection('Swipe_game_data').doc();

      // Set the session-level data
      await sessionDoc.set({
        'level': level,
        'score': score,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add biometric data as a subcollection within the session document
      for (var data in biometricData) {
        await sessionDoc.collection('biometricData').add(data);
      }

      print('Biometric data stored successfully in Firestore!');
    } catch (e) {
      print('Failed to store biometric data in Firestore: $e');
    }
  }
}



class DataCollectionService {
  double calculateSwipePathStraightness(double initialX, double initialY, double endX, double endY) {
    double straightDistance = sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
    double actualDistance = (endX - initialX).abs() + (endY - initialY).abs();
    return straightDistance / actualDistance;
  }

  double calculateSwipeAngle(double initialX, double initialY, double endX, double endY) {
    return atan2(endY - initialY, endX - initialX) * (180 / pi);
  }

  double calculateSwipeSpeed(double distance, double duration) {
    return distance / duration;
  }

  double calculateSwipeAcceleration(double speed, double duration) {
    return speed / duration;
  }

  double calculateSwipeJerk(double acceleration, double duration) {
    return acceleration / duration;
  }

  double calculateSwipeDistance(double initialX, double initialY, double endX, double endY) {
    return sqrt(pow(endX - initialX, 2) + pow(endY - initialY, 2));
  }

  double calculateSwipeDuration(int startTime, int endTime) {
    return (endTime - startTime) / 1000.0; // convert milliseconds to seconds
  }
}

