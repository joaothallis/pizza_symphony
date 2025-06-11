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

  -- Check if pizza is complete
  if #added_ingredients == #ingredients then
    show_message = true
  end
end

function love.keypressed(key)
  local note_index = key_map[key]
  if note_index and not show_message then
    -- Play sound if available
    if sounds[piano_notes[note_index]] then
      sounds[piano_notes[note_index]]:play()
    end

    -- Add ingredient if not already added
    if not table.contains(added_ingredients, ingredients[note_index]) then
      table.insert(added_ingredients, ingredients[note_index])
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
  love.graphics.setColor(colors.text)
  for i, ingredient in ipairs(added_ingredients) do
    love.graphics.print(ingredient, 350, 150 + i * 20)
  end

  -- Draw hearts
  love.graphics.setColor(colors.heart)
  for _, heart in ipairs(hearts) do
    love.graphics.print("<3", heart.x, heart.y)
  end

  -- Draw instructions or final message
  love.graphics.setColor(colors.text)
  if not show_message then
    love.graphics.print("Play the piano (A, S, D, F) to make a veggie pizza!", 200, 50)
  else
    love.graphics.print(message, 200, 50)
  end
end
