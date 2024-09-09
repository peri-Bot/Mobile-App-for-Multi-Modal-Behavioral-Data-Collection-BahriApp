import 'package:bahri_app/screens/game_screens/motion_game/stepgame_mainscreen.dart';
import 'package:flutter/material.dart';

import '../../../services/game_card.dart';
import 'ballgame_mainscreen.dart';


class MotionGamesMain extends StatefulWidget {
  const MotionGamesMain({super.key});

  @override
  _MotionGamesMainState createState() => _MotionGamesMainState();
}

class _MotionGamesMainState extends State<MotionGamesMain> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Motion Games',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ListView(
          padding: const EdgeInsets.all(30.0),
          children: [
            const Text(
              "Challenges",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GameCard(
              title: 'Step Score',
              description: 'Walk and score based on the accuracy of your steps.',
              onPlayPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartScreen()),
                );
              },
            ),
            GameCard(
              title: 'Gyroscope Challenge',
              description: 'Test your balance with gyroscope-based challenges.',
              onPlayPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GyroScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
