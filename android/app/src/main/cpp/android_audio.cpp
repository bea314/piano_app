#include "android_audio.h"
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <vector>
#include <mutex>
#include <cstring>

static SLObjectItf engineObj = nullptr;
static SLEngineItf engine = nullptr;
static SLObjectItf outputMixObj = nullptr;
static SLObjectItf playerObj = nullptr;
static SLPlayItf playerPlay = nullptr;
static SLAndroidSimpleBufferQueueItf bufferQueue = nullptr;

static int sampleRate = 44100;
static const int bufSize = 1024;
static std::vector<short> audioBuffer1(bufSize);
static std::vector<short> audioBuffer2(bufSize);
static std::vector<short>* currentBuffer = &audioBuffer1;
static std::mutex audioMutex;
static bool running = false;

// Forward
void fillBuffer(short* buffer, int size);

// Callback cuando OpenSL necesita más audio
void bufferCallback(SLAndroidSimpleBufferQueueItf bq, void* context) {
    if (!running) return;
    std::lock_guard<std::mutex> lock(audioMutex);
    fillBuffer(currentBuffer->data(), bufSize);
    (*bq)->Enqueue(bq, currentBuffer->data(), bufSize * sizeof(short));
    // Alterna buffer
    currentBuffer = (currentBuffer == &audioBuffer1) ? &audioBuffer2 : &audioBuffer1;
}

// Esto se llamará desde piano_engine.cpp
static float (*s_nextSample)() = nullptr;
void android_audio_write_sample(float sample) {
    // ¡NO LA USES DIRECTO EN ESTA IMPLEMENTACIÓN!
    // OpenSL pedirá el buffer usando fillBuffer.
}

// La función que el motor de síntesis debe setear para obtener los samples actuales (delegación)
void android_audio_set_callback(float (*nextSampleFunc)()) {
    s_nextSample = nextSampleFunc;
}

// Llenar buffer con muestras desde tu síntesis (llamado desde el hilo OpenSL)
void fillBuffer(short* buffer, int size) {
    if (!s_nextSample) {
        memset(buffer, 0, size * sizeof(short));
        return;
    }
    for (int i = 0; i < size; ++i) {
        float sample = s_nextSample();
        // Clamp [-1, 1] y convierte a 16-bit PCM
        if (sample > 1.0f) sample = 1.0f;
        if (sample < -1.0f) sample = -1.0f;
        buffer[i] = (short)(sample * 32767);
    }
}

// Inicialización del motor
void android_audio_init(int sr) {
    sampleRate = sr;
    running = false;

    slCreateEngine(&engineObj, 0, nullptr, 0, nullptr, nullptr);
    (*engineObj)->Realize(engineObj, SL_BOOLEAN_FALSE);
    (*engineObj)->GetInterface(engineObj, SL_IID_ENGINE, &engine);

    // Output Mix
    (*engine)->CreateOutputMix(engine, &outputMixObj, 0, nullptr, nullptr);
    (*outputMixObj)->Realize(outputMixObj, SL_BOOLEAN_FALSE);
}

// Comienza la reproducción
void android_audio_start() {
    if (playerObj) return; // ya iniciado

    running = true;

    SLDataLocator_AndroidSimpleBufferQueue locBufq = {SL_DATALOCATOR_ANDROIDSIMPLEBUFFERQUEUE, 2};
    SLDataFormat_PCM formatPcm = {
        SL_DATAFORMAT_PCM, 1, // canales: mono
        (SLuint32)(sampleRate * 1000), SL_PCMSAMPLEFORMAT_FIXED_16,
        SL_PCMSAMPLEFORMAT_FIXED_16, SL_SPEAKER_FRONT_CENTER, SL_BYTEORDER_LITTLEENDIAN
    };
    SLDataSource audioSrc = {&locBufq, &formatPcm};
    SLDataLocator_OutputMix locOutmix = {SL_DATALOCATOR_OUTPUTMIX, outputMixObj};
    SLDataSink audioSnk = {&locOutmix, nullptr};

    const SLInterfaceID ids[1] = {SL_IID_ANDROIDSIMPLEBUFFERQUEUE};
    const SLboolean req[1] = {SL_BOOLEAN_TRUE};
    (*engine)->CreateAudioPlayer(engine, &playerObj, &audioSrc, &audioSnk, 1, ids, req);
    (*playerObj)->Realize(playerObj, SL_BOOLEAN_FALSE);
    (*playerObj)->GetInterface(playerObj, SL_IID_PLAY, &playerPlay);
    (*playerObj)->GetInterface(playerObj, SL_IID_ANDROIDSIMPLEBUFFERQUEUE, &bufferQueue);

    // Configura callback
    (*bufferQueue)->RegisterCallback(bufferQueue, bufferCallback, nullptr);

    // Comienza
    (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_PLAYING);
    bufferCallback(bufferQueue, nullptr); // primer buffer
}

// Detiene y limpia todo
void android_audio_stop() {
    running = false;
    if (playerObj) {
        (*playerPlay)->SetPlayState(playerPlay, SL_PLAYSTATE_STOPPED);
        (*playerObj)->Destroy(playerObj);
        playerObj = nullptr;
        playerPlay = nullptr;
        bufferQueue = nullptr;
    }
    if (outputMixObj) {
        (*outputMixObj)->Destroy(outputMixObj);
        outputMixObj = nullptr;
    }
    if (engineObj) {
        (*engineObj)->Destroy(engineObj);
        engineObj = nullptr;
        engine = nullptr;
    }
}
