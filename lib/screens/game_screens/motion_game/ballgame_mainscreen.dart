import 'package:flutter/material.dart';
import 'ball_game.dart';

class GyroScreen extends StatelessWidget {
  const GyroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ball Navigation game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ready to play?',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 8,
                ),
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15), // Ensure image follows the border's rounded corners
                child: Image.asset(
                  'assets/Motion_Game/ball.gif',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Move the ball through the obstacles toward the goal by titlting you phone in differnt direction '
                  'and reach the goal',
              style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle: const TextStyle(fontSize: 24),
                backgroundColor: Colors.white,
                foregroundColor: Colors.teal,
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BallGame()),
                );
              },
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    ));
  }
}
