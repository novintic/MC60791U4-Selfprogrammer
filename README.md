This is a take at the MC68701/U4 self- programmer board published in application note AN906A/D by Motorola in 1987.

It allows the 'self-programming' of the MC68701(U4) microcontroller (basically an 6801 with built in Eprom).

Probably the only conceivable use for this thing nowadays is to program a 68701U4 to be used as a replacement for the custom 'PS4' chip on a Bubble Bobble arcade PCB. But if you read this you'll most likely already know that.

MC68701U4s are still more or less readily available on Ebay (either NOS or used).

Some additions and modifications to the original design have been made:
 - redesigned the power supply for the +21V programming voltage using an MC34063 based boost converter circuit
 - uses 27C512 ROMS as these are easily available and dirt cheap
 - Added a Vpp- Voltage LED: will light dim when 5V present and bright wenn 21V Vpp is switched on.

Usage: 
 - Eprom U3 must be programmed with the minprgu4.bin which contains the selfprogramming- code
 - Eprom U4 contains the image to be programmed to the MCU's Eprom (most likely 'a78-01.17' found in the 'bin'- folder).
 - Turn off Power (SW1), put SW2 in 'RESET' position
 - Insert the MC68701U4
 - Switch power on.'PWR' LED should light. 'Vpp' LED will be off (indicating /RST is low)
 - Switch SW2 to 'PRGRM'. 'Vpp' will light dim indicating 5V present at /RST which will take the MCU out of reset and rum minprgu4. At the same time LED 'BLANK' should light indicating blank check. If this check fails, both 'BLANK' and 'FAIL' LEDs will light.
 - If blank- check passes, minprgu4 will switch on Vpp. 'Vpp'- LED will light brightly. Programming of the MCU starts and will take approximately 4 minutes.
 - If programming was successful - which means that the data has been verified correctly - LED 'PASS' will light. If not, LED 'FAIL' will light.

-----------------------------------------------------------------------------------------------
IMPORTANT!

MINPRGU4 must be located from $1850-$1FFF on EPROM U3 (NOT starting from $1800 as the instructions in 'Self-Programming the MC68701/U4) document could be interpreted).

The Program on U4 must be at $1000-$1FFF on the EPROM U4 for MC68701U4 (for MC68701: $1800-$1FFF)

-----------------------------------------------------------------------------------------------


You can find more info here (also, most of the above changes are based on suggestions from this thread):
https://www.eevblog.com/forum/microcontrollers/self-programming-the-mc68701-and-the-mc68701u4-(motorola)/

This is another quick/messy release. the files have not really been cleaned up. You should be able to upload 'gerber.zip' to your favorite PCB manufacturer.

The board has been tested and works well for us, however, we'll not be able to offer any kind of support.  Please use at your own risk, thank you.

mirko(NOVINTIC) 01/2025
