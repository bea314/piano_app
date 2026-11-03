#pragma once
#include <jni.h>
#ifdef __cplusplus
extern "C" {
#endif

void piano_init(int sampleRate);
void piano_start();
void piano_stop();
void piano_note_on(int midi);
void piano_note_off(int midi);
void piano_all_notes_off();

#ifdef __cplusplus
}
#endif
