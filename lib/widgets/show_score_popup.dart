import 'package:flutter/material.dart';

class ShowScorePopup extends StatelessWidget {
  const ShowScorePopup({
    super.key,
    this.radius = 10,
    required this.score,
    required this.highScore,
  });

  final double radius;
  final int score;
  final int highScore;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Game Over",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  height: 11,
                ),
                Text(
                  'Score: $score',
                  style: TextStyle(
                    fontSize: 16,
                    color: score >= highScore ? Colors.green : Colors.red,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'HighScore: 25',
                  style: TextStyle(
                    fontSize: 16,
                    //fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  alignment: Alignment.center,
                  height: 35,
                  width: 250,
                  child: const Text(
                    "Go Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 11,
          ),
        ],
      ),
    );
  }
}
