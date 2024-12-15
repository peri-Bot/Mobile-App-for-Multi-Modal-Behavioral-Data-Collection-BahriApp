import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'dart:math';
import './../widgets/keyboard/utils/types.dart';
import 'package:http/http.dart' as http;

class HandwritingServices {
  String? uid;
  String? svgContent;
  Future<void> fetchUserId() async {
    uid = await getUserId();
    debugPrint("User ID is set: ==$uid");
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();
    return await secureStorage.read(key: 'uid');
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

  Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('offlineHandwritingData');
  }

  String exportToSVG(List<Offset?> points) {
    final StringBuffer buffer = StringBuffer();

    // SVG header
    buffer.writeln('<svg xmlns="http://www.w3.org/2000/svg" version="1.1">');

    // Path element for drawing
    buffer.write('<path d="');

    for (int i = 0; i < points.length; i++) {
      if (points[i] != null) {
        final command = (i == 0 || points[i - 1] == null) ? 'M' : 'L';
        buffer.write('$command ${points[i]!.dx},${points[i]!.dy} ');
      }
    }

    buffer.writeln('" fill="none" stroke="black" stroke-width="2" />');

    // Close the SVG
    buffer.writeln('</svg>');

    return buffer.toString();
  }

  Future<String> saveHandwritingData(Map<String, dynamic> gameInfo) async {
    bool isOnline = await isConnectedToInternet();

    gameInfo['uid'] = uid;

    final Map<String, dynamic> requestData = {
      'gameInfo': gameInfo,
      'HandwritingData': svgContent,
    };

    debugPrint('Request Data:');
    debugPrint('Game Info: ${requestData['gameInfo']}');
    debugPrint('Handwriting Data: ${requestData['HandwritingData']}');
    if (!isOnline) {
      // Save data to Hive if offline
      var box = Hive.box('offlineHandwritingData');
      await box.add(requestData);
      debugPrint('Data saved locally (offline).');
      return 'saved_locally';
    }

    final url = Uri.parse(
        'http://15.184.243.127:8080/collect_Handwriting_data'); // Use your Dart Frog server address

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        // User registered successfully
        debugPrint('  Handwriting Data added');
        return 'success';
      } else {
        // Handle error
        debugPrint('Could not add Handwriting data: ${response.body}');
        var box = Hive.box('offlineHandwritingData');
        await box.add(requestData);
        debugPrint('Data saved locally (offline).');
        return 'Server Error: saved_locally';
      }
    } catch (e) {
      debugPrint('Error occurred Handwriting : $e');
      var box = Hive.box('offlineHandwritingData');
      await box.add(requestData);
      debugPrint('Data saved locally (offline).');
      return 'Server Error: saved_locally';
    }
  }
}
