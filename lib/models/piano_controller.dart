import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../piano_ffi.dart';

class PianoState {
  final Set<int> pressedKeys;
  const PianoState({required this.pressedKeys});
}

class PianoController extends StateNotifier<PianoState> {
  PianoController() : super(const PianoState(pressedKeys: {}));

  /// 8 octavas: C1 (24) a B8 (107)
  static const int lowestMidi = 24; // C1
  static const int highestMidi = 107; // B8
  static List<int> midiRange = List.generate(highestMidi - lowestMidi + 1, (i) => lowestMidi + i);

  void noteOn(int midi) {
    if (!midiRange.contains(midi)) return;
    if (!state.pressedKeys.contains(midi)) {
      final next = {...state.pressedKeys, midi};
      state = PianoState(pressedKeys: next);
      pianoNoteOn(midi);
    }
  }

  void noteOff(int midi) {
    if (!midiRange.contains(midi)) return;
    if (state.pressedKeys.contains(midi)) {
      final next = {...state.pressedKeys}..remove(midi);
      state = PianoState(pressedKeys: next);
      pianoNoteOff(midi);
    }
  }

  List<int> get keys => midiRange;
}

final pianoControllerProvider = StateNotifierProvider<PianoController, PianoState>(
  (ref) => PianoController(),
);