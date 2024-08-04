import 'package:bahri_app/screens/login_screen.dart';
import 'package:bahri_app/screens/signup_screen.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6E9FF),
      body: SafeArea(
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Spacer(flex: 2), // Adds space to push the logo down
                  const LogoCircularBorder(widthfactor: 0.8),
                  const Spacer(flex: 1), // Adds space below the logo
                  const Text(
                    'Bahri App',
                    style: TextStyle(
                      fontFamily: "assets/fonts/Poppins-Regular.ttf",
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(flex: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB19EF0),
                            minimumSize: const Size(double.infinity, 65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 19,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10), // Add space between buttons
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                            minimumSize: const Size(double.infinity, 65),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 19,
                              color: Colors.black,
                              fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                              //fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2), // Adds space at the bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
