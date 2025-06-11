# Valentine's Day Song for Your Pianist Girlfriend
# Created with Sonic Pi for a romantic, playful vibe
# Inspired by her love for piano, pizza, cheese, bread, and coffee

use_bpm 120  # Set a moderate tempo for a warm, romantic feel

# Intro: A gentle piano melody to capture her pianist heart
use_synth :piano
live_loop :melody do
  play_pattern_timed [:C4, :E4, :G4, :B4, :A4, :F4], [0.5, 0.5, 0.5, 0.5, 1, 1], release: 1
  play_pattern_timed [:D4, :F4, :A4, :C5, :B4, :G4], [0.5, 0.5, 0.5, 0.5, 1, 1], release: 1
  sleep 4  # Pause to let the melody breathe
end

# Beat: A rhythmic pulse inspired by the joy of pizza and bread
live_loop :drum_beat, sync: :melody do
  sample :drum_bass_soft, amp: 1.5  # Soft kick for a cozy feel
  sleep 1
  sample :drum_cymbal_soft, amp: 0.5  # Gentle cymbal for texture
  sleep 0.5
  sample :drum_snare_soft, amp: 1  # Snare for a crisp, bread-like crunch
  sleep 0.5
end

# Bassline: Warm and cheesy, like her favorite cheese
use_synth :fm
live_loop :bass, sync: :melody do
  play :C2, release: 0.8, amp: 1.2
  sleep 1
  play :G2, release: 0.8, amp: 1.2
  sleep 1
  play :A2, release: 0.8, amp: 1.2
  sleep 1
  play :F2, release: 0.8, amp: 1.2
  sleep 1
end

# Coffee-inspired arpeggio: Perky and energetic
live_loop :coffee_arp, sync: :melody do
  use_synth :pretty_bell  # Bright sound for coffee's energy
  play_pattern_timed chord(:C4, :major), 0.25, release: 0.3, amp: 0.8
  play_pattern_timed chord(:F4, :major), 0.25, release: 0.3, amp: 0.8
  play_pattern_timed chord(:G4, :major), 0.25, release: 0.3, amp: 0.8
  play_pattern_timed chord(:A4, :minor), 0.25, release: 0.3, amp: 0.8
end

# Add a playful pizza-inspired sound effect
live_loop :pizza_sfx, sync: :melody do
  sleep 8  # Play less frequently for surprise
  sample :misc_crow, rate: 0.5, amp: 0.6  # Playful, quirky sound for pizza
  sleep 8
end