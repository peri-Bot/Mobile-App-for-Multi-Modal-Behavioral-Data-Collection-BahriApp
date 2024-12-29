// ignore_for_file: unused_import, unnecessary_import

import 'dart:ffi' as ffi;
//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:bahri_app/screens/game_screens/handwriting_screen.dart';
import 'package:bahri_app/screens/game_screens/key_stroke_lvl_screen.dart';
import 'package:bahri_app/screens/game_screens/key_stroke_screen.dart';
import 'package:bahri_app/screens/game_screens/motion_game/acceleroGame.dart';
import 'package:bahri_app/screens/game_screens/motion_game/accelerogame_mainscreen.dart';
import 'package:bahri_app/screens/game_screens/motion_game/gyroGame_mainScreen.dart';
import 'package:bahri_app/screens/game_screens/pic_pick_lvl_screen.dart';
import 'package:bahri_app/screens/game_screens/swipe_level_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => GamesList();
}

class GamesList extends State<GamesListScreen> {
  //bool firstSwitchValue = false;

  bool _collapsedWalk = false;
  bool _collapsedSwipe = false;
  bool firstSwitchValue = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text(
      //     'Games',
      //     style: TextStyle(
      //       fontFamily: "assets/fonts/Poppins-Regular.ttf",
      //       fontSize: 25,

      //       //fontWeight: FontWeight.bold,
      //       color: Colors.black,
      //     ),
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      // ),
      body: Stack(
        children: [
          // Container(
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       begin: Alignment.bottomCenter,
          //       end: Alignment.topCenter,
          //       colors: [
          //         Color.fromRGBO(183, 153, 255, 1),
          //         Color.fromRGBO(172, 188, 255, 1),
          //         Color.fromRGBO(174, 226, 255, 1),
          //       ],
          //     ),
          //   ),
          // ),
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
                        // const SizedBox(height: 55),
                        // const SizedBox(
                        //   child: StrokeText(
                        //     text: 'Keystroke Test',
                        //     textStyle: TextStyle(
                        //       fontFamily: "assets/fonts/Poppins-Regular.ttf",
                        //       fontSize: 40,
                        //       fontWeight: FontWeight.bold,
                        //       color: Color.fromARGB(255, 255, 255, 255),
                        //     ),
                        //     strokeColor: Color.fromARGB(255, 0, 0, 0),
                        //     strokeWidth: 7,
                        //   ),
                        // ),
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
//                         const SizedBox(height: 36),
//                         AnimatedToggleSwitch<bool>.size(
//                           current: firstSwitchValue,
//                           values: const [false, true],
//                           iconOpacity: 0.2,
//                           indicatorSize: const Size.fromWidth(100),
//                           customIconBuilder: (context, local, global) => Text(
//                             local.value ? "Amharic" : "English",
//                             style: TextStyle(
//                                 color: Color.lerp(Colors.black, Colors.white,
//                                     local.animationValue)),
//                           ),
//                           animationDuration: const Duration(milliseconds: 75),

//                           borderWidth: 5.0,
//                           iconAnimationType: AnimationType.onHover,
//                           style: ToggleStyle(
//                             backgroundColor: Colors.white,
//                             indicatorColor: Colors.black,
//                             borderColor: Colors.transparent,
//                             borderRadius: BorderRadius.circular(9),
//                           ),
// // ToggleStyle
//                           selectedIconScale: 1.0,
//                           onChanged: (value) =>
//                               setState(() => firstSwitchValue = value),
//                         ),
                        // const SizedBox(height: 36),
                        // const Text(
                        //   'Note: The game will start right when you choose a difficulty',
                        //   style: TextStyle(
                        //     fontFamily: "assets/fonts/Poppins-Regular.ttf",
                        //     fontSize: 12,
                        //     //fontWeight: FontWeight.bold,
                        //     color: Color.fromARGB(255, 255, 255, 255),
                        //   ),
                        // ),

                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onExpansionChanged: (value) {
                              setState(() {});
                            },
                            leading: const Icon(Icons.touch_app),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Tap Game",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PicPickLvlScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: const <Widget>[
                              ListTile(
                                title: Text(
                                  "Tap the ceneter of the images that are not bombs 💣 to score points",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),

                            leading: Icon(_collapsedSwipe
                                ? Icons.swipe_vertical
                                : Icons.swipe),
                            onExpansionChanged: (value) {
                              setState(() {
                                _collapsedSwipe = value;
                              });
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Swipe Game",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LevelSelectionScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: const <Widget>[
                              ListTile(
                                title: Text(
                                  "Swipe left to right or right to left, and bottom to top or top to bottom accordingly to score points.",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onExpansionChanged: (value) {
                              setState(() {});
                            },
                            leading: const Icon(Icons.keyboard),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Typing Game",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const KeyStrokeLevelScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: const <Widget>[
                              ListTile(
                                title: Text(
                                  "Type the displayed texts accuratly to score points",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            onExpansionChanged: (value) {
                              setState(() {});
                            },
                            leading: const Icon(Icons.sports_soccer),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Gyro Game",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const GyroScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 7,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: const <Widget>[
                              ListTile(
                                title: Text(
                                  "Move the ball to the finish line by tilting your phone without touching any objects or borders.",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),

                            leading: Icon(
                              _collapsedWalk
                                  ? Icons.directions_run
                                  : Icons.directions_walk,
                            ),
                            onExpansionChanged: (value) {
                              setState(() {
                                _collapsedWalk = value;
                              });
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Activity Game",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const StartScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 7,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      // side: const BorderSide(
                                      //     color: Colors.black)
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: const <Widget>[
                              ListTile(
                                title: Text(
                                  "Walk with your phone to reach the specified number of steps.",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        Card(
                          child: ExpansionTile(
                            collapsedBackgroundColor: Colors.white,
                            //backgroundColor: Color.fromARGB(255, 231, 90, 90),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            collapsedShape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),

                            leading: const Icon(Icons.draw),
                            onExpansionChanged: (value) {
                              setState(() {});
                            },
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Handwriting",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontSize: 21.0,
                                      fontWeight: FontWeight.w500),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                HandwritingScreen(
                                                    isAmharic:
                                                        firstSwitchValue)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 7,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      // side: const BorderSide(
                                      //     color: Colors.black)
                                    ),
                                  ),
                                  child: const Text(
                                    "Play",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              ],
                            ),
                            //trailing: ,
                            tilePadding: const EdgeInsets.all(9),

                            children: <Widget>[
                              const ListTile(
                                title: Text(
                                  "write The Showen Letter in the Box Using Handwriting",
                                  style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              const SizedBox(height: 20),
                              AnimatedToggleSwitch<bool>.size(
                                current: firstSwitchValue,
                                values: const [false, true],
                                iconOpacity: 0.2,
                                indicatorSize: const Size.fromWidth(100),
                                customIconBuilder: (context, local, global) =>
                                    Text(
                                  local.value ? "አማርኛ" : "English",
                                  style: TextStyle(
                                      color: Color.lerp(Colors.black,
                                          Colors.white, local.animationValue)),
                                ),
                                animationDuration:
                                    const Duration(milliseconds: 75),

                                borderWidth: 5.0,
                                iconAnimationType: AnimationType.onHover,
                                style: ToggleStyle(
                                  backgroundColor: Colors.white,
                                  indicatorColor: Colors.black,
                                  borderColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
// ToggleStyle
                                selectedIconScale: 1.0,
                                onChanged: (value) =>
                                    setState(() => firstSwitchValue = value),
                              ),
                            ],
                          ),
                        )
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
