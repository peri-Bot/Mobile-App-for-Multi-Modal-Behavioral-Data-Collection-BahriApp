import '../widgets/keyboard/artistic_multilingual_keyboard.dart';

class Keystroke {
  String keyText;
  KeyTypes keyType;
  DateTime pressTime;
  DateTime releaseTime;
  Duration holdTime;
  Duration flightTime;
  Duration interKeyTime;

  Keystroke({
    required this.keyText,
    required this.keyType,
    required this.pressTime,
    required this.releaseTime,
    required this.holdTime,
    required this.flightTime,
    required this.interKeyTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'keyText': keyText,
      'keyType': keyType.toString(),
      'pressTime': pressTime.toIso8601String(),
      'releaseTime': releaseTime.toIso8601String(),
      'holdTime': holdTime.inMilliseconds,
      'flightTime': flightTime.inMilliseconds,
      'interKeyTime': interKeyTime.inMilliseconds,
    };
  }
}
