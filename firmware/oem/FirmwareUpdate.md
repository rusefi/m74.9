*****Firmware update procedure*****

There is two ways to write a new firmware:
- using standard bootlader
- placement of a custom loader in RAM

***Standard boot***

used for uploading main firmware

- start programming session: `10 02`, it should automatically restart ECU to boot mode
- enter security (see below)
- run RequestDownload with address 08001000 and length 000FF000: `34 00 44 08 00 10 00 00 0F F0 00`
- sequentially run TransferData: `36 00 ...` (up to 2K bytes data per request)
- run RequestTransferExit: `37`
- run Routine FF01 with address 08001000 length 000FF000 and checksum CC9E: `31 01 FF 01 44 08 00 10 00 00 0F F0 00 CC 9E`
- run Routine FF00 with address 08200000 length 00001000: `31 01 FF 00 44 08 20 00 00 00 00 10 00`
- run RequestDownload with address 08200000 and length 00000010:`34 00 44 08 20 00 00 00 00 00 10`
- transfer 16 bytes by TransferData: `36 00 ...`
- run RequestTransferExit: `37`
- reboot ECU: `11 01`


***Custom loader***

used to write eeprom and to read back flash/eeprom

- start systemSupplierSpecific session: `10 60`, ECU didnt switched to boot(!)
- enter security (see below)
- sequentally run WriteMemoryByAddress to upload custom binary at 20019800..2001B148: `3D 24 <addr 4 bytes> <len 2 bytes> <data, up to 512 bytes>`
- run Routine F000 with address 20019800: `31 01 F0 00 20 01 98 00`
- run SecurityAccess (algorithm not known)
- now you able to run RoutineControl, ReadMemoryByAddress, WriteMemoryByAddress with some weird (crypted?) parameters. Transferred data also looks crypted.


**Security access**

Security access for bootloader and core fw performed with this exchange:

```
-> 27 01 <rnd, 1 byte>
<- 67 01 <seed, 4 bytes big endian>
-> 27 02 <key, 4 bytes big endian>
<- 67 02
```

Key must be calculated with this formula:
```
uint32_t Uds_Security_CalcKey(uint32_t secret, uint32_t seed, uint8_t rnd)
{
    if (rnd < 220)
        rnd += 35;
    else
        rnd = 255;

    for (uint8_t i = 0; i < rnd; i ++)
    {
        if ((int)seed < 0)
            seed = secret ^ seed << 1;
        else
            seed <<= 1;
    }
    return seed;
}
```
where `secret` is `0x57649392` for main app and `0xB24F5249` for bootloader.


**Avaliable routines**

UDS service 31 RunRoutine supports several routines

- F000 (only in main firmware, not avaliable in bootloader) can start any user code: `31 01 F0 00 <addr, 4 bytes big endian>`. Sample: `31 01 F0 00 20 01 98 00`.
- FF00 (probably, only in boot) can erase memory: `31 01 FF 00 44 <addr, 4 bytes> <size, 4 bytes>`. Sample: `31 01 FF 00 44 08 20 00 00 00 00 10 00`.
- FF01 (also looks like only in boot) can verify checksum. Algorithm is very simple, just uint16_t with summ of all bytes: `31 01 FF 01 44 <addr, 4 bytes> <size, 4 bytes> <checksum, 2 bytes big endian>`. Sample: `31 01 FF 01 44 08 00 10 00 00 0F F0 00 CC 9E`
