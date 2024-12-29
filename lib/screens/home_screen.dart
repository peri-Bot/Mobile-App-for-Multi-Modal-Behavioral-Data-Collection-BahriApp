import 'package:bahri_app/screens/game_screens/games_list_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: FractionallySizedBox(
            widthFactor: 0.8,
            heightFactor: 0.8,
            child: Column(
              children: [
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                Container(
                  height: 75,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                      ]),
                  child: SizedBox.expand(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white, // Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                        padding: EdgeInsets.zero, // Remove any default padding
                      ),
                      child: const Text(
                        'Progress',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "assets/fonts/Poppins.ttf",
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                      ],
                    ),
                    // child: SizedBox.expand(
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //             const KeyStrokeLevelScreen()));
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       foregroundColor: Colors.black,
                    //       backgroundColor: Colors.white, // Text color
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(11),
                    //       ),
                    //       padding: EdgeInsets.zero, // Remove any default padding
                    //     ),
                    //     child: const Text(
                    //       'Play Game',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    // fontSize: 16,
                    // fontFamily: "assets/fonts/Poppins.ttf",
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    child: SizedBox.fromSize(
                      //size: const Size(300, 150), // large rectangular button size
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(11), // rounded rectangle
                        child: Material(
                          color: const Color.fromARGB(
                              255, 255, 255, 255), // button color
                          child: InkWell(
                            //splashColor: Colors.green, // splash color
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const GamesListScreen()));
                            }, // button pressed
                            child: Stack(
                              children: <Widget>[
                                // First Icon at top left, tilted
                                Positioned(
                                  top: -40,
                                  left: 0,
                                  child: Transform.rotate(
                                    angle: -0.6, // tilt angle in radians
                                    child: const Icon(Icons.gamepad,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 15.0,
                                              offset: Offset(6, 2.0))
                                        ],
                                        size: 150,
                                        color:
                                            Color.fromARGB(255, 101, 101, 101)),
                                  ),
                                ),
                                // Second Icon at top right, tilted
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Transform.rotate(
                                    angle: -0.8, // tilt angle in radians
                                    child: const Icon(Icons.sports_esports,
                                        size: 100,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 15.0,
                                              offset: Offset(6, 2.0))
                                        ],
                                        color: Color.fromARGB(255, 43, 42, 42)),
                                  ),
                                ),
                                // Positioned(
                                //   top: 70,
                                //   right: 80,
                                //   child: Transform.rotate(
                                //     angle: -0.4, // tilt angle in radians
                                //     child: const Icon(Icons.sports_esports,
                                //         size: 60,
                                //         shadows: <Shadow>[
                                //           Shadow(
                                //               color: Colors.black45,
                                //               blurRadius: 15.0,
                                //               offset: Offset(6, 2.0))
                                //         ],
                                //         color: Color.fromARGB(255, 54, 53, 53)),
                                //   ),
                                // ),
                                // Third Icon at bottom left, tilted
                                Positioned(
                                  bottom: 20,
                                  left: 20,
                                  child: Transform.rotate(
                                    angle: 0.2, // tilt angle in radians
                                    child: const Icon(Icons.extension,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 15.0,
                                              offset: Offset(6, 2.0))
                                        ],
                                        size: 40,
                                        color: Color.fromARGB(255, 0, 0, 0)),
                                  ),
                                ),
                                Positioned(
                                  bottom: 40,
                                  left: 80,
                                  child: Transform.rotate(
                                    angle: 0.5, // tilt angle in radians
                                    child: const Icon(Icons.smart_toy,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 15.0,
                                              offset: Offset(6, 2.0))
                                        ],
                                        size: 60,
                                        color: Color.fromARGB(255, 54, 53, 53)),
                                  ),
                                ),
                                // Fourth Icon at bottom right, tilted
                                Positioned(
                                  bottom: 20,
                                  right: 20,
                                  child: Transform.rotate(
                                    angle: -0.2, // tilt angle in radians
                                    child: const Icon(Icons.videogame_asset,
                                        shadows: <Shadow>[
                                          Shadow(
                                              color: Colors.black45,
                                              blurRadius: 15.0,
                                              offset: Offset(6, 2.0))
                                        ],
                                        size: 90,
                                        color:
                                            Color.fromARGB(255, 101, 101, 101)),
                                  ),
                                ),
                                // Center text
                                const Center(
                                  child: Text(
                                    "Play Games",
                                    style: TextStyle(
                                      //fontSize: 24,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      fontFamily: "assets/fonts/Poppins.ttf",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
