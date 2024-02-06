local modelName = "Unknown"
local lowVoltage = 6.6
local currentVoltage = 8.4
local highVoltage = 8.4
local gpsLAT = 0
local gpsLON = 0
local gpsLAT_H = 0
local gpsLON_H = 0
local gpsPrevLAT = 0
local gpsPrevLON = 0
local gpsSATS = 0
local gpsALT = 0
local gpsSpeed = 0
local gpssatId = 0
local gpsspeedId = 0
local gpsaltId = 0
local gpsFIX = 0
local gpsDtH = 0
local gpsTotalDist = 0
local log_write_wait_time = 10
local old_time_write = 0
local update = true
local reset = false
local string_gmatch = string.gmatch
local now = 0
local ctr = 0

local old_time_write2 = 0
local wait = 100

local function rnd(v,d)
	if d then
		return math.floor((v*10^d)+0.5)/(10^d)
	else
		return math.floor(v+0.5)
	end
end

local function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));    
	return hours..":"..mins..":"..secs
  end
end

local function getTelemetryId(name)    
	field = getFieldInfo(name)
	if field then
		return field.id
	else
		return-1
	end
end

local function calc_Distance(LatPos, LonPos, LatHome, LonHome)
	local d2r = math.pi/180
	local d_lon = (LonPos - LonHome) * d2r 
	local d_lat = (LatPos - LatHome) * d2r 
	local a = math.pow(math.sin(d_lat/2.0), 2) + math.cos(LatHome*d2r) * math.cos(LatPos*d2r) * math.pow(math.sin(d_lon/2.0), 2)
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
	local dist = (6371000 * c) / 1000	
	return rnd(dist,2)
end

local function init()  				
	gpsId = getTelemetryId("GPS")
	--number of satellites crossfire
	gpssatId = getTelemetryId("Sats")

	--get IDs GPS Speed and GPS altitude
	gpsspeedId = getTelemetryId("GSpd") --GPS ground speed m/s
	gpsaltId = getTelemetryId("Alt") --GPS altitude m

end

local function background()	

	--####################################################################
	--get Latitude, Longitude, Speed and Altitude
	--####################################################################	
	gpsLatLon = getValue("GPS")
		
	if (type(gpsLatLon) == "table") then 			
		gpsLAT = rnd(gpsLatLon["lat"],6)
		gpsLON = rnd(gpsLatLon["lon"],6)		
		gpsSpeed = rnd(getValue(gpsspeedId) * 1.852,1)
		gpsALT = rnd(getValue(gpsaltId),0)		
				
		--set home postion only if more than 5 sats available
		if (tonumber(gpsSATS) > 5) and (reset == true) then
			--gpsLAT_H = rnd(gpsLatLon["pilot-lat"],6)
			--gpsLON_H = rnd(gpsLatLon["pilot-lon"],6)	
			gpsLAT_H = rnd(gpsLatLon["lat"],6)
			gpsLON_H = rnd(gpsLatLon["lon"],6)	
			reset = false
		end		

		update = true	
	else
		update = false
	end
	
	gpsSATS = getValue(gpssatId)
	

	gpsSATS = string.sub (gpsSATS, 0,3)		
		

	if (tonumber(gpsSATS) >= 5) then
	
		if (gpsLAT ~= gpsPrevLAT) and (gpsLON ~=  gpsPrevLON) then				
			
			if (gpsLAT_H ~= 0) and  (gpsLON_H ~= 0) then 
			
				--distance to home
				gpsDtH = rnd(calc_Distance(gpsLAT, gpsLON, gpsLAT_H, gpsLON_H),2)			
				gpsDtH = string.format("%.2f",gpsDtH)		
				
				--total distance traveled					
				if (gpsPrevLAT ~= 0) and  (gpsPrevLON ~= 0) and (gpsLAT ~= 0) and  (gpsLON ~= 0)then	
					print("GPS_Debug_Prev", gpsPrevLAT,gpsPrevLON)	
					print("GPS_Debug_curr", gpsLAT,gpsLON)	
					
					gpsTotalDist =  rnd(tonumber(gpsTotalDist) + calc_Distance(gpsLAT,gpsLON,gpsPrevLAT,gpsPrevLON),2)			
					gpsTotalDist = string.format("%.2f",gpsTotalDist)					
				end
			end
										
			gpsPrevLAT = gpsLAT
			gpsPrevLON = gpsLON	
			
		end 
	end
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

