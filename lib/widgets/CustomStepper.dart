import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomStepper extends StatelessWidget {
  CustomStepper({
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
            width: 35.0,
            height: 35.0,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: circleColor,
            ),
            child: Center(
              child: Icon(Icons.task_alt,
                  size: 30,
                  color: (i == _curStep) ? _activeColor : _inactiveColor),
            )),
      );
      if (i != steps.length - 1) {
        list.add(Expanded(
            child: Container(
          height: lineWidth,
          color: lineColor,
        )));
      }
    });

    return list;
  }

  List<Widget> _titleViews() {
    var list = <Widget>[];
    Color clr;
    steps.asMap().forEach((i, text) {
      if (i == _curStep) {
        clr = Colors.black;
      } else {
        clr = Colors.white;
      }
      list.add(Text(text["title"], style: TextStyle(color: clr)));
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _titleViews(),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: _iconViews(),
        ),
      ],
    );
  }
}
