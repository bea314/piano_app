import 'package:flutter/material.dart';

import '../theme/piano_theme.dart';

class PianoKey extends StatelessWidget {
  final bool isBlack;
  final bool active;
  final String? label;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const PianoKey({
    super.key,
    required this.isBlack,
    required this.active,
    required this.label,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    final baseFill = isBlack ? const Color(0xFF121212) : PianoTheme.ivory;
    final activeFill = isBlack
        ? PianoTheme.accent.withValues(alpha: 0.85)
        : PianoTheme.accent.withValues(alpha: 0.35);

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 45),
        curve: Curves.easeOut,
        width: double.infinity,
        height: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: isBlack ? 0.5 : 0.35),
        decoration: BoxDecoration(
          color: active ? activeFill : baseFill,
          border: Border.all(
            color: active ? PianoTheme.accent : PianoTheme.keyBorder,
            width: isBlack ? 1.5 : 1,
          ),
          borderRadius: isBlack
              ? const BorderRadius.vertical(bottom: Radius.circular(5))
              : const BorderRadius.vertical(bottom: Radius.circular(6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isBlack ? 0.55 : 0.25),
              blurRadius: active ? 2 : 4,
              offset: Offset(0, active ? 1 : 3),
            ),
          ],
        ),
        child: label == null
            ? null
            : Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: isBlack ? 4 : 10),
                  child: Text(
                    label!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isBlack
                          ? (active ? PianoTheme.background : Colors.white70)
                          : PianoTheme.accentMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: isBlack ? 9 : 11,
                      height: 1,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
