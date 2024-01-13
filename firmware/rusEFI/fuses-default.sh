#!/bin/sh

openocd -f interface/jlink.cfg -c 'transport select swd' -f ./at32f4x.cfg \
	-c "init" \
	-c "halt" \
	-c "flash probe 2" \
	-c "flash erase_sector 2 0 last" \
	-c "flash write_bank 2 fuses-default.bin" \
	-c "reset" \
	-c "exit"

echo "Please power-cycle board now!"
