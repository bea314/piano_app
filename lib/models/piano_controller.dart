import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio/piano_audio.dart';
import 'piano_keyboard_spec.dart';

class PianoState {
  final Set<int> pressedKeys;
  const PianoState({required this.pressedKeys});
}

class PianoController extends StateNotifier<PianoState> {
  PianoController() : super(const PianoState(pressedKeys: {}));

  static final Set<int> _validMidis = PianoKeyboardSpec.midiRange.toSet();

  void noteOn(int midi) {
    if (!_validMidis.contains(midi)) return;
    if (!state.pressedKeys.contains(midi)) {
      final next = {...state.pressedKeys, midi};
      state = PianoState(pressedKeys: next);
      pianoNoteOn(midi);
    }
  }

  void noteOff(int midi) {
    if (!_validMidis.contains(midi)) return;
    if (state.pressedKeys.contains(midi)) {
      final next = {...state.pressedKeys}..remove(midi);
      state = PianoState(pressedKeys: next);
      pianoNoteOff(midi);
    }
  }
}

final pianoControllerProvider =
    StateNotifierProvider<PianoController, PianoState>(
  (ref) => PianoController(),
);
