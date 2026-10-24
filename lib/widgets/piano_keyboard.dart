import 'package:flutter/material.dart';
import 'piano_key.dart';

class PianoKeyboard extends StatelessWidget {
  final Set<int> activeMidis;
  final void Function(int) onKeyDown;
  final void Function(int) onKeyUp;
  final double maxWidth;
  final double maxHeight;

  static const int firstMidi = 60; // C4
  static const int numKeys = 21; // 1.75 octavas (12*1.75)
  static List<int> get midiRange =>
      List.generate(numKeys, (i) => firstMidi + i);

  const PianoKeyboard({
    super.key,
    required this.activeMidis,
    required this.onKeyDown,
    required this.onKeyUp,
    required this.maxWidth,
    required this.maxHeight,
  });

  bool isWhite(int midi) => [0, 2, 4, 5, 7, 9, 11].contains((midi % 12));

  static String midiLabel(int midi) {
    const names = [
      'C', 'C#\nDb', 'D', 'D#\nEb', 'E', 'F', 'F#\nGb',
      'G', 'G#\nAb', 'A', 'A#\nBb', 'B'
    ];
    int octave = (midi ~/ 12) - 1;
    return '${names[midi % 12]}$octave';
  }

  @override
  Widget build(BuildContext context) {
    final whites = midiRange.where(isWhite).toList();
    final blacks = midiRange.where((m) => !isWhite(m)).toList();

    final totalWhiteKeys = whites.length;
    final whiteKeyHeight =
        (maxHeight * 0.92).clamp(120.0, 280.0);
    final whiteKeyWidth = (maxWidth / 10).clamp(44.0, 72.0);
    final blackKeyWidth = whiteKeyWidth * 0.58;
    final blackKeyHeight = whiteKeyHeight * 0.58;
    final keyboardWidth = whiteKeyWidth * totalWhiteKeys;

    return SizedBox(
      width: maxWidth,
      height: whiteKeyHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.paddingOf(context).left > 0 ? 4 : 0,
        ),
        child: SizedBox(
          width: keyboardWidth,
          height: whiteKeyHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: whites.map((midi) {
                  return SizedBox(
                    width: whiteKeyWidth,
                    height: whiteKeyHeight,
                    child: PianoKey(
                      isBlack: false,
                      active: activeMidis.contains(midi),
                      label: midiLabel(midi),
                      color: Colors.blue,
                      onDown: () => onKeyDown(midi),
                      onUp: () => onKeyUp(midi),
                    ),
                  );
                }).toList(),
              ),
              ...blacks.map((midi) {
                final pos = whites.indexWhere((w) => w > midi);
                if (pos <= 0) return const SizedBox.shrink();
                return Positioned(
                  left: (pos * whiteKeyWidth) - (blackKeyWidth / 2),
                  top: 0,
                  width: blackKeyWidth,
                  height: blackKeyHeight,
                  child: PianoKey(
                    isBlack: true,
                    active: activeMidis.contains(midi),
                    label: midiLabel(midi),
                    color: Colors.indigo,
                    onDown: () => onKeyDown(midi),
                    onUp: () => onKeyUp(midi),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
