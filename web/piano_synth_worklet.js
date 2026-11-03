/// AudioWorklet synthesis — matches Dart [PianoSynthesis] / native engine math.
class PianoSynthProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.activeNotes = new Set();
    this.gains = new Map();
    this.t = 0;
    this.sampleRate = 44100;
    this.attackSamples = Math.max(1, Math.floor(this.sampleRate * 0.002));

    this.port.onmessage = (event) => {
      const data = event.data;
      if (!data || !data.type) return;
      if (data.type === 'config') {
        this.sampleRate = data.sampleRate || 44100;
        this.attackSamples = Math.max(1, Math.floor(this.sampleRate * 0.002));
        return;
      }
      const midi = data.midi;
      if (data.type === 'noteOn') {
        this.activeNotes.add(midi);
        this.gains.set(midi, 0);
      } else if (data.type === 'noteOff') {
        this.activeNotes.delete(midi);
        this.gains.delete(midi);
      } else if (data.type === 'allOff') {
        this.activeNotes.clear();
        this.gains.clear();
      }
    };
  }

  midiToHz(midi) {
    return 440 * Math.pow(2, (midi - 69) / 12);
  }

  process(inputs, outputs) {
    const output = outputs[0][0];
    if (!output) return true;

    for (let i = 0; i < output.length; i++) {
      let sample = 0;
      for (const midi of this.activeNotes) {
        let gain = this.gains.get(midi) ?? 1;
        if (gain < 1) {
          gain = Math.min(1, gain + 1 / this.attackSamples);
          this.gains.set(midi, gain);
        }
        const freq = this.midiToHz(midi);
        sample +=
          0.15 * gain * Math.sin((2 * Math.PI * freq * this.t) / this.sampleRate);
      }
      output[i] = Math.max(-1, Math.min(1, sample));
      if (this.activeNotes.size > 0) this.t += 1;
    }
    return true;
  }
}

registerProcessor('piano-synth-processor', PianoSynthProcessor);
