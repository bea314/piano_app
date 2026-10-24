import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/piano_audio.dart';
import '../models/piano_controller.dart';
import 'piano_keyboard.dart';

/// Shared shell: app bar, safe areas, and keyboard placement (all platforms).
class PianoScreen extends ConsumerWidget {
  const PianoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pianoControllerProvider);
    final controller = ref.read(pianoControllerProvider.notifier);
    final media = MediaQuery.of(context);
    final horizontalSafe =
        media.padding.left + media.padding.right + media.viewPadding.left;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano by EU DE'),
        centerTitle: true,
        bottom: PreferredSize(
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
        minimum: EdgeInsets.fromLTRB(
          horizontalSafe > 0 ? 4 : 8,
          4,
          horizontalSafe > 0 ? 4 : 8,
          media.padding.bottom > 0 ? 2 : 8,
        ),
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
    );
  }
}
