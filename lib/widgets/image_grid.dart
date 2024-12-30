import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/pic_pick_services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ImageGrid extends StatefulWidget {
  final int gridSize;
  final String intensityLevel; // New parameter for distortion intensity
  final Function() updateCorrect;
  final Function() updateWrong;
  final int seconds;

  const ImageGrid(
      {super.key,
      required this.gridSize,
      required this.intensityLevel,
      required this.updateCorrect,
      required this.updateWrong,
      required this.seconds});

  @override
  State<ImageGrid> createState() => _ImageGrid();
}

class _ImageGrid extends State<ImageGrid> {
  late int gridSize;
  late String intensityLevel;
  late List<String> currentImages;
  late int score;
  late int _correct = 0;
  late int _wrong = 0;
  late int seconds;
  late int _tapPressTime;
  late int _tapReleaseTime;
  late int _responseTime;
  Offset? _tapLocalInitialLocation;
  Offset? _tapGlobalInitialLocation;
  double? normalizedX;
  double? normalizedY;
  Offset? _intendedTapLocation;
  DateTime? _tapTimeofDay;
  double? _targetSizeArea;
  Size? screenSize;
  double? screenWidth;
  double? screenHeight;
  double? screenDiagonalLength;
  int _tapCount = 0;
  Timer? _timer;
  double _tapRepeatRate = 0.0;
  final int _timeFrame = 2; // 1 second
  Offset? _tapGlobalFinalLocation;
  Offset? _tapLocalFinalLocation;
  final GlobalKey _gridKey = GlobalKey();
  List<Map<String, dynamic>> tapData = [];
  late Map<String, dynamic> gameInfo;
  bool gameEnded = false;
  Timer? gameTimer;

  TapDataCollectionService tapDataCollectionService =
      TapDataCollectionService();
  String? uid;
  Future<void> fetchUserId() async {
    uid = await getUserId();
    print("User ID is set: ==$uid");
    setState(() {});
  }

  //double? _tapForce;

