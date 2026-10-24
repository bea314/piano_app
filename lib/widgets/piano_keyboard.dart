import 'package:flutter/material.dart';
import 'piano_key.dart';

class PianoKeyboard extends StatelessWidget {
  final Set<int> activeMidis;
  final void Function(int) onKeyDown;
  final void Function(int) onKeyUp;

  static const int firstMidi = 60; // C4
  static const int numKeys = 21;   // 1.75 octavas (12*1.75)
  static List<int> get midiRange => List.generate(numKeys, (i) => firstMidi + i);

  PianoKeyboard({
    super.key,
    required this.activeMidis,
    required this.onKeyDown,
    required this.onKeyUp,
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
    // Para 1.75 octavas, mostramos 21 teclas.
    final whites = midiRange.where(isWhite).toList();
    final blacks = midiRange.where((m) => !isWhite(m)).toList();

    final totalWhiteKeys = whites.length;
    final whiteKeyWidth = MediaQuery.of(context).size.width / 8; // 1.75 octavas ~ 8 blancas visibles
    final blackKeyWidth = whiteKeyWidth * 0.6;
    final whiteKeyHeight = MediaQuery.of(context).size.height * 0.28;
    final blackKeyHeight = whiteKeyHeight * 0.6;

    return SizedBox(
      height: whiteKeyHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: whiteKeyWidth * totalWhiteKeys,
          height: whiteKeyHeight,
          child: Stack(
            children: [
              // White keys
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
              // Black keys
              ...blacks.map((midi) {
                // Ubica la tecla negra entre las blancas
                final pos = whites.indexWhere((w) => w > midi);
                if (pos == 0 || pos == -1) return const SizedBox.shrink();
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
