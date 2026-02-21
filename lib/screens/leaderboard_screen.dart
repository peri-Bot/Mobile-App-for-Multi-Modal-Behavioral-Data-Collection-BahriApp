import 'package:bahri_app/services/UserServices.dart';
import 'package:bahri_app/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  UserServices userServices = UserServices();
  final LeaderboardService _leaderboardService = LeaderboardService();
  bool _showTeams = false;
  bool _isLoading = true;
  late Color usrCardColor;
  late String uname;
  List<Map<String, dynamic>> _userLeaderboard = [];
  List<Map<String, dynamic>> _teams = [];
  List<Map<String, dynamic>> _teamScores = [];
  List<Color> medalColors = [Colors.amber, Colors.grey, Colors.brown];

  final Map<String, String> gameDisplayNames = {
    'keystrokeFreetextAmh': 'Amharic Freetext Typing',
    'keystrokeFreetextEng': 'English Freetext Typing',
    'tap': 'Tapping Game',
    'accelo': 'Activity Game',
    'handwritingAmh': 'Amharic Handwriting',
    'handwritingEng': 'English Handwriting',
    'keystrokeAmh': 'Amharic Predefined Typing ',
    'keystrokeEng': 'English Predefined Typing',
    'keystrokePassword': 'Password Typing',
    'swipe': 'Swipe Game',
    'gyro': 'Gyroscope Game'
  };

  @override
  void initState() {
    super.initState();

    _fetchData();
    _leaderboardService.fetchUserId();
    getUserName();
  }

  void getUserName() async {
    final profile = await userServices.getUserProfile();
    uname = profile['userName'];
  }

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

  void _showGameRecommendations(Map<String, dynamic> user) {
    final playedGames = Map<String, bool>.from(user['playedGames']);
    final unplayedGames = playedGames.entries
        .where((entry) => !entry.value)
        .map((entry) => gameDisplayNames[entry.key] ?? entry.key)
        .toList();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          title: Text('Recommendations for ${user['userName']}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Score: ${user['score']}\nGames Played: ${user['gamesPlayed']} out of ${gameDisplayNames.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (unplayedGames.isEmpty)
                  const Text(
                    'Congratulations! You have played all available games!',
                    style: TextStyle(color: Colors.green),
                  )
                else ...[
                  const Text(
                    'Try these games to improve your score:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...unplayedGames.map((game) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.stars,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(game)),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: Playing more games increases your score multiplier!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
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
                    final isCurrentUser = displayName == uname;
                    if (isCurrentUser) {
                      setState(() {
                        usrCardColor = const Color.fromARGB(255, 78, 255, 163);
                      });
                    } else {
                      usrCardColor = Colors.white;
                    }
                    final score = item['score'];
                    return Card(
                      elevation: 3,
                      color: usrCardColor,
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
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName,
                                    overflow: TextOverflow.clip,
                                    softWrap: false,
                                    maxLines: 1,
                                  ),
                                  //if (_showTeams)
                                  // Text(
                                  //   overflow: TextOverflow.clip,
                                  //   softWrap: false,
                                  //   maxLines: 1,
                                  //   'Active Members: ${item['activeMembersCount']}/${item['totalMembersCount']}',
                                  //   style:
                                  //       Theme.of(context).textTheme.bodySmall,
                                  // ),
                                  if (!_showTeams && isCurrentUser)
                                    IconButton(
                                      icon: const Icon(Icons.info_outline,
                                          color: Colors.deepPurple, size: 20),
                                      onPressed: () =>
                                          _showGameRecommendations(item),
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
