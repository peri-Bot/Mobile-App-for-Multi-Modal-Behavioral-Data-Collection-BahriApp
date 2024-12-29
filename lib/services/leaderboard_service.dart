import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LeaderboardService {
  final String serverUrl = 'http://15.184.243.127:8080';
  String? uid;
  Future<List<Map<String, dynamic>>> fetchTeams() async {
    final response = await http.get(Uri.parse('$serverUrl/get_teams'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['teams']);
    } else {
      throw Exception('Failed to fetch teams');
    }
  }

  Future<void> fetchUserId() async {
    uid = await getUserId();
    //debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response =
        await http.get(Uri.parse('$serverUrl/api/v2/get_user_leaderboard'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (!data.containsKey('leaderboard')) {
        throw Exception('Invalid response format: missing leaderboard key');
      }

      final leaderboard = List<Map<String, dynamic>>.from(data['leaderboard']);
      return leaderboard;
    } else {
      throw Exception('Failed to fetch users: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchLeaderboardData() async {
    final response =
        await http.get(Uri.parse('$serverUrl/api/v2/get_user_leaderboard'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (!data.containsKey('userLeaderboard') || !data.containsKey('teams')) {
        throw Exception('Invalid response format: missing required keys');
      }

      return data;
    } else {
      throw Exception(
          'Failed to fetch leaderboard data: ${response.statusCode}');
    }
  }
}
