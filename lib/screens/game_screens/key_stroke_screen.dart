import 'dart:math';

import 'package:flutter/material.dart';
import 'package:artistic_multilingual_keyboards/artistic_multilingual_keyboard.dart';
import 'package:artistic_multilingual_keyboards/keyboards_layouts/keyboard_layouts.dart';
import 'package:artistic_multilingual_keyboards/utils/languages_alphabets.dart';
import 'package:artistic_multilingual_keyboards/utils/types.dart';

class KeyStrokeScreen extends StatefulWidget {
  final int difficulty;
  const KeyStrokeScreen({super.key, required this.difficulty});

  @override
  State<KeyStrokeScreen> createState() => _KeyStrokeScreen();
}

class _KeyStrokeScreen extends State<KeyStrokeScreen> {
  late int difficulty;
  List<String> difficulties = [" Easy", " Medium", " Hard"];
  int _score = 0;

  //final TextEditingController _controller = TextEditingController();
  TextEditingController englishTEController = TextEditingController();
  TextEditingController urduTEController = TextEditingController();
  TextEditingController sindhiTEController = TextEditingController();

  FocusNode engFocusNode = FocusNode();
  FocusNode urduFocusNode = FocusNode();
  FocusNode sindhiFocusNode = FocusNode();

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  KeyboardLanguages currentKeyboardLanguage = KeyboardLanguages.english;
  KeyboardAction currentKeyboardAction = KeyboardAction.actionNext;
  bool _isKeyboardOpen = false;

  String? _targetSentence;
  Map<int, List<String>> sentenceMap = {
    0: [
      "The quick brown fox.",
      "Flutter is good.",
      "Sandwiches on the table.",
      "There were seven balloons.",
      "You didn't tell me.",
      "Practice makes perfect.",
      "Hello, world!",
    ],
    1: [
      "A gentle breeze rustled the leaves on the trees.",
      "The cat sat on the windowsill, watching the birds.",
      "She baked a delicious cake for her friend's birthday.",
      "The children played happily in the park all afternoon.",
      "He read a fascinating book about ancient civilizations.",
      "The sun set, painting the sky with hues of orange and pink.",
      "They enjoyed a picnic by the lake on a sunny day.",
    ],
    2: [
      "As the sun set, the sky was painted with a beautiful array of colors, creating a breathtaking view.",
      "The cat, with its sleek fur and piercing eyes, sat on the windowsill, intently watching the birds outside.",
      "She spent the entire afternoon baking a delicious cake, carefully decorating it for her friend's birthday celebration.",
      "The children, full of energy and laughter, played happily in the park, making the most of the sunny afternoon.",
      "He immersed himself in a fascinating book about ancient civilizations, losing track of time as he read.",
      "The sun set behind the mountains, casting long shadows and painting the sky with vibrant hues of orange and pink.",
      "They packed a basket with their favorite foods and enjoyed a relaxing picnic by the lake, soaking in the beautiful weather.",
    ]
  };

  List<String>? _sentences;
  @override
  void initState() {
    super.initState();
    difficulty = widget.difficulty;
    _sentences = sentenceMap[difficulty];
    _getRandomSentence();
    currentKeyboardTEController = englishTEController;
    currentKeyboardFocusNode = engFocusNode;
    englishTEController.addListener(_handleTextChanged);
    print("added listener");
    engFocusNode.addListener(() {
      setState(() {
        if (engFocusNode.hasFocus) {
          currentKeyboardFocusNode = engFocusNode;
          currentKeyboardAction = KeyboardAction.actionNext;
          currentKeyboardTEController = englishTEController;
          currentKeyboardLanguage = KeyboardLanguages.english;
          _isKeyboardOpen = true;
        } else {
          _isKeyboardOpen = false;
        }
      });
    });
  }

  void _handleTextChanged() {
    setState(() {
      // This will trigger a rebuild and call _buildTextSpan to update the UI
    });
  }

  void _getRandomSentence() {
    final random = Random();
    setState(() {
      _targetSentence = _sentences?[random.nextInt(_sentences!.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'keyStroke Test ${difficulties[difficulty]}',
          //tap the center of the images that are not distorted
          style: const TextStyle(
            fontFamily: "assets/fonts/Poppins-Regular.ttf",
            fontSize: 25,

            //fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus(); // Unfocus from the text field

              Future.delayed(const Duration(milliseconds: 100), () {
                _getRandomSentence(); // Select a new random sentence
                englishTEController
                    .clear(); // Clear the text field after the focus has been removed
              });
            }, // Refreshes the sentence
          ),
        ],
        backgroundColor: Colors.transparent,
        //elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            //size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
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
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 46),

                    Container(
                      margin: const EdgeInsets.all(6.0),
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.transparent)),
                      child: Text(
                        _targetSentence!,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    // Container(
                    //   padding: const EdgeInsets.all(13),
                    //   width: 400,
                    //   height: 400,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(11),
                    //   ),
                    // )
                    TextField(
                      controller: englishTEController,
                      maxLines: null, // Allows multiline input
                      onChanged: (text) {
                        print("yo");
                        setState(() {});
                      },
                      focusNode: engFocusNode,
                      textDirection: TextDirection.ltr,
                      readOnly: true,
                      showCursor: true,
                      textAlign: TextAlign.start,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          hintText: 'Type the sentence above...',
                          fillColor: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.all(2.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white),
                      child: RichText(
                        text: _buildTextSpan(englishTEController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomSheet: GestureDetector(
        child: KeyboardLayouts(
          textEditingController: currentKeyboardTEController,
          focusNode: currentKeyboardFocusNode,
          isKeyboardOpen: _isKeyboardOpen,
          enableLanguageButton: false,
          keyboardBackgroundColor: Colors.transparent,
          keysBackgroundColor: Color.fromARGB(255, 255, 255, 255),
          keyTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          keyElevation: 10,
          keyShadowColor: Colors.black,
          keyBorderRadius: BorderRadius.circular(8),
          keyboardAction: currentKeyboardAction,
          currentKeyboardLanguage: currentKeyboardLanguage,
          keyboardActionNextEvent: () {
            if (engFocusNode.hasFocus) {
              engFocusNode.unfocus();
              urduFocusNode.requestFocus();
            } else if (urduFocusNode.hasFocus) {
              urduFocusNode.unfocus();
              sindhiFocusNode.requestFocus();
            }
          },
          keyboardActionDoneEvent: () {
            setState(() {
              _isKeyboardOpen = !_isKeyboardOpen;
            });
          },
        ),
      ),
    );
  }

  TextSpan _buildTextSpan(String inputText) {
    List<TextSpan> spans = [];
    for (int i = 0; i < _targetSentence!.length; i++) {
      Color color;
      if (i < inputText.length) {
        if (inputText[i] == _targetSentence?[i]) {
          color = Colors.green; // Correct character
        } else {
          color = Colors.red; // Incorrect character
        }
      } else {
        color = Colors.grey; // Characters yet to be typed
      }

      // Replace space with a visible special character
      String? textChar = _targetSentence?[i] == ' ' ? '␣' : _targetSentence?[i];

      spans.add(TextSpan(
        text: textChar,
        style: TextStyle(color: color, fontSize: 18),
      ));
    }
    return TextSpan(children: spans);
  }
}
