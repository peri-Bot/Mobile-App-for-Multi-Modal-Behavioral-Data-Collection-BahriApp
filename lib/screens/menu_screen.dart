import 'package:bahri_app/screens/TeamPages/CreateTeam.dart';
import 'package:bahri_app/screens/TeamPages/Jointeam.dart';
import 'package:bahri_app/screens/TeamPages/MainTeamScreen.dart';
import 'package:bahri_app/screens/TeamPages/NoTeamPage.dart';
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
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.black),
              title: Text('Profile', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                ProfilePage()
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.black),
              title: Text('Home', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    BaseScreen()
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.groups, color: Colors.black),
              title: Text('Group', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    InitialScreen()
                ));
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
            Divider(color: Colors.white), // Add a divider for the settings section
            ListTile(
              title: Text(
                'Settings',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report, color: Colors.black),
              title: Text('Report', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.black),
              title: Text('About', style: TextStyle(color: Colors.black)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    AboutScreen()
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.black),
              title: Text('Logout', style: TextStyle(color: Colors.black)),
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
