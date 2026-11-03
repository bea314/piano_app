import 'package:flutter/services.dart';

import '../models/piano_keyboard_spec.dart';

/// QWERTY → semitone offset from [firstMidi] (expects range starting on C).
abstract final class PianoComputerKeyboard {
  PianoComputerKeyboard._();

  static final Map<LogicalKeyboardKey, int> _semitoneOffsets = {
    // Lower octave (Z row)
    LogicalKeyboardKey.keyZ: 0,
    LogicalKeyboardKey.keyS: 1,
    LogicalKeyboardKey.keyX: 2,
    LogicalKeyboardKey.keyD: 3,
    LogicalKeyboardKey.keyC: 4,
    LogicalKeyboardKey.keyV: 5,
    LogicalKeyboardKey.keyG: 6,
    LogicalKeyboardKey.keyB: 7,
    LogicalKeyboardKey.keyH: 8,
    LogicalKeyboardKey.keyN: 9,
    LogicalKeyboardKey.keyJ: 10,
    LogicalKeyboardKey.keyM: 11,
    // Upper octave (Q row)
    LogicalKeyboardKey.keyQ: 12,
    LogicalKeyboardKey.digit2: 13,
    LogicalKeyboardKey.keyW: 14,
    LogicalKeyboardKey.digit3: 15,
    LogicalKeyboardKey.keyE: 16,
    LogicalKeyboardKey.keyR: 17,
    LogicalKeyboardKey.digit5: 18,
    LogicalKeyboardKey.keyT: 19,
    LogicalKeyboardKey.digit6: 20,
    LogicalKeyboardKey.keyY: 21,
    LogicalKeyboardKey.digit7: 22,
    LogicalKeyboardKey.keyU: 23,
  };

  static int? midiForKey(LogicalKeyboardKey key, int octaveOffset) {
    final offset = _semitoneOffsets[key];
    if (offset == null) return null;
    final first = PianoKeyboardSpec.firstMidiFor(octaveOffset);
    if (first % 12 != 0) return null;
    final midi = first + offset;
    if (!PianoKeyboardSpec.midiRangeFor(octaveOffset).contains(midi)) {
      return null;
    }
    return midi;
  }
}
