----------------------------------------------------------
-- Written by Farley Farley
-- farley <at> neonsurge __dot__ com
-- From: https://github.com/AndrewFarley/Taranis-XLite-Q7-Lua-Dashboard
-- Please feel free to submit issues, feedback, etc.
-- Crawler diagram by mshagg


------- GLOBALS -------
-- The model name when it can't detect a model name from the handset
local modelName = "Unknown"
local lowVoltage = 6.6
local currentVoltage = 8.4
local highVoltage = 8.4
-- For our timer tracking
local timerLeft = 0
local maxTimerValue = 0
-- Animation increment
-- Our global to get our current rssi
local rssi = 0
-- Define the screen size
local screen_width = 128
local screen_height = 64
-- Define the size and position of the "Vehicle" shape
local vehicle_width = 16
local vehicle_height = 30
local vehicle_driveshaft_width = 2 -- Adjusted thickness of the driveshaft
local vehicle_x = (screen_width - vehicle_width) / 2 - 5 -- Move left by 5 pixels
local vehicle_y = (screen_height +15 - vehicle_height) / 2
-- Define the width of the axles
local axle_width = 4 -- Adjusted width of the axles
-- Define the size of the wheels
local wheel_width = 6
local wheel_height = 10

------- HELPERS -------
-- Helper converts voltage to percentage of voltage for a sexy battery percent
local function convertVoltageToPercentage(voltage)
  local curVolPercent = math.ceil(((((highVoltage - voltage) / (highVoltage - lowVoltage)) - 1) * -1) * 100)
  if curVolPercent < 0 then
    curVolPercent = 0
  end
  if curVolPercent > 100 then
    curVolPercent = 100
  end
  return curVolPercent
end

-- Sexy voltage helper
local function drawTransmitterVoltage(start_x,start_y,voltage)
  
  local batteryWidth = 17
  
  -- Battery Outline
  lcd.drawRectangle(start_x, start_y, batteryWidth + 2, 6, SOLID)
  lcd.drawLine(start_x + batteryWidth + 2, start_y + 1, start_x + batteryWidth + 2, start_y + 4, SOLID, FORCE) -- Positive Nub

  -- Battery Percentage (after battery)
  local curVolPercent = convertVoltageToPercentage(voltage)
  if curVolPercent < 20 then
    lcd.drawText(start_x + batteryWidth + 5, start_y, curVolPercent.."%", SMLSIZE + BLINK)
  else
    if curVolPercent == 100 then
      lcd.drawText(start_x + batteryWidth + 5, start_y, "99%", SMLSIZE)
    else
      lcd.drawText(start_x + batteryWidth + 5, start_y, curVolPercent.."%", SMLSIZE)
    end
      
  end
  
  -- Filled in battery
  local pixels = math.ceil((curVolPercent / 100) * batteryWidth)
  if pixels == 1 then
    lcd.drawLine(start_x + pixels, start_y + 1, start_x + pixels, start_y + 4, SOLID, FORCE)
  end
  if pixels > 1 then
    lcd.drawRectangle(start_x + 1, start_y + 1, pixels, 4)
  end
  if pixels > 2 then
    lcd.drawRectangle(start_x + 2, start_y + 2, pixels - 1, 2)
    lcd.drawLine(start_x + pixels, start_y + 2, start_x + pixels, start_y + 3, SOLID, FORCE)
  end
end

