import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/widgets/linear_timer.dart';
import 'package:flutter/widgets.dart';
import 'package:bahri_app/widgets/image_grid.dart';
import 'package:bahri_app/widgets/show_score_popup.dart';

class PicPick extends StatefulWidget {
  final int difficulty;
  const PicPick({super.key, required this.difficulty});

  @override
  State<PicPick> createState() => _PicPick();
}

class _PicPick extends State<PicPick> {
  late int difficulty;
  List<String> difficulties = [" Easy", " Medium", " Hard"];
  List<int> timeLimits = [12000, 10000, 10000];
  final GlobalKey<LinearTimerState> _timerKey = GlobalKey<LinearTimerState>();

  int _score = 0;
  @override
  void initState() {
    super.initState();
    difficulty = widget.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Pic Pick :${difficulties[difficulty]}',
          //tap the center of the images that are not distorted
          style: const TextStyle(
            fontFamily: "assets/fonts/Poppins-Regular.ttf",
            fontSize: 25,

            //fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        //elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
            //size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
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
          constraints: const BoxConstraints.expand(),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 56),
                    LinearTimer(
                      key: _timerKey,
                      durationMiliseconds: timeLimits[difficulty],
                      onTimerFinish: () {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return ShowScorePopup(
                              score: _score,
                              highScore: 22,
                            );
                          },
                        );
                      },
                      onTimerStop: (elapsedTime) {
                        print('Timer stopped after $elapsedTime milliseconds.');
                      },
                    ),
                    const SizedBox(height: 56),
                    Container(
                        padding: const EdgeInsets.all(13),
                        width: 400,
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: displayGame(difficulty)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(13),
                      width: 100,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Center(
                        child: Text(
                          "Score: $_score",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayGame(int difficulty) {
    switch (difficulty) {
      case 0:
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Center(
              child: ImageGrid(
            gridSize: 2,
            intensityLevel: 'Easy',
            onScoreUpdate: _updateScore,
            seconds: timeLimits[0],
          ));
        });
      case 1:
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Center(
              child: ImageGrid(
            gridSize: 3,
            intensityLevel: 'Medium',
            onScoreUpdate: _updateScore,
            seconds: timeLimits[1],
          ));
        });
      case 2:
        return StatefulBuilder(builder:
            (BuildContext context, void Function(void Function()) setState) {
          return Center(
              child: ImageGrid(
            gridSize: 3,
            intensityLevel: 'Hard',
            onScoreUpdate: _updateScore,
            seconds: timeLimits[2],
          ));
        });
      default:
        return Container();
    }
  }

  void _updateScore(int newScore) {
    // New callback function
    setState(() {
      _score = newScore;
    });
  }
}
