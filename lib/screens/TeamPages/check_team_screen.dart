import 'package:bahri_app/screens/TeamPages/MainTeamScreen.dart';
import 'package:bahri_app/screens/TeamPages/NoTeamPage.dart';
import 'package:bahri_app/screens/TeamPages/request_rejected_screen.dart';
import 'package:bahri_app/screens/TeamPages/team_admin_screen.dart';
import 'package:bahri_app/screens/TeamPages/waiting_for_approval.dart';
import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/screens/welcome_screen.dart';
import 'package:bahri_app/services/teams_services.dart';
import 'package:bahri_app/widgets/LogoCircularBorder.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CheckTeamScreen extends StatefulWidget {
  const CheckTeamScreen({super.key});

  @override
  State<CheckTeamScreen> createState() => _CheckTeamScreen();
}

class _CheckTeamScreen extends State<CheckTeamScreen> {
  final _secureStorage = const FlutterSecureStorage();
  final _teamsServices = TeamsServices.empty();
  String? teamID;

  @override
  void initState() {
    super.initState();
    _teamsServices.fetchUserId(); // Fetch the user ID in the service
    _checkConnectionAndTeamStatus();
  }

  Future<void> _checkConnectionAndTeamStatus() async {
    // Keep checking for internet connectivity
    while (!(await isConnectedToInternet())) {
      await Future.delayed(
          const Duration(seconds: 1)); // Wait before checking again
    }

    // Once connected, proceed with checking team status
    _checkTeamStatus();
  }

  Future<void> _checkTeamStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    // Call the checkUserStatus method in TeamsServices to determine team status
    Map<String, dynamic> teamStatus = await _teamsServices.checkUserStatus();

    if (mounted) {
      if (teamStatus['status'] == 'inTeam') {
        final teamID = teamStatus['teamID'];
        if (teamStatus['isManager'] == true) {
          // If the user is the team admin, navigate to the TeamAdminScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeamAdminScreen(
                      teamID: teamID,
                    )),
          );
        } else {
          // If the user is not the team admin, navigate to the regular TeamInfoPage
          debugPrint("Navigating to team info page");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => TeamInfoPage(
                      teamID: teamID,
                    )),
          );
        }
      } else if (teamStatus['status'] == 'pendingRequest') {
        // If the user has a pending join request, navigate to WaitingForApprovalPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const WaitingForApprovalScreen()),
        );
      } else if (teamStatus['status'] == 'rejected') {
        // If the user's join request was rejected, navigate to the RequestRejectedScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RequestRejectedScreen()),
        );
      } else if (teamStatus['status'] == 'notInATeam') {
        // If the user is not in a team, navigate to the page where they can create or join a team
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const InitialScreen()), // This could be a screen for joining or creating teams
        );
      } else {
        // Handle other possible cases, such as errors
        debugPrint('Something went wrong. Status: ${teamStatus['status']}');
      }
    }
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gradient background

          // Content goes here
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.groups,
                    size: 30,
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Checking for internet connection...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