local function drawFlightTimer(start_x, start_y)
  local timerWidth = 44
  local timerHeight = 20
  local myWidth = 0
  local percentageLeft = 0
  
  lcd.drawRectangle( start_x, start_y, timerWidth, 10 )
  lcd.drawText( start_x + 2, start_y + 2, "Timer", SMLSIZE )
  lcd.drawRectangle( start_x, start_y + 10, timerWidth, timerHeight )

  if timerLeft < 0 then
    lcd.drawRectangle( start_x + 2, start_y + 20, 3, 2 )
    lcd.drawText( start_x + 2 + 3, start_y + 12, (timerLeft * -1).."s", DBLSIZE + BLINK )
  else
    lcd.drawTimer( start_x + 2, start_y + 12, timerLeft, DBLSIZE )
  end 
  
  percentageLeft = (timerLeft / maxTimerValue)
  local offset = 0
  while offset < (timerWidth - 2) do
    if (percentageLeft * (timerWidth - 2)) > offset then
      -- print("Percent left: "..percentageLeft.." width: "..myWidth.." offset: "..offset.." timerHeight: "..timerHeight)
      lcd.drawLine( start_x + 1 + offset, start_y + 11, start_x + 1 + offset, start_y + 9 + timerHeight - 1, SOLID, 0)
    end
    offset = offset + 1
  end
  
end

local function drawTime()
  -- Draw date time
  local datenow = getDateTime()
  local min = datenow.min .. ""
  if datenow.min < 10 then
    min = "0" .. min
  end
  local hour = datenow.hour .. ""
  if datenow.hour < 10 then
    hour = "0" .. hour
  end
  if math.ceil(math.fmod(getTime() / 100, 2)) == 1 then
    hour = hour .. ":"
  end
  lcd.drawText(107,0,hour, SMLSIZE)
  lcd.drawText(119,0,min, SMLSIZE)
end

