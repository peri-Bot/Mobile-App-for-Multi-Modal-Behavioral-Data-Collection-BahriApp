import 'package:bahri_app/services/password_entry_services.dart';
import 'package:flutter/material.dart';
import '../../widgets/keyboard/artistic_multilingual_keyboard.dart';

class PasswordEntryScreen extends StatefulWidget {
  const PasswordEntryScreen({super.key});

  @override
  State<PasswordEntryScreen> createState() => _PasswordEntryScreenState();
}

class _PasswordEntryScreenState extends State<PasswordEntryScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final PasswordTextService passwordTextSService = PasswordTextService();
  final String _correctPassword = "Ba.1932\$";
  bool _isKeyboardOpen = false;

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  late Map<String, dynamic> gameInfo;

  KeyboardAction currentKeyboardAction = KeyboardAction.actionDone;
  @override
  void initState() {
    super.initState();
    passwordTextSService.fetchUserId();
    passwordTextSService.initHive();
    currentKeyboardTEController = _passwordController;
    currentKeyboardFocusNode = _passwordFocusNode;
    _passwordFocusNode.addListener(() {
      setState(() {
        _isKeyboardOpen = _passwordFocusNode.hasFocus;
        if (_isKeyboardOpen) {
          currentKeyboardAction = KeyboardAction.actionDone;
          currentKeyboardTEController = _passwordController;
          currentKeyboardFocusNode = _passwordFocusNode;
        }
      });
      gameInfo = {
        'startTime': DateTime.now().toIso8601String(),
      };
    });
  }

  void _checkPassword() {
    if (_passwordController.text == _correctPassword) {
      gameInfo['endTime'] = DateTime.now().toIso8601String();
      gameInfo['completeUserInput'] = currentKeyboardTEController.text;
      passwordTextSService.saveKeyStrokePasswordTextData(gameInfo);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Complete'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('Go back'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Password Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter Password',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    readOnly: true,
                    showCursor: true,
                  ),
                ),
                ElevatedButton(
                  onPressed: _checkPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    maximumSize: const Size(100, 150),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: KeyboardLayouts(
        textEditingController: currentKeyboardTEController,
        focusNode: currentKeyboardFocusNode,
        isKeyboardOpen: _isKeyboardOpen,
        keyboardAction: currentKeyboardAction,
        enableLanguageButton: false,
        keyboardBackgroundColor: Colors.transparent,
        keysBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        keyTextStyle: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        keyBorderRadius: BorderRadius.circular(8),
        currentKeyboardLanguage:
            KeyboardLanguages.english, // Assuming English keyboard
        onButtonPressed: (keyText, keyType) {
          passwordTextSService.onButtonPressed(
              getKeyText(keyText, keyType), keyType);
          debugPrint(getKeyText(keyText, keyType));
          //_buildtxt(tEController.text);
        },
        onKeyTapDown: (details) {
          debugPrint("inside tapDOwn");
          passwordTextSService.onKeyTapDown(details);
        },
        onKeyTapUp: (details) {
          debugPrint("inside tapUP");

          passwordTextSService.onKeyTapUp(details);
        },
      ),
    );
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

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
