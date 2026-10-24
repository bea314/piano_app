import 'dart:math' as math;

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

/// Misma lógica que [piano_engine.cpp]: senos sumados por nota activa.
class PianoSynthesis {
  int sampleRate = 44100;
  double t = 0;
  final Set<int> activeNotes = {};

  double midiToHz(int midi) =>
      440.0 * math.pow(2, (midi - 69) / 12.0).toDouble();

  double nextSampleFloat() {
    var sample = 0.0;
    for (final midi in activeNotes) {
      final freq = midiToHz(midi);
      sample += 0.15 * math.sin(2 * math.pi * freq * t / sampleRate);
    }
    if (activeNotes.isNotEmpty) {
      t += 1;
    }
    return sample;
  }

  void fillPcm(PcmArrayInt16 buffer) {
    for (var i = 0; i < buffer.count; i++) {
      final s = nextSampleFloat().clamp(-1.0, 1.0);
      buffer[i] = (s * 32767).round();
    }
  }
}
