import 'dart:math' as math;

import 'package:web/web.dart';

import 'piano_audio_common.dart';

AudioContext? _ctx;
final Map<int, OscillatorNode> _oscillators = {};

PianoAudioBackend get pianoAudioBackend => PianoAudioBackend.webAudio;

String get pianoAudioBackendLabel => labelForBackend(pianoAudioBackend);

Future<void> pianoInit(int sampleRate) async {
  _ctx = AudioContext();
  // sampleRate del contexto lo elige el navegador; la fórmula MIDI sigue igual.
}

void pianoStart() {
  _ctx?.resume();
}

void pianoStop() {
  for (final osc in _oscillators.values) {
    osc.stop();
  }
  _oscillators.clear();
  _ctx?.close();
  _ctx = null;
}

void pianoNoteOn(int midi) {
  final ctx = _ctx;
  if (ctx == null || _oscillators.containsKey(midi)) return;

  ctx.resume();

  final osc = ctx.createOscillator();
  osc.type = 'sine';
  osc.frequency.value =
      440.0 * math.pow(2, (midi - 69) / 12.0).toDouble();

  final gain = ctx.createGain();
  gain.gain.value = 0.15;

  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start();

  _oscillators[midi] = osc;
}

void pianoNoteOff(int midi) {
  final osc = _oscillators.remove(midi);
  if (osc == null) return;
  osc.stop();
}
