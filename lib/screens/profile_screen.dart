import 'package:bahri_app/screens/welcome_screen.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bahri_app/services/UserServices.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserServices _userServices = UserServices();

  TextEditingController? usernameController;
  TextEditingController? nameController;
  TextEditingController? genderController;
  TextEditingController? skillController;
  TextEditingController? doBController;
  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: "");
    nameController = TextEditingController(text: "");
    genderController = TextEditingController(text: "");
    skillController = TextEditingController(text: "");
    doBController = TextEditingController(text: "");
    _populateTextControllers();
  }

  void _populateTextControllers() async {
    final profile = await _userServices.getUserProfile();

    setState(() {
      usernameController?.text = profile['userName'];
      debugPrint("${usernameController?.text}");
      nameController?.text = "${profile['firstName']} ${profile['lastName']}";
      genderController?.text = profile['gender'] == "f" ? "Female" : "Male";
      skillController?.text = profile['skillLevel'];
      doBController?.text =
          calculateAge(profile['dateOfBirth'] as String).toString();
      debugPrint("${doBController?.text}");
    });
  }

  int calculateAge(String birthDateString) {
    // Parse the birth date string into a DateTime object
    DateTime birthDate = DateTime.parse(birthDateString);
    DateTime today = DateTime.now();

    // Calculate the age
    int age = today.year - birthDate.year;

    // Adjust age if the current date is before the birthday this year
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  Future<bool> _exitApp(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          textAlign: TextAlign.center,
          'Confirm Logout',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.exit_to_app,
              size: 50,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            SizedBox(height: 10),
            Text(
              'Are you sure you want to Logout?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
                child: const Text(
                  'No',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  UserServices userServices = UserServices();
                  userServices.logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                    (Route<dynamic> route) => false, // Remove all routes
                  );
                },
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9))),
                child: const Text('Yes'),
              ),
            ],
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () async {
                bool shouldExit = await _exitApp(context);
                if (shouldExit) {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }
              },
              child: const Icon(
                Icons.logout_outlined,
                size: 25,
              ),
            ),
          )
        ],
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
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Divider(color: Colors.transparent),
                    const Divider(color: Colors.transparent),
                    const LogoCircularBorder(widthfactor: 0.30),
                    const SizedBox(
                      height: 7,
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Divider(color: Colors.transparent),
                          TextField(
                            controller: usernameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Username',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const Divider(color: Colors.transparent),
                          TextField(
                            controller: nameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Full Name',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: genderController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Gender',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: skillController,
                            readOnly: true,
                            showCursor: false,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Skill Level',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: doBController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelText: 'Age',
                              border: UnderlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
