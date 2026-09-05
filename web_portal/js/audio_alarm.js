/**
 * TrainWake Web Portal - Audio Alarm Synthesizer
 * Uses Web Audio API to create authentic escalating railway wake-up alarm sound
 */

class WebAlarmPlayer {
  constructor() {
    this.audioCtx = null;
    this.oscillator1 = null;
    this.oscillator2 = null;
    this.gainNode = null;
    this.isPlaying = false;
    this.intervalId = null;
  }

  _initContext() {
    if (!this.audioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.audioCtx = new AudioContext();
    }
    if (this.audioCtx.state === 'suspended') {
      this.audioCtx.resume();
    }
  }

  play() {
    if (this.isPlaying) return;
    this._initContext();
    this.isPlaying = true;

    // Pulse siren pattern between 880Hz (A5) and 1320Hz (E6)
    let toggle = false;

    const playBeep = () => {
      if (!this.isPlaying) return;

      const osc = this.audioCtx.createOscillator();
      const gain = this.audioCtx.createGain();

      osc.type = 'triangle';
      osc.frequency.setValueAtTime(toggle ? 987.77 : 1318.51, this.audioCtx.currentTime); // B5 / E6

      gain.gain.setValueAtTime(0.01, this.audioCtx.currentTime);
      gain.gain.exponentialRampToValueAtTime(0.4, this.audioCtx.currentTime + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.001, this.audioCtx.currentTime + 0.25);

      osc.connect(gain);
      gain.connect(this.audioCtx.destination);

      osc.start();
      osc.stop(this.audioCtx.currentTime + 0.28);

      toggle = !toggle;
    };

    playBeep();
    this.intervalId = setInterval(playBeep, 320);

    // Notify UI
    window.dispatchEvent(new CustomEvent('trainwake:alarm_started'));
  }

  stop() {
    if (!this.isPlaying) return;
    this.isPlaying = false;
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
    window.dispatchEvent(new CustomEvent('trainwake:alarm_stopped'));
  }

  toggle() {
    if (this.isPlaying) {
      this.stop();
    } else {
      this.play();
    }
  }
}

const alarmPlayer = new WebAlarmPlayer();
