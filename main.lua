-- Valentine's Day Pizza Symphony Game (Vegetarian Edition with Background Music)
-- Run in LÖVE framework (love2d.org)

-- Game state
local ingredients = {"Cheese", "Spinach", "Bell Peppers", "Olives"}
local added_ingredients = {}
local piano_notes = {"c", "d", "e", "f"}
local key_map = {a = 1, s = 2, d = 3, f = 4} -- Map keys to notes/ingredients
local message = "Happy Valentine's Day, my love! You're my perfect veggie pizza! <3"
local show_message = false
local hearts = {} -- For heart animations
local sounds = {}
local background_music = nil

-- Colors for light/dark themes
local colors = {
  background = {0.1, 0.1, 0.3}, -- Dark blue
  text = {1, 1, 1}, -- White
  pizza = {0.8, 0.5, 0.2}, -- Dough color
  heart = {1, 0.4, 0.4} -- Pinkish-red
}

local ingredient_colors = {
  Cheese = {1, 1, 0.5}, -- yellow
  Spinach = {0.3, 0.8, 0.3}, -- green
  ["Bell Peppers"] = {1, 0.5, 0.1}, -- orange
  Olives = {0.2, 0.2, 0.2} -- black
}

local ingredient_positions = {
  {x = 400, y = 200},
  {x = 440, y = 180},
  {x = 370, y = 240},
  {x = 430, y = 230}
}

local floating_labels = {}
local pizza_complete = false
local heart_burst_timer = 0
local timer = 30
local score = 0
local game_state = "playing" -- can be "playing", "win", "lose"
local current_target = nil
local show_target = false
local combo = 0
local combo_timer = 0
local max_combo = 0

local function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
end

-- GUITAR HERO-LIKE GAMEPLAY: Piano notes (ingredients) fall from the top. Player must press the correct key as the note reaches the hit zone to add the ingredient to the pizza. Each ingredient can only be added once. Score and combo for accuracy. Game ends when all ingredients are added or time runs out.

local falling_notes = {} -- {ingredient_idx, x, y, hit, active}
local note_speed = 180 -- pixels per second
local hit_zone_y = 480
local note_spawn_timer = 0
local note_spawn_interval = 1.5
local notes_to_spawn = {}

function reset_game()
  added_ingredients = {}
  show_message = false
  pizza_complete = false
  heart_burst_timer = 0
  floating_labels = {}
  timer = 30
  score = 0
  game_state = "playing"
  combo = 0
  max_combo = 0
  falling_notes = {}
  note_spawn_timer = 0
  notes_to_spawn = {}
  -- Prepare notes to spawn (one for each ingredient, shuffled)
  for i = 1, #ingredients do table.insert(notes_to_spawn, i) end
  shuffle(notes_to_spawn)
end

function love.load()
  love.window.setTitle("Veggie Pizza Symphony for My Pianist")
  love.window.setMode(800, 600)

  -- Load background music
  background_music = love.audio.newSource("piano_pizza.wav", "stream")
  background_music:setLooping(true)
  background_music:setVolume(0.3) -- Increased volume for more audible background
  background_music:play()

  -- Load piano note sounds (optional, comment out if no sound files)
  for _, note in ipairs(piano_notes) do
    sounds[note] = love.audio.newSource("piano-" .. note .. ".wav", "static")
    sounds[note]:setVolume(1.0) -- Max volume for piano notes
  end

  -- Initialize hearts
  for i = 1, 10 do
    table.insert(hearts, {x = math.random(0, 800), y = math.random(0, 600), speed = 30 + math.random() * 40})
  end
  reset_game()
end

function spawn_next_note()
  if #notes_to_spawn > 0 then
    local idx = table.remove(notes_to_spawn, 1)
    local x = 225 + (idx-1)*80
    table.insert(falling_notes, {ingredient_idx=idx, x=x, y=-40, hit=false, active=true})
  end
end

