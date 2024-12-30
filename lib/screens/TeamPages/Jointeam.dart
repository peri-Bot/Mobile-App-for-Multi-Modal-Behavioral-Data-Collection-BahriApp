import 'package:bahri_app/screens/base_screen.dart';
import 'package:bahri_app/services/teams_services.dart';
import 'package:flutter/material.dart';

class JoinTeamPage extends StatefulWidget {
  const JoinTeamPage({super.key});

  @override
  State<JoinTeamPage> createState() => _JoinTeamPageState();
}

class _JoinTeamPageState extends State<JoinTeamPage> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _teamsFuture;
  List<Map<String, dynamic>> _filteredTeams = [];
  final TeamsServices _teamsServices = TeamsServices.empty();

  @override
  void initState() {
    super.initState();
    _teamsFuture = TeamsServices().getTeams();
    _teamsServices.fetchUserId();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtering teams based on the search input
  void _filterTeams(String query) {
    setState(() {
      _teamsFuture.then((teams) {
        _filteredTeams = teams.where((team) {
          final teamName = team['teamName'].toLowerCase();
          return teamName.contains(query.toLowerCase());
        }).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.lightBlueAccent,
      appBar: AppBar(
        title: const Text('Join Team'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      const Text(
                        'Search for a team to join',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 3, 2, 2),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _searchController,
                        onChanged: _filterTeams,
                        decoration: InputDecoration(
                          labelText: 'Search teams',
                          hintText: 'Enter team name or keyword',
                          filled: true,
                          fillColor: Colors.white,
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Available Teams',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Fetch and display teams
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _teamsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Failed to load teams'));
                          } else if (snapshot.hasData) {
                            final teams = snapshot.data!;
                            // Use filtered teams or all teams
                            final displayTeams = _filteredTeams.isEmpty &&
                                    _searchController.text.isEmpty
                                ? teams
                                : _filteredTeams;

                            if (displayTeams.isEmpty) {
                              return const Center(
                                  child: Text('No teams found'));
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: displayTeams.length,
                              itemBuilder: (context, index) {
                                final team = displayTeams[index];
                                return Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        team['teamName'] ?? 'Unknown Team'),
                                    subtitle: Text(team['teamDescription'] ??
                                        'No description'),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        showLoaderDialog(context);
                                        String result = await _teamsServices
                                            .submitJoinRequest(team["teamID"]);
                                        if (result == "sucess") {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      "you have submmited your request to join: ${team['teamName']}")));

                                          Navigator.of(context).popUntil(
                                              (route) => route.isFirst);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const BaseScreen()),
                                          );
                                        }
                                        // Add join team logic here
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        backgroundColor:
                                            const Color(0xFFB19EF0),
                                      ),
                                      child: const Text(
                                        'Join',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 7),
              child: const Text("Requesting...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
