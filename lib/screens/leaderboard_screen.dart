import 'package:bahri_app/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
//import 'leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  bool _showTeams = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dataList = [];
  List<Map<String, dynamic>> _userLeaderboard = [];
  List<Map<String, dynamic>> _teams = [];
  List<Map<String, dynamic>> _teamScores = [];
  List<Color> medalColors = [Colors.amber, Colors.grey, Colors.brown];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _leaderboardService.fetchUserId();
  }

  // Future<void> _fetchData() async {
  //   setState(() => _isLoading = true);
  //   try {
  //     if (_showTeams) {
  //       _dataList = await _leaderboardService.fetchTeams();
  //     } else {
  //       _dataList = await _leaderboardService.fetchUsers();
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching data: $e');
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }
  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _leaderboardService.fetchLeaderboardData();
      _userLeaderboard =
          List<Map<String, dynamic>>.from(data['userLeaderboard']);
      _teams = List<Map<String, dynamic>>.from(data['teams']);
      _calculateTeamScores();
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _calculateTeamScores() {
    _teamScores = _teams.map((team) {
      final memberIds = List<String>.from(team['members']);
      int totalScore = 0;
      int teamMembersFound = 0;

      for (final memberId in memberIds) {
        final userScore = _userLeaderboard.firstWhere(
          (user) => user['userId'] == memberId,
          orElse: () => {'score': 0},
        );

        if (userScore['score'] != null) {
          totalScore += userScore['score'] as int;
          teamMembersFound++;
        }
      }

      return {
        'teamName': team['teamName'],
        'score': totalScore,
        'activeMembersCount': teamMembersFound,
        'totalMembersCount': memberIds.length,
      };
    }).toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
  }

  void _toggleView() {
    setState(() => _showTeams = !_showTeams);
    //_fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final displayList = _showTeams ? _teamScores : _userLeaderboard;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: Icon(_showTeams ? Icons.group : Icons.person),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: List.generate(displayList.length, (index) {
                    final item = displayList[index];
                    final displayName =
                        _showTeams ? item['teamName'] : item['userName'];
                    final score = item['score'];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              index < 3 ? medalColors[index] : Colors.black,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ), // Ranking number
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //children: [Text(displayName), Text(score.toString())],
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(displayName),
                                  if (_showTeams)
                                    Text(
                                      'Active Members: ${item['activeMembersCount']}/${item['totalMembersCount']}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ),
                            Text(score.toString()),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
    );
  }
}
