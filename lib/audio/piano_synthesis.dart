import 'dart:math' as math;

/// Per-note sine amplitude — matches [piano_engine.cpp] and prior web gain.
const double kPianoNoteAmplitude = 0.15;

/// Default output sample rate for all backends.
const int kPianoSampleRate = 44100;

/// Same logic as native Android [piano_engine.cpp]: summed sines per active note.
class PianoSynthesis {
  int sampleRate = kPianoSampleRate;
  double t = 0;
  final Set<int> activeNotes = {};

  double midiToHz(int midi) =>
      440.0 * math.pow(2, (midi - 69) / 12.0).toDouble();

  double nextSampleFloat() {
    var sample = 0.0;
    for (final midi in activeNotes) {
      final freq = midiToHz(midi);
      sample +=
          kPianoNoteAmplitude * math.sin(2 * math.pi * freq * t / sampleRate);
    }
    if (activeNotes.isNotEmpty) {
      t += 1;
    }
    return sample;
  }

  void fillFloat32(List<double> output, {int offset = 0, int? length}) {
    final end = offset + (length ?? output.length - offset);
    for (var i = offset; i < end; i++) {
      output[i] = nextSampleFloat().clamp(-1.0, 1.0);
    }
  }
}
