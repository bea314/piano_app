import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio/piano_audio.dart';

import 'models/piano_controller.dart';
import 'widgets/piano_keyboard.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS || Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  await pianoInit(44100);
  pianoStart();
  runApp(const ProviderScope(child: PianoApp()));
}

class PianoApp extends ConsumerStatefulWidget {
  const PianoApp({super.key});
  @override
  ConsumerState<PianoApp> createState() => _PianoAppState();
}

class _PianoAppState extends ConsumerState<PianoApp> {
  @override
  void dispose() {
    pianoStop();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pianoControllerProvider);
    final controller = ref.read(pianoControllerProvider.notifier);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Piano by EU DE'),
          centerTitle: true,
          bottom: pianoAudioBackend == PianoAudioBackend.nativeAndroid
              ? null
              : PreferredSize(
                  preferredSize: const Size.fromHeight(28),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      pianoAudioBackendLabel,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: PianoKeyboard(
                  maxWidth: constraints.maxWidth,
                  maxHeight: constraints.maxHeight,
                  activeMidis: state.pressedKeys,
                  onKeyDown: controller.noteOn,
                  onKeyUp: controller.noteOff,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}