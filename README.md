# Veggie Pizza Symphony

A romantic, musical mini-game for Valentine's Day, inspired by piano, pizza, and love! Play a Guitar Hero-style rhythm game using piano notes to create the perfect veggie pizza for your pianist girlfriend.

## Features
- **Guitar Hero-like gameplay:** Piano notes (ingredients) fall from the top. Hit the correct key as the note reaches the hit zone to add the ingredient to your pizza.
- **Custom piano sounds:** Each note (C, D, E, F) is generated and played as you hit the keys.
- **Background music:** A custom, romantic piano track sets the mood.
- **Combo and scoring system:** Earn points and combos for accuracy.
- **Visual feedback:** Animated hearts, floating labels, and a celebratory message when the pizza is complete.
- **Replayable:** Missed notes respawn, so you can always finish the pizza if you keep playing!

## Controls
- **A, S, D, F:** Play the corresponding piano notes to catch falling ingredients.
- **R:** Restart the game at any time.

## How to Play
1. Start the game with LÖVE (love2d).
2. Watch for falling notes (ingredients) and press the matching key as they reach the hit zone.
3. Each correct hit adds an ingredient to your pizza.
4. Complete the pizza before time runs out to win!
5. Enjoy the music, visuals, and a special Valentine's Day message.

## Requirements
- [LÖVE 2D](https://love2d.org/) (tested with 11.x)
- Python 3 (optional, for generating piano note WAV files)
- NumPy (for `generate_piano_notes.py`)

## Generating Piano Note Sounds
If you want to regenerate the piano note WAV files:

1. Make sure you have Python 3 and NumPy installed (see `shell.nix` for a Nix shell setup).
2. Run:
   ```sh
   python generate_piano_notes.py
   ```
   This will create `piano-c.wav`, `piano-d.wav`, `piano-e.wav`, and `piano-f.wav`.

## Custom Background Music
- The background music (`piano_pizza.wav`) was composed in Sonic Pi. See `piano_pizza.wav.rb` for the source code.

## File Structure
- `main.lua` — Main game code (LÖVE 2D)
- `generate_piano_notes.py` — Script to generate piano note WAV files
- `piano-c.wav`, `piano-d.wav`, `piano-e.wav`, `piano-f.wav` — Piano note sounds
- `piano_pizza.wav` — Background music
- `piano_pizza.wav.rb` — Sonic Pi source for background music
- `shell.nix` — Nix shell for Python/NumPy environment

## License
This project is a personal, romantic gift and is shared for inspiration and learning. Use, modify, and share with love!

---
Happy Valentine's Day! <3
