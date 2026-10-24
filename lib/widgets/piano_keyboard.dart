import 'package:flutter/material.dart';

import '../models/piano_keyboard_spec.dart';
import 'piano_key.dart';
import 'piano_keyboard_layout.dart';

class PianoKeyboard extends StatelessWidget {
  final Set<int> activeMidis;
  final void Function(int) onKeyDown;
  final void Function(int) onKeyUp;
  final double maxWidth;
  final double maxHeight;

  const PianoKeyboard({
    super.key,
    required this.activeMidis,
    required this.onKeyDown,
    required this.onKeyUp,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final midiRange = PianoKeyboardSpec.midiRange;
    final whites = midiRange.where(PianoKeyboardSpec.isWhiteKey).toList();
    final blacks = midiRange.where((m) => !PianoKeyboardSpec.isWhiteKey(m)).toList();

    final totalWhiteKeys = whites.length;
    final whiteKeyHeight = PianoKeyboardLayout.whiteKeyHeight(maxHeight);
    final whiteKeyWidth = PianoKeyboardLayout.whiteKeyWidth(maxWidth);
    final blackKeyWidth = whiteKeyWidth * PianoKeyboardLayout.blackKeyWidthRatio;
    final blackKeyHeight =
        whiteKeyHeight * PianoKeyboardLayout.blackKeyHeightRatio;
    final keyboardWidth = whiteKeyWidth * totalWhiteKeys;

    final edgeInset = MediaQuery.paddingOf(context).left +
        MediaQuery.paddingOf(context).right;

    return SizedBox(
      width: maxWidth,
      height: whiteKeyHeight,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: edgeInset > 0 ? 4 : 0),
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
                      label: PianoKeyboardSpec.midiLabel(midi),
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
                    label: PianoKeyboardSpec.midiLabel(midi),
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
