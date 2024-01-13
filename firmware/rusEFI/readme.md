See https://rusefi.com/build_server/rusefi_bundle_m74_9.zip

See https://github.com/rusefi/rusefi/tree/master/firmware/config/boards/m74_9

## flags

Itelma uses custom user system area flags e.g. "fuses".

rusEFI likes RAM we go with default user system area flags e.g. "fuses".

fuses-default.bin - default user area dump extracted from AT32F435-START with default RAM vs FLASH cache configuration:
384 Kb of RAM + 256Kb for cache for zero-wait flash
	
	