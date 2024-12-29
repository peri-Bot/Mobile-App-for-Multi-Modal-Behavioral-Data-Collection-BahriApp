import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/services/UserServices.dart';
import 'package:stroke_text/stroke_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final FirebaseLoginServices _auth = FirebaseLoginServices();
  final loginValidate = UserServices();
  bool _isSignInPressed = false;
  bool _pwdhide = true;

  void _login(BuildContext context) async {
    String email = loginValidate.usernameController.text;
    String password = loginValidate.passwordController.text;

    UserServices userServices = UserServices();
    String response = await userServices.loginDartFrog(email, password);
    if (context.mounted && response == 'sucess') {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BaseScreen()),
      );
    } else {
      if (context.mounted) {
        setState(() {
          _isSignInPressed = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to sign in: Please try again later")),
        );
      }
    }
  }

  @override
  void dispose() {
    loginValidate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(183, 153, 255, 1),
                    Color.fromRGBO(172, 188, 255, 1),
                    Color.fromRGBO(174, 226, 255, 1),
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Center(
                  child: Form(
                    key: loginValidate.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          flex: 10,
                          child: Container(
                            alignment: Alignment.center,
                            height: 150,
                            width: constraints.maxWidth * 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // const Text(
                                //   'Login here',
                                //   style: TextStyle(
                                //     fontSize: 28, // Responsive font size
                                //     fontWeight: FontWeight.bold,
                                //     fontFamily:
                                //         "assets/fonts/Poppins-SemiBold.ttf",
                                //   ),
                                //   textAlign: TextAlign.center,
                                // ),
                                const StrokeText(
                                  text: 'Welcome Back',
                                  textStyle: TextStyle(
                                    fontFamily:
                                        "assets/fonts/Poppins-Regular.ttf",
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                  textAlign: TextAlign.center,
                                  strokeColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  strokeWidth: 1.6,
                                ),
                                SizedBox(height: constraints.maxHeight * 0.01),

                                const Text(
                                  'Enter your credentials to login in!',
                                  style: TextStyle(
                                    fontSize: 16, // Responsive font size
                                    fontFamily:
                                        "assets/fonts/Poppins-SemiBold.ttf",
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: constraints.maxHeight * 0.01),
                                SizedBox(height: constraints.maxHeight * 0.01),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Flexible(
                          flex: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextFormField(
                                controller: loginValidate.usernameController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.account_circle,
                                    color: Colors.black,
                                  ),
                                  hintText: 'Username',
                                  filled: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: loginValidate.validateUsername,
                              ),
                              SizedBox(
                                height: constraints.maxHeight * 0.02,
                              ),
                              TextFormField(
                                controller: loginValidate.passwordController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.key,
                                      color: Colors.black),
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
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                obscureText: _pwdhide,
                                validator: loginValidate.validatePassword,
                              ),
                              const SizedBox(height: 7),
                              // const Align(
                              //   alignment: Alignment.centerRight,
                              //   child: Text(
                              //     'Forgot your password?',
                              //     style: TextStyle(
                              //       color: Colors.black,
                              //       fontFamily:
                              //           "assets/fonts/Poppins-SemiBold.ttf",
                              //       decoration: TextDecoration.underline,
                              //     ),
                              //   ),
                              // ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isSignInPressed = true;
                                  });
                                  _login(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 55),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFFB19EF0),
                                ),
                                child: _isSignInPressed
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign in',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontFamily:
                                              "assets/fonts/Poppins-SemiBold.ttf",
                                          //fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                              SizedBox(
                                height: constraints.maxHeight * 0.02,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: constraints.maxHeight * 0.01),
                        Flexible(
                          flex: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignupScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 35),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Text(
                                  'Create a new Account',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontFamily:
                                        "assets/fonts/Poppins-SemiBold.ttf",
                                    //fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
