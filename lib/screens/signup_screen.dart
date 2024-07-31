import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:bahri_app/widgets/CustomStepper.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromRGBO(172, 185, 255, 1),
      body: SafeArea(
          child: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                Color.fromRGBO(183, 153, 255, 1),
                Color.fromRGBO(172, 188, 255, 1),
                Color.fromRGBO(174, 226, 255, 1),
              ]),
        ),
        child: SingleChildScrollView(
          //physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                FractionallySizedBox(
                  //widthFactor: 0.5,
                  child: Container(
                    alignment: Alignment.center,
                    // decoration:
                    //     BoxDecoration(border: Border.all(color: Colors.black)),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        fontFamily: "assets/fonts/Poppins-Bold.ttf",
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(color: Colors.transparent),
                const Divider(color: Colors.transparent),
                const LogoCircularBorder(widthfactor: 0.7),
                const Divider(color: Colors.transparent),
                FractionallySizedBox(
                  widthFactor: 0.85,
                  child: CustomStepper(
                    currentStep: _currentStep,
                    steps: const [
                      {'title': 'Email', 'image': 'assets/images/check.svg'},
                      {'title': 'Name', 'image': 'assets/images/check.svg'},
                      {
                        'title': 'Birthdate',
                        'image': 'assets/images/check.svg'
                      },
                      {'title': 'Gender', 'image': 'assets/images/check.svg'},
                      {'title': 'Pwd', 'image': 'assets/images/check.svg'},
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 25,
                ),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: changeTextBox(_currentStep, context),
                ),
                const Divider(
                  color: Colors.transparent,
                  height: 15,
                ),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep++;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB19EF0),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                        //fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}

Widget changeTextBox(int currentStep, BuildContext context) {
  switch (currentStep) {
    case 0:
      return const TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(),
        ),
      );
    case 1:
      return const TextField(
        decoration: InputDecoration(
          labelText: 'Name',
          border: OutlineInputBorder(),
        ),
      );
    case 2:
      return GestureDetector(
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            // You can format the picked date and set it to a TextEditingController to display it
          }
        },
        child: const AbsorbPointer(
          child: TextField(
            decoration: InputDecoration(
              labelText: 'Birthdate',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      );
    case 3:
      return DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        items: ['Male', 'Female'].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          // Handle change
        },
      );
    case 4:
      return const Column(
        children: [
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 15),
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );
    default:
      return Container();
  }
}
