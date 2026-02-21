import 'package:bahri_app/screens/TeamPages/check_team_screen.dart';
import 'package:bahri_app/screens/about_screen.dart';
import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/screens/leaderboard_screen.dart';
import 'package:bahri_app/screens/profile_screen.dart';
import 'package:bahri_app/screens/welcome_screen.dart';
import 'package:bahri_app/widgets/PopupDialogBox.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/screens/report_screen.dart';
import 'package:flutter/services.dart';

import '../services/UserServices.dart'; // Import the ReportScreen

class MenuDrawer extends StatelessWidget {
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
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(11), bottomRight: Radius.circular(11)),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Stack(
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Positioned(
                  top: 34,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Closes the drawer
                    },
                  ),
                ),
              ],
            ),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                  ]),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.account_circle, color: Colors.black),
                    title: const Text('Profile',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfilePage()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.home, color: Colors.black),
                    title: const Text('Home',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BaseScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups, color: Colors.black),
                    title: const Text('Team',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BaseScreen(
                                    initialIndex: 1,
                                  )));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.groups, color: Colors.black),
                    title: const Text('Leaderboard',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BaseScreen(
                                    initialIndex: 2,
                                  )));
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white),
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, offset: Offset(4.0, 4.0))
                  ]),
              child: Column(
                children: [
                  const ListTile(
                    title: Text(
                      'Settings',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.report, color: Colors.black),
                    title: const Text('Report',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.black),
                    title: const Text('About',
                        style: TextStyle(color: Colors.black)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AboutScreen()));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.black),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.black)),
                    onTap: () async {
                      bool shouldExit = await _exitApp(context);
                      if (shouldExit) {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      }
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "\n",
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
        ),
      ),
    );
  }
}
