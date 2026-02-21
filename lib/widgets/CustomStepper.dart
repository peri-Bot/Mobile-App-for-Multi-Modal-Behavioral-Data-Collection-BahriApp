import 'package:flutter/material.dart';
import 'package:stroke_text/stroke_text.dart';

class CustomStepper extends StatelessWidget {
  const CustomStepper({
    super.key,
    required int currentStep,
    required this.steps,
  })  : _curStep = currentStep,
        assert(currentStep >= 0 == true && currentStep <= steps.length);

  final int _curStep;
  final Color _activeColor = Colors.black;
  final Color _inactiveColor = const Color.fromARGB(255, 255, 255, 255);
  final double lineWidth = 5;
  final List<Map<String, dynamic>> steps;

  List<Widget> _iconViews() {
    var list = <Widget>[];
    steps.asMap().forEach((i, icon) {
      Color circleColor =
          (i == 0 || _curStep >= i) ? _activeColor : _inactiveColor;
      Color lineColor = _curStep > i ? _activeColor : _inactiveColor;

      list.add(
        Container(
          width: 19.0,
          height: 19.0,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
          child: Center(
            child: Icon(
              Icons.task_alt,
              size: 15,
              color: (i == _curStep) ? _activeColor : _inactiveColor,
            ),
          ),
        ),
      );

      if (i != steps.length - 1) {
        list.add(
          Expanded(
            child: Container(
              height: lineWidth,
              color: lineColor,
            ),
          ),
        );
      }
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Text(
        //   steps[_curStep]["title"].toString().toUpperCase(),
        //   style: const TextStyle(
        //       color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        // ),
        StrokeText(
          text: steps[_curStep]["title"].toString().toUpperCase(),
          textStyle: const TextStyle(
            fontFamily: "assets/fonts/Poppins-Regular.ttf",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          strokeColor: Color.fromARGB(255, 255, 255, 255),
          strokeWidth: 1.9,
        ),
        const SizedBox(height: 10),
        Row(
          children: _iconViews(),
        ),
      ],
    );
  }
}
