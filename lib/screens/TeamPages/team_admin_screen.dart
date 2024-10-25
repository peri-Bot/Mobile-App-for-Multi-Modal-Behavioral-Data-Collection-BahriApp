import 'package:bahri_app/screens/base_screen.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/services/teams_services.dart';

class TeamAdminScreen extends StatefulWidget {
  final String teamID;

  const TeamAdminScreen({required this.teamID, super.key});

  @override
  State<TeamAdminScreen> createState() => _TeamAdminScreenState();
}

class _TeamAdminScreenState extends State<TeamAdminScreen> {
  final TeamsServices _teamsServices = TeamsServices.empty();

  List<Map<String, dynamic>> pendingRequests = [];
  List<Map<String, dynamic>> teamMembers = [];

  @override
  void initState() {
    super.initState();
    _teamsServices.fetchUserId();
    _fetchPendingRequests();
    _fetchTeamMembers();
  }

  Future<void> _fetchPendingRequests() async {
    final requests = await _teamsServices.getPendingRequests(widget.teamID);
    setState(() {
      pendingRequests = requests;
    });
  }

  Future<void> _fetchTeamMembers() async {
    debugPrint("Fetching memebers:");

    final members = await _teamsServices.getTeamMembers(widget.teamID);
    debugPrint("teamMemebrs: $members");
    setState(() {
      teamMembers = members;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Team Admin'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
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
          SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildPendingRequestsSection(),
                    const SizedBox(height: 20),
                    _buildTeamMembersSection(),
                    const SizedBox(height: 20),
                    _buildKickOutSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Requests',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        pendingRequests.isEmpty
            ? const Text('No pending requests')
            : Column(
                children: pendingRequests.map((request) {
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(request['userName']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              _acceptRequest(request['userID']);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              _rejectRequest(request['userID']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTeamMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            : Column(
                children: teamMembers.map((member) {
                  return Card(
                    elevation: 3,
                    child: ListTile(
                      title: Text(member['userName']),
                      subtitle: Text(
                          'Tap Score: ${member['tapScore']}, Keystroke Score: ${member['keystrokeScore']}, Swipe Score: ${member['swipeScore']}'),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildKickOutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kick a Member Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: teamMembers
              .where((member) =>
                  member['userID'].toString().trim() !=
                  _teamsServices.uid.toString().trim())
              .map((member) {
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text(member['userName']),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _kickOutMember(member['userID']);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _acceptRequest(String userID) async {
    await _teamsServices.acceptJoinRequest(widget.teamID, userID);
    _fetchPendingRequests();
    _fetchTeamMembers();
  }

  Future<void> _rejectRequest(String userID) async {
    await _teamsServices.rejectJoinRequest(widget.teamID, userID);
    _fetchPendingRequests();
  }

  Future<void> _kickOutMember(String userID) async {
    await _teamsServices.kickOutMember(widget.teamID, userID);
    _fetchTeamMembers();
  }
}
