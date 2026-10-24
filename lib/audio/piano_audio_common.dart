enum PianoAudioBackend {
  nativeAndroid,
  iosAudioUnit,
  dartPcm,
  webAudio,
}

String labelForBackend(PianoAudioBackend backend) {
  return switch (backend) {
    PianoAudioBackend.nativeAndroid => 'Motor nativo (Android)',
    PianoAudioBackend.iosAudioUnit =>
      'Síntesis Dart + AudioUnit (iOS)',
    PianoAudioBackend.dartPcm => 'Síntesis Dart (desktop)',
    PianoAudioBackend.webAudio => 'Web Audio (web)',
  };
}
