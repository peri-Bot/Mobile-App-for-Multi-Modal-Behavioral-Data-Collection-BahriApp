import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../screens/game_screens/slide_game_screen.dart';

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


class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.reference();

  void storeBiometricData(int level, int score, List<Map<String, dynamic>> biometricData) {
    // Create a unique ID for each game session
    String sessionId = DateTime.now().millisecondsSinceEpoch.toString();

    _database.child('game_sessions').child(sessionId).set({
      'level': level,
      'score': score,
      'biometricData': biometricData,
    }).then((_) {
      print('Biometric data stored successfully!');
    }).catchError((error) {
      print('Failed to store biometric data: $error');
    });
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

