import 'package:flutter/material.dart';

class PianoKey extends StatelessWidget {
  final bool isBlack;
  final bool active;
  final String label;
  final Color color;
  final VoidCallback onDown;
  final VoidCallback onUp;

  const PianoKey({
    super.key,
    required this.isBlack,
    required this.active,
    required this.label,
    required this.color,
    required this.onDown,
    required this.onUp,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: isBlack ? 34 : 56,
        height: isBlack ? 120 : 200,
        margin: EdgeInsets.symmetric(horizontal: isBlack ? 2 : 1),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: isBlack ? 0.8 : 0.5)
              : (isBlack ? Colors.black : Colors.white),
          border: Border.all(color: Colors.black54, width: isBlack ? 2.5 : 1.5),
          borderRadius: isBlack
              ? const BorderRadius.vertical(bottom: Radius.circular(8))
              : BorderRadius.circular(6),
          boxShadow: isBlack
              ? [const BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(1, 3))]
              : [const BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(1, 2))],
        ),
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.only(top: isBlack ? 6 : 12),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.19),
              border: Border.all(color: color, width: 1.2),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: isBlack ? 9 : 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
