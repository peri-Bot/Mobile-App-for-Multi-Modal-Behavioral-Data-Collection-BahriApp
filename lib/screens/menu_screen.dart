import 'package:bahri_app/screens/TeamPages/CreateTeam.dart';
import 'package:bahri_app/screens/TeamPages/Jointeam.dart';
import 'package:bahri_app/screens/TeamPages/MainTeamScreen.dart';
import 'package:bahri_app/screens/TeamPages/NoTeamPage.dart';
import 'package:bahri_app/screens/TeamPages/check_team_screen.dart';
import 'package:bahri_app/screens/about_screen.dart';
import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/screens/home_screen.dart';
import 'package:bahri_app/screens/profile_screen.dart';
import 'package:bahri_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/screens/report_screen.dart';

import '../services/UserServices.dart'; // Import the ReportScreen

class MenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.black),
              title:
                  const Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.black),
              title: const Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BaseScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.groups, color: Colors.black),
              title: const Text('Team', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CheckTeamScreen()));
              },
            ),
            /* ListTile(
              leading: Icon(Icons.leaderboard, color: Colors.black),
              title: Text('Leaderboard', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    ProfilePage()
                ));
              },
            ),*/
            const Divider(
                color: Colors.white), // Add a divider for the settings section
            const ListTile(
              title: Text(
                'Settings',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.black),
              title:
                  const Text('Report', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.black),
              title: const Text('About', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.black),
              title:
                  const Text('Logout', style: TextStyle(color: Colors.black)),
              onTap: () {
                UserServices userServices = UserServices();
                userServices.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                  (Route<dynamic> route) => false, // Remove all routes
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