function love.update(dt)
  -- Update heart animations
  for _, heart in ipairs(hearts) do
    heart.y = heart.y - heart.speed * dt
    if heart.y < -20 then
      heart.y = 600
      heart.x = math.random(0, 800)
    end
  end

  -- Update floating labels
  for i = #floating_labels, 1, -1 do
    local label = floating_labels[i]
    label.y = label.y - 30 * dt
    label.alpha = label.alpha - 0.7 * dt
    if label.alpha <= 0 then
      table.remove(floating_labels, i)
    end
  end

  -- Heart burst animation when pizza is complete
  if pizza_complete and heart_burst_timer > 0 then
    heart_burst_timer = heart_burst_timer - dt
    if heart_burst_timer <= 0 then
      heart_burst_timer = 0
    end
  end

  if game_state == "playing" then
    timer = timer - dt
    -- Defensive: ensure key_feedback is always a table
    if type(key_feedback) ~= "table" then
      key_feedback = {a = 0, s = 0, d = 0, f = 0}
    end
    for k, v in pairs(key_feedback) do
      if v > 0 then key_feedback[k] = v - dt end
    end
    -- Spawn notes at intervals
    note_spawn_timer = note_spawn_timer - dt
    if note_spawn_timer <= 0 and #notes_to_spawn > 0 then
      spawn_next_note()
      note_spawn_timer = note_spawn_interval
    end
    -- Move notes
    for _, note in ipairs(falling_notes) do
      if note.active then
        note.y = note.y + note_speed * dt
        -- Missed note
        if note.y > hit_zone_y + 40 and not note.hit then
          note.active = false
          combo = 0
          -- Respawn missed note at the top to give another chance
          table.insert(notes_to_spawn, note.ingredient_idx)
        end
      end
    end
    -- Win check
    if #added_ingredients == #ingredients and not pizza_complete then
      show_message = true
      pizza_complete = true
      heart_burst_timer = 1.5
      game_state = "win"
      score = math.max(0, math.floor(timer))
      for i = 1, 20 do
        table.insert(hearts, {
          x = 400 + math.random(-80, 80),
          y = 200 + math.random(-80, 80),
          speed = 80 + math.random() * 120,
          burst = true,
          angle = math.random() * 2 * math.pi
        })
      end
    end
    if timer <= 0 and game_state == "playing" then
      game_state = "lose"
      show_message = false
    end
    -- Combo timer
    if combo > 0 then
      combo_timer = combo_timer - dt
      if combo_timer <= 0 then
        combo = 0
      end
    end
  end
end

function love.keypressed(key)
  if key == "r" then
    reset_game()
    return
  end
  if game_state ~= "playing" then return end
  local note_index = key_map[key]
  if note_index then
    key_feedback[key] = 0.2
    -- Find the closest active note of this type in the hit zone
    local best_note = nil
    local best_dist = 9999
    for _, note in ipairs(falling_notes) do
      if note.active and not note.hit and note.ingredient_idx == note_index then
        local dist = math.abs(note.y - hit_zone_y)
        if dist < 40 and dist < best_dist then
          best_note = note
          best_dist = dist
        end
      end
    end
    if best_note then
      best_note.hit = true
      best_note.active = false
      -- Play sound if available
      if sounds[piano_notes[note_index]] then
        sounds[piano_notes[note_index]]:stop()
        sounds[piano_notes[note_index]]:play()
      end
      if not table_contains(added_ingredients, ingredients[note_index]) then
        table.insert(added_ingredients, ingredients[note_index])
        table.insert(floating_labels, {
          text = "+" .. ingredients[note_index],
          x = ingredient_positions[note_index].x,
          y = ingredient_positions[note_index].y,
          alpha = 1
        })
        combo = combo + 1
        combo_timer = 2
        if combo > max_combo then max_combo = combo end
        score = score + 10 + combo * 2
      end
    else
      combo = 0
      key_feedback[key] = 0.5
    end
  end
end

function love.mousepressed(x, y, button)
  if button ~= 1 or game_state ~= "playing" then return end
  -- Check for active falling notes in the hit zone under the mouse
  local hit_any = false
  for _, note in ipairs(falling_notes) do
    if note.active and not note.hit then
      local dist = math.sqrt((x - note.x)^2 + (y - note.y)^2)
      if dist <= 24 and math.abs(note.y - hit_zone_y) < 40 then
        -- Simulate keypress for this note
        note.hit = true
        note.active = false
        local note_index = note.ingredient_idx
        local key = get_key_for_ingredient(note_index)
        if key then key_feedback[key] = 0.2 end
        -- Play sound if available
        if sounds[piano_notes[note_index]] then
          sounds[piano_notes[note_index]]:stop()
          sounds[piano_notes[note_index]]:play()
        end
        if not table_contains(added_ingredients, ingredients[note_index]) then
          table.insert(added_ingredients, ingredients[note_index])
          table.insert(floating_labels, {
            text = "+" .. ingredients[note_index],
            x = ingredient_positions[note_index].x,
            y = ingredient_positions[note_index].y,
            alpha = 1
          })
          combo = combo + 1
          combo_timer = 2
          if combo > max_combo then max_combo = combo end
          score = score + 10 + combo * 2
        end
        hit_any = true
        break -- Only allow one note per click
      end
    end
  end
  if not hit_any then
    combo = 0
  end
end

-- Helper to get key for ingredient idx
function get_key_for_ingredient(idx)
  for k, v in pairs(key_map) do
    if v == idx then return k end
  end
end

-- Helper to check if a table contains a value
function table_contains(tbl, element)
  for _, value in ipairs(tbl) do
    if value == element then
      return true
    end
  end
  return false
end

