import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/piano_audio.dart';
import '../models/piano_controller.dart';
import '../models/piano_keyboard_spec.dart';
import '../theme/piano_theme.dart';
import 'piano_computer_keyboard.dart';
import 'piano_keyboard.dart';

/// Shared shell: header, controls, and full-width keyboard (all platforms).
class PianoScreen extends ConsumerStatefulWidget {
  const PianoScreen({super.key});

  @override
  ConsumerState<PianoScreen> createState() => _PianoScreenState();
}

class _PianoScreenState extends ConsumerState<PianoScreen> {
  final FocusNode _focusNode = FocusNode(debugLabel: 'piano');
  final Set<LogicalKeyboardKey> _keysHeld = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    final controller = ref.read(pianoControllerProvider.notifier);
    final octave = ref.read(pianoControllerProvider).octaveOffset;

    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        controller.shiftOctave(-1);
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        controller.shiftOctave(1);
        return KeyEventResult.handled;
      }
      if (_keysHeld.contains(event.logicalKey)) {
        return KeyEventResult.handled;
      }
      final midi = PianoComputerKeyboard.midiForKey(
        event.logicalKey,
        octave,
      );
      if (midi != null) {
        _keysHeld.add(event.logicalKey);
        controller.noteOn(midi);
        return KeyEventResult.handled;
      }
    } else if (event is KeyUpEvent) {
      _keysHeld.remove(event.logicalKey);
      final midi = PianoComputerKeyboard.midiForKey(
        event.logicalKey,
        octave,
      );
      if (midi != null) {
        controller.noteOff(midi);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pianoControllerProvider, (previous, next) {
      if (previous?.octaveOffset != next.octaveOffset) {
        _keysHeld.clear();
      }
    });

    final state = ref.watch(pianoControllerProvider);
    final controller = ref.read(pianoControllerProvider.notifier);
    final first = state.midiRange.first;
    final last = state.midiRange.last;

    return Scaffold(
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _onKeyEvent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PIANO',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontFamily: 'Georgia',
                                  letterSpacing: 3,
                                  color: PianoTheme.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'by EU DE',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          if (kDebugMode) ...[
                            const SizedBox(height: 4),
                            Text(
                              pianoAudioBackendLabel,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(fontSize: 10),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Octave down',
                      onPressed: () => controller.shiftOctave(-1),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${PianoKeyboardSpec.noteName(first)} – '
                      '${PianoKeyboardSpec.noteName(last)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    IconButton(
                      tooltip: 'Octave up',
                      onPressed: () => controller.shiftOctave(1),
                      icon: const Icon(Icons.add),
                    ),
                    IconButton(
                      tooltip: state.showLabels
                          ? 'Hide key labels'
                          : 'Show key labels',
                      onPressed: controller.toggleLabels,
                      icon: Icon(
                        state.showLabels
                            ? Icons.label
                            : Icons.label_off_outlined,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: PianoTheme.keyBorder),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.bottomCenter,
                      child: PianoKeyboard(
                        maxWidth: constraints.maxWidth,
                        maxHeight: constraints.maxHeight,
                        octaveOffset: state.octaveOffset,
                        showLabels: state.showLabels,
                        activeMidis: state.pressedKeys,
                        onKeyDown: controller.noteOn,
                        onKeyUp: controller.noteOff,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
