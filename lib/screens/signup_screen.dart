import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:bahri_app/widgets/CustomStepper.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:bahri_app/services/UserServices.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  bool _visibleBackBtn = false;
  String? _error;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _selectedGender;

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
                        var errRetrun = validate(_currentStep);
                        if (errRetrun.isEmpty || errRetrun == "") {
                          _currentStep++;
                          if (_currentStep > 0) {
                            _visibleBackBtn = true;
                          } else if (_currentStep <= 0) {
                            _visibleBackBtn = false;
                          }
                          _error = null;
                        } else {
                          _error = errRetrun;
                        }
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
                ),
                const Divider(color: Colors.transparent),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Visibility(
                    visible: _visibleBackBtn,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                          if (_currentStep > 0) {
                            _visibleBackBtn = true;
                          } else if (_currentStep <= 0) {
                            _visibleBackBtn = false;
                          }
                          _error = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                          //fontWeight: FontWeight.bold,
                        ),
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

  Widget changeTextBox(
    int currentStep,
    BuildContext context,
  ) {
    switch (currentStep) {
      case 0:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            );
          },
        );
      case 1:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            );
          },
        );
      case 2:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    _birthdateController.text =
                        "${pickedDate.toLocal()}".split(' ')[0];
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _birthdateController,
                  decoration: InputDecoration(
                    labelText: 'Birthdate',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            );
          },
        );
      case 3:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
              value: _selectedGender,
              items: ['Male', 'Female'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedGender = newValue;
                });
              },
            );
          },
        );
      case 4:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        );
      default:
        return Container();
    }
  }

  String validate(int currentStep) {
    UserServices usrsrvs = UserServices();
    var error = "";
    switch (currentStep) {
      case 0:
        error = usrsrvs.validateUserInput(email: _emailController.text.trim());
      case 1:
        String? fname;
        if (_nameController.text.trim().isEmpty) {
          fname = _nameController.text;
        } else if (_nameController.text.trim().isNotEmpty &&
            (!_nameController.text.trimRight().contains(" ") ||
                _nameController.text.trim().length <= 2)) {
          fname = _nameController.text.trim();
        }
        if (fname != null) {
          error = usrsrvs.validateUserInput(firstName: fname);
        }
        if (error.isEmpty) {
          error = usrsrvs.validateUserInput(
              lastName: _nameController.text.trim().isNotEmpty &&
                      !_nameController.text.trimRight().contains(" ")
                  ? ""
                  : _nameController.text.trim().split(" ")[1]);
        }
      case 2:
        error = usrsrvs.validateUserInput(
            birthdate: _birthdateController.text.trim());
      case 3:
        error = usrsrvs.validateUserInput(gender: _selectedGender);
      default:
        error = "";
    }
    return error;
  }
}
