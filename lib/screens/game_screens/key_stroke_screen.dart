import 'dart:math';

import 'package:bahri_app/widgets/linear_timer.dart';
import 'package:bahri_app/widgets/show_score_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../widgets/keyboard/artistic_multilingual_keyboard.dart';
//import 'package:artistic_multilingual_keyboards/artistic_multilingual_keyboard.dart';

//import 'package:artistic_multilingual_keyboards/keyboards_layouts/keyboard_layouts.dart';
//import '../../widgets/keyboard/keyboards_layouts/keyboard_layouts.dart';

//import 'package:artistic_multilingual_keyboards/utils/languages_alphabets.dart';
//import 'package:artistic_multilingual_keyboards/utils/types.dart';

class KeyStrokeScreen extends StatefulWidget {
  final int difficulty;
  final bool isAmharic;
  const KeyStrokeScreen(
      {super.key, required this.difficulty, required this.isAmharic});

  @override
  State<KeyStrokeScreen> createState() => _KeyStrokeScreen();
}

class _KeyStrokeScreen extends State<KeyStrokeScreen> {
  late int difficulty;
  late bool isAmharic;
  List<String> difficulties = [" Easy", " Medium", " Hard"];
  String hintTextAmh = "ከላይ ያለውን ዓረፍተ ነገር ይፃፉ...";
  String hintTextEng = "Type the sentence above...";
  List<int> timeLimitsEng = [30000, 50000, 50000];
  List<int> timeLimitsAmh = [40000, 120000, 120000];
  int _totalKeystrokes = 0;
  late List<bool?> correctnessBoolArray;

  int _score = 0;
  TextSpan? richtxt;

  //final TextEditingController _controller = TextEditingController();
  TextEditingController tEController = TextEditingController();

  FocusNode focusNode = FocusNode();
  late int _totalMistakes;
  late int _totalCorrect;

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  KeyboardLanguages currentKeyboardLanguage = KeyboardLanguages.amharic;
  KeyboardAction currentKeyboardAction = KeyboardAction.actionDone;
  bool _isKeyboardOpen = false;
  final GlobalKey<LinearTimerState> _timerKey = GlobalKey<LinearTimerState>();

  final ValueNotifier<TextSpan> _textSpanNotifier =
      ValueNotifier<TextSpan>(const TextSpan());

