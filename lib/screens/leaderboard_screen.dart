import 'package:bahri_app/services/leaderboard_service.dart';
import 'package:flutter/material.dart';
//import 'leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  bool _showTeams = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dataList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      if (_showTeams) {
        _dataList = await _leaderboardService.fetchTeams();
      } else {
        _dataList = await _leaderboardService.fetchUsers();
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleView() {
    setState(() => _showTeams = !_showTeams);
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
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
                  children: List.generate(_dataList.length, (index) {
                    final item = _dataList[index];
                    final displayName =
                        _showTeams ? item['teamName'] : item['userName'];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              //fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ), // Ranking number
                        ),
                        title: Text(displayName),
                      ),
                    );
                  }),
                ),
              ),
            ),
    );
  }
}
