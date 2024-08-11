import 'dart:async';

import 'package:flutter/material.dart';

class LinearTimer extends StatefulWidget {
  final int durationMiliseconds;
  final Function onTimerFinish;

  const LinearTimer(
      {super.key,
      required this.durationMiliseconds,
      required this.onTimerFinish});

  @override
  State<LinearTimer> createState() => _LinearTimerState();
}

class _LinearTimerState extends State<LinearTimer> {
  late int _milisecondsRemaining;
  late double _barWidth;
  int durationMiliseconds = 17;

  @override
  void initState() {
    super.initState();
    _milisecondsRemaining = widget.durationMiliseconds;
    _barWidth = 1.0;
    startTimer();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: durationMiliseconds), (timer) {
      setState(() {
        if (_milisecondsRemaining > 0) {
          _milisecondsRemaining -= durationMiliseconds;
          _barWidth = _milisecondsRemaining <= 0
              ? 0
              : _milisecondsRemaining / widget.durationMiliseconds;
        } else {
          widget.onTimerFinish();
          timer.cancel();
        }
      });
    });
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
