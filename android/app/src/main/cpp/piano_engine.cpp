#include "piano_engine.h"
#include "android_audio.h"
#include <mutex>
#include <unordered_map>
#include <unordered_set>
#include <cmath>
#include <atomic>

static std::atomic<bool> running{false};
static int s_sampleRate = 44100;
static std::unordered_set<int> activeNotes;
static std::unordered_map<int, float> noteGains;
static std::mutex notesMutex;
static double t = 0;

static int attackSamples() {
    int n = (int)(s_sampleRate * 0.002);
    return n < 1 ? 1 : n;
}

static float gainFor(int midi) {
    auto it = noteGains.find(midi);
    if (it == noteGains.end()) return 1.0f;
    float g = it->second;
    if (g < 1.0f) {
        g = std::min(1.0f, g + 1.0f / (float)attackSamples());
        it->second = g;
    }
    return g;
}

float nextSample() {
    float sample = 0.0f;
    {
        std::lock_guard<std::mutex> lock(notesMutex);
        for (int midi : activeNotes) {
            double freq = 440.0 * pow(2.0, (midi - 69) / 12.0);
            float gain = gainFor(midi);
            sample += 0.15f * gain * (float)sin(2 * M_PI * freq * t / s_sampleRate);
        }
        if (!activeNotes.empty())
            t += 1.0;
    }
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
    {
        std::lock_guard<std::mutex> lock(notesMutex);
        activeNotes.clear();
        noteGains.clear();
    }
    android_audio_stop();
}

void piano_note_on(int midi) {
    std::lock_guard<std::mutex> lock(notesMutex);
    activeNotes.insert(midi);
    noteGains[midi] = 0.0f;
}

void piano_note_off(int midi) {
    std::lock_guard<std::mutex> lock(notesMutex);
    activeNotes.erase(midi);
    noteGains.erase(midi);
}

void piano_all_notes_off() {
    std::lock_guard<std::mutex> lock(notesMutex);
    activeNotes.clear();
    noteGains.clear();
}
