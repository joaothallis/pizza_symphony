import numpy as np
import wave
import struct

# Audio parameters
sample_rate = 44100  # Hz
duration = 0.5       # seconds
amplitude = 0.95     # Increased volume (near max, was 0.8)

# Piano note frequencies (middle octave, C4 to F4)
notes = {
    "c": 261.63,  # C4
    "d": 293.66,  # D4
    "e": 329.63,  # E4
    "f": 349.23   # F4
}

def generate_sine_wave(frequency, duration, sample_rate, amplitude):
    """Generate a sine wave with a harmonic for a piano-like sound."""
    t = np.linspace(0, duration, int(sample_rate * duration), False)
    # Base tone + second harmonic (1/3 amplitude) for richer sound
    wave = amplitude * (np.sin(2 * np.pi * frequency * t) + 0.33 * np.sin(2 * np.pi * 2 * frequency * t))
    # Apply envelope to avoid clicks (fade in/out)
    envelope = np.exp(-4 * t / duration) * np.exp(-4 * (duration - t) / duration)
    # Normalize to prevent clipping
    audio = wave * envelope * 32767 / np.max(np.abs(wave * envelope))
    return audio.astype(np.int16)

def save_wav(filename, audio):
    """Save audio data to a WAV file."""
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)  # Mono
        wav_file.setsampwidth(2)  # 16-bit
        wav_file.setframerate(sample_rate)
        # Convert to binary data
        for sample in audio:
            wav_file.writeframes(struct.pack('<h', sample))

def main():
    for note, freq in notes.items():
        # Generate sine wave for the note
        audio = generate_sine_wave(freq, duration, sample_rate, amplitude)
        # Save to WAV file
        filename = f"piano-{note}.wav"
        save_wav(filename, audio)
        print(f"Generated {filename}")

if __name__ == "__main__":
    main()
