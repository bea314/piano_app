import 'dart:async';

import 'package:flutter_pcm_sound/flutter_pcm_sound.dart';

import 'piano_synthesis.dart';

const _feedThreshold = 8000;
const _feedSize = 4096;

final PianoSynthesis _synth = PianoSynthesis();

Future<void> pcmPianoInit(
  int sampleRate, {
  bool preferIosPlayback = false,
}) async {
  _synth.sampleRate = sampleRate;
  _synth.t = 0;
  _synth.activeNotes.clear();
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
  _synth.activeNotes.clear();
  unawaited(FlutterPcmSound.release());
}

void pcmPianoNoteOn(int midi) {
  _synth.activeNotes.add(midi);
}

void pcmPianoNoteOff(int midi) {
  _synth.activeNotes.remove(midi);
}

void _onFeed(int remainingFrames) {
  final buffer = PcmArrayInt16.zeros(count: _feedSize);
  _synth.fillPcm(buffer);
  unawaited(FlutterPcmSound.feed(buffer));
}
