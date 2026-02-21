import 'package:flutter/material.dart';

class FadeMessageBox extends StatefulWidget {
  final String message;
  final Duration duration;
  final Color backgroundColor;
  final TextStyle textStyle;

  const FadeMessageBox({
    super.key,
    required this.message,
    this.duration = const Duration(seconds: 3),
    this.backgroundColor = const Color.fromARGB(177, 255, 255, 255),
    this.textStyle = const TextStyle(
        color: Color.fromARGB(255, 0, 0, 0),
        fontSize: 16,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none),
  });

  @override
  State<FadeMessageBox> createState() => _FadeMessageBoxState();
}

class _FadeMessageBoxState extends State<FadeMessageBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Configure animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Create fade-out animation
    _opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    // Start the animation and dismiss the dialog after it completes
    _controller.forward().whenComplete(() {
      if (mounted) {
        Navigator.of(context).pop(); // Close the dialog
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            widget.message,
            style: widget.textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