  String? _targetSentence;
  Map<int, List<String>> sentenceMapEng = {
    0: [
      "The quick brown fox.",
      "Coffee is good.",
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
  Map<int, List<String>> sentenceMapAmh = {
    0: [
      "ፈጣን ቡናማ ቀበሮ።",
      "ቡና ጥሩ ነው።",
      "ጠረጴዛው ላይ ሳንድዊች።",
      "ሰባት ፊኛዎች ነበሩ።",
      "አልነገርከኝም።",
      "ልምምድ ፍጹም ያደርጋል።",
      "ሰላም ዓለም።",
    ],
    1: [
      "ረጋ ያለ ንፋስ በዛፎቹ ላይ ቅጠሎቹን ነጠቀ።",
      "ድመቷ በመስኮቱ ላይ ተቀምጣ ወፎቹን ተመለከተች።",
      "ለጓደኛዋ ልደት ጣፋጭ ኬክ ጋገረች።",
      "ልጆቹ ከሰአት በኋላ በፓርኩ ውስጥ በደስታ ሲጫወቱ ነበር።",
      "ስለ ጥንታዊ ሥልጣኔዎች አስደናቂ መጽሐፍ አነበኩኝ።",
      "ፀሀይ ስትጠልቅ ሰማዩን በብርቱካን እና ሮዝ ቀለሞች ሳለች",
      "ፀሐያማ በሆነ ቀን በሐይቁ ዳር የሽርሽር ጉዞ ነበረን።",
    ],
    2: [
      "ፀሀይ ስትጠልቅ ሰማዩ በቀለማት ያሸበረቀ ቀለም በመቀባቱ አስደናቂ እይታ ፈጠረ።",
      "ድመቷ ፣ በሚያማምሩ ፀጉሯ እና በሚወጉ አይኖች ፣ በመስኮቱ መስኮቱ ላይ ተቀምጣ ወፎቹን በትኩረት እያየች።",
      "ለጓደኛዋ የልደት በዓል በጥንቃቄ በማስጌጥ ቀኑን ሙሉ ጣፋጭ ኬክ በመጋገር አሳለፈች።",
      "በጉልበት እና በሳቅ የተሞሉ ልጆቹ በፓርኩ ውስጥ በደስታ ተጫውተው ፀሐያማ ከሰአት አሳልፈዋል።",
      "ስለ ጥንታዊ ሥልጣኔዎች በሚያስደንቅ መጽሐፍ ውስጥ እራሱን ሰጠ ፣ ሲያነብ ጊዜን አጣ።",
      "ፀሀይ ከተራሮች ጀርባ ጠልቃለች ፣ ረጅም ጥላዎችን እየጣለች እና ሰማዩን በብርቱካናማ እና ሮዝ ቀለሞች ቀባች።",
      "ከሚወዷቸው ምግቦች ጋር ቅርጫት ጠቅልለው በሐይቁ ዳር ዘና ባለ የሽርሽር ጉዞ ተዝናኑ፣ ውብ በሆነው የአየር ሁኔታ ውስጥ ገብተዋል።",
    ]
  };

  List<String>? _sentences;

  @override
  void initState() {
    super.initState();
    _score = 0;
    _totalMistakes = 0;
    _totalCorrect = 0;
    difficulty = widget.difficulty;
    isAmharic = widget.isAmharic;
    if (isAmharic) {
      _sentences = sentenceMapAmh[difficulty];
    } else {
      _sentences = sentenceMapEng[difficulty];
    }
    _getRandomSentence();
    correctnessBoolArray =
        List<bool?>.generate(_targetSentence!.length, (index) => null);
    // tEController.addListener(() {
    //   setState(() {
    //     _buildTextSpan(tEController.text);
    //   });
    // });
    currentKeyboardTEController = tEController;
    currentKeyboardFocusNode = focusNode;
    _buildTextSpan(tEController.text);
    // if (!isAmharic) {
    //   tEController.addListener(() {
    //     setState(() {
    //       _buildTextSpan(tEController.text);
    //     });
    //   });
    // }

    focusNode.addListener(() {
      setState(() {
        if (focusNode.hasFocus) {
          currentKeyboardFocusNode = focusNode;
          currentKeyboardAction = KeyboardAction.actionDone;
          currentKeyboardTEController = tEController;
          if (isAmharic) {
            currentKeyboardLanguage = KeyboardLanguages.amharic;
          } else {
            currentKeyboardLanguage = KeyboardLanguages.english;
          }
          _isKeyboardOpen = true;
        } else {
          _isKeyboardOpen = false;
        }
      });
    });
  }

  void _getRandomSentence() {
    final random = Random();
    setState(() {
      _targetSentence = _sentences?[random.nextInt(_sentences!.length)];
    });
  }

  @override
  void dispose() {
    _textSpanNotifier.dispose();
    super.dispose();
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
                tEController
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
                    const SizedBox(
                      height: 45,
                    ),
                    LinearTimer(
                        key: _timerKey,
                        durationMiliseconds: isAmharic
                            ? timeLimitsAmh[difficulty]
                            : timeLimitsEng[difficulty],
                        onTimerStop: (remainingTime) {
                          _setScore(remainingTime);
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return ShowScorePopup(
                                score: _score,
                                highScore: 22,
                              );
                            },
                          );
                        },
                        onTimerFinish: (remainingTime) {
                          _setScore(remainingTime);

                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return ShowScorePopup(
                                score: _score,
                                highScore: 22,
                              );
                            },
                          );
                        }),
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
                      controller: tEController,
                      maxLines: null, // Allows multiline input

                      focusNode: focusNode,
                      textDirection: TextDirection.ltr,
                      readOnly: true,
                      showCursor: true,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          filled: true,
                          hintText: isAmharic ? hintTextAmh : hintTextEng,
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
                      child: ValueListenableBuilder<TextSpan>(
                        valueListenable: _textSpanNotifier,
                        builder: (context, richText, child) {
                          return RichText(
                            text: richText,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 46),
                    ElevatedButton(
                      onPressed: () {
                        _timerKey.currentState!.stopTimer();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size(145, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Finish',
                        style: TextStyle(
                          fontSize: 21,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                          //fontWeight: FontWeight.bold,
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
      bottomSheet: showKeyboard(),
    );
  }

  void _buildTextSpan(String inputText) {
    List<TextSpan> spans = [];
    var mistakes = 0;
    var correct = 0;
    for (int i = 0; i < _targetSentence!.length; i++) {
      Color color;
      if (i < inputText.length) {
        if (inputText[i] == _targetSentence?[i]) {
          color = Colors.green; // Correct character
          correct++;
        } else {
          color = Colors.red; // Incorrect character
          mistakes++;
        }
      } else {
        color = Colors.grey; // Characters yet to be typed
        mistakes++;
      }

      // Replace space with a visible special character
      String? textChar = _targetSentence?[i] == ' ' ? '␣' : _targetSentence?[i];

      spans.add(TextSpan(
        text: textChar,
        style: TextStyle(color: color, fontSize: 18),
      ));
    }
    _totalMistakes = mistakes;
    _totalCorrect = correct;
    _textSpanNotifier.value = TextSpan(children: spans);
  }

  Widget showKeyboard() {
    return KeyboardLayouts(
      key: UniqueKey(),
      textEditingController: currentKeyboardTEController,
      focusNode: currentKeyboardFocusNode,
      isKeyboardOpen: _isKeyboardOpen,
      enableLanguageButton: false,
      keyboardBackgroundColor: Colors.transparent,
      keysBackgroundColor: Color.fromARGB(255, 255, 255, 255),
      keyTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      //keyElevation: 10,
      keyShadowColor: Colors.black,
      keyBorderRadius: BorderRadius.circular(8),
      keyboardAction: currentKeyboardAction,
      currentKeyboardLanguage: currentKeyboardLanguage,
      keyboardActionNextEvent: () {
        if (focusNode.hasFocus) {
          focusNode.unfocus();
          focusNode.requestFocus();
        } else if (focusNode.hasFocus) {
          focusNode.unfocus();
          focusNode.requestFocus();
        }
      },
      onButtonPressed: (keyText, keyType) {
        _buildTextSpan(tEController.text);
        //_buildtxt(tEController.text);
      },
      onKeyTapDown: (details) {},

      onKeyTapUp: (details) {},
    );
  }

  void _setScore(int remainingTime) {
    remainingTime = remainingTime ~/ 1000;
    if (_totalMistakes > 0) {
      _score = _totalCorrect + remainingTime - (_totalMistakes * 10);
    } else {
      _score = _totalCorrect + remainingTime;
    }
    if (_score < 0) {
      _score = 0;
    }
  }
}
