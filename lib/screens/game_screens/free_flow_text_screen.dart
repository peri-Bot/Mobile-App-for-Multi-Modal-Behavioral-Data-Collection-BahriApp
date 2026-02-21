import 'package:bahri_app/services/freetext_service.dart';
import 'package:bahri_app/widgets/fade_message_box.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../widgets/keyboard/artistic_multilingual_keyboard.dart';

class FreeFlowTextScreen extends StatefulWidget {
  final bool isAmharic;

  const FreeFlowTextScreen({super.key, required this.isAmharic});

  @override
  State<FreeFlowTextScreen> createState() => _FreeFlowTextScreenState();
}

class _FreeFlowTextScreenState extends State<FreeFlowTextScreen> {
  late bool isAmharic;
  bool _canPop = false;

  void updateCanPop(bool value) {
    setState(() {
      _canPop = value;
    });
  }

  final FreeTextService freeTextService = FreeTextService();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  late Map<String, dynamic> gameInfo;

  KeyboardLanguages currentKeyboardLanguage = KeyboardLanguages.amharic;
  KeyboardAction currentKeyboardAction = KeyboardAction.actionDone;
  bool _isKeyboardOpen = false;
  String? _hintText;

  @override
  void initState() {
    super.initState();
    isAmharic = widget.isAmharic;
    currentKeyboardTEController = _textController;
    currentKeyboardFocusNode = _textFocusNode;
    if (isAmharic) {
      _hintText = 'የተሰማህን ሃሳብ ፃፍ';
    } else {
      _hintText = "Note Whatever Comes to Mind";
    }
    _textController.addListener(_scrollToBottom);
    _textFocusNode.addListener(() {
      setState(() {
        _isKeyboardOpen = _textFocusNode.hasFocus;
        if (_isKeyboardOpen) {
          currentKeyboardAction = KeyboardAction.actionNewLine;
          currentKeyboardTEController = _textController;
          currentKeyboardFocusNode = _textFocusNode;

          if (isAmharic) {
            currentKeyboardLanguage = KeyboardLanguages.amharic;
          } else {
            currentKeyboardLanguage = KeyboardLanguages.english;
          }
        }
      });
    });

    // Add listener to monitor text changes

    freeTextService.fetchUserId();
    freeTextService.initHive();
    gameInfo = {
      'startTime': DateTime.now().toIso8601String(),
      'language': isAmharic ? "Amharic" : "English",
    };
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TextController: $_textController');
    debugPrint('FocusNode: $_textFocusNode');
    debugPrint('IsKeyboardOpen: $_isKeyboardOpen');
    debugPrint('KeyboardAction: $currentKeyboardAction');
    debugPrint('KeyboardLanguage: $currentKeyboardLanguage');
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }

        // Show the fade message box when the back button is pressed
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder: (context) {
            return const FadeMessageBox(
              message: "Please Play the game first.", // Custom message
              duration: Duration(seconds: 2), // Custom fade duration
            );
          },
        );
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Free Flow Text'),
          leading: IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => (),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // Background Gradient
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Character Counter
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Align(
                    //     alignment: Alignment.topRight,
                    //     child: Text(
                    //       '${_textController.text.length}/$_maxCharacters',
                    //       style: const TextStyle(
                    //         color: Colors.white,
                    //         fontWeight: FontWeight.bold,
                    //         fontSize: 16,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(
                      height: 50,
                    ),

                    Text(
                      _hintText!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "assets/fonts/Poppins-Regular.ttf",
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      // strokeColor: const Color.fromARGB(255, 255, 255, 255),
                      // strokeWidth: 1,
                    ),
                    // Text Input Field
                    const SizedBox(
                      height: 60,
                    ),
                    SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _textController,
                              focusNode: _textFocusNode,
                              scrollController: _scrollController,

                              decoration: const InputDecoration(
                                labelText: 'Enter Text',
                                border: UnderlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              readOnly:
                                  true, // Set to true if you want it read-only.
                              showCursor: true,
                              maxLines:
                                  4, // Allows unlimited lines, but constrained by the height.
                              keyboardType: TextInputType.multiline,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 46),
                    ElevatedButton(
                      onPressed: () {
                        if (currentKeyboardTEController.length > 1) {
                          gameInfo['endTime'] =
                              DateTime.now().toIso8601String();
                          gameInfo['completeUserInput'] =
                              currentKeyboardTEController.text;
                          freeTextService.saveKeyStrokeFreeTextData(gameInfo);
                          _showEnd();
                        } else {
                          // Show the fade message box when the back button is pressed
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent dismissing by tapping outside
                            builder: (context) {
                              return const FadeMessageBox(
                                message:
                                    "Please play the game first.", // Custom message
                                duration: Duration(
                                    seconds: 2), // Custom fade duration
                              );
                            },
                          );
                        }
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
          ],
        ),
        bottomSheet: KeyboardLayouts(
          key: UniqueKey(),
          textEditingController: currentKeyboardTEController,
          focusNode: currentKeyboardFocusNode,
          isKeyboardOpen: _isKeyboardOpen,
          enableLanguageButton: false,
          keyboardBackgroundColor: Colors.transparent,
          keysBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          keyShadowColor: Colors.black,
          keyElevation: 10,
          keyTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          keyBorderRadius: BorderRadius.circular(8),
          keyboardAction: currentKeyboardAction,
          currentKeyboardLanguage: currentKeyboardLanguage,
          onButtonPressed: (keyText, keyType) {
            freeTextService.onButtonPressed(
                getKeyText(keyText, keyType), keyType);
            debugPrint(getKeyText(keyText, keyType));
            //_buildtxt(tEController.text);
          },
          onKeyTapDown: (details) {
            debugPrint("inside tapDOwn");
            freeTextService.onKeyTapDown(details);
          },
          onKeyTapUp: (details) {
            debugPrint("inside tapUP");

            freeTextService.onKeyTapUp(details);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  String getKeyText(String originalKeyText, KeyTypes keyType) {
    switch (keyType) {
      case KeyTypes.backSpace:
        return "backspace";
      case KeyTypes.doneKey:
        return "Done";
      case KeyTypes.changeKeyboardKey:
        return "ChangeKeyboard";
      case KeyTypes.changeLanguageKey:
        return "ChangeLangauge";
      case KeyTypes.newLineKey:
        return "NewLine";
      case KeyTypes.nextKey:
        return "NextKey";
      case KeyTypes.textKey:
        if (originalKeyText == " ") {
          return "Space";
        } else {
          return originalKeyText;
        }

      default:
        return originalKeyText;
    }
  }

  void _showEnd() {
    var radius = 10.0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Successfully Recorded",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Center(
                      child: Text(
                        'Go back to levels page',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Navigate back
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
              const SizedBox(
                height: 11,
              ),
            ],
          ),
        );
      },
    );
  }
}
