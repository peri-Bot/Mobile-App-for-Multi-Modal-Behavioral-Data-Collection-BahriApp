import 'dart:math';
import 'package:bahri_app/services/handwriting_services.dart';
import 'package:bahri_app/widgets/fade_message_box.dart';
import 'package:flutter/material.dart';

class HandwritingScreen extends StatefulWidget {
  final bool isAmharic;
  const HandwritingScreen({super.key, required this.isAmharic});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  List<Offset?> points = []; // List of points for the drawing
  late bool isAmharic;
  bool _canPop = false;
  bool _drawn = false;

  void updateCanPop(bool value) {
    setState(() {
      _canPop = value;
    });
  }

  final HandwritingServices handwritingServices = HandwritingServices();
  late Map<String, dynamic> gameInfo;

  String? randomLetter; // Generate a random uppercase letter
  @override
  void initState() {
    super.initState();
    isAmharic = widget.isAmharic;
    if (!isAmharic) {
      randomLetter = String.fromCharCode(Random().nextBool()
          ? Random().nextInt(26) + 65
          : Random().nextInt(26) + 97);
    } else {
      randomLetter = String.fromCharCode(Random().nextInt(128) + 0x1200);
    }
    handwritingServices.fetchUserId();
    handwritingServices.initHive();
    gameInfo = {
      'startTime': DateTime.now().toIso8601String(),
      'Letter': "$randomLetter",
      'language': isAmharic ? "Amharic" : "English",
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }

        // Show the fade message box when the back button is pressed
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent dismissing by tapping outside
          builder: (context) {
            return const FadeMessageBox(
              message: "Please Play the game first.", // Custom message
              duration: Duration(seconds: 2), // Custom fade duration
            );
          },
        );
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Handwriting Practice'),
          leading: IconButton(
            icon: const Icon(Icons.lock),
            onPressed: () {
              // Navigator.of(context).pop(); // Navigate back
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      readOnly: true,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromARGB(0, 255, 255, 255),
                        hintText: randomLetter, // Display the random letter
                        hintStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        color: Colors.white, // Canvas background
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _drawn = true;
                              points.add(details
                                  .localPosition); // Add current touch position
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              points.add(
                                  null); // Add null to indicate a break in the path
                            });
                          },
                          child: CustomPaint(
                            painter: _DrawingPainter(points),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_drawn) {
                          gameInfo['endTime'] =
                              DateTime.now().toIso8601String();

                          handwritingServices.svgContent =
                              handwritingServices.exportToSVG(points);
                          handwritingServices.saveHandwritingData(gameInfo);

                          _showEnd();
                        } else {
                          showDialog(
                            context: context,
                            barrierDismissible:
                                false, // Prevent dismissing by tapping outside
                            builder: (context) {
                              return const FadeMessageBox(
                                message:
                                    "Please Play the game first.", // Custom message
                                duration: Duration(
                                    seconds: 2), // Custom fade duration
                              );
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        minimumSize: const Size(145, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 21,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontFamily: "assets/fonts/Poppins-SemiBold.ttf",
                          //fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //   ElevatedButton(
                    //   onPressed: () async {
                    //     final svgContent = exportToSVG(points);
                    //     await saveToSVG(svgContent);
                    //   },
                    //   child: const Text('SUBMIT'),
                    // ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts the list of points into an SVG string

  /// Saves the SVG string to a file

  void _showEnd() {
    var radius = 10.0;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Successfully Recorded",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 11,
                    ),
                    Center(
                      child: Text(
                        'Go back to levels page',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Navigate back
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(radius),
                          bottomRight: Radius.circular(radius),
                        ),
                      ),
                      alignment: Alignment.center,
                      height: 35,
                      width: 250,
                      child: const Text(
                        "Go Back",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 11,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;

  _DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
