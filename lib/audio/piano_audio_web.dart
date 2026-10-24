import 'dart:js_interop';

import 'package:web/web.dart';

import 'piano_audio_common.dart';
import 'piano_synthesis.dart';

const _scriptBufferSize = 4096;

AudioContext? _ctx;
ScriptProcessorNode? _processor;
final PianoSynthesis _synth = PianoSynthesis();

PianoAudioBackend get pianoAudioBackend => PianoAudioBackend.webAudio;

String get pianoAudioBackendLabel => labelForBackend(pianoAudioBackend);

Future<void> pianoInit(int sampleRate) async {
  _synth.sampleRate = sampleRate;
  _synth.t = 0;
  _synth.activeNotes.clear();
  _ctx = AudioContext();
}

void pianoStart() {
  final ctx = _ctx;
  if (ctx == null) return;

  _processor?.disconnect();
  _processor = ctx.createScriptProcessor(_scriptBufferSize, 0, 1);
  _processor!.onaudioprocess = ((Event event) {
    final output =
        (event as AudioProcessingEvent).outputBuffer.getChannelData(0).toDart;
    for (var i = 0; i < output.length; i++) {
      output[i] = _synth.nextSampleFloat().clamp(-1.0, 1.0);
    }
  }).toJS;
  _processor!.connect(ctx.destination);
  ctx.resume();
}

void pianoStop() {
  _synth.activeNotes.clear();
  _processor?.disconnect();
  _processor = null;
  _ctx?.close();
  _ctx = null;
}

void _ensureRunning() {
  _ctx?.resume();
}

void pianoNoteOn(int midi) {
  _ensureRunning();
  _synth.activeNotes.add(midi);
}

void pianoNoteOff(int midi) {
  _synth.activeNotes.remove(midi);
}
