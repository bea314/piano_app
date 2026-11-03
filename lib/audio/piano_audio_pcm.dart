import 'dart:async';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

import 'piano_synthesis.dart';

/// Smaller buffers → lower touch-to-sound latency (watch for underruns on device).
const _feedThreshold = 2048;
const _feedSize = 1024;

final PianoSynthesis _synth = PianoSynthesis();

Future<void> pcmPianoInit(
  int sampleRate, {
  bool preferIosPlayback = false,
}) async {
  _synth.sampleRate = sampleRate;
  _synth.t = 0;
  _synth.allNotesOff();
  await FlutterPcmSound.setLogLevel(LogLevel.error);
  await FlutterPcmSound.setup(
    sampleRate: sampleRate,
    channelCount: 1,
    iosAudioCategory: preferIosPlayback
        ? IosAudioCategory.playback
        : IosAudioCategory.soloAmbient,
    iosAllowBackgroundAudio: false,
  );
  await FlutterPcmSound.setFeedThreshold(_feedThreshold);
  FlutterPcmSound.setFeedCallback(_onFeed);
}

void pcmPianoStart() {
  FlutterPcmSound.start();
}

void pcmPianoStop() {
  _synth.allNotesOff();
  unawaited(FlutterPcmSound.release());
}

void pcmPianoNoteOn(int midi) {
  _synth.noteOn(midi);
}

void pcmPianoNoteOff(int midi) {
  _synth.noteOff(midi);
}

void pcmPianoAllNotesOff() {
  _synth.allNotesOff();
}

void _onFeed(int remainingFrames) {
  final buffer = PcmArrayInt16.zeros(count: _feedSize);
  for (var i = 0; i < buffer.count; i++) {
    final s = _synth.nextSampleFloat().clamp(-1.0, 1.0);
    buffer[i] = (s * 32767).round();
  }
  unawaited(FlutterPcmSound.feed(buffer));
}