function love.draw()
  -- Set background
  love.graphics.setBackgroundColor(colors.background)

  -- Draw piano keys with feedback
  local key_x = {a = 200, s = 260, d = 320, f = 380}
  for k, x in pairs(key_x) do
    if key_feedback[k] > 0 then
      love.graphics.setColor(1, 1, 0.3)
    else
      love.graphics.setColor(colors.text)
    end
    love.graphics.rectangle("line", x, 400, 50, 100)
    love.graphics.print(string.upper(k), x + 20, 450)
  end

  -- Draw pizza (circle with ingredients)
  love.graphics.setColor(colors.pizza)
  love.graphics.circle("fill", 400, 200, 100) -- Pizza base
  -- Draw toppings
  for i, ingredient in ipairs(added_ingredients) do
    local pos = ingredient_positions[i]
    love.graphics.setColor(ingredient_colors[ingredient] or {1,1,1})
    love.graphics.circle("fill", pos.x, pos.y, 18)
    love.graphics.setColor(colors.text)
    love.graphics.print(ingredient, pos.x - 30, pos.y + 20)
  end
  -- Draw floating labels
  for _, label in ipairs(floating_labels) do
    love.graphics.setColor(1, 1, 1, label.alpha)
    love.graphics.print(label.text, label.x, label.y)
  end
  -- Draw hearts
  for _, heart in ipairs(hearts) do
    if heart.burst and pizza_complete and heart_burst_timer > 0 then
      local burst_x = 400 + math.cos(heart.angle) * (1.5 - heart_burst_timer) * 120
      local burst_y = 200 + math.sin(heart.angle) * (1.5 - heart_burst_timer) * 120
      love.graphics.setColor(colors.heart)
      love.graphics.print("<3", burst_x, burst_y)
    elseif not heart.burst then
      love.graphics.setColor(colors.heart)
      love.graphics.print("<3", heart.x, heart.y)
    end
  end
  -- Draw timer and score
  love.graphics.setColor(colors.text)
  love.graphics.print("Time: " .. math.ceil(timer), 600, 50)
  love.graphics.print("Score: " .. score, 600, 80)
  -- Move <3! to a more visible location
  love.graphics.setColor(1, 0.4, 0.4)
  love.graphics.setFont(love.graphics.newFont(32))
  love.graphics.print("<3!", 600, 20)
  love.graphics.setFont(love.graphics.newFont(12))
  -- Draw key-ingredient mapping
  love.graphics.setColor(colors.text)
  love.graphics.print("Keys:", 600, 120)
  for idx, ingredient in ipairs(ingredients) do
    local key = string.upper(get_key_for_ingredient(idx))
    love.graphics.setColor(colors.text)
    love.graphics.print(key .. ": " .. ingredient, 600, 120 + idx * 20)
  end
  -- Draw current target ingredient
  if show_target and game_state == "playing" then
    love.graphics.setColor(1, 1, 0.3)
    local key = string.upper(get_key_for_ingredient(current_target))
    love.graphics.print("Next: Press '" .. key .. "' for " .. ingredients[current_target] .. "!", 200, 50)
    love.graphics.setColor(colors.text)
    love.graphics.print("Press R to restart", 200, 80)
  end
  -- Draw falling notes
  for _, note in ipairs(falling_notes) do
    if note.active then
      local ing = ingredients[note.ingredient_idx]
      love.graphics.setColor(ingredient_colors[ing] or {1,1,1})
      love.graphics.circle("fill", note.x, note.y, 24)
      -- Draw key label with high contrast (black for yellow, white otherwise)
      if ing == "Cheese" then
        love.graphics.setColor(0,0,0)
      else
        love.graphics.setColor(colors.text)
      end
      love.graphics.print(string.upper(get_key_for_ingredient(note.ingredient_idx)), note.x-10, note.y-10)
    end
  end
  -- Draw hit zone
  love.graphics.setColor(1,1,1,0.2)
  love.graphics.rectangle("fill", 200, hit_zone_y-24, 320, 48)
  love.graphics.setColor(colors.text)
  love.graphics.rectangle("line", 200, hit_zone_y-24, 320, 48)
  love.graphics.print("HIT ZONE", 340, hit_zone_y-40)
  -- Draw combo
  if combo > 1 then
    love.graphics.setColor(1, 1, 0.3)
    love.graphics.print("Combo: " .. combo .. "!", 200, 120)
    love.graphics.setColor(colors.text)
  end
  -- Draw max combo on win
  if game_state == "win" then
    love.graphics.setColor(0,1,0)
    love.graphics.print("Max Combo: " .. max_combo, 200, 40)
    love.graphics.setColor(colors.text)
    love.graphics.print("Pizza Complete! Score: " .. score, 200, 20)
    -- Draw the message in multiple lines for clarity, and highlight the <3
    local msg = "Happy Valentine's Day, my love!\nYou're my perfect veggie pizza! "
    love.graphics.print(msg, 200, 50)
    love.graphics.setColor(1, 0.4, 0.4)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.print("<3", 200, 90)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(colors.text)
    love.graphics.print("Press R to play again!", 200, 130)
  elseif game_state == "lose" then
    love.graphics.setColor(1,0,0)
    love.graphics.print("Time's up! Try again!", 200, 50)
    love.graphics.setColor(colors.text)
    love.graphics.print("Press R to restart", 200, 80)
  end
end
