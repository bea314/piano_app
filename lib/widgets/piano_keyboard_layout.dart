/// Layout metrics shared by [PianoKeyboard] on every platform.
class PianoKeyboardLayout {
  PianoKeyboardLayout._();

  static const double minWhiteKeyHeight = 140;
  static const double maxWhiteKeyHeight = 420;
  static const double minWhiteKeyWidth = 36;
  static const double maxWhiteKeyWidth = 96;

  /// Black keys: wider than prior build for touch/mouse targets.
  static const double blackKeyWidthRatio = 0.62;
  static const double blackKeyHeightRatio = 0.62;

  static double whiteKeyHeight(double maxHeight) {
    final target = maxHeight * 0.88;
    return target.clamp(minWhiteKeyHeight, maxWhiteKeyHeight);
  }

  /// Width when the keyboard should fill the viewport (no horizontal scroll).
  static double whiteKeyWidthFill(double maxWidth, int whiteKeyCount) {
    if (whiteKeyCount <= 0) return minWhiteKeyWidth;
    return (maxWidth / whiteKeyCount).clamp(minWhiteKeyWidth, maxWhiteKeyWidth);
  }

  /// Width when keys would be too narrow — scroll horizontally instead.
  static double whiteKeyWidthScroll(int whiteKeyCount) {
    return minWhiteKeyWidth;
  }

  static bool shouldScrollHorizontally(double maxWidth, int whiteKeyCount) {
    if (whiteKeyCount <= 0) return false;
    return maxWidth / whiteKeyCount < minWhiteKeyWidth;
  }
}