local function drawname()
  local modeldata = model.getInfo()
  if modeldata then
    modelName = modeldata['name']
	lcd.drawText( 64 - math.ceil((#modelName * 5) / 2),0, modelName, SMLSIZE)
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
  

  -- Now draw how full our voltage is...
  local totalvoltage = getValue('RxBt')
  local voltage = totalvoltage/6
  local voltagetext = string.format("%.2f", voltage)
  voltageLow = 3.3
  voltageHigh = 4.2
  voltageIncrement = ((voltageHigh - voltageLow) / 47)
  lcd.drawText (30,50, voltagetext, MIDSIZE)
  lcd.drawText (55,50, "v/cell", SMLSIZE)
  
  local offset = 0  -- Start from the bottom up
  while offset < 47 do
    if ((offset * voltageIncrement) + voltageLow) < tonumber(voltage) then
      lcd.drawLine( start_x + 1, start_y + 49 - offset, start_x + batteryWidth - 1, start_y + 49 - offset, SOLID, 0)
    end
    offset = offset + 1
  end
end

local function drawspds()

local speed = getValue ("GSpd")
local maxspeed = getValue ("GSpd+")
local speed2 = string.format("%.1f", speed)
local maxspeed2 = string.format("%.1f", maxspeed)
lcd.drawText (35,12, speed2, MIDSIZE)
lcd.drawText (55,12, "km/hr", SMLSIZE)
lcd.drawText (35,30, maxspeed2, MIDSIZE)
lcd.drawText (55,30, "km/hr", SMLSIZE)
lcd.drawText (55,38, "(Max)", SMLSIZE)
end


local function run(event)  
	lcd.clear()  
	background() 
	
		if event == EVT_ENTER_LONG then
		gpsDtH = 0
		gpsTotalDist = 0
		gpsLAT_H = 0
		gpsLON_H = 0
		reset = true
		end
		
	currentVoltage = getValue('tx-voltage')
	drawTime()
	drawTransmitterVoltage(0,0, currentVoltage)
	drawname()
	drawVoltageImage(3, 10)
	drawspds()
	lcd.drawLine(0, 7, 128, 7, SOLID, FORCE)
	lcd.drawLine(0,64,128,64, SOLID, FORCE)

			
	lcd.drawPixmap(86,9, "/IMAGES/gps.bmp")		
	lcd.drawPixmap(86,28, "/IMAGES/tx.bmp")		
	lcd.drawPixmap(86,47, "/IMAGES/odo.bmp")
	lcd.drawLine(84,8, 84, 64, SOLID, FORCE)
	lcd.drawLine (20,26,128,26, SOLID, FORCE)
	lcd.drawLine (20,45,128,45, SOLID, FORCE)
    lcd.drawLine (20,7,20,64, SOLID, FORCE)	

	if update == true then
				
		lcd.drawText(105,14, gpsSATS, SMLSIZE)		
		lcd.drawText(104,28, gpsDtH, SMLSIZE)
		lcd.drawText(116,37, "km"  , SMLSIZE)
		lcd.drawText(104,47, gpsTotalDist, SMLSIZE)
		lcd.drawText(116,55, "km"  , SMLSIZE)

	elseif update == false then
		
		lcd.drawText(105,14, gpsSATS, SMLSIZE + INVERS + BLINK )		
		lcd.drawText(104,28, gpsDtH , SMLSIZE + INVERS + BLINK)
		lcd.drawText(116,37, "km"  , SMLSIZE)
		lcd.drawText(104,47, gpsTotalDist , SMLSIZE + INVERS + BLINK)
		lcd.drawText(116,55, "km"  , SMLSIZE)		

	end	
end
 
return {init=init, run=run, background=background}