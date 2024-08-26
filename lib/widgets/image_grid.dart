import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class ImageGrid extends StatefulWidget {
  final int gridSize;
  final String intensityLevel; // New parameter for distortion intensity
  final Function(int) onScoreUpdate;

  const ImageGrid({
    super.key,
    required this.gridSize,
    required this.intensityLevel,
    required this.onScoreUpdate,
  });

  @override
  State<ImageGrid> createState() => _ImageGrid();
}

class _ImageGrid extends State<ImageGrid> {
  late int gridSize;
  late String intensityLevel;
  late List<String> currentImages;
  late int score;
  double? _tapPressTime;
  double? _tapReleaseTime;
  double? _responseTime;
  Offset? _tapLocalInitialLocation;
  Offset? _tapGlobalInitialLocation;
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
  final int _timeFrame = 1; // 1 second
  Offset? _tapGlobalFinalLocation;
  Offset? _tapLocalFinalLocation;
  final GlobalKey _gridKey = GlobalKey();

  //double? _tapForce;
  double? _tapSurfaceArea;

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
    'assets/pic_pick_images/Image(21).jpg',
    'assets/pic_pick_images/Image(22).jpg',
    'assets/pic_pick_images/Image(23).jpg',
    'assets/pic_pick_images/Image(24).jpg',
    'assets/pic_pick_images/distortedEasy(1).jpg',
    'assets/pic_pick_images/distortedEasy(2).jpg',
    'assets/pic_pick_images/distortedEasy(3).jpg',
    'assets/pic_pick_images/distortedEasy(4).jpg',
    'assets/pic_pick_images/distortedEasy(5).jpg',
    'assets/pic_pick_images/distortedEasy(6).jpg',
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
    'assets/pic_pick_images/distortedHard(1).jpg',
    'assets/pic_pick_images/distortedHard(2).jpg',
    'assets/pic_pick_images/distortedHard(3).jpg',
    'assets/pic_pick_images/distortedHard(4).jpg',
    'assets/pic_pick_images/distortedHard(5).jpg',
    'assets/pic_pick_images/distortedHard(6).jpg',
    'assets/pic_pick_images/distortedHard(7).jpg',
    'assets/pic_pick_images/distortedHard(8).jpg',
    'assets/pic_pick_images/distortedHard(9).jpg',
    'assets/pic_pick_images/distortedHard(10).jpg',
  ];

  @override
  void initState() {
    super.initState();
    gridSize = widget.gridSize;
    intensityLevel = widget.intensityLevel;
    score = 0;
    _initializeGrid();
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
        score = score - 4; // Deduct a point if the image is distorted
        if (score <= 0) {
          score = 0;
        }
      } else {
        score++; // Add a point if the image is not distorted
      }
      widget.onScoreUpdate(score);

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
      _targetSizeArea = (itemWidth / gridSize) * (itemHeight / gridSize);
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
              _tapPressTime = DateTime.now().millisecondsSinceEpoch as double?;
              _tapGlobalInitialLocation = details.globalPosition;
              _tapLocalInitialLocation = details.localPosition;
              screenSize = MediaQuery.of(context).size;
              screenWidth = screenSize!.width;
              screenHeight = screenSize!.height;
              screenDiagonalLength =
                  sqrt(pow(screenWidth!, 2) + pow(screenHeight!, 2));

              // Get the global position of the tap

              // Normalize the tap position by the screen size
              double normalizedX =
                  _tapGlobalInitialLocation!.dx / screenSize!.width;
              double normalizedY =
                  _tapGlobalInitialLocation!.dy / screenSize!.height;
              // Assuming force and surface area can be captured from details if supported
              //_tapForce = details.pressure;
              // _tapSurfaceArea = details;
            },
            onTap: () {
              _responseTime = DateTime.now().millisecondsSinceEpoch as double?;
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
            },
            onTapUp: (details) {
              _tapReleaseTime =
                  DateTime.now().millisecondsSinceEpoch as double?;
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
    _timer?.cancel();
    super.dispose();
  }
}
