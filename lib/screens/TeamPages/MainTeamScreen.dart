import 'package:bahri_app/screens/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/services/teams_services.dart';

class TeamInfoPage extends StatefulWidget {
  final String teamID;

  const TeamInfoPage({required this.teamID, super.key});

  @override
  State<TeamInfoPage> createState() => _TeamInfoPageState();
}

class _TeamInfoPageState extends State<TeamInfoPage> {
  final TeamsServices _teamsServices = TeamsServices.empty();
  List<Map<String, dynamic>> teamMembers = [];

  @override
  void initState() {
    super.initState();
    _teamsServices.fetchUserId();
    _fetchTeamMembers();
  }

  Future<void> _fetchTeamMembers() async {
    final members = await _teamsServices.getTeamMembers(widget.teamID);
    setState(() {
      teamMembers = members;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Team Info'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const BaseScreen()),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    teamMembers.isEmpty
                        ? const Text('No team members found')
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: teamMembers.length,
                            itemBuilder: (context, index) {
                              final member = teamMembers[index];
                              return Card(
                                elevation: 3,
                                child: ListTile(
                                  title: Text(member['userName']),
                                ),
                              );
                            },
                          ),
                    const SizedBox(height: 20),
                    _buildLeaveButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveButton() {
    return ElevatedButton(
      onPressed: () {
        _confirmLeaveDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: const Text(
        'Leave Team',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  Future<void> _confirmLeaveDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Leave Team'),
          content: const Text('Are you sure you want to leave the team?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Leave'),
              onPressed: () {
                Navigator.of(context).pop();
                _leaveTeam();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _leaveTeam() async {
    final userID = _teamsServices.uid;
    if (userID != null) {
      await _teamsServices.kickOutMember(widget.teamID, userID);

      if (mounted) {
        // Ensure the widget is still mounted

        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BaseScreen()),
        );
      }
    }
  }
}
