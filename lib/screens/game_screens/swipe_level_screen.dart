import 'package:flutter/material.dart';
import 'swipe_game_screen.dart'; // Import your game screen here

class LevelSelectionScreen extends StatelessWidget {
  final String userId; // Pass userId to keep consistency

  LevelSelectionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Swipe Game'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
            // Add the Select Level text
            const Text(
              'Select Level',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40), // Add spacing between the text and buttons

            // The level selection buttons
            _buildLevelButton(context, 'Easy', 1),
            const SizedBox(height: 20), // Add spacing between the buttons
            _buildLevelButton(context, 'Medium', 2),
            const SizedBox(height: 20), // Add spacing between the buttons
            _buildLevelButton(context, 'Hard', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String levelName, int level) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(
              level: level, // Pass the selected level
              userId: userId, // Pass the userId
              onLevelComplete: (score) {
                // Define what to do when level is complete
                print('Level complete with score: $score');
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0), // Wider padding
        child: Container(
          width: double.infinity, // Make the button full width
          height: 80, // Adjust the height of the boxes
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(20), // Adjust border radius
            border: Border.all(
              color: Colors.black, // Add a black border
              width: 3, // Adjust the border thickness
            ),
          ),
          child: Center(
            child: Text(
              levelName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
