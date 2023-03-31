## Some notes about original firmware

### Memory layout

##### Core:

- 08001000 .. 080013ff (vector table)
- 08001400 .. 08051a9b (code/rodata)
- 08069000 .. 0807f1ff (calibration tables)
- 0807fffc .. 0807ffff (checksum ??)
- 08080000 .. 080b224f (code)
- 080ffffc .. 080fffff (checksum ??)

##### Boot:

- 08000000 .. 080003ff (vector table)
- 08201000 .. 08209c5f (code/rodata)
- 0822dffc .. 0822dfff (checksum ??)

##### Unknown:

- 08200000 .. 0820000f (signature)
- 0824f000 .. 0824f3ff

##### Eeprom emulation: 

- 08250000 .. 0826ffff
- 08270000 .. 0828ffff


### Allowed to write areas

(according to bootloader table @ 08209b74, core table @ 08050be0):
(flash addresses mapped one-by-one, eeprom addresses shifted)

- 08000000 .. 08274fff - common flash (addresses overlapped??)
- 08200000 .. 08200003 - common flash
- 0824f000 .. 0824f3ff - common flash
- 00000000 .. 00000FF3 - eeprom
- 00010000 .. 000101F3 - eeprom
- 08274000 .. 08274fff - flash
- 0824e000 .. 0824efff - flash


### Bootloader communication interface

Both core and bootloader uses the same sources to implement UDS protocol. Of course, each application has own copy of these functions, but it's structure completely the same.
Bootloader uses only CAN, and Core also has SPI interface (to interact with L9779 ?) and USART (probably KLINE?).

#### Supported UDS services

(core table @ 0804f05c, bootloader table @ 082087f0)

- 0x10 Diag session control
- 0x11 ECU reset
- 0x14 Clear DTC
- 0x19 Read DTC
- 0x22 Read data by identifier
- 0x27 Security access
- 0x28 Communication control
- 0x2E Write data by identifier
- 0x2F Input/output control by identifier
- 0x31 Routine control
- 0x34 Request download
- 0x36 Transfer data
- 0x37 Request transfer exit
- 0x3D Write memory by address
- 0x3E Tester present
- 0x85 Control DTC settings

These services availiable in both modes, but some of them cannot work because needed internal callbacks defined dynamically.
I have no ideas, how memory read works (there is NO suitable service).

To write a new firmware, probably (!) next sequence should be used:

- switch diag session 0x10
- enter security code 0x27 (for Core functions)
- reboot ECU to bootloader (0x11)
- again switch diag session 0x10
- enter security code 0x27 (algoritm is slightly differs from previous one)
- request download 0x34 to the ECU
- transfer data 0x36
- exit transfer mode 0x37
- run routine to write flash itself 0x31
- repeat download for a next memory block


### Startup sequence

Ram signatures @ 0x20000000:
| value in memory | signature type |
| ---        | --- |
| 0x4df9123b | 0 |
| 0xf9c74a52 | 1 |
| other      | 2 |

Flash signature @ 0x8200000:
| value in memory | signature type |
| ---        | --- |
| 0x2548A4D2 | 0 |
| 0x43A0C212 | 1 |
| other      | 2 |

Bootloader will run core in these cases:
- flash sign == 1 and ram sign == 1 or 2
- ram signature == 1

There is NO checks to core integrity (at least, I couldn't find any suitable functions), so bootlader will try to start ANY application.

To start core bootloader just jumps to reset vector, stored at 08001004 (see memory layout).

Core should (!!) manually set stack pointer and SCB_VTOR
 