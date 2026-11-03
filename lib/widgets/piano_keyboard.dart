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
  final int octaveOffset;
  final bool showLabels;

  const PianoKeyboard({
    super.key,
    required this.activeMidis,
    required this.onKeyDown,
    required this.onKeyUp,
    required this.maxWidth,
    required this.maxHeight,
    required this.octaveOffset,
    required this.showLabels,
  });

  @override
  Widget build(BuildContext context) {
    final midiRange = PianoKeyboardSpec.midiRangeFor(octaveOffset);
    final whites = midiRange.where(PianoKeyboardSpec.isWhiteKey).toList();
    final blacks =
        midiRange.where((m) => !PianoKeyboardSpec.isWhiteKey(m)).toList();

    final totalWhiteKeys = whites.length;
    final scroll = PianoKeyboardLayout.shouldScrollHorizontally(
      maxWidth,
      totalWhiteKeys,
    );
    final whiteKeyHeight = PianoKeyboardLayout.whiteKeyHeight(maxHeight);
    final whiteKeyWidth = scroll
        ? PianoKeyboardLayout.whiteKeyWidthScroll(totalWhiteKeys)
        : PianoKeyboardLayout.whiteKeyWidthFill(maxWidth, totalWhiteKeys);
    final blackKeyWidth = whiteKeyWidth * PianoKeyboardLayout.blackKeyWidthRatio;
    final blackKeyHeight =
        whiteKeyHeight * PianoKeyboardLayout.blackKeyHeightRatio;
    final keyboardWidth = whiteKeyWidth * totalWhiteKeys;

    Widget keyboard = SizedBox(
      width: keyboardWidth,
      height: whiteKeyHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: whites.map((midi) {
              final label = showLabels
                  ? PianoKeyboardSpec.whiteKeyLabel(midi)
                  : null;
              return SizedBox(
                width: whiteKeyWidth,
                height: whiteKeyHeight,
                child: PianoKey(
                  isBlack: false,
                  active: activeMidis.contains(midi),
                  label: label,
                  onDown: () => onKeyDown(midi),
                  onUp: () => onKeyUp(midi),
                ),
              );
            }).toList(),
          ),
          ...blacks.map((midi) {
            final pos = whites.indexWhere((w) => w > midi);
            if (pos <= 0) return const SizedBox.shrink();
            final label = showLabels
                ? PianoKeyboardSpec.blackKeyLabel(midi)
                : null;
            return Positioned(
              left: (pos * whiteKeyWidth) - (blackKeyWidth / 2),
              top: 0,
              width: blackKeyWidth,
              height: blackKeyHeight,
              child: PianoKey(
                isBlack: true,
                active: activeMidis.contains(midi),
                label: label,
                onDown: () => onKeyDown(midi),
                onUp: () => onKeyUp(midi),
              ),
            );
          }),
        ],
      ),
    );

    if (scroll) {
      keyboard = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: keyboard,
      );
    }

    return SizedBox(
      width: maxWidth,
      height: whiteKeyHeight,
      child: scroll
          ? keyboard
          : Center(child: keyboard),
    );
  }
}