local function drawRSSI(start_x, start_y)
  local timerWidth = 44
  local timerHeight = 15
  local myWidth = 0
  local percentageLeft = 0
  
  lcd.drawRectangle( start_x, start_y, timerWidth, 10 )
  lcd.drawText( start_x + 2, start_y + 2, "RSSI:", SMLSIZE)
  if rssi < 50 then
    lcd.drawText( start_x + 23, start_y + 2, rssi, SMLSIZE + BLINK)
  else
    lcd.drawText( start_x + 23, start_y + 2, rssi, SMLSIZE)
  end
  lcd.drawRectangle( start_x, start_y + 10, timerWidth, timerHeight )
  
  
  if rssi > 0 then
    lcd.drawLine(start_x + 1,  start_y + 20, start_x + 1,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 2,  start_y + 20, start_x + 2,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 3,  start_y + 20, start_x + 3,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 4,  start_y + 20, start_x + 4,  start_y + 23, SOLID, FORCE)
  end
  if rssi > 10 then
    lcd.drawLine(start_x + 5,  start_y + 19, start_x + 5,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 6,  start_y + 19, start_x + 6,  start_y + 23, SOLID, FORCE)
  end
  if rssi > 13 then
    lcd.drawLine(start_x + 7,  start_y + 19, start_x + 7,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 8,  start_y + 19, start_x + 8,  start_y + 23, SOLID, FORCE)
  end
  if rssi > 16 then
    lcd.drawLine(start_x + 9,  start_y + 18, start_x + 9,  start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 10, start_y + 18, start_x + 10, start_y + 23, SOLID, FORCE)
  end
  if rssi > 19 then
    lcd.drawLine(start_x + 11, start_y + 18, start_x + 11, start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 12, start_y + 18, start_x + 12, start_y + 23, SOLID, FORCE)
  end
  if rssi > 22 then
    lcd.drawLine(start_x + 13, start_y + 17, start_x + 13, start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 14, start_y + 17, start_x + 14, start_y + 23, SOLID, FORCE)
  end
  if rssi > 25 then
    lcd.drawLine(start_x + 15, start_y + 17, start_x + 15, start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 16, start_y + 17, start_x + 16, start_y + 23, SOLID, FORCE)
  end
  if rssi > 28 then
    lcd.drawLine(start_x + 17, start_y + 16, start_x + 17, start_y + 23, SOLID, FORCE)
    lcd.drawLine(start_x + 18, start_y + 16, start_x + 18, start_y + 23, SOLID, FORCE)
  end
  if rssi > 31 then
    lcd.drawLine(start_x + 19, start_y + 16, start_x + 19, start_y + 23, SOLID, FORCE)
  end
  if rssi > 34 then
    lcd.drawLine(start_x + 20, start_y + 16, start_x + 20, start_y + 23, SOLID, FORCE)
  end
  if rssi > 37 then
    lcd.drawLine(start_x + 21, start_y + 15, start_x + 21, start_y + 23, SOLID, FORCE)
  end
  if rssi > 40 then
    lcd.drawLine(start_x + 22, start_y + 15, start_x + 22, start_y + 23, SOLID, FORCE)
  end
  if rssi > 43 then
    lcd.drawLine(start_x + 23, start_y + 15, start_x + 23, start_y + 23, SOLID, FORCE)
  end
  if rssi > 46 then
    lcd.drawLine(start_x + 24, start_y + 15, start_x + 24, start_y + 23, SOLID, FORCE)
  end
  if rssi > 49 then
    lcd.drawLine(start_x + 25, start_y + 14, start_x + 25, start_y + 23, SOLID, FORCE)
  end
  if rssi > 52 then
    lcd.drawLine(start_x + 26, start_y + 14, start_x + 26, start_y + 23, SOLID, FORCE)
  end
  if rssi > 55 then
    lcd.drawLine(start_x + 27, start_y + 14, start_x + 27, start_y + 23, SOLID, FORCE)
  end
  if rssi > 58 then
    lcd.drawLine(start_x + 28, start_y + 14, start_x + 28, start_y + 23, SOLID, FORCE)
  end
  if rssi > 61 then
    lcd.drawLine(start_x + 29, start_y + 13, start_x + 29, start_y + 23, SOLID, FORCE)
  end
  if rssi > 64 then
    lcd.drawLine(start_x + 30, start_y + 13, start_x + 30, start_y + 23, SOLID, FORCE)
  end
  if rssi > 67 then
    lcd.drawLine(start_x + 31, start_y + 13, start_x + 31, start_y + 23, SOLID, FORCE)
  end
  if rssi > 70 then
    lcd.drawLine(start_x + 32, start_y + 13, start_x + 32, start_y + 23, SOLID, FORCE)
  end
  if rssi > 73 then
    lcd.drawLine(start_x + 33, start_y + 12, start_x + 33, start_y + 23, SOLID, FORCE)
  end
  if rssi > 76 then
    lcd.drawLine(start_x + 34, start_y + 12, start_x + 34, start_y + 23, SOLID, FORCE)
  end
  if rssi > 79 then
    lcd.drawLine(start_x + 35, start_y + 12, start_x + 35, start_y + 23, SOLID, FORCE)
  end
  if rssi > 82 then
    lcd.drawLine(start_x + 36, start_y + 12, start_x + 36, start_y + 23, SOLID, FORCE)
  end
  if rssi > 85 then
    lcd.drawLine(start_x + 37, start_y + 11, start_x + 37, start_y + 23, SOLID, FORCE)
  end
  if rssi > 88 then
    lcd.drawLine(start_x + 38, start_y + 11, start_x + 38, start_y + 23, SOLID, FORCE)
  end
  if rssi > 91 then
    lcd.drawLine(start_x + 39, start_y + 11, start_x + 39, start_y + 23, SOLID, FORCE)
  end
  if rssi > 94 then
    lcd.drawLine(start_x + 40, start_y + 11, start_x + 40, start_y + 23, SOLID, FORCE)
  end
  if rssi > 97 then
    lcd.drawLine(start_x + 41, start_y + 11, start_x + 41, start_y + 23, SOLID, FORCE)
  end
  if rssi > 98 then
    lcd.drawLine(start_x + 42, start_y + 11, start_x + 42, start_y + 23, SOLID, FORCE)
  end
  
  if rssi > 0 then
    lcd.drawLine(101, 5, 101, 5, SOLID, FORCE)
    lcd.drawLine(100, 2, 102, 2, SOLID, FORCE)
    lcd.drawLine(99, 3, 99, 3, SOLID, FORCE)
    lcd.drawLine(103, 3, 103, 3, SOLID, FORCE)
    lcd.drawLine(99, 0, 103, 0, SOLID, FORCE)
    lcd.drawLine(98, 1, 98, 1, SOLID, FORCE)
    lcd.drawLine(104, 1, 104, 1, SOLID, FORCE)
  end
  
