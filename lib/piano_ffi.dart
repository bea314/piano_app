import 'dart:ffi' as ffi;
import 'dart:io';


final ffi.DynamicLibrary _lib = () {
  if (Platform.isAndroid) {
    return ffi.DynamicLibrary.open("libpiano_engine.so");
  } else if (Platform.isIOS) {
    return ffi.DynamicLibrary.process();
  }
  throw UnsupportedError("Unsupported platform");
}();

typedef _piano_init_c = ffi.Void Function(ffi.Int32 sampleRate);
typedef _piano_start_c = ffi.Void Function();
typedef _piano_stop_c = ffi.Void Function();
typedef _piano_note_on_c = ffi.Void Function(ffi.Int32 midi);
typedef _piano_note_off_c = ffi.Void Function(ffi.Int32 midi);

final _pianoInit = _lib
    .lookupFunction<_piano_init_c, void Function(int)>('piano_init');
final _pianoStart = _lib
    .lookupFunction<_piano_start_c, void Function()>('piano_start');
final _pianoStop = _lib
    .lookupFunction<_piano_stop_c, void Function()>('piano_stop');
final _pianoNoteOn = _lib
    .lookupFunction<_piano_note_on_c, void Function(int)>('piano_note_on');
final _pianoNoteOff = _lib
    .lookupFunction<_piano_note_off_c, void Function(int)>('piano_note_off');

// Métodos públicos para llamar desde Dart:
void pianoInit(int sampleRate) => _pianoInit(sampleRate);
void pianoStart() => _pianoStart();
void pianoStop() => _pianoStop();
void pianoNoteOn(int midi) => _pianoNoteOn(midi);
void pianoNoteOff(int midi) => _pianoNoteOff(midi);
