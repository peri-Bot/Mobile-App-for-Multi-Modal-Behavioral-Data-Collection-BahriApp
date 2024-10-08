import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/swipe_data_collection.dart';
import '../../services/swipe_game_firebase_services.dart';

class GameScreen extends StatefulWidget {
  final DataCollectionService _dataCollectionService = DataCollectionService();
  final int level;
  final Function(int score) onLevelComplete;

  GameScreen({
    super.key,
    required this.level,
    required this.onLevelComplete,
    // Required userId in constructor
  });

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 10;
  Timer? _timer;
  final List<Map<String, dynamic>> _swipeData = [];
  double screenResponseTime = 16.67; // in milliseconds
  double screenSensitivity = 1.0;
  double screenPerformanceIndex =
      1.0; // Example performance index for time of day

  late AnimationController _animationController;
  double? _initialX;
  double? _initialY;
  late int _startTime;

  final FirestoreService _firestoreService = FirestoreService();
  final DataCollectionService _dataCollectionService = DataCollectionService();

  @override
  void initState() {
    super.initState();
    _loadQuestionsForLevel(widget.level);
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _timeLeft),
    );
    _animationController.forward();
  }

  double calculateScreenArea(BuildContext context) {
    final view = View.of(context);
    final width = view.physicalSize.width;
    final height = view.physicalSize.height;
    return width * height;
  }

  void _loadQuestionsForLevel(int level) {
    if (level == 3) {
      _questions = [
        {
          'image': 'assets/slide_game/dog.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/fox.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/mole.jpg',
          'questionType': 'mammal',
          'answer': false
        },
        {
          'image': 'assets/slide_game/enshelalit.jpg',
          'questionType': 'mammal',
          'answer': false
        },
        {
          'image': 'assets/slide_game/frog.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/hipoo.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/monkey.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/OIP.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/squierl.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/seal.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/sheep.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/horse.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/bird.jpg',
          'questionType': 'mammal',
          'answer': true
        },
        {
          'image': 'assets/slide_game/mole.jpg',
          'questionType': 'mammal',
          'answer': true
        },
      ];
    } else if (level == 2) {
      _questions = [
        {
          'image': 'assets/slide_game/countries/cambodia.jpg',
          'questionType': 'flag',
          'answer': false
        },
        {
          'image': 'assets/slide_game/countries/wales.jpg',
          'questionType': 'flag',
          'answer': false
        },
        {
          'image': 'assets/slide_game/countries/uganda.jpg',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/scotland.jpg',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/angola.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/Armenia.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/Austria.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/ethiopia.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/tunisia.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/Austria.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/moroco.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/denmark.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/rwanda.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/bhutan.png',
          'questionType': 'flag',
          'answer': true
        },
        {
          'image': 'assets/slide_game/countries/burkina.png',
          'questionType': 'flag',
          'answer': true
        },
      ];
    } else if (level == 1) {
      _questions = [
        {
          'image': 'assets/slide_game/veggies/orange.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/gomen.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/papper.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/tomato.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/apple.jpg',
          'questionType': 'fruit',
          'answer': false
        },
        {
          'image': 'assets/slide_game/veggies/cuccumber.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/banana.jpg',
          'questionType': 'fruit',
          'answer': false
        },
        {
          'image': 'assets/slide_game/veggies/cucember.png',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/cabbage.jpg',
          'questionType': 'fruit',
          'answer': true
        },
        {
          'image': 'assets/slide_game/veggies/fruit.jpg',
          'questionType': 'fruit',
          'answer': true
        },
      ];
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
          _animationController.value = _timeLeft / 10.0;
        });
      } else {
        _nextQuestion();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _nextQuestion() {
    _stopTimer();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _timeLeft = 10;
        _animationController.value = 1.0;
        _animationController.duration = Duration(seconds: _timeLeft);
        _startTimer();
      });
    } else {
      _stopTimer();
      // _firestoreService.storeSwipeData(
      //   widget.userId, // passing the user id yes yes yes
      //   widget.level,
      //   _score,
      //   _swipeData,
      // );
      widget.onLevelComplete(_score);
      _showGameOverDialog();
    }
  }

  void _checkAnswer(bool answer) {
    if (answer == _questions[_currentQuestionIndex]['answer']) {
      setState(() {
        _score++;
      });
    }
    _nextQuestion();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Your score is $_score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to level selection
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.black,
              minimumSize: const Size(100, 40),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stopTimer();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String questionText = '';
    if (_questions[_currentQuestionIndex]['questionType'] == 'mammal') {
      questionText = 'Is this animal a mammal?';
    } else if (_questions[_currentQuestionIndex]['questionType'] == 'flag') {
      questionText = 'Is this flag from Africa?';
    } else if (_questions[_currentQuestionIndex]['questionType'] == 'fruit') {
      questionText = 'Is this a fruit?';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Level ${widget.level}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(183, 153, 255, 1),
              Color.fromRGBO(172, 188, 255, 1),
              Color.fromRGBO(174, 226, 255, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 5),
                SizedBox(
                  width: 200,
                  height: 20,
                  child: LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.blue[100],
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.blue[900]!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onPanStart: (details) {
                  _initialX = details.localPosition.dx;
                  _initialY = details.localPosition.dy;
                  _startTime = DateTime.now().millisecondsSinceEpoch;
                },
                onPanEnd: (details) {
                  int endTime = DateTime.now().millisecondsSinceEpoch;
                  double endX = details.velocity.pixelsPerSecond.dx;
                  double endY = details.velocity.pixelsPerSecond.dy;
                  double distance =
                      _dataCollectionService.calculateSwipeDistance(
                          _initialX!, _initialY!, endX, endY);
                  double duration = _dataCollectionService
                      .calculateSwipeDuration(_startTime, endTime);
                  double speed = _dataCollectionService.calculateSwipeSpeed(
                      distance, duration);
                  double straightness =
                      _dataCollectionService.calculateSwipePathStraightness(
                          _initialX!, _initialY!, endX, endY);
                  double angle = _dataCollectionService.calculateSwipeAngle(
                      _initialX!, _initialY!, endX, endY);
                  double acceleration = _dataCollectionService
                      .calculateSwipeAcceleration(speed, duration);

                  double jerk = _dataCollectionService.calculateSwipeJerk(
                      acceleration, duration);
                  double deceleration = _dataCollectionService
                      .calculateSwipeDeceleration(speed, duration);
                  double areaCoverage =
                      _dataCollectionService.calculateSwipeAreaCoverage(
                          _initialX!,
                          _initialY!,
                          endX,
                          endY,
                          calculateScreenArea(context));
                  double fingerOrientation =
                      _dataCollectionService.calculateSwipeFingerOrientation(
                          _initialX!, _initialY!, endX, endY);
                  double movementVariability = _dataCollectionService
                      .calculateSwipeFingerMovementVariability(
                          _initialX!, _initialY!, endX, endY);
                  double timeOfDayImpact =
                      _dataCollectionService.calculateTimeOfDayImpact();
                  double snsl =
                      _dataCollectionService.calculateSNSL(distance, context);
                  double snss =
                      _dataCollectionService.calculateSNSS(speed, context);
                  double snsa =
                      _dataCollectionService.calculateSNSA(angle, context);
                  double snsd = _dataCollectionService.calculateSNSD(
                      duration, screenResponseTime);
                  //  double snsp = _dataCollectionService.calculateSNSP(1.0, screenSensitivity); // will work on this later
                  double snspc = _dataCollectionService.calculateSNSPC(
                      straightness, context);
                  double snspl =
                      _dataCollectionService.calculateSNSPL(distance, context);
                  double snsa_acc = _dataCollectionService
                      .calculateSNSA_Acceleration(acceleration, context);
                  double snsd_dec = _dataCollectionService
                      .calculateSNSD_Deceleration(deceleration, context);
                  double snsj =
                      _dataCollectionService.calculateSNSJ(jerk, context);
                  double spsac = _dataCollectionService.calculateSPSAC(
                      1.0, context); // Assuming swipe area is 1.0 for demo
                  double snss_straight = _dataCollectionService
                      .calculateSNSS_Straightness(straightness, context);
                  double snsfo = _dataCollectionService.calculateSNSFO(1.0,
                      context); // Assuming finger orientation is 1.0 for demo
                  double sns_fmv = _dataCollectionService.calculateSNSFMV(1.0,
                      context); // Assuming finger movement variability is 1.0
                  double snstdi = _dataCollectionService.calculateSNSTDI(
                      1.0, screenPerformanceIndex); // Example values
                  Map<String, dynamic> swipeData = {
                    'initialX': _initialX,
                    'initialY': _initialY,
                    'endX': endX,
                    'endY': endY,
                    'duration': duration,
                    'distance': distance,
                    'speed': speed,
                    'straightness': straightness,
                    'angle': angle,
                    'acceleration': acceleration,
                    'jerk': jerk,
                    'deceleration': deceleration,
                    'areaCoverage': areaCoverage,
                    'fingerOrientation': fingerOrientation,
                    'movementVariability': movementVariability,
                    'timeOfDayImpact': timeOfDayImpact,
                    'SN Swipe Length': snsl,
                    'SN Swipe Speed': snss,
                    'SN Swipe Angle': snsa,
                    'SN Swipe Duration': snsd,
                    //'SN Swipe Pressure': snsp,
                    'SN Swipe Path Curvature': snspc,
                    'SN Swipe Path Length': snspl,
                    'SN Swipe Acceleration': snsa_acc,
                    'SN Swipe Deceleration': snsd_dec,
                    'SN Swipe Jerk': snsj,
                    'Screen Proportional Swipe Area Coverage': spsac,
                    'SN Swipe Straightness': snss_straight,
                    'SN Swipe Finger Orientation': snsfo,
                    'SN Swipe Finger Movement Variability': sns_fmv,
                    'SN Swipe Time of Day Impact': snstdi,
                    //everyone note that SN stands for screen normalized
                  };

                  _swipeData.add(swipeData);

                  // Determine swipe direction
                  // Determine swipe directions
                  bool isSwipeRight = details.velocity.pixelsPerSecond.dx > 0;
                  bool isSwipeLeft = details.velocity.pixelsPerSecond.dx < 0;
                  bool isSwipeUp = details.velocity.pixelsPerSecond.dy < 0;
                  bool isSwipeDown = details.velocity.pixelsPerSecond.dy > 0;

                  if (widget.level == 3) {
                    // Handle up/down swipes for level 3
                    if (isSwipeUp) {
                      _checkAnswer(true); // Swipe up
                    } else if (isSwipeDown) {
                      _checkAnswer(false); // Swipe down
                    }
                  } else {
                    // Handle left/right swipes for levels 1 and 2
                    if (isSwipeRight) {
                      _checkAnswer(true); // Swiped right
                    } else if (isSwipeLeft) {
                      _checkAnswer(false); // Swiped left
                    }
                  }

                  // Check swipe direction
                  //_checkAnswer(details.velocity.pixelsPerSecond.dx > 0); // Swiped right (True) or left (False) yes yes yes
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.asset(
                            _questions[_currentQuestionIndex]['image']),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        questionText,
                        style:
                            const TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Icon(Icons.swipe, size: 40, color: Colors.white),
                      Text(
                          widget.level == 3
                              ? "Swipe Up or Down"
                              : "Swipe Left or Right",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: $_score',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
