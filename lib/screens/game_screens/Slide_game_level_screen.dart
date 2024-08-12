import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../../services/slide_game_services.dart';


class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  _LevelSelectionScreenState createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  final List<bool> _levelsUnlocked = [true, false, false, false, false, false]; // More levels

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Level Selection'),
        backgroundColor: Colors.grey,
        elevation: 10,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText(
                'Select Level',
                textStyle: const TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
                //duration: Duration(seconds: 2),
              ),
            ],
            repeatForever: true,
            isRepeatingAnimation: true,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: List.generate(_levelsUnlocked.length, (index) {
                  return LevelButton(
                    level: index + 1,
                    isUnlocked: _levelsUnlocked[index],
                    onLevelComplete: (score) {
                      setState(() {
                        if (score >= 2 && index + 1 < _levelsUnlocked.length) {
                          _levelsUnlocked[index + 1] = true;
                        }
                      });
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
