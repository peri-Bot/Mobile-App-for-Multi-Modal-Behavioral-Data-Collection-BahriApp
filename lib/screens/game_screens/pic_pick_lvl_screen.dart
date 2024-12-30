import 'package:bahri_app/screens/game_screens/pic_pick_screen.dart';
import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

class PicPickLvlScreen extends StatelessWidget {
  const PicPickLvlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      //backgroundColor: const Color(0xFFE6E9FF),
      appBar: AppBar(
        // title: const Text(
        //   'Pic Pick',
        //   style: TextStyle(
        //     fontFamily: "assets/fonts/Poppins-Regular.ttf",
        //     fontSize: 25,

        //     //fontWeight: FontWeight.bold,
        //     color: Colors.black,
        //   ),
        // ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color.fromRGBO(183, 153, 255, 1),
                  Color.fromRGBO(172, 188, 255, 1),
                  Color.fromRGBO(174, 226, 255, 1),
                ],
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
                        //const Spacer(flex: 2), // Adds space to push the logo down
                        // /const LogoCircularBorder(widthfactor: 0.8),
                        //const Spacer(flex: 1), // Adds space below the logo
                        const SizedBox(height: 55),
                        const SizedBox(
                          child: StrokeText(
                            text: 'Pic Pick',
                            textStyle: TextStyle(
                              fontFamily: "assets/fonts/Poppins-Regular.ttf",
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                            strokeColor: Color.fromARGB(255, 0, 0, 0),
                            strokeWidth: 7,
                          ),
                        ),
                        // const SizedBox(height: 25),
                        // const SizedBox(
                        //   child: StrokeText(
                        //     text: 'Choose Difficulty',
                        //     textStyle: TextStyle(
                        //       fontFamily: "assets/fonts/Poppins-Regular.ttf",
                        //       fontSize: 27,
                        //       fontWeight: FontWeight.bold,
                        //       color: Color.fromARGB(255, 255, 255, 255),
                        //     ),
                        //     strokeColor: Color.fromARGB(255, 0, 0, 0),
                        //     strokeWidth: 0,
                        //   ),
                        // ),
                        const SizedBox(height: 36),
                        const Text(
                          'Note: The game will start right when you choose a difficulty',
                          style: TextStyle(
                            fontFamily: "assets/fonts/Poppins-Regular.ttf",
                            fontSize: 12,
                            //fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                        const SizedBox(height: 46),
                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 const PicPick(difficulty: 0)));
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
                                    builder: (context) =>
                                        const PicPick(difficulty: 1)));
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
                              'Start',
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

                        // ElevatedButton(
                        //   onPressed: () {
                        //     Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 const PicPick(difficulty: 2)));
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
                        //       'Hard',
                        //       style: TextStyle(
                        //         fontSize: 21,
                        //         color: Color.fromARGB(255, 0, 0, 0),
                        //         fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                        //         //fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        //const Spacer(flex: 1),

                        //const Spacer(flex: 2), // Adds space at the bottom
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
}
