#!/bin/sh

# Read EOPB0 and nEOPB0

openocd -f interface/jlink.cfg -c 'transport select swd' -f ./at32f4x.cfg \
	-c "init" \
	-c "halt" \
	-c "flash mdw 0x1FFFC010" \
	-c "reset" \
	-c "exit"

echo "Value at 0x1FFFC010 should be 0x00ff05fa!"
echo "Please check. If not, run fuses-default.sh!"
