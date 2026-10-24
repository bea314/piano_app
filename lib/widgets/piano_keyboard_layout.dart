/// Layout metrics shared by [PianoKeyboard] on every platform.
class PianoKeyboardLayout {
  PianoKeyboardLayout._();

  static const double minWhiteKeyHeight = 120;
  static const double maxWhiteKeyHeight = 280;
  static const double heightFill = 0.92;

  static const double minWhiteKeyWidth = 44;
  static const double maxWhiteKeyWidth = 72;
  static const double whiteKeysPerViewport = 10;

  static const double blackKeyWidthRatio = 0.58;
  static const double blackKeyHeightRatio = 0.58;

  static double whiteKeyHeight(double maxHeight) =>
      (maxHeight * heightFill).clamp(minWhiteKeyHeight, maxWhiteKeyHeight);

  static double whiteKeyWidth(double maxWidth) =>
      (maxWidth / whiteKeysPerViewport).clamp(minWhiteKeyWidth, maxWhiteKeyWidth);
}
