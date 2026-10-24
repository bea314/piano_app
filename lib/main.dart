import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'piano_ffi.dart'; // Tu archivo FFI

import 'models/piano_controller.dart';
import 'widgets/piano_keyboard.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pianoInit(44100); // O tu sampleRate
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
        ),
        body: OrientationBuilder(
          builder: (context, orientation) {
            return Center(
              child: PianoKeyboard(
                activeMidis: state.pressedKeys,
                onKeyDown: controller.noteOn,
                onKeyUp: controller.noteOff,
                midiRange: controller.keys, 
              ),
            );
          },
        ),
      ),
    );
  }
}