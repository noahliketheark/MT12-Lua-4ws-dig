# Radiomaster MT12 Surface Based Luas
A series of telemetry scripts focused on surface base vehicles

Forked from the amazing Taranis XLite Q7 Lua Dashboard by AndrewFarley:
From: https://github.com/AndrewFarley/Taranis-XLite-Q7-Lua-Dashboard

## Scripts completed:

1. 2 Speed Crawler with Lockable Diffs. "2SpdA.lua".  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, RSSI and Timer.

![Alt text](Radiomaster-MT12-Surface-Based-Luas/blob/master/Screenshots/2SpdA.png?raw=true "Optional Title")

## Scripts to be added:

1. 2 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, Drive Mode and Timer.
2. 3 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, RSSI and Timer.
3. 3 Speed Crawler with Lockable Diffs.  Visually represents the state of a two speed transmission and whether diffs are open or locked.  Shows Battery, Drive Mode and Timer.
4. MOA Crawler with front and rear dig.  Visually represents the state of front and rear dig, as well as % overdrive for front wheels.
   

## Installing

1. Download the lua scripts and place into the /SCRIPTS/TELEMETRY folder of your SD card
2. Enable the lua as a telemetry screen (Display menu, screen type "Script")

## Configuration

The scripts read certain sensors, switch positions and channel values to perform their various functions.

For example, the script will read channel values to determine the state of locked differentials.

Everyone has their own way of setting up their radio - this is the beauty of EdgeTX
But it also means some editing of the scripts will be required in order to have the functions work
correctly with your setup.  This is relatively simple and only requires you to be able to open, edit
and save the lua using a simple editing program.  I suggest Notepad++

There are relevant comments in the luas themselves, and more detailed instructions will be documented
in the configurations.md file.
