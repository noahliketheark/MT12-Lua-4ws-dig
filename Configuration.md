Lua Script Configurations

## Two speed crawler with lockable diffs, battery, RSSI and timer (2SpdA)

The following components need to be configured in order for the script to operate correctly:

1. Battery sensor.

The battery indicator on the left hand side of screen reads battery voltage from a telemetry sensor.
Note that the script expects a SINGLE CELL value.  If you only have total battery voltage available
through telemetry, you will need to create a new sensor and apply the appropriate ratio.  I suggest
naming this sensor "Cell".

Voltage telemetry sensor is configured on line 302.  Currently reading 'Cell'.

2. Transmission state (High/Low)

The script reads a channel value to determine the state of the two speed transmission.  
It is currently configured to read channel 3.  For channel values > 512 it will dispay the H symbol.
For channel values < -512 it will display the L symbol.

Change the channel number on line 403 to whatever channel your transmission servo is on.
Change the channel values on lines 404 (for L) and 409 (for H) to suit the output values for the transmission servo.

3. Diffs (open or locked)

The script monitors channels 5 and 6 for the state of front and rear diffs, respectively.

Lines 371 to 383 contain the function which handles this.  In its current configuration it
will showed locked (filled wheels) when these channels are > 0.  Adjust the channels numbers
and positions accordingly, to suit your setup.

## Two speed crawler with lockable diffs, battery, drive mode and timer (2SpdB)

The following components need to be configured in order for the script to operate correctly:

1. Battery sensor.

The battery indicator on the left hand side of screen reads battery voltage from a telemetry sensor.
Note that the script expects a SINGLE CELL value.  If you only have total battery voltage available
through telemetry, you will need to create a new sensor and apply the appropriate ratio.  I suggest
naming this new sensor "Cell".

Voltage telemetry sensor is configured on line 176.  Currently reading 'Cell'.

2. Transmission state (High/Low)

The script reads a channel value to determine the state of the two speed transmission.  
It is currently configured to read channel 3.  For channel values > 512 it will dispay the H symbol.
For channel values < -512 it will display the L symbol.

Change the channel number on line 277 to whatever channel your transmission servo is on.
Change the channel values on lines 278 (for L) and 283 (for H) to suit the output values for the transmission servo.

3. Diffs (open or locked)

The script monitors channels 5 and 6 for the state of front and rear diffs, respectively.

Lines 245 to 257 contain the function which handles this.  In its current configuration it
will showed locked (filled wheels) when these channels are > 0.  Adjust the channels numbers
and positions accordingly, to suit your setup.


## VFD Twin Transmission

This script reads GVAR1 and GVAR2 to determine transmission status:

GVAR1 @ -100 = OD status "Low"
GVAR1 @ 0 = OD status "RWD"
GVAR1 @ +100 = OD status "High"

GVAR1 @ -100 = DIG status "4WD"
GVAR1 @ 0 = DIG status "FWD"
GVAR1 @ +100 = DIG status "LOCK"

Drag brake reads S2 position and displays as 10% to 100%

Battery voltage reads sensor RxBt and divides by 3 (assumes 3 cell lipo)

## GPS Telemetry

This script is based on the Matek ELRS vario receiver with a GPS unit attached.  It should work out of the box.

Installation instructions: 
Copy GPS.lua to your scripts/telemetry folder
Create a folder called IMAGES on the root of your SD card.  Place the three .BMP files (gps.bmp, odo.bmp and tx.bmp) in the newly created IMAGES folder.
Set a telemetry screen with SCRIPT/GPS

Note: battery meter and v/cell readout assumes 6 cell battery.  Change the divider in line 245 to suit your cell count.
Note: if distance from home and total distance are not working, long press enter, then return from the popup menu.
