import 'package:flutter/gestures.dart';
import 'package:bahri_app/widgets/keyboard/utils/types.dart';

class Keystroke {
  final String keyText;
  final KeyTypes keyType;
  final DateTime pressTime;
  late final DateTime releaseTime;
  final DateTime screenAppearanceTime;

  Keystroke({
    required this.keyText,
    required this.keyType,
    required this.pressTime,
    required this.releaseTime,
    required this.screenAppearanceTime,
  });

  // Calculated attributes
  Duration get holdTime => releaseTime.difference(pressTime);
  Duration get latency => screenAppearanceTime.difference(pressTime);

  // These will be calculated in the service class
  Duration? flightTime;
  Duration? interKeyTime;
  Duration? seekTime;
  double? holdFlightTimeRatio;
  double? flightToHoldRatio;
}
