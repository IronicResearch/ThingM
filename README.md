ThingM

ThingM stop-motion camera control and optical printer sequencer is a Z80-based embedded device with keypad, LCD, optional serial IO, and stepper motor controller adapted for stop-motion cameras and projectors.

The name “ThingM” is an ironic homage to the JK ITSM stop-motion control which was previously prototyped for JK Camera with all its quirkiness, particularly its insane custom keypad. Unlike ITSM, ThingM controllers were designed and built entirely by Dave Milici / Ironic Research Labs using off-the-shelf keypads, LCDs, stepper motor drivers, and other components which actually worked.

All Z80-compatible components were used for CPU, PIO, SIO, CTC, plus RAM and EPROM. Functions were accessed via a 16-key keypad and displayed on an alphanumeric LED or LCD with 3-letter command prompts. Optional RS232 serial interface was enabled on ThingM-OP and ThingM-II optical printer sequencers to allow for remote control operation. Input triggers allowed remote single-frame operation via pushbutton switches, and output triggers could be connected to solid-state relays for turning on lighting accessories during exposures.

All Z80 development was done on 8-bit CP/M compatible systems using CP/M MAC macro assembler. Technically MAC assembled 8080 instructions so Z80 instructions were assembled by Z80.LIB macro library using 8080-style syntax. Later development was handled by CP/M emulation environments and/or Z80 co-processor boards from Z-World. Hence MAC is renamed “MAC.CPM” for distinction from MS-DOS .COM files.

```
	MAC THTMR279.ASM
	DIR THTMR279.HEX
```

Assembly input files are in text-based .ASM format, and output files are in Intel .HEX format compatible with EPROM burners. The use of 8-bit EPROMs for Z80 machine code memory pre-dated modern flash memory, so EPROMs typically had to be erased and programmed from scratch for code updates.

