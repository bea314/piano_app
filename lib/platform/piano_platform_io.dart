import 'dart:io' show Platform;

import 'package:flutter/services.dart';

bool get pianoIsMobile => Platform.isIOS || Platform.isAndroid;

Future<void> configurePianoSystemChrome() async {
  if (!pianoIsMobile) return;
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
}

Future<void> resetPianoSystemChrome() async {
  if (!pianoIsMobile) return;
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
}
