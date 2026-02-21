import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import 'swipe_game_screen.dart'; // Import your game screen here

class LevelSelectionScreen extends StatelessWidget {
  // Pass userId to keep consistency

  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading:
            true, // This makes sure the back button appears
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(183, 153, 255, 1),
                  Color.fromRGBO(172, 188, 255, 1),
                  Color.fromRGBO(174, 226, 255, 1),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                            height: 55), // Add spacing to push content down

                        // Title (Pic Pick)
                        // const Text(
                        //   'Swipe Game',
                        //   style: TextStyle(
                        //     fontSize: 40,
                        //     fontWeight: FontWeight.bold,
                        //     color: Colors.white,
                        //     shadows: [
                        //       Shadow(
                        //         offset: Offset(5.0, 5.0),
                        //         blurRadius: 3.0,
                        //         color: Colors.black,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const StrokeText(
                          text: 'Swipe Game',
                          textStyle: TextStyle(
                            fontFamily: "assets/fonts/Poppins-Regular.ttf",
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                          strokeColor: Color.fromARGB(255, 255, 255, 255),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 36),

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

                        // _buildLevelButton(context, 'Easy', 1, 'HighScore:'),
                        // const SizedBox(height: 46),
                        // _buildLevelButton(context, 'Medium', 2, 'HighScore:'),
                        // const SizedBox(height: 46),
                        // _buildLevelButton(context, 'Hard', 3, 'HighScore:'),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => GameScreen(
                        //           level: 1, // Pass the selected level
                        //           // Pass the userId
                        //           onLevelComplete: (score) {
                        //             debugPrint(
                        //                 'Level complete with score: $score');
                        //           },
                        //         ),
                        //       ),
                        //     );
                        //   },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor:
                        //         const Color.fromARGB(255, 255, 255, 255),
                        //     minimumSize: const Size(double.infinity, 75),
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(10),
                        //     ),
                        //   ),
                        //   child: const Center(
                        //     child: Text(
                        //       'Easy',
                        //       style: TextStyle(
                        //         fontSize: 21,
                        //         color: Color.fromARGB(255, 0, 0, 0),
                        //         fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                        //         //fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 46),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  level: 2, // Pass the selected level
                                  // Pass the userId
                                  onLevelComplete: (score) {
                                    debugPrint(
                                        'Level complete with score: $score');
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            minimumSize: const Size(double.infinity, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Left or Right ',
                              style: TextStyle(
                                fontSize: 21,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 46),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GameScreen(
                                  level: 3, // Pass the selected level
                                  // Pass the userId
                                  onLevelComplete: (score) {
                                    debugPrint(
                                        'Level complete with score: $score');
                                  },
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            minimumSize: const Size(double.infinity, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Up or Down',
                              style: TextStyle(
                                fontSize: 21,
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                                //fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
              // Pass the userId
              onLevelComplete: (score) {
                debugPrint('Level complete with score: $score');
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
