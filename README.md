# Radiomaster MT12 Surface Based Luas
A series of telemetry scripts focused on surface base vehicles

Forked from the amazing Taranis XLite Q7 Lua Dashboard by AndrewFarley:
From: https://github.com/AndrewFarley/Taranis-XLite-Q7-Lua-Dashboard

## Scripts completed:

2 Speed Crawler with Lockable Diffs. "2SpdA.lua".  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, RSSI and Timer.

![Alt text](/Screenshots/2SpdA.png?raw=true "Optional Title")

2 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, Drive Mode and Timer.

![Alt text](/Screenshots/2SpdB.png?raw=true "Optional Title")

Dashboard for VFD Twin transmission.  Displays status of Overdrive and DIG functions, as well as drage brake (for castle ESC) and battery info.

![Alt text](/Screenshots/screenshot_zorro_24-01-23_12-03-41.png?raw=true "Optional Title")

GPS Telemetry.  Shows battery info, current/max speed, GPS sats locked, distance from transmitter (home), total distance covered (odometer)

Located in GPS folder.  Note instructions in configuration.md regarding necessary bitmaps and v/cell adjustment (currently assumes 6 cell)

![Alt text](/Screenshots/screenshot_zorro_24-02-06_20-06-48.png?raw=true "Optional Title")

## Scripts to be added:

- 3 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, RSSI and Timer.
  
- 3 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, Drive Mode and Timer.

- MOA Crawler with front and rear dig.  Visually represents the state of front and rear dig, as well as % overdrive for front wheels.
   

## Installing

1. Download the lua scripts and place into the /SCRIPTS/TELEMETRY folder of your SD card
2. Enable the lua as a telemetry screen (Display menu, screen type "Script")
3. Where applicable, place any .BMP files in /IMAGES folder (create folder if needed)

## Configuration

The scripts read certain sensors, switch positions and channel values to perform their various functions.

For example, the script will read channel values to determine the state of locked differentials.

Everyone has their own way of setting up their radio - this is the beauty of EdgeTX
But it also means some editing of the scripts will be required in order to have the functions work
correctly with your setup.  This is relatively simple and only requires you to be able to open, edit
and save the lua using a simple editing program.  I suggest Notepad++

There are relevant comments in the luas themselves, and more detailed instructions will be documented
in the configurations.md file.
