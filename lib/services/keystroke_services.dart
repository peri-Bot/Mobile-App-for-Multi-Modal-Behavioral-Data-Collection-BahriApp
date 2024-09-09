import '../models/keystroke.dart';
import '../widgets/keyboard/artistic_multilingual_keyboard.dart';

class KeystrokeServices {
  DateTime? lastKeyPressTime;
  DateTime? lastKeyReleaseTime;
  DateTime? keyPressStartTime;
  String? lastKeyPressed;
  Duration totalHoldTime = Duration.zero;
  Duration totalFlightTime = Duration.zero;
  int totalKeyPresses = 0;
  int totalKeyReleases = 0;
  int totalCharactersTyped = 0;
  List<Duration> keyPressDurations = [];
  List<Duration> keyReleaseDurations = [];
  List<Duration> interKeyTimes = [];
  List<Map<String, dynamic>> keyStrokeData = [];

  // Handle key press event
  void onKeyPressed(String keyText, KeyTypes keyType) {
    final now = DateTime.now();

    Duration flightTime = Duration.zero;
    Duration interKeyTime = Duration.zero;

    // Calculate Flight Time and Interkey Time
    if (lastKeyReleaseTime != null) {
      flightTime = now.difference(lastKeyReleaseTime!);
      totalFlightTime += flightTime;
      interKeyTimes.add(flightTime);
      interKeyTime = flightTime;
    }

    // Record key press details
    keyPressStartTime = now;
    totalKeyPresses++;
    totalCharactersTyped++;
    lastKeyPressed = keyText;
    lastKeyPressTime = now;
  }

  // Handle key release event
  void onKeyReleased(String keyText, KeyTypes keyType) {
    final now = DateTime.now();

    if (keyPressStartTime != null) {
      final holdTime = now.difference(keyPressStartTime!);
      totalHoldTime += holdTime;
      keyPressDurations.add(holdTime);
      lastKeyReleaseTime = now;
      totalKeyReleases++;

      // Store keystroke data for this key
      Keystroke keystroke = Keystroke(
        keyText: keyText,
        keyType: keyType,
        pressTime: keyPressStartTime!,
        releaseTime: now,
        holdTime: holdTime,
        flightTime: lastKeyReleaseTime != null
            ? now.difference(lastKeyReleaseTime!)
            : Duration.zero,
        interKeyTime:
            interKeyTimes.isNotEmpty ? interKeyTimes.last : Duration.zero,
      );

      // Add the data to keyStrokeData list as a map
      keyStrokeData.add(keystroke.toMap());
    }
  }

  // Metric Calculation Methods
  double calculateHoldFlightRatio() {
    return totalFlightTime.inMilliseconds == 0
        ? 0
        : totalHoldTime.inMilliseconds / totalFlightTime.inMilliseconds;
  }

  double calculateTypingSpeed() {
    final timeElapsed = totalHoldTime + totalFlightTime;
    return timeElapsed.inMinutes == 0
        ? 0
        : totalCharactersTyped / timeElapsed.inMinutes;
  }

  double calculateAverageKeyPressDuration() {
    return keyPressDurations.isEmpty
        ? 0
        : keyPressDurations
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) /
            keyPressDurations.length;
  }

  double calculateAverageKeyReleaseDuration() {
    return keyReleaseDurations.isEmpty
        ? 0
        : keyReleaseDurations
                .map((d) => d.inMilliseconds)
                .reduce((a, b) => a + b) /
            keyReleaseDurations.length;
  }

  double calculateAverageInterkeyTime() {
    return interKeyTimes.isEmpty
        ? 0
        : interKeyTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) /
            interKeyTimes.length;
  }

  // Add other metric calculation methods here as needed...
}
