import 'package:flutter/material.dart';
import 'swipe_game_screen.dart'; // Import your game screen here

class LevelSelectionScreen extends StatelessWidget {
  final String userId; // Pass userId to keep consistency

  LevelSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: true, // This makes sure the back button appears
    ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 10), // Add spacing to push content down

            // Title (Pic Pick)
            const Text(
              'Swipe Game',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(5.0, 5.0),
                    blurRadius: 3.0,
                    color: Colors.black,
                  ),
                ],
              ),
            ),

            // Subtitle (Note)
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 40),
              child: Text(
                'Note: The game will start right when you choose a difficulty',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),

            // The level selection buttons with HighScore label
            _buildLevelButton(context, 'Easy', 1, 'HighScore:'),
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Medium', 2, 'HighScore:'),
            const SizedBox(height: 20),
            _buildLevelButton(context, 'Hard', 3, 'HighScore:'),
          ],
        ),
      ),
    );
  }

  // Modified _buildLevelButton function to include the "HighScore" text
  Widget _buildLevelButton(
      BuildContext context, String levelName, int level, String highScoreText) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              level: level, // Pass the selected level
              userId: userId, // Pass the userId
              onLevelComplete: (score) {
                print('Level complete with score: $score');
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: 2.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  levelName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Text(
                  highScoreText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
