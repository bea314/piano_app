import 'dart:io' show Platform;

import '../piano_ffi.dart' as ffi;
import 'piano_audio_common.dart';
import 'piano_audio_pcm.dart' as pcm;

PianoAudioBackend get pianoAudioBackend {
  if (Platform.isAndroid) {
    return PianoAudioBackend.nativeAndroid;
  }
  if (Platform.isIOS) {
    return PianoAudioBackend.iosAudioUnit;
  }
  return PianoAudioBackend.dartPcm;
}

String get pianoAudioBackendLabel => labelForBackend(pianoAudioBackend);

Future<void> pianoInit(int sampleRate) async {
  if (Platform.isAndroid) {
    ffi.pianoInit(sampleRate);
    return;
  }
  await pcm.pcmPianoInit(sampleRate, preferIosPlayback: Platform.isIOS);
}

void pianoStart() {
  if (Platform.isAndroid) {
    ffi.pianoStart();
    return;
  }
  pcm.pcmPianoStart();
}

void pianoStop() {
  if (Platform.isAndroid) {
    ffi.pianoStop();
    return;
  }
  pcm.pcmPianoStop();
}

void pianoNoteOn(int midi) {
  if (Platform.isAndroid) {
    ffi.pianoNoteOn(midi);
    return;
  }
  pcm.pcmPianoNoteOn(midi);
}

void pianoNoteOff(int midi) {
  if (Platform.isAndroid) {
    ffi.pianoNoteOff(midi);
    return;
  }
  pcm.pcmPianoNoteOff(midi);
}
