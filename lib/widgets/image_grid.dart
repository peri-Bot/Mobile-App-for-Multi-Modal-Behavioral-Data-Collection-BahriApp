import 'dart:math';
import 'package:flutter/material.dart';

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
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: gridSize,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gridSize * gridSize,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _onImageTap(index),
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
  }
}
