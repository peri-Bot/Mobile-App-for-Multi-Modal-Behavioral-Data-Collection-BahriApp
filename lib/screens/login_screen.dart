import 'package:bahri_app/screens/home_screen.dart';
import 'package:bahri_app/screens/signup_screen.dart';
import 'package:bahri_app/services/firebase_login_services.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/services/UserServices.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseLoginServices _auth = FirebaseLoginServices();
  final loginValidate = UserServices();

  void _login() async {
    String email = loginValidate.usernameController.text;
    String password = loginValidate.passwordController.text;

    try {
      User? user = await _auth.signInWithEmailPassword(email, password);
      if (user != null) {
        print("Login Successful");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to sign in")),
        );
      }
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sign in: $e")),
      );
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
                    Color.fromRGBO(172, 188, 255, 1.0), // RGB color
                    Color.fromRGBO(174, 226, 255, 1.0), // RGB color
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                                const Text(
                                  'Login here',
                                  style: TextStyle(
                                    fontSize: 28, // Responsive font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: constraints.maxHeight * 0.01),
                                const Text(
                                  'Welcome back you\'ve been missed!',
                                  style: TextStyle(
                                    fontSize: 16, // Responsive font size
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
                                  hintText: 'Email',
                                  filled: true,
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
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                obscureText: true,
                                validator: loginValidate.validatePassword,
                              ),
                              const SizedBox(height: 0),
                              const Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                              ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: const Color(0xFFCF98FF),
                                ),
                                child: const Text('Sign in'),
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
                                    MaterialPageRoute(builder: (context) => const SignupScreen()),
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
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              SizedBox(height: constraints.maxHeight * 0.02),
                              const Text("or continue with"),
                              SizedBox(
                                height: constraints.maxHeight * 0.05,
                                width: constraints.maxWidth * .8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.g_translate,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
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

