import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/piano_audio.dart';
import 'piano_keyboard_spec.dart';

class PianoState {
  final Set<int> pressedKeys;
  final int octaveOffset;
  final bool showLabels;

  const PianoState({
    required this.pressedKeys,
    this.octaveOffset = 0,
    this.showLabels = true,
  });

  List<int> get midiRange =>
      PianoKeyboardSpec.midiRangeFor(octaveOffset);

  PianoState copyWith({
    Set<int>? pressedKeys,
    int? octaveOffset,
    bool? showLabels,
  }) {
    return PianoState(
      pressedKeys: pressedKeys ?? this.pressedKeys,
      octaveOffset: octaveOffset ?? this.octaveOffset,
      showLabels: showLabels ?? this.showLabels,
    );
  }
}

class PianoController extends StateNotifier<PianoState> {
  PianoController() : super(const PianoState(pressedKeys: {}));

  Set<int> get _validMidis => state.midiRange.toSet();

  Future<void> _ensureAudio() => pianoEnsureAudioUnlocked();

  void noteOn(int midi) {
    if (!_validMidis.contains(midi)) return;
    unawaited(_ensureAudio());
    if (!state.pressedKeys.contains(midi)) {
      state = state.copyWith(pressedKeys: {...state.pressedKeys, midi});
      pianoNoteOn(midi);
    }
  }

  void noteOff(int midi) {
    if (!_validMidis.contains(midi)) return;
    if (state.pressedKeys.contains(midi)) {
      final next = {...state.pressedKeys}..remove(midi);
      state = state.copyWith(pressedKeys: next);
      pianoNoteOff(midi);
    }
  }

  void releaseAll() {
    for (final midi in state.pressedKeys.toList()) {
      pianoNoteOff(midi);
    }
    state = state.copyWith(pressedKeys: {});
    pianoAllNotesOff();
  }

  void shiftOctave(int delta) {
    final next = (state.octaveOffset + delta)
        .clamp(PianoKeyboardSpec.minOctaveOffset, PianoKeyboardSpec.maxOctaveOffset);
    if (next == state.octaveOffset) return;
    releaseAll();
    state = state.copyWith(octaveOffset: next);
  }

  void toggleLabels() {
    state = state.copyWith(showLabels: !state.showLabels);
  }
}

final pianoControllerProvider =
    StateNotifierProvider<PianoController, PianoState>(
  (ref) => PianoController(),
);