end

local function drawVoltageImage(start_x, start_y)
  
  -- Define the battery width (so we can adjust it later)
  local batteryWidth = 12 

  -- Draw our battery outline
  lcd.drawLine(start_x + 2, start_y + 1, start_x + batteryWidth - 2, start_y + 1, SOLID, 0)
  lcd.drawLine(start_x, start_y + 2, start_x + batteryWidth - 1, start_y + 2, SOLID, 0)
  lcd.drawLine(start_x, start_y + 2, start_x, start_y + 50, SOLID, 0)
  lcd.drawLine(start_x, start_y + 50, start_x + batteryWidth - 1, start_y + 50, SOLID, 0)
  lcd.drawLine(start_x + batteryWidth, start_y + 3, start_x + batteryWidth, start_y + 49, SOLID, 0)

  -- top one eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 8, start_x + batteryWidth - 1, start_y + 8, SOLID, 0)
  -- top quarter line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 2), start_y + 14, start_x + batteryWidth - 1, start_y + 14, SOLID, 0)
  -- third eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 20, start_x + batteryWidth - 1, start_y + 20, SOLID, 0)
  -- Middle line
  lcd.drawLine(start_x + 1, start_y + 26, start_x + batteryWidth - 1, start_y + 26, SOLID, 0)
  -- five eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 32, start_x + batteryWidth - 1, start_y + 32, SOLID, 0)
  -- bottom quarter line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 2), start_y + 38, start_x + batteryWidth - 1, start_y + 38, SOLID, 0)
  -- seven eighth line
  lcd.drawLine(start_x + batteryWidth - math.ceil(batteryWidth / 4), start_y + 44, start_x + batteryWidth - 1, start_y + 44, SOLID, 0)
  
  -- Voltage top
  lcd.drawText(start_x + batteryWidth + 4, start_y + 0, "4.35v", SMLSIZE)
  -- Voltage middle
  lcd.drawText(start_x + batteryWidth + 4, start_y + 24, "3.82v", SMLSIZE)
  -- Voltage bottom
  lcd.drawText(start_x + batteryWidth + 4, start_y + 47, "3.3v", SMLSIZE)
  
  -- Now draw how full our voltage is...
  local voltage = getValue('Cell')
  voltageLow = 3.3
  voltageHigh = 4.35
  voltageIncrement = ((voltageHigh - voltageLow) / 47)
  
  local offset = 0  -- Start from the bottom up
  while offset < 47 do
    if ((offset * voltageIncrement) + voltageLow) < tonumber(voltage) then
      lcd.drawLine( start_x + 1, start_y + 49 - offset, start_x + batteryWidth - 1, start_y + 49 - offset, SOLID, 0)
    end
    offset = offset + 1
  end
end

local function gatherInput(event)
  
  -- Get our RSSI
  rssi = getRSSI()

  -- Read timer 1
  timerLeft = getValue('timer1')
  -- And set our max timer if it's bigger than our current max timer
  if timerLeft > maxTimerValue then
    maxTimerValue = timerLeft
  end

  -- Get our current transmitter voltage
  currentVoltage = getValue('tx-voltage')

end

