import 'dart:math';
import 'package:flutter/material.dart';

import '../screens/game_screens/swipe_game_screen.dart';
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
              onLevelComplete: onLevelComplete, userId: '1',
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






