import 'package:bahri_app/widgets/fade_message_box.dart';
import 'package:flutter/material.dart';
import 'package:bahri_app/widgets/linear_timer.dart';
import 'package:bahri_app/widgets/image_grid.dart';
import 'package:bahri_app/widgets/show_score_popup.dart';

class PicPick extends StatefulWidget {
  final int difficulty;
  const PicPick({super.key, required this.difficulty});

  @override
  State<PicPick> createState() => _PicPick();
}

class _PicPick extends State<PicPick> with TickerProviderStateMixin {
  late int difficulty;
  List<String> difficulties = [" Easy", " Medium", " Hard"];
  List<int> timeLimits = [12000, 10000, 10000];
  final GlobalKey<LinearTimerState> _timerKey = GlobalKey<LinearTimerState>();

  // Animation controllers for correct and wrong containers
  late AnimationController _correctAnimationController;
  late AnimationController _wrongAnimationController;
  late Animation<Color?> _correctColorAnimation;
  late Animation<Color?> _wrongColorAnimation;
  bool _canPop = false;
  void updateCanPop(bool value) {
    setState(() {
      _canPop = value;
    });
  }

  int _correct = 0;
  int _wrong = 0;

  @override
  void initState() {
    super.initState();
    difficulty = widget.difficulty;

    // Initialize animation controllers
    _correctAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _wrongAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Create color animations
    _correctColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green.shade200,
    ).animate(CurvedAnimation(
      parent: _correctAnimationController,
      curve: Curves.easeInOut,
    ));

    _wrongColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.red.shade200,
    ).animate(CurvedAnimation(
      parent: _wrongAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _correctAnimationController.dispose();
    _wrongAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const FadeMessageBox(
              message: "Please finish the game first.",
              duration: Duration(seconds: 2),
            );
          },
        );
      },
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Tap Game',
            style: TextStyle(
              fontFamily: "assets/fonts/Poppins-Regular.ttf",
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.lock,
              color: Colors.black,
            ),
            onPressed: () {},
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
                        onTimerFinish: (elapsedTime) {
                          updateCanPop(true);
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              return const ShowScorePopup(
                                radius: 8,
                              );
                            },
                          );
                        },
                        onTimerStop: (elapsedTime) {
                          debugPrint(
                              'Timer stopped after $elapsedTime milliseconds.');
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
                        child: displayGame(difficulty),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedBuilder(
                            animation: _correctColorAnimation,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(13),
                                width: 130,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _correctColorAnimation.value,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Center(
                                  child: Text(
                                    "Correct: $_correct",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            },
                          ),
                          AnimatedBuilder(
                            animation: _wrongColorAnimation,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.all(13),
                                width: 130,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: _wrongColorAnimation.value,
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Center(
                                  child: Text(
                                    "Wrong: $_wrong",
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      )
                    ],
                  ),
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
            updateCorrect: _updateCorrect,
            updateWrong: _updateWrong,
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
            updateCorrect: _updateCorrect,
            updateWrong: _updateWrong,
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
            updateCorrect: _updateCorrect,
            updateWrong: _updateWrong,
            seconds: timeLimits[2],
          ));
        });
      default:
        return Container();
    }
  }

  void _updateCorrect() {
    setState(() {
      _correct++;
    });
    // Flash animation for correct container
    _correctAnimationController.forward().then((_) {
      _correctAnimationController.reverse();
    });
  }

  void _updateWrong() {
    setState(() {
      _wrong++;
    });
    // Flash animation for wrong container
    _wrongAnimationController.forward().then((_) {
      _wrongAnimationController.reverse();
    });
  }
}
