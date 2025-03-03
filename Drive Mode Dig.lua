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


local function list()
    local line1 = 13
    local line2 = 26
    local line3 = 39
    local line4 = 52
    local x1 = 52
    local x2 = 88
    local x3 = 96
    local FM
    local FMname
    FM, FMname = getFlightMode()
  -- Line 1 --    
	lcd.drawText (x1,line1, "MODE: " .. FMname, 0) 
  -- Line 2 --
    lcd.drawText (x1,line2, "TH:" .. math.floor(getValue ("ch2") / 10.235), 0)
		--G2 is forward (-> side) throttle input weight, G3 is reverse (<- side) throttle input weight
		lcd.drawText (x2,line2, getValue ("gvar2") .. "/" .. getValue ("gvar3"), 0)  
  -- Line 3 --
   	lcd.drawText (x1,line3, "STR:" .. math.floor(getValue ("ch1") / 10.235) , 0)
    	lcd.drawText (x3,line3, "R:" .. math.floor(getValue ("ch3") / 10.235) , 0)
		--if getValue ("ls14") > 0 then
    	--lcd.drawText (x1, line3, "4WS", 0)
    	--end
  -- Line 4 --
    local ch4pos = getValue ("ch4")
    	if ch4pos < 0 then  
		lcd.drawText (x1,line4, "DIG: 4X4", 0)
    	elseif ch4pos == 0 then 
    	lcd.drawText (x1,line4, "DIG: OPEN", 0)
    	elseif ch4pos > 0 then 
    	lcd.drawText (x1,line4, "DIG: LOCKED", 0)
    	end

  --local rssi = getRSSI()
  --if rssi == 0 then
  --lcd.drawText( x1, line4, "RSSI: NONE", 0)
  --elseif rssi < 50 then
  --lcd.drawText( x1, line4, "RSSI: " .. rssi, 0 + BLINK)
  --else
  --lcd.drawText( x1, line4, "RSSI: " .. rssi, 0)
  --end

end
 

local function getMinutesSecondsAsString(seconds)
    -- Returns MM:SS as a string
    local minutes = math.floor(seconds/60) -- seconds/60 gives minutes
    seconds = seconds % 60 -- seconds % 60 gives seconds
    return  (string.format("%02d:%02d", minutes, seconds))
end
  
local function timer()
	local cells = 2
	if getValue('RxBt') > 8.8 then
	cells = 3
	elseif getValue('RxBt') > 13.2 then
	cells = 4
	end	
	local volt = getValue('RxBt') / cells * 100
	local x1box = 18
	local y1box = 10
	local y2box = 23
	local y3box = 36
	local y4box = 49
	
	lcd.drawFilledRectangle(x1box, y1box, 30, 13, GREY_DEFAULT)
		lcd.drawNumber (x1box + 4, y1box + 3, volt, INVERS+PREC2)
		lcd.drawText (lcd.getLastPos(), y1box + 3, "v", INVERS)
	lcd.drawRectangle(x1box, y2box, 30, 13, GREY_DEFAULT)
		lcd.drawText (x1box + 4, y2box + 3, getMinutesSecondsAsString(getValue('timer1')), 0)
	lcd.drawRectangle(x1box, y3box, 30, 13, GREY_DEFAULT)
		lcd.drawText (x1box + 4, y3box + 3, getMinutesSecondsAsString(getValue('timer2')), 0)
	lcd.drawRectangle(x1box, y4box, 30, 13, GREY_DEFAULT)
		lcd.drawText (x1box + 4, y4box + 3, getMinutesSecondsAsString(getValue('timer3')), 0)
	
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
  local cells = 2
    if getValue('RxBt') > 8.8 then
	  cells = 3
    elseif getValue('RxBt') > 13.2 then
	  cells = 4
    else
    end	
	
  local totalvoltage = getValue('RxBt')
  local voltage = totalvoltage / cells

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
  drawVoltageImage(1, 10)
  list()
  timer()
  
end


local function init_func()
  local modeldata = model.getInfo()
  if modeldata then
    modelName = modeldata['name']
  end
end


return { run=run, init=init_func  }