  List<String> images = [
    'assets/pic_pick_images/Image(1).jpg',
    'assets/pic_pick_images/Image(2).jpg',
    'assets/pic_pick_images/Image(3).jpg',
    'assets/pic_pick_images/Image(4).jpg',
    'assets/pic_pick_images/Image(5).jpg',
    'assets/pic_pick_images/Image(6).jpg',
    'assets/pic_pick_images/Image(7).jpg',
    'assets/pic_pick_images/Image(8).jpg',
    'assets/pic_pick_images/Image(9).jpg',
    'assets/pic_pick_images/Image(10).jpg',
    'assets/pic_pick_images/Image(11).jpg',
    'assets/pic_pick_images/Image(12).jpg',
    'assets/pic_pick_images/Image(13).jpg',
    'assets/pic_pick_images/Image(14).jpg',
    'assets/pic_pick_images/Image(15).jpg',
    'assets/pic_pick_images/Image(16).jpg',
    'assets/pic_pick_images/Image(17).jpg',
    'assets/pic_pick_images/Image(18).jpg',
    'assets/pic_pick_images/Image(19).jpg',
    'assets/pic_pick_images/Image(20).jpg',
    'assets/pic_pick_images/distortedMedium(1).jpg',
    'assets/pic_pick_images/distortedMedium(2).jpg',
    'assets/pic_pick_images/distortedMedium(3).jpg',
    'assets/pic_pick_images/distortedMedium(4).jpg',
    'assets/pic_pick_images/distortedMedium(5).jpg',
    'assets/pic_pick_images/distortedMedium(6).jpg',
    'assets/pic_pick_images/distortedMedium(7).jpg',
    'assets/pic_pick_images/distortedMedium(8).jpg',
    'assets/pic_pick_images/distortedMedium(9).jpg',
    'assets/pic_pick_images/distortedMedium(10).jpg',
  ];

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;
    intensityLevel = widget.intensityLevel;
    score = 0;
    seconds = widget.seconds;
    _initializeGrid();
    fetchUserId();
    tapDataCollectionService.initHive();
    gameInfo = {
      'gridSize': '$gridSize x $gridSize',
      'difficulty': intensityLevel,
      'startTime': DateTime.now().toIso8601String(),
    };
    gameTimer = Timer(Duration(milliseconds: seconds), endGame);
  }

  void endGame() {
    if (!gameEnded) {
      gameEnded = true;
      gameInfo['endTime'] = DateTime.now().toIso8601String();
      gameInfo['uid'] = uid;
      gameInfo['CorrectCount'] = _correct;
      gameInfo['WrongCount'] = _wrong;
      // Use a microtask to ensure this runs after the current build cycle
      Future.microtask(() {
        tapDataCollectionService.saveTapData(tapData, gameInfo);
      });
    }
  }

  void _initializeGrid() {
    // Populate the grid with non-distorted images initially
    currentImages = List.generate(gridSize * gridSize, (index) {
      return _getRandomImage(nonDistortedOnly: true);
    });
  }

  String _getRandomImage({bool nonDistortedOnly = false}) {
    List<String> availableImages = nonDistortedOnly
        ? images.where((img) => !_isDistorted(img)).toList()
        : images
            .where((img) => _matchesIntensity(img) || !_isDistorted(img))
            .toList();

    int randomIndex = Random().nextInt(availableImages.length);
    return availableImages[randomIndex];
  }

  void _onImageTap(int index) {
    setState(() {
      String tappedImage = currentImages[index];

      if (_isDistorted(tappedImage)) {
        widget.updateWrong();
        _wrong++;
      } else {
        widget.updateCorrect();
        _correct++; // Add a point if the image is not distorted
      }

      // Replace the tapped image with a new one while respecting the distorted limit
      currentImages[index] = _getNextImage();
    });
  }

  String _getNextImage() {
    int distortedCount = currentImages.where((img) => _isDistorted(img)).length;
    int maxDistorted = (gridSize * gridSize) ~/ 2;

    bool allowDistorted = distortedCount < maxDistorted;
    List<String> availableImages = allowDistorted
        ? images
            .where((img) => _matchesIntensity(img) || !_isDistorted(img))
            .toList()
        : images.where((img) => !_isDistorted(img)).toList();

    int randomIndex = Random().nextInt(availableImages.length);
    return availableImages[randomIndex];
  }

  bool _isDistorted(String imageName) {
    return imageName.toLowerCase().contains("distorted");
  }

  bool _matchesIntensity(String imageName) {
    return imageName.toLowerCase().contains(intensityLevel.toLowerCase());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double itemWidth = constraints.maxWidth / gridSize;
      double itemHeight = constraints.maxHeight / gridSize;
      _targetSizeArea = ((itemWidth / gridSize) * (itemHeight / gridSize));
      return GridView.builder(
        key: _gridKey,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          double x = (index % 2) * itemWidth;
          double y = (index ~/ 2) * itemHeight;
          // Calculate the intended tap location (center of the item)
          _intendedTapLocation = Offset(x + itemWidth / 2, y + itemHeight / 2);
          return GestureDetector(
            onTapDown: (details) {
              _tapPressTime = DateTime.now().millisecondsSinceEpoch;
              _tapGlobalInitialLocation = details.globalPosition;
              _tapLocalInitialLocation = details.localPosition;
              screenSize = MediaQuery.of(context).size;
              screenWidth = screenSize!.width;
              screenHeight = screenSize!.height;
              screenDiagonalLength =
                  sqrt(pow(screenWidth!, 2) + pow(screenHeight!, 2));

              // Get the global position of the tap

              // Normalize the tap position by the screen size
              normalizedX = _tapGlobalInitialLocation!.dx / screenSize!.width;
              normalizedY = _tapGlobalInitialLocation!.dy / screenSize!.height;
              // Assuming force and surface area can be captured from details if supported
              //_tapForce = details.pressure;
              // _tapSurfaceArea = details;
            },
            onTap: () {
              _responseTime = DateTime.now().millisecondsSinceEpoch;
              _tapTimeofDay = DateTime.now();

              if (_timer == null || !_timer!.isActive) {
                _tapCount = 0;
                _timer = Timer.periodic(Duration(seconds: _timeFrame), (timer) {
                  _tapRepeatRate = _tapCount / _timeFrame;
                  timer.cancel(); // Stop the timer after calculating TRR
                });
              }
              _onImageTap(index);
              setState(() {
                _tapCount++;
              });

              Map<String, dynamic> TapData = {
                'TapPressTime': _tapPressTime,
                'TapReleaseTime': _tapReleaseTime,
                'TapDuration': tapDataCollectionService.calculateTapDuration(
                    _tapPressTime, _tapReleaseTime),
                'TapInitialGlobalLocationX': _tapGlobalInitialLocation!.dx,
                'TapInitialGlobalLocationY': _tapGlobalInitialLocation!.dy,
                'TapFinalGlobalLocationX': _tapGlobalFinalLocation!.dx,
                'TapFinalGlobalLocationY': _tapGlobalFinalLocation!.dy,
                'TapInitialLocalLocationX': _tapLocalInitialLocation!.dx,
                'TapInitialLocalLocationY': _tapLocalInitialLocation!.dy,
                'TapFinalLocalLocationX': _tapLocalFinalLocation!.dx,
                'TapFinalLocalLocationY': _tapLocalFinalLocation!.dy,
                'TapGlobalMovementX':
                    _tapGlobalFinalLocation!.dx - _tapGlobalInitialLocation!.dx,
                'TapGlobalMovementY':
                    _tapGlobalFinalLocation!.dy - _tapGlobalInitialLocation!.dy,
                'TapLocalMovementX':
                    _tapLocalFinalLocation!.dx - _tapLocalInitialLocation!.dx,
                'TapLocalMovementY':
                    _tapLocalFinalLocation!.dy - _tapLocalInitialLocation!.dy,
                'normalizedX': normalizedX,
                'normalizedY': normalizedY,
                'tapDrift': tapDataCollectionService.calculateTapDrift(
                    _intendedTapLocation!, _tapGlobalInitialLocation!),
                'Latency': tapDataCollectionService.calculateTapLatency(
                    _responseTime, _tapPressTime),
                'TapSpeed': tapDataCollectionService.calculateTapSpeed(
                    _tapPressTime, _responseTime),
                'TapTimeofTheDay': '${_tapTimeofDay}Z',
                '_targetSizeAre': _targetSizeArea,
                'TapRepeatRate/2Seconds': _tapRepeatRate,
              };
              tapData.add(TapData);
            },
            onTapUp: (details) {
              _tapReleaseTime = DateTime.now().millisecondsSinceEpoch;
              _tapGlobalFinalLocation = details.globalPosition;
              _tapLocalFinalLocation = details.localPosition;
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Image.asset(
                  currentImages[index],
                  key: ValueKey(currentImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<String?> getUserId() async {
    const secureStorage = FlutterSecureStorage();

    await secureStorage.read(key: 'uid');

    return await secureStorage.read(key: 'uid');
  }
}
