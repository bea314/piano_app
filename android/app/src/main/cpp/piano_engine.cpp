#include <android/log.h> // LOGS DE ANDROID PARA DEBUG NATIVO
#include "piano_engine.h"
#include "android_audio.h"
#include <thread>
#include <mutex>
#include <unordered_set>
#include <cmath>
#include <atomic>

static std::atomic<bool> running{false};
static int s_sampleRate = 44100;
static std::unordered_set<int> activeNotes;
static std::mutex notesMutex;
static double t = 0;

// Para OpenSL: genera el sample siguiente
float nextSample() {
    float sample = 0.0f;
    {
        std::lock_guard<std::mutex> lock(notesMutex);
        for (int midi : activeNotes) {
            double freq = 440.0 * pow(2.0, (midi - 69) / 12.0);
            sample += 0.15f * sin(2 * M_PI * freq * t / s_sampleRate);
        }
    }
    // Avanza el tiempo sólo si hay notas activas
    if (!activeNotes.empty())
        t += 1.0;
    return sample;
}

void piano_init(int sampleRate) {
    s_sampleRate = sampleRate;
    t = 0;
    android_audio_set_callback(nextSample);
    android_audio_init(sampleRate);
}

void piano_start() {
    running = true;
    android_audio_start();
}

void piano_stop() {
    running = false;
    android_audio_stop();
}

void piano_note_on(int midi) {
    __android_log_print(ANDROID_LOG_INFO, "PianoApp", "note_on: %d", midi);
    std::lock_guard<std::mutex> lock(notesMutex);
    activeNotes.insert(midi);
}

void piano_note_off(int midi) {
    std::lock_guard<std::mutex> lock(notesMutex);
    activeNotes.erase(midi);
}
