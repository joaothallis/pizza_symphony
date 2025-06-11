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

function love.load()
  love.window.setTitle("Veggie Pizza Symphony for My Pianist")
  love.window.setMode(800, 600)

  -- Load background music
  background_music = love.audio.newSource("piano_pizza.wav", "stream")
  background_music:setLooping(true)
  background_music:setVolume(0.05) -- Further reduced volume for very subtle background
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

  -- Show message when pizza is complete
  if #added_ingredients == #ingredients and not pizza_complete then
    show_message = true
    pizza_complete = true
    heart_burst_timer = 1.5 -- 1.5 seconds burst
    -- Burst hearts
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
end

function love.keypressed(key)
  if key == "r" then
    -- Reset game
    added_ingredients = {}
    show_message = false
    pizza_complete = false
    heart_burst_timer = 0
    floating_labels = {}
    return
  end
  local note_index = key_map[key]
  if note_index and not show_message then
    -- Play sound if available
    if sounds[piano_notes[note_index]] then
      sounds[piano_notes[note_index]]:play()
    end
    -- Add ingredient if not already added
    if not table.contains(added_ingredients, ingredients[note_index]) then
      table.insert(added_ingredients, ingredients[note_index])
      -- Add floating label
      table.insert(floating_labels, {
        text = "+" .. ingredients[note_index],
        x = ingredient_positions[note_index].x,
        y = ingredient_positions[note_index].y,
        alpha = 1
      })
    end
  end
end

function table.contains(table, element)
  for _, value in ipairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function love.draw()
  -- Set background
  love.graphics.setBackgroundColor(colors.background)

  -- Draw piano keys
  love.graphics.setColor(colors.text)
  love.graphics.rectangle("line", 200, 400, 50, 100) -- A key
  love.graphics.rectangle("line", 260, 400, 50, 100) -- S key
  love.graphics.rectangle("line", 320, 400, 50, 100) -- D key
  love.graphics.rectangle("line", 380, 400, 50, 100) -- F key
  love.graphics.print("A", 220, 450)
  love.graphics.print("S", 280, 450)
  love.graphics.print("D", 340, 450)
  love.graphics.print("F", 400, 450)

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
  -- Draw instructions or final message
  love.graphics.setColor(colors.text)
  if not show_message then
    love.graphics.print("Play the piano (A, S, D, F) to make a veggie pizza!", 200, 50)
    love.graphics.print("Press R to restart", 200, 80)
  else
    love.graphics.print(message, 200, 50)
    love.graphics.print("Press R to make another pizza!", 200, 80)
  end
end
