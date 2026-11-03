import 'dart:math' as math;

/// Per-note sine amplitude — matches [piano_engine.cpp] and prior web gain.
const double kPianoNoteAmplitude = 0.15;

/// Default output sample rate for all backends.
const int kPianoSampleRate = 44100;

/// ~2 ms attack to reduce clicks without noticeable latency.
const double kPianoAttackSeconds = 0.002;

/// Same logic as native Android [piano_engine.cpp]: summed sines per active note.
class PianoSynthesis {
  PianoSynthesis();

  int sampleRate = kPianoSampleRate;
  double t = 0;
  final Set<int> activeNotes = {};
  final Map<int, double> _noteGains = {};

  int get _attackSamples =>
      math.max(1, (sampleRate * kPianoAttackSeconds).round());

  double midiToHz(int midi) =>
      440.0 * math.pow(2, (midi - 69) / 12.0).toDouble();

  void noteOn(int midi) {
    activeNotes.add(midi);
    _noteGains[midi] = 0;
  }

  void noteOff(int midi) {
    activeNotes.remove(midi);
    _noteGains.remove(midi);
  }

  void allNotesOff() {
    activeNotes.clear();
    _noteGains.clear();
  }

  double _gainFor(int midi) {
    var gain = _noteGains[midi] ?? 1.0;
    if (gain < 1.0) {
      gain = math.min(1.0, gain + 1.0 / _attackSamples);
      _noteGains[midi] = gain;
    }
    return gain;
  }

  double nextSampleFloat() {
    var sample = 0.0;
    for (final midi in activeNotes) {
      final freq = midiToHz(midi);
      final gain = _gainFor(midi);
      sample += kPianoNoteAmplitude *
          gain *
          math.sin(2 * math.pi * freq * t / sampleRate);
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