-- Function to draw the graphical representation of the transmission 
local function draw_vehicle()
    lcd.drawFilledRectangle(vehicle_x + (vehicle_width - vehicle_driveshaft_width) / 2, vehicle_y + 2, vehicle_driveshaft_width, vehicle_height - 6)
    local transmission_size = 6
    local transmission_x = vehicle_x + (vehicle_width - transmission_size) / 2
    local transmission_y = vehicle_y + (vehicle_height - transmission_size) / 2
    lcd.drawRectangle(transmission_x, transmission_y, transmission_size, transmission_size)

    -- Draw the axles
    lcd.drawFilledRectangle(vehicle_x - 2, vehicle_y - 2, vehicle_width + 4, axle_width)
    lcd.drawFilledRectangle(vehicle_x - 2, vehicle_y + vehicle_height - axle_width, vehicle_width + 4, axle_width)

    -- Draw the front wheels 
    lcd.drawRectangle(vehicle_x - 2 - wheel_width, vehicle_y - 5, wheel_width, wheel_height)
    lcd.drawRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y - 5, wheel_width, wheel_height)

    -- Draw the rear wheels 
    lcd.drawRectangle(vehicle_x - 2 - wheel_width, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
    lcd.drawRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
end

-- Draw L when in low speed
local function indicate_low_speed()
    local letter_l_size = 14 -- Adjusted font size
    local letter_l_x = vehicle_x + (vehicle_width - vehicle_driveshaft_width + 7) / 2 - letter_l_size -- Move to the left of the upright part
    local letter_l_y = vehicle_y + (vehicle_height - letter_l_size + 6) / 2
    lcd.drawText(letter_l_x, letter_l_y, "L", SMLSIZE) -- Adjusted font size
end

-- Draw H when in high speed 
local function indicate_high_speed()
    local letter_h_size = 14 -- Adjusted font size
    local letter_h_x = vehicle_x + (vehicle_width + vehicle_driveshaft_width + 14) / 2 -- Move to the right of the upright part
    local letter_h_y = vehicle_y + (vehicle_height - letter_h_size + 6) / 2
    lcd.drawText(letter_h_x, letter_h_y, "H", SMLSIZE) -- Adjusted font size
end

-- Fill wheels when diffs locked CHANGE CHANNEL NUMBERS IN LINES 373 AND 387 AND CHANNEL VALUES IN 374 AND 379 TO SUIT YOUR MODEL 
local function draw_locked_diffs()

    local channel_5_value = getValue("ch5") 
    if channel_5_value > 0 then
        lcd.drawFilledRectangle(vehicle_x - 2 - wheel_width, vehicle_y - 5, wheel_width, wheel_height)
        lcd.drawFilledRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y - 5, wheel_width, wheel_height)
	end
	local channel_6_value = getValue("ch6")
    if channel_6_value > 0 then
		lcd.drawFilledRectangle(vehicle_x - 2 - wheel_width, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
		lcd.drawFilledRectangle(vehicle_x - 2 + vehicle_width + 4, vehicle_y + vehicle_height - wheel_height + 3, wheel_width, wheel_height)
    end
end

local function run(event)
  
  lcd.clear()
  gatherInput(event)
  
  -- Draw a horizontal line seperating the header
  lcd.drawLine(0, 7, 128, 7, SOLID, FORCE)

  -- Draw our model name centered at the top of the screen
  lcd.drawText( 64 - math.ceil((#modelName * 5) / 2),0, modelName, SMLSIZE)

  -- Draw our sexy voltage
  drawTransmitterVoltage(0,0, currentVoltage)
  
  -- Draw the "Vehicle" shape with adjusted proportions, axles, Wheels, a Transmission, and a Vehicle Driveshaft
  draw_vehicle()

  -- Display L for low speed.  Change channel number line 403 and value line 404 to suit your model
    local channel_3_value = getValue("ch3")
    if channel_3_value < -512 then
    indicate_low_speed()
    end

  --Display H for high speed.  Change channel number line 403 and value line 409 to suit your model
    if channel_3_value > 512 then
        -- Draw the same size letter "H" to the right of the upright part
        indicate_high_speed()
    end

  --Fill in the wheels if diffs are locked
 draw_locked_diffs()

  -- Draw our flight timer
  drawFlightTimer(84, 34)
  
  -- Draw RSSI
  drawRSSI(84, 8)
  
  -- Draw Time in Top Right
  drawTime()
  
  -- Draw voltage battery graphic
  drawVoltageImage(3, 10)
  
  return 0
end


local function init_func()
  -- Called once when model is loaded, only need to get model name once...
  local modeldata = model.getInfo()
  if modeldata then
    modelName = modeldata['name']
  end
end


return { run=run, init=init_func  }