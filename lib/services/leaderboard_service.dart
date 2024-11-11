import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaderboardService {
  final String serverUrl = 'http://15.184.243.127:8080';

  Future<List<Map<String, dynamic>>> fetchTeams() async {
    final response = await http.get(Uri.parse('$serverUrl/get_teams'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['teams']);
    } else {
      throw Exception('Failed to fetch teams');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(Uri.parse('$serverUrl/get_users'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
