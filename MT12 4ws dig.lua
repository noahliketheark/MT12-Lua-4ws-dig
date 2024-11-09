------- GLOBALS -------
-- The model name when it can't detect a model name from the handset
local modelName = "Unknown"
local lowVoltage = 6.6
local currentVoltage = 8.4
local highVoltage = 8.4
-- For our timer tracking
local timerLeft = 0
local maxTimerValue = 0
-- Our global to get our current rssi
local rssi = 0
-- Define the screen size
local screen_width = 128
local screen_height = 64


local function str()

	local logic14 = getValue ("ls14")
	if logic14 < 0 then 
	lcd.drawText (55,13, "STR: MANUAL", 0)
	end
	if logic14 > 0 then 
	lcd.drawText (55,13, "STR: 4WS", 0)
	end


	local ch4pos = getValue ("ch4")
	if ch4pos < 0 then 
	lcd.drawText (55,26, "DIG: 4X4", 0)
	end
	if ch4pos == 0 then 
	lcd.drawText (55,26, "DIG: OPEN ->", 0)
	end
	if ch4pos > 0 then 
	lcd.drawText (55,26, "DIG: LOCKED <-", 0)
	end


	local odpos = getValue ("sa")
	if odpos == 0 then 
	lcd.drawText (55,39, "OD:  LOW", 0)
	end
	if odpos < 0 then 
	lcd.drawText (55,39, "OD:  HIGH", 0)
	end
	if odpos > 0 then 
	lcd.drawText (55,39, "OD:  TURBO", 0)
	end

	lcd.drawText (55,52, "+" .. getValue ("gvar2") .. "/-" .. getValue ("gvar3") .. "  thr:" .. getValue ("gvar4"), SMLSIZE)

end


local function getMinutesSecondsAsString(seconds)
  -- Returns MM:SS as a string
  local minutes = math.floor(seconds/60) -- seconds/60 gives minutes
  seconds = seconds % 60 -- seconds % 60 gives seconds
  return  (string.format("%02d:%02d", minutes, seconds))
end

  
local function timer()
lcd.drawFilledRectangle(20, 10, 30, 13, GREY_DEFAULT)
lcd.drawRectangle(20, 23, 30, 13, GREY_DEFAULT)
lcd.drawRectangle(20, 36, 30, 13, GREY_DEFAULT)
lcd.drawRectangle(20, 49, 30, 13, GREY_DEFAULT)

  local totalvoltage = getValue('RxBt')
  local voltage = totalvoltage/3 * 100
  lcd.drawNumber (24, 13, voltage, INVERS+PREC2)
  lcd.drawText (41, 13, "v", INVERS)
  
  lcd.drawText (24,26, getMinutesSecondsAsString(getValue('timer1')), 0)
  lcd.drawText (24,39, getMinutesSecondsAsString(getValue('timer2')), 0)
  lcd.drawText (24,52, getMinutesSecondsAsString(getValue('timer3')), 0)
  end
  
  
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
  

  -- Now draw how full our voltage is...
  local totalvoltage = getValue('RxBt')
  local voltage = totalvoltage/3
  voltageLow = 3.3
  voltageHigh = 4.2
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
  rssi = getRSSI()
  timerLeft = getValue('timer1')
    if timerLeft > maxTimerValue then
    maxTimerValue = timerLeft
  end
  currentVoltage = getValue('tx-voltage')

end


local function run(event)
  
  lcd.clear()
  gatherInput(event)
  
  lcd.drawLine(0, 7, 128, 7, SOLID, FORCE)
  lcd.drawText( 64 - math.ceil((#modelName * 5) / 2),0, modelName, SMLSIZE)
  drawTransmitterVoltage(0,0, currentVoltage)
  drawTime()
  drawVoltageImage(3, 10)
  str()
  timer()
  
end


local function init_func()
  local modeldata = model.getInfo()
  if modeldata then
    modelName = modeldata['name']
  end
end


return { run=run, init=init_func  }
