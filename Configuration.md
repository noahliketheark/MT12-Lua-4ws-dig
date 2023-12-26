Lua Script Configurations

## Two speed crawler with lockable diffs, battery, RSSI and timer

The following components need to be configured in order for the script to operate correctly:

1. Battery sensor.

The battery indicator on the left hand side of screen reads battery voltage from a telemetry sensor.
Note that the script expects a SINGLE CELL value.  If you only have total battery voltage available
through telemetry, you will need to create a new sensor and apply the appropriate ratio.

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
