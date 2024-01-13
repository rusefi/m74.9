#!/bin/sh

openocd -f interface/jlink.cfg -c 'transport select swd' -f ./at32f4x.cfg \
	-c "init" \
	-c "halt" \
	-c "flash probe 0" \
	-c "flash read_bank 0 readback-fw-bank0.bin" \
	-c "flash probe 1" \
	-c "flash read_bank 1 readback-fw-bank1.bin" \
	-c "flash probe 2" \
	-c "flash read_bank 2 readback-fuses.bin" \
	-c "reset" \
	-c "exit"
