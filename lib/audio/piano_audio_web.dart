import 'dart:async' show unawaited;
import 'dart:js_interop';

import 'package:web/web.dart';

import 'piano_audio_common.dart';
import 'piano_synthesis.dart';

AudioContext? _ctx;
AudioWorkletNode? _worklet;
bool _workletReady = false;
int _sampleRate = kPianoSampleRate;

PianoAudioBackend get pianoAudioBackend => PianoAudioBackend.webAudio;

String get pianoAudioBackendLabel => labelForBackend(pianoAudioBackend);

Future<void> pianoInit(int sampleRate) async {
  _sampleRate = sampleRate == 0 ? kPianoSampleRate : sampleRate;
  _ctx?.close();
  _ctx = AudioContext(
    AudioContextOptions(latencyHint: 'interactive'.toJS),
  );
  await _ctx!.audioWorklet.addModule('piano_synth_worklet.js').toDart;
  _workletReady = true;
}

void pianoStart() {
  final ctx = _ctx;
  if (ctx == null || !_workletReady) return;

  _worklet?.disconnect();
  _worklet = AudioWorkletNode(ctx, 'piano-synth-processor');
  _worklet!.port.postMessage(
    {'type': 'config', 'sampleRate': _sampleRate}.jsify(),
  );
  _worklet!.connect(ctx.destination);
  ctx.resume();
}

void pianoStop() {
  _postMessage('allOff', 0);
  _worklet?.disconnect();
  _worklet = null;
  _ctx?.close();
  _ctx = null;
  _workletReady = false;
}

Future<void> pianoEnsureAudioUnlocked() async {
  final ctx = _ctx;
  if (ctx == null) return;
  if (ctx.state == 'suspended') {
    await ctx.resume().toDart;
  }
}

void pianoNoteOn(int midi) {
  unawaited(pianoEnsureAudioUnlocked());
  _postMessage('noteOn', midi);
}

void pianoNoteOff(int midi) {
  _postMessage('noteOff', midi);
}

void pianoAllNotesOff() {
  _postMessage('allOff', 0);
}

void _postMessage(String type, int midi) {
  final port = _worklet?.port;
  if (port == null) return;
  port.postMessage({'type': type, 'midi': midi}.jsify());
}
