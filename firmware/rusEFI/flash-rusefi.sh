#!/bin/sh

openocd -f interface/jlink.cfg -c 'transport select swd' -f ./at32f4x.cfg \
	-c "init" \
	-c "halt" \
	-c "flash probe 0" \
	-c "flash write_image erase rusefi.bin 0x08000000" \
	-c "flash verify_image rusefi.bin 0x08000000" \
	-c "reset" \
	-c "exit"
