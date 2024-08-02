import 'package:bahri_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    // Add other screens here, e.g. SecondScreen(), ThirdScreen(), etc.
    const Center(child: Text('Groups Screen')), // Placeholder for Groups Screen
    const Center(
        child:
            Text('Leaderboard Screen')), // Placeholder for Leaderboard Screen
    const Center(
        child: Text(
            'Pending Actions Screen')), // Placeholder for Pending Actions Screen
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
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
          // Content goes here
          SafeArea(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(
          Icons.menu,
          color: Colors.white,
          size: 25,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Icon(
              Icons.account_circle,
              size: 25,
            ),
          )
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: 53,
        backgroundColor:
            Colors.transparent, // Make navigation bar background transparent
        //color: Colors.transparent,
        //animationCurve: Curves.ease,
        animationDuration: const Duration(milliseconds: 150),
        items: const [
          Icon(Icons.home),
          Icon(Icons.groups),
          Icon(Icons.leaderboard),
          Icon(Icons.pending_actions),
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
//backgroundColor: const Color.fromRGBO(172, 185, 255, 1),
