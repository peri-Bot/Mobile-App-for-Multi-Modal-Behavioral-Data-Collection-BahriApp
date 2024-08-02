import 'package:bahri_app/widgets/PopupDialogBox.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:bahri_app/widgets/CustomStepper.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:bahri_app/services/UserServices.dart';
import 'package:pinput/pinput.dart';

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
  String? _selectedSkill;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                      {'title': 'DoB', 'image': 'assets/images/check.svg'},
                      {'title': 'Gender', 'image': 'assets/images/check.svg'},
                      {'title': 'Skill', 'image': 'assets/images/check.svg'},
                      {'title': 'PWD', 'image': 'assets/images/check.svg'},
                      {'title': 'TOS', 'image': 'assets/images/check.svg'},
                      {'title': "OTP", 'image': 'assets/images/check.svg'}
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
                          if (_currentStep < 7) {
                            _currentStep++;
                          }
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
    final levels = ["Basic", "Mid", "Skilled ", "Expert"];
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
                labelText: 'First Name And Last Name [Separated by Space]',
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
                  initialDate: DateTime(2011),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2011),
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
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(0.0),
                child: Text(
                  'Select Your Phone Skill level',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "assets/fonts/Poppins-Bold.ttf",
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    //crossAxisSpacing: 0,
                  ),
                  itemCount: levels.length,
                  itemBuilder: (context, index) {
                    return RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4.0),
                      //dense: true,
                      value: levels[index],
                      groupValue: _selectedSkill,
                      selected: _selectedSkill == levels[index],
                      onChanged: (newValue) {
                        setState(
                          () {
                            _selectedSkill = newValue;
                          },
                        );
                      },
                      title: Row(
                        children: [
                          Flexible(
                            //fit: FlexFit.loose,
                            child: Text(
                              levels[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          Flexible(
                            //fit: FlexFit.tight,
                            child: IconButton(
                              onPressed: () {
                                String filename = "";
                                switch (index) {
                                  case 0:
                                    filename = "Basic_Skill.md";
                                  case 1:
                                    filename = "Intermediate_Skill.md";
                                  case 2:
                                    filename = "Advanced_Skill.md";
                                  case 3:
                                    filename = "Expert_skill.md";
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Popupdialogbox(
                                      mdFileName: filename,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.help_outline,
                                size: 11,
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            ],
          );
        });
      case 5:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: _error,
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        );
      case 6:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                const Center(
                  child: Text(
                    "Confirm Details",
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const Divider(color: Colors.transparent),
                TextField(
                  controller: _emailController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const Divider(color: Colors.transparent),
                TextField(
                  controller: _nameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _birthdateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Date of birth',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: _selectedGender),
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: _selectedSkill),
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Skill Level',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "By creating an account, you are agreeing to our\n",
                      style: const TextStyle(
                          fontFamily: "assets/fonts/Poppins-Bold.ttf",
                          color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Terms & Conditions ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Popupdialogbox(
                                    mdFileName: 'Terms_and_Conditions.md',
                                  );
                                },
                              );
                            },
                        ),
                        const TextSpan(text: "and "),
                        TextSpan(
                          text: "Privacy Policy! ",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Popupdialogbox(
                                    mdFileName: 'Privacy__Policy.md',
                                  );
                                },
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        );

      case 7:
        return StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) {
            return Column(
              children: [
                Center(
                  child: Text(
                    "Enter the code sent to ${_emailController.text}",
                    style: const TextStyle(
                      fontFamily: "assets/fonts/Poppins-Bold.ttf",
                    ),
                  ),
                ),
                const Divider(color: Colors.transparent),
                const Pinput(
                  length: 4,
                )
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
      case 4:
        error = usrsrvs.validateUserInput(skillLevle: _selectedSkill);
      case 5:
        error = usrsrvs.validateUserInput(
            password: _passwordController.text.trim(),
            rePassword: _confirmPasswordController.text.trim());
      default:
        error = "";
    }
    return error;
  }
}
