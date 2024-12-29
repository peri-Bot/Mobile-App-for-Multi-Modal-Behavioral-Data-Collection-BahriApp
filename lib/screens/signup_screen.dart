import 'package:bahri_app/screens/login_screen.dart';
import 'package:bahri_app/services/enums.dart';
import 'package:bahri_app/widgets/PopupDialogBox.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/widgets.dart';
import 'package:bahri_app/widgets/CustomStepper.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:bahri_app/services/UserServices.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:stroke_text/stroke_text.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  int _currentStep = 0;
  bool _visibleBackBtn = false;
  bool _isBackBtnDIsabled = false;
  bool _isContinueBtnDIsabled = false;

  String? _error;
  final TextEditingController _usernameController = TextEditingController();
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
      extendBody: true,
      extendBodyBehindAppBar: true,
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
                    child: const StrokeText(
                      text: "CREATE ACCOUNT",
                      textStyle: TextStyle(
                        fontFamily: "assets/fonts/Poppins-Regular.ttf",
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                      strokeColor: Color.fromARGB(255, 255, 255, 255),
                      strokeWidth: 1.9,
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
                      {'title': 'Username', 'image': 'assets/images/check.svg'},
                      {'title': 'fullName', 'image': 'assets/images/check.svg'},
                      {
                        'title': 'Date of Birth',
                        'image': 'assets/images/check.svg'
                      },
                      {'title': 'Gender', 'image': 'assets/images/check.svg'},
                      {'title': 'Skill', 'image': 'assets/images/check.svg'},
                      {'title': 'Password', 'image': 'assets/images/check.svg'},
                      {
                        'title': 'Terms of Service',
                        'image': 'assets/images/check.svg'
                      },
                      //{'title': "OTP", 'image': 'assets/images/check.svg'}
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
                    onPressed: _isContinueBtnDIsabled
                        ? null
                        : () async {
                            // Move async here instead of in setState
                            var errRetrun = validate(_currentStep);

                            if (_currentStep == 6) {
                              setState(() {
                                _isBackBtnDIsabled = true;
                                _isContinueBtnDIsabled = true;
                              });

                              UserServices newSrvc = UserServices();
                              Random rng = Random();
                              final dateString = _birthdateController.text;
                              final dateFormat = DateFormat('yyyy-MM-dd');
                              DateTime dateti = dateFormat.parse(dateString);

                              newSrvc.newUser = newSrvc.createUser(
                                  id: rng.nextInt(100).toDouble(),
                                  firstName:
                                      _nameController.text.trim().split(" ")[0],
                                  lastName:
                                      _nameController.text.trim().split(" ")[1],
                                  dOB: dateti,
                                  gender: _selectedGender![0],
                                  userName: _usernameController.text.trim(),
                                  skillLevel: _selectedSkill!,
                                  password: _passwordController.text,
                                  progress: rng.nextInt(100).toDouble());
                              var result =
                                  newSrvc.registerUserDartFrog(context);
                              confirmregister(result);
                            } else if (errRetrun.isEmpty || errRetrun == "") {
                              if (_currentStep == 0) {
                                setState(() {
                                  _isContinueBtnDIsabled = true;
                                  _error = null;
                                });

                                UserServices uService = UserServices();
                                var res =
                                    await uService.checkUsernameAvailability(
                                        _usernameController.text.trim());

                                setState(() {
                                  switch (res) {
                                    case UsernameCheckResult.usernameAvailable:
                                      _currentStep++;
                                      _error = null;
                                      _isContinueBtnDIsabled = false;
                                      break;
                                    case UsernameCheckResult.usernameTaken:
                                      _isContinueBtnDIsabled = false;
                                      _error =
                                          "Username '${_usernameController.text.trim()}' is already taken.";
                                      break;
                                    case UsernameCheckResult.error:
                                      _error =
                                          "An error occurred while checking the username.";
                                      _isContinueBtnDIsabled = false;
                                      break;
                                    default:
                                      _error =
                                          "An error occurred while checking the username.";
                                      _isContinueBtnDIsabled = false;
                                      break;
                                  }
                                  if (_currentStep > 0) {
                                    _visibleBackBtn = true;
                                  } else if (_currentStep <= 0) {
                                    _visibleBackBtn = false;
                                  }
                                });
                              } else if (_currentStep < 6) {
                                setState(() {
                                  _currentStep++;
                                  _error = null;

                                  if (_currentStep > 0) {
                                    _visibleBackBtn = true;
                                  } else if (_currentStep <= 0) {
                                    _visibleBackBtn = false;
                                  }
                                });
                              }
                            } else {
                              setState(() {
                                _error = errRetrun;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB19EF0),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isContinueBtnDIsabled
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
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
                        _isBackBtnDIsabled
                            ? null
                            : setState(() {
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
                      child: _isBackBtnDIsabled
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            )
                          : const Text(
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
              controller: _usernameController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                labelText: 'Username',
                errorText: _error,
                border: const UnderlineInputBorder(),
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
                fillColor: Colors.white,
                filled: true,
                labelText: 'First Name And Last Name [Separated by Space]',
                errorText: _error,
                border: const UnderlineInputBorder(),
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
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Birthdate',
                    errorText: _error,
                    border: const UnderlineInputBorder(),
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
                fillColor: Colors.white,
                filled: true,
                errorText: _error,
                border: const UnderlineInputBorder(),
              ),
              dropdownColor: Colors.white, // Background color of dropdown menu
              menuMaxHeight: 200, // Optional: limits the height of dropdown
              borderRadius:
                  BorderRadius.circular(8), // Border radius of dropdown menu
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
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: StrokeText(
                        text: 'SELECT YOUR PHONE UTILIZATION SKILL LEVEL',
                        textStyle: TextStyle(
                          fontFamily: "assets/fonts/Poppins-Regular.ttf",
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        strokeColor: Color.fromARGB(255, 255, 255, 255),
                        strokeWidth: 0,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                      ),
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          contentPadding: EdgeInsets.zero,
                          visualDensity: const VisualDensity(
                            horizontal: -4.0,
                            vertical: -4.0, // Added vertical density adjustment
                          ),
                          value: levels[index],
                          groupValue: _selectedSkill,
                          selected: _selectedSkill == levels[index],
                          onChanged: (newValue) {
                            setState(() {
                              _selectedSkill = newValue;
                            });
                          },
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .center, // Align items vertically center
                            children: [
                              Expanded(
                                // Wrap RichText with Expanded
                                child: RichText(
                                  textAlign: TextAlign.start,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: levels[index],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                          height: 1.0, // Add line height
                                        ),
                                      ),
                                      const WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: SizedBox(
                                            width:
                                                7), // Add space between text and icon
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment
                                            .middle, // Align icon with text
                                        child: SizedBox(
                                          // Wrap IconButton with SizedBox for consistent sizing
                                          height: 24,
                                          width: 24,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints:
                                                const BoxConstraints(), // Remove default constraints
                                            onPressed: () {
                                              String filename = "";
                                              switch (index) {
                                                case 0:
                                                  filename = "Basic_Skill.md";
                                                case 1:
                                                  filename =
                                                      "Intermediate_Skill.md";
                                                case 2:
                                                  filename =
                                                      "Advanced_Skill.md";
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
                                              Icons.info,
                                              size:
                                                  17, // Slightly increased icon size
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              )
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
                    fillColor: Colors.white,
                    filled: true,
                    errorText: _error,
                    border: const UnderlineInputBorder(),
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
                    fillColor: Colors.white,
                    filled: true,
                    border: const UnderlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
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
                  controller: _usernameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Username',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const Divider(color: Colors.transparent),
                TextField(
                  controller: _nameController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Full Name',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _birthdateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Date of birth',
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: _selectedGender),
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Gender',
                    fillColor: Colors.white,
                    filled: true,
                    border: UnderlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: TextEditingController(text: _selectedSkill),
                  readOnly: true,
                  decoration: const InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelText: 'Skill Level',
                    fillColor: Colors.white,
                    filled: true,
                    border: UnderlineInputBorder(),
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

      default:
        return Container();
    }
  }

  String validate(int currentStep) {
    UserServices usrsrvs = UserServices();
    var error = "";
    switch (currentStep) {
      case 0:
        error = usrsrvs.validateUserInput(
            username: _usernameController.text.trim());
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

  void confirmregister(Future<String> result) async {
    String res = await result;
    if (!mounted) return;

    if (res == 'sucess') {
      int countdown = 5; // Initial countdown value

      // Show a dialog with countdown
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent closing the dialog manually
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              // Timer to update countdown every second
              Future.delayed(Duration(seconds: 1), () {
                if (countdown > 1) {
                  setState(() {
                    countdown--;
                  });
                } else {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate back to the login screen
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                }
              });

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11), // Set border radius
                ),
                backgroundColor: Colors.white, // Set dialog background color
                child: Padding(
                  padding: const EdgeInsets.all(
                      20.0), // Add padding inside the dialog
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Wrap content
                    children: [
                      const Text(
                        "Successfully Registered",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Black text color
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Redirecting to homepage in $countdown seconds...",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black, // Black text color
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      _isContinueBtnDIsabled = false;
      _isBackBtnDIsabled = false;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something went wrong, Please try again later")));
    }
  }
}
