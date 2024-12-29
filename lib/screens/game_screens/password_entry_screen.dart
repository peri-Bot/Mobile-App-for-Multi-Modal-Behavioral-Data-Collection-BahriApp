import 'package:bahri_app/services/password_entry_services.dart';
import 'package:bahri_app/widgets/fade_message_box.dart';
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
  bool _pwdhide = true;

  late TextEditingController currentKeyboardTEController;
  late FocusNode currentKeyboardFocusNode;
  late Map<String, dynamic> gameInfo;
  bool _canPop = false;

  void updateCanPop(bool value) {
    setState(() {
      _canPop = value;
    });
  }

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
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: const Text('Success'),
      //       content: const Text('Complete'),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop(); // Close the dialog
      //             Navigator.of(context).pop(); // Go back to previous screen
      //           },
      //           child: const Text('Go back'),
      //         ),
      //       ],
      //     );
      //   },
      // );
      _showEnd();
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Incorrect password')),
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) {
          return const FadeMessageBox(
            message: "Incorrect Password.", // Custom message
            duration: Duration(seconds: 2), // Custom fade duration
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Password Entry'),
          leading: IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () => (),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 20.0),
                        child: RichText(
                          softWrap: true,
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: "Write this Password ",
                            style: TextStyle(
                              fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                              fontWeight: FontWeight.w400,
                              color: Colors.black, // Default color for the text
                              fontSize: 20, // Adjust font size as needed
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: " Ba.1932\$",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      25, // Make it slightly larger for emphasis
                                  color: Color.fromARGB(255, 255, 1,
                                      1), // Change color to make it more visible
                                ),
                              ),
                              TextSpan(
                                text: " into the Provided Text Box below",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      maxLength: 8,
                      obscureText: _pwdhide,
                      decoration: InputDecoration(
                        labelText: 'Enter Password',
                        border: const UnderlineInputBorder(),
                        filled: true,
                        suffixIcon: IconButton(
                          icon: _pwdhide
                              ? const Icon(Icons.visibility,
                                  color: Colors.black)
                              : const Icon(Icons.visibility_off,
                                  color: Colors.black),
                          onPressed: () {
                            setState(() {
                              _pwdhide = !_pwdhide;
                            });
                          },
                        ),
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
          keyBorderRadius: BorderRadius.circular(2),
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

  void _showEnd() {
    var radius = 10.0;
    showDialog(
      context: context,
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
