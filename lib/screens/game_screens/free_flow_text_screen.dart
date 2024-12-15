import 'package:bahri_app/services/freetext_service.dart';
import 'package:flutter/material.dart';
import '../../widgets/keyboard/artistic_multilingual_keyboard.dart';

class FreeFlowTextScreen extends StatefulWidget {
  final bool isAmharic;

  const FreeFlowTextScreen({super.key, required this.isAmharic});

  @override
  State<FreeFlowTextScreen> createState() => _FreeFlowTextScreenState();
}

class _FreeFlowTextScreenState extends State<FreeFlowTextScreen> {
  late bool isAmharic;
  bool _isDialogVisible = false;

  final FreeTextService freeTextService = FreeTextService();

  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  late Map<String, dynamic> gameInfo;

  KeyboardLanguages currentKeyboardLanguage = KeyboardLanguages.amharic;
  KeyboardAction currentKeyboardAction = KeyboardAction.actionDone;
  final int _maxCharacters = 8;
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    super.initState();
    isAmharic = widget.isAmharic;
    currentKeyboardTEController = _textController;
    currentKeyboardFocusNode = _textFocusNode;
    _textFocusNode.addListener(() {
      setState(() {
        _isKeyboardOpen = _textFocusNode.hasFocus;
        if (_isKeyboardOpen) {
          currentKeyboardAction = KeyboardAction.actionDone;
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
    _textController.addListener(_onTextChanged);
    freeTextService.fetchUserId();
    freeTextService.initHive();
    gameInfo = {
      'startTime': DateTime.now().toIso8601String(),
    };
  }

  void _onTextChanged() {
    // Check if text has reached maximum length
    if (_textController.text.length == _maxCharacters && !_isDialogVisible) {
      _isDialogVisible = true;
      // Show dialog when max characters are reached
      _showMaxCharacterDialog();
    }

    // Force update to refresh the character count
    setState(() {});
  }

  void _showMaxCharacterDialog() {
    gameInfo['endTime'] = DateTime.now().toIso8601String();
    gameInfo['completeUserInput'] = currentKeyboardTEController.text;
    freeTextService.saveKeyStrokeFreeTextData(gameInfo);
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Maximum Characters Reached'),
          content:
              const Text('You have entered the maximum number of characters.'),
          actions: [
            TextButton(
              onPressed: () {
                _isDialogVisible = false;
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to previous screen
                //Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('TextController: $_textController');
    print('FocusNode: $_textFocusNode');
    print('IsKeyboardOpen: $_isKeyboardOpen');
    print('KeyboardAction: $currentKeyboardAction');
    print('KeyboardLanguage: $currentKeyboardLanguage');
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Free Flow Text'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Character Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      '${_textController.text.length}/$_maxCharacters',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Text Input Field
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _textController,
                    focusNode: _textFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Enter Text',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                    showCursor: true,
                    maxLength: _maxCharacters,
                    buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) {
                      return Container(); // Hide default counter
                    },
                  ),
                ),
              ],
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
}
