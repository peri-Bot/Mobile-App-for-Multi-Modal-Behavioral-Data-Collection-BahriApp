import 'dart:async';

import 'package:flutter/material.dart';

class LinearTimer extends StatefulWidget {
  final int durationMiliseconds;
  final Function onTimerFinish;
  final Function(int) onTimerStop;

  const LinearTimer({
    super.key,
    required this.durationMiliseconds,
    required this.onTimerFinish,
    required this.onTimerStop, // Pass callback to report elapsed time when stopped
  });

  @override
  State<LinearTimer> createState() => LinearTimerState();
}

class LinearTimerState extends State<LinearTimer> {
  late int _milisecondsRemaining;
  late double _barWidth;
  Timer? _timer;

  int durationMiliseconds = 17;

  @override
  void initState() {
    super.initState();
    _milisecondsRemaining = widget.durationMiliseconds;
    _barWidth = 1.0;

    startTimer();
  }

  void startTimer() {
    _timer =
        Timer.periodic(Duration(milliseconds: durationMiliseconds), (timer) {
      setState(() {
        if (_milisecondsRemaining > 0) {
          _milisecondsRemaining -= durationMiliseconds;
          _barWidth = _milisecondsRemaining <= 0
              ? 0
              : _milisecondsRemaining / widget.durationMiliseconds;
        } else {
          widget.onTimerFinish(_milisecondsRemaining);
          timer.cancel();
        }
      });
    });
  }

  void stopTimer() {
    if (_timer != null && _timer!.isActive) {
      _milisecondsRemaining;
      _timer!.cancel();
      widget.onTimerStop(
          _milisecondsRemaining); // Call the callback to report the elapsed time
    }
  }

  @override
  void dispose() {
    stopTimer(); // Ensure timer stops when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 40.0,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.black,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _barWidth,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Text(
                    _milisecondsRemaining <= 0
                        ? "Finished"
                        : ("${(_milisecondsRemaining / 1000).toStringAsFixed(0)}s left"),
                    style: TextStyle(
                      color: _milisecondsRemaining <= 0
                          ? Colors.white
                          : Colors.black,
                      fontFamily: "assets/fonts/Poppins-Regular.ttf",
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.timer_sharp,
                  color: Colors.white,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}
