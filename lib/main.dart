import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio/piano_audio.dart';

import 'models/piano_controller.dart';
import 'widgets/piano_keyboard.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: PianoKeyboard(
                activeMidis: state.pressedKeys,
                onKeyDown: controller.noteOn,
                onKeyUp: controller.noteOff,
              ),
            );
          },
        ),
      ),
    );
  }
}