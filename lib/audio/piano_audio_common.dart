enum PianoAudioBackend {
  nativeAndroid,
  dartPcm,
  webAudio,
}

String labelForBackend(PianoAudioBackend backend) {
  return switch (backend) {
    PianoAudioBackend.nativeAndroid => 'Motor nativo (Android)',
    PianoAudioBackend.dartPcm => 'Síntesis Dart (preview iOS/desktop)',
    PianoAudioBackend.webAudio => 'Web Audio (preview web)',
  };
}
