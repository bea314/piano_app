#ifndef ANDROID_AUDIO_H
#define ANDROID_AUDIO_H

#ifdef __cplusplus
extern "C" {
#endif

void android_audio_init(int sampleRate);
void android_audio_start();
void android_audio_stop();
void android_audio_write_sample(float sample); // Ya no se necesita directamente, pero dejamos la firma para compatibilidad

void android_audio_set_callback(float (*nextSampleFunc)());

#ifdef __cplusplus
}
#endif

#endif // ANDROID_AUDIO_H
