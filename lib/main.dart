import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio/piano_audio.dart';
import 'audio/piano_synthesis.dart';
import 'platform/piano_platform.dart';
import 'widgets/piano_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configurePianoSystemChrome();
  await pianoInit(kPianoSampleRate);
  pianoStart();
  runApp(const ProviderScope(child: PianoApp()));
}

class PianoApp extends StatefulWidget {
  const PianoApp({super.key});

  @override
  State<PianoApp> createState() => _PianoAppState();
}

class _PianoAppState extends State<PianoApp> {
  @override
  void dispose() {
    pianoStop();
    resetPianoSystemChrome();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Piano by EU DE',
      home: PianoScreen(),
    );
  }
}
