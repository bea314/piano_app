/// Shared keyboard layout and note naming — same on web, Android, and iOS.
class PianoKeyboardSpec {
  PianoKeyboardSpec._();

  static const int baseFirstMidi = 60; // C4
  static const int numKeys = 24; // two octaves (C4–B5)
  static const int minOctaveOffset = -2;
  static const int maxOctaveOffset = 3;

  static int firstMidiFor(int octaveOffset) =>
      baseFirstMidi + octaveOffset.clamp(minOctaveOffset, maxOctaveOffset) * 12;

  static List<int> midiRangeFor(int octaveOffset) {
    final first = firstMidiFor(octaveOffset);
    return List.generate(numKeys, (i) => first + i);
  }

  static bool isWhiteKey(int midi) =>
      const [0, 2, 4, 5, 7, 9, 11].contains(midi % 12);

  /// Short label for white keys (e.g. `C4`).
  static String whiteKeyLabel(int midi) {
    const names = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
    final whiteIndex = [0, 2, 4, 5, 7, 9, 11].indexOf(midi % 12);
    final octave = (midi ~/ 12) - 1;
    return '${names[whiteIndex]}$octave';
  }

  /// Optional sharp name for black keys (e.g. `C#`).
  static String? blackKeyLabel(int midi) {
    const names = [
      null,
      'C#',
      null,
      'D#',
      null,
      null,
      'F#',
      null,
      'G#',
      null,
      'A#',
      null,
    ];
    return names[midi % 12];
  }

  /// Compact name for any key (e.g. `F#4`).
  static String noteName(int midi) {
    const names = [
      'C',
      'C#',
      'D',
      'D#',
      'E',
      'F',
      'F#',
      'G',
      'G#',
      'A',
      'A#',
      'B',
    ];
    final octave = (midi ~/ 12) - 1;
    return '${names[midi % 12]}$octave';
  }
}
