import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mailto/mailto.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String? selectedError;
  final TextEditingController _customErrorController = TextEditingController();

  final List<String> commonErrors = [
    "App Crashing",
    "Slow Performance",
    "Login Issues",
    "Data Sync Issues",
    "Other"
  ];

  Future<void> _sendReport(String message) async {
    // Construct the email using mailto
    final mailtoLink = Mailto(
      to: ['BahriApp@gmail.com'],
      subject: 'Error Report from User',
      body: message,
    );

    // Launch the mailto link
    await launch('$mailtoLink');
  }

  Future<void> _submitReport() async {
    // Check if user is online
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showDialog('Error', 'Please connect to the internet and try again.');
      return;
    }

    // Get the selected or custom error message
    String errorMessage = selectedError == 'Other'
        ? _customErrorController.text
        : selectedError ?? '';

    if (errorMessage.isEmpty) {
      _showDialog('Error', 'Please select or enter an error to report.');
      return;
    }

    try {
      await _sendReport(errorMessage);
      _showDialog('Success', 'Your report has been sent successfully.');
    } catch (e) {
      _showDialog('Error', 'Failed to send report. Please try again.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Report an Issue'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Text
              SizedBox(height: 150), // Spacing to adjust for the transparent app bar
              Text(
                'We\'re here to help!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),

              // Known Errors Dropdown
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedError,
                  decoration: InputDecoration.collapsed(hintText: ''),
                  hint: Text('Select an issue'),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedError = newValue;
                    });
                  },
                  items: commonErrors.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),

              // If 'Other' is selected, show a TextField for custom input
              if (selectedError == 'Other')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _customErrorController,
                    decoration: InputDecoration(
                      labelText: 'Describe the issue',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                  ),
                ),

              SizedBox(height: 16),

              // Submit Button with the same gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [
                      Color.fromRGBO(183, 153, 255, 1),
                      Color.fromRGBO(172, 188, 255, 1),
                      Color.fromRGBO(174, 226, 255, 1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
