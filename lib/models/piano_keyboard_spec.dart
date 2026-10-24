/// Shared keyboard layout and note naming — same on web, Android, and iOS.
class PianoKeyboardSpec {
  PianoKeyboardSpec._();

  static const int firstMidi = 60; // C4
  static const int numKeys = 21; // 1.75 octaves

  static List<int> get midiRange =>
      List.generate(numKeys, (i) => firstMidi + i);

  static bool isWhiteKey(int midi) =>
      const [0, 2, 4, 5, 7, 9, 11].contains(midi % 12);

  static String midiLabel(int midi) {
    const names = [
      'C',
      'C#\nDb',
      'D',
      'D#\nEb',
      'E',
      'F',
      'F#\nGb',
      'G',
      'G#\nAb',
      'A',
      'A#\nBb',
      'B',
    ];
    final octave = (midi ~/ 12) - 1;
    return '${names[midi % 12]}$octave';
  }
}
