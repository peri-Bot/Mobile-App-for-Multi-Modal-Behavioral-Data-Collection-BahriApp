import 'package:bahri_app/screens/TeamPages/check_team_screen.dart';
import 'package:bahri_app/screens/game_screens/games_list_screen.dart';
import 'package:bahri_app/screens/leaderboard_screen.dart';
import 'package:bahri_app/screens/profile_screen.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

import 'menu_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    //const HomeScreen(),
    const GamesListScreen(),
    // Add other screens here, e.g. SecondScreen(), ThirdScreen(), etc.
    const CheckTeamScreen(), // Placeholder for Groups Screen
    LeaderboardPage(), // Placeholder for Leaderboard Screen
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      drawer: MenuDrawer(), // Add this line
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
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 25,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: const Icon(
                Icons.account_circle,
                size: 25,
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 53,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 150),
        items: const [
          Icon(Icons.home),
          Icon(Icons.groups),
          Icon(Icons.leaderboard),
        ],
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}
