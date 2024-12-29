//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:bahri_app/screens/game_screens/free_flow_text_screen.dart';
import 'package:bahri_app/screens/game_screens/key_stroke_screen.dart';
import 'package:bahri_app/screens/game_screens/password_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class KeyStrokeLevelScreen extends StatefulWidget {
  const KeyStrokeLevelScreen({super.key});

  @override
  State<KeyStrokeLevelScreen> createState() => KeyStrokeLvlScreen();
}

class KeyStrokeLvlScreen extends State<KeyStrokeLevelScreen> {
  bool firstSwitchValue = false;
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
                            text: 'Keystroke Game',
                            textStyle: TextStyle(
                              fontFamily: "assets/fonts/Poppins-Regular.ttf",
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                            strokeColor: Color.fromARGB(255, 255, 255, 255),
                            strokeWidth: 3,
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
                        AnimatedToggleSwitch<bool>.size(
                          current: firstSwitchValue,
                          values: const [false, true],
                          iconOpacity: 0.2,
                          indicatorSize: const Size.fromWidth(100),
                          customIconBuilder: (context, local, global) => Text(
                            local.value ? "አማርኛ" : "English",
                            style: TextStyle(
                                color: Color.lerp(Colors.black, Colors.white,
                                    local.animationValue)),
                          ),
                          animationDuration: const Duration(milliseconds: 75),

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
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => KeyStrokeScreen(
                                        difficulty: 0,
                                        isAmharic: firstSwitchValue)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            minimumSize: const Size(double.infinity, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Predefined Text',
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontFamily:
                                      "assets/fonts/Poppins-SemiBold.ttf",
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 46),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FreeFlowTextScreen(
                                        isAmharic: firstSwitchValue)));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            minimumSize: const Size(double.infinity, 75),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Free Text',
                                style: TextStyle(
                                  fontSize: 21,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontFamily:
                                      "assets/fonts/Poppins-SemiBold.ttf",
                                  //fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 46),

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

                            leading: const Icon(Icons.info),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Password",
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
                                                const PasswordEntryScreen()));
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

                            children: <Widget>[
                              ListTile(
                                title: RichText(
                                  text: const TextSpan(
                                    text: "Write This Sample Password ",
                                    style: TextStyle(
                                      fontFamily:
                                          "assets/fonts/Poppins-SemiBold.ttf",
                                      fontWeight: FontWeight.w400,
                                      color: Colors
                                          .black, // Default color for the text
                                      fontSize:
                                          16, // Adjust font size as needed
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: " Ba.1932\$",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize:
                                              18, // Make it slightly larger for emphasis
                                          color: Colors
                                              .red, // Change color to make it more visible
                                        ),
                                      ),
                                      TextSpan(
                                        text: " into the Provided Text Box",
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
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
