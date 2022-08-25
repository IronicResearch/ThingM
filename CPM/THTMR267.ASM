
* The birth of a new ThingM.
* Production version IRL 3+4.

* 11-21-02
* Copyright 1989-2002 Dave Milici,
* Ironic Research Labs, San Francisco.

* Telephone / Calculator Keypad layout option.
* Liquid Crystal Display / LED Display option.
* Serial Interface / Multiplexed IO option.

* 400 ppr half-stepper / 2000 ppr micro-stepper.
* 16-bit run-time ramping.
* Open-loop operation counts stepper pulses.
* Closed-loop operation senses switch interrupts.
* Extended ramping operation > 1 revolution for continuous frames.

* Single motor installation for Adolph Esposito.
* Camera only functions for 16mm Bolex Reflex with 1:1 or 8:1 drive.
* Half-stepping motor driver.

* Based on Dual motor configuration
* originally used by George Coates Performance Works
* and later adapted for Adam Zoglin and Michael Rudnick.

* DC stepping motor for Camera
* DC stepping motor for Auxiliary motor or 2nd Camera
* Home switch sensing inverted = Low.
* Dual DC Enable lines for either/both cameras/motors.
* Sequencer Alternate operation.

* Real-time clock (sort of).
* Variable Lapse Time.
* Variable Exposure Time.
* Variable Motor High-Power Enable Time.
* User-definable Minimum Motor Speed.
* 2nd Level Internal Menu.

* Measure lapse times according to real-time clock.
* Allow quick status displays of data at run-time.
* Whip-open Film Speed for Time-Exposures.
* Torque time-out whenever motor stops.
* Trigger operation for pre-, sync-, or post-exposures.



FALSE:    EQU 0
TRUE:     EQU NOT FALSE

VERSION:  EQU 267        ;Version Number
PROTOTYP: EQU FALSE      ;Prototype ?

LEDISPLY: EQU False      ;LED display
LCDISPLY: EQU True       ;LCD display
LCDLONG   EQU true       ;LCD longer than 16 chars
LCD2ROW   EQU true       ;LCD with 2nd row
LCDREAD   EQU false      ;LCD module is read/write or write-only ?

PHONEKEY: EQU True       ;Telephone keypad

MUXIO:    EQU True       ;Multiplexed Input / Output
SERIALIO: EQU False      ;Serial Interface Input / Output

CLK1MHZ:  EQU FALSE      ;1 MHz
CLK125M:  EQU False      ;1.2288 MHz
CLK180M:  EQU True       ;1.8432 MHz
CLK2MHZ:  EQU FALSE      ;2 MHz
CLK250M:  EQU FALSE      ;2.4576 MHz
CLK360M:  EQU FALSE      ;3.6864 MHz
CLK4MHZ:  EQU FALSE      ;4 MHz
CLK6MHZ:  EQU FALSE      ;6 MHz
CLK8MHZ:  EQU FALSE      ;8 MHz

VEXPOPTN: EQU TRUE       ;Variable Exposure Time Option
VLPSOPTN: EQU TRUE       ;Variable Lapse Time Option
VTRGOPTN: EQU TRUE       ;Variable Output Trigger Delay Option
VTRQOPTN: EQU TRUE       ;Variable Torque Time-out Option
POWROPTN: EQU FALSE      ;Motor Power Toggle Option
TRGXOPTN: EQU FALSE      ;Output Trigger Toggle Option
DRVROPTN: EQU True       ;Driver Type Toggle Option
RACKOPTN: EQU FALSE      ;Rack-Over Switch Detection Option
SEQROPTN: EQU False      ;Dual-Motor Sequencer Option
PRETRGOP: EQU True	 ;pre-exposure trigger delay
SYNTRGOP: EQU FALSE	 ;sync-exposure trigger only
POSTRGOP: EQU FALSE      ;post-exposure trigger delay

GEAROPTN: EQU TRUE	 ;Bolex 1:1 or 8:1 gear drive option

	  IF PROTOTYP

ROMADDR:  EQU 0000H      ;ROM code space
RAMADDR:  EQU 8000H      ;RAM data space

CTCADDR:  EQU 80H        ;CTC counters
PIOADDR:  EQU 40H        ;PIO ports
SIOADDR:  EQU 20H        ;SIO ports
LEDADDR:  EQU 10H        ;LED displays

	  ENDIF

	  IF NOT PROTOTYP

ROMADDR:  EQU 0000H      ;ROM code space
RAMADDR:  EQU 8000H      ;RAM data space

CTCADDR:  EQU 1CH        ;CTC counters
PIOADDR:  EQU 18H        ;PIO ports
SIOADDR:  EQU 14H        ;SIO ports
LEDADDR:  EQU 00H        ;LED displays

	  ENDIF



          MACLIB Z80
          MACLIB UTILITY



; LED or LCD display assignments.

	  IF LEDISPLY
LED:      EQU LEDADDR+0  ;LED output display port
	  ENDIF

	  IF LCDISPLY

LCD:      EQU LEDADDR+0  ;LCD output display port

LCDCNTL:  EQU LEDADDR+0  ;LCD control+address register
LCDDATA:  EQU LEDADDR+1  ;LCD data register

	  ENDIF




CTC0:     EQU CTCADDR+0  ;counter/timer 0
CTC1:     EQU CTCADDR+1  ;counter/timer 1
CTC2:     EQU CTCADDR+2  ;counter/timer 2
CTC3:     EQU CTCADDR+3  ;counter/timer 3

PIOA:     EQU PIOADDR+0  ;PIO data port A
PIOCNTLA: EQU PIOADDR+1  ;PIO control port A

PIOB:     EQU PIOADDR+2  ;PIO data port B
PIOCNTLB: EQU PIOADDR+3  ;PIO control port B

KEYSCAN:  EQU PIOA       ;keypad scanning output
KEYSENS:  EQU PIOA       ;keypad sensing input

CONTROL:  EQU PIOB       ;control output port
STATUS:   EQU PIOB       ;status input port

MOTRCNTL: EQU PIOB       ;motor control output port
SWITCH:   EQU PIOB       ;sensing switch input port

	  IF PROTOTYP

MTRG:     EQU 7          ;motor run trigger output line
MDIR:     EQU 6          ;motor direction output line
MEN2:     EQU 5          ;motor enable DC Low-Power standby
MEN1:     EQU 3          ;motor enable DC

DCUR:     EQU 4          ;display cursor enable line

SHME:     EQU 0          ;switch home input
SRKO:     EQU 1          ;switch count input
STRG:     EQU 2          ;switch trigger input

	  ENDIF

	  IF NOT PROTOTYP

MTRG:     EQU 7          ;motor run trigger output line
MDIR:     EQU 6          ;motor direction output line
MEN2:     EQU 5          ;motor enable DC Low-Power standby
MEN1:     EQU 4          ;motor enable DC

DCUR:     EQU 3          ;display cursor enable line

SHME:     EQU 0          ;switch home input
SRKO:     EQU 1          ;switch count input
STRG:     EQU 2          ;switch trigger input

	  ENDIF




SIOA:     EQU SIOADDR+0  ;SIO data port A
SIOCNTLA: EQU SIOADDR+1  ;SIO control port A

SIOB:     EQU SIOADDR+2  ;SIO data port B
SIOCNTLB: EQU SIOADDR+3  ;SIO control port B

SIOCMD:   EQU SIOCNTLB   ;SIO command output port
SIODATA:  EQU SIOB       ;SIO data input/output port
SIOSTAT:  EQU SIOCNTLB   ;SIO status input port
BAUDCLK:  EQU CTC2       ;SIO baud clock generator




; Microprocessor clock speed dependent constants.

	  IF CLK1MHZ

QT01:     EQU 39         ;0.01 sec quantum time @ 1 MHz / 256
QT01SOFT: EQU 417        ;0.01 sec quantum time @ 1 MHz / 24 T-states
KSCALEHF: EQU 15600      ;speed scaling constant half-stepping @ 1 MHz
LOWSPDHF: EQU 62         ;minimum low speed half-stepping @ 1 MHz
KSCALEMS: EQU 3120       ;speed scaling constant micro-stepping @ 1 MHz
LOWSPDMS: EQU 12         ;minimum low speed micro-stepping @ 1 MHz
BNCETM:   EQU 2*500      ;mechanical switch debouncing time
BAUD9600: EQU 3          ;9600 baud rate clock @ 1 MHz / 2 / 16

	  ENDIF

	  IF CLK125M

QT01:     EQU 48         ;0.01 sec quantum time @ 1.2288 MHz / 256 exactly
QT01SOFT: EQU 512        ;0.01 sec quantum time @ 1.2 MHz / 24 T-states
KSCALEHF: EQU 19170      ;speed scaling constant half-stepping @ 1.2 MHz
LOWSPDHF: EQU 76         ;minimum low speed half-stepping @ 1.2 MHz
KSCALEMS: EQU 3834       ;speed scaling constant micro-stepping @ 1.2 MHz
LOWSPDMS: EQU 15         ;minimum low speed micro-stepping @ 1.2 MHz
BNCETM:   EQU 2*620      ;mechanical switch debouncing time
BAUD9600: EQU 4          ;9600 baud rate clock @ 1.2 MHz / 2 / 16 exactly

	  ENDIF

	  IF CLK180M

QT01:     EQU 72         ;0.01 sec quantum time @ 1.8432 MHz / 256 exactly
QT01SOFT: EQU 768        ;0.01 sec quantum time @ 1.8 MHz / 24 T-states
KSCALEHF: EQU 28080      ;speed scaling constant half-stepping @ 1.8 MHz
LOWSPDHF: EQU 111        ;minimum low speed half-stepping @ 1.8 MHz
KSCALEMS: EQU 5616       ;speed scaling constant micro-stepping @ 1.8 MHz
LOWSPDMS: EQU 22         ;minimum low speed micro-stepping @ 1.8 MHz
BNCETM:   EQU 2*900      ;mechanical switch debouncing time
BAUD9600: EQU 6          ;9600 baud rate clock @ 1.8 MHz / 2 / 16 exactly
BAUD4800: EQU 12         ;4800 baud rate clock @ 1.8 MHz / 2 / 16 exactly

	  ENDIF

	  IF CLK2MHZ

QT01:     EQU 78         ;0.01 sec quantum time @ 2 MHz / 256
QT01SOFT: EQU 833        ;0.01 sec quantum time @ 2 MHz / 24 T-states
KSCALEHF: EQU 31200      ;speed scaling constant half-stepping @ 2 MHz
LOWSPDHF: EQU 123        ;minimum low speed half-stepping @ 2 MHz
KSCALEMS: EQU 6240       ;speed scaling constant micro-stepping @ 2 MHz
LOWSPDMS: EQU 24         ;minimum low speed micro-stepping @ 2 MHz
BNCETM:   EQU 2*1000     ;mechanical switch debouncing time
BAUD9600: EQU 7          ;9600 baud rate clock @ 2 MHz / 2 / 16

	  ENDIF

	  IF CLK250M

QT01:     EQU 96         ;0.01 sec quantum time @ 2.4576 MHz / 256 exactly
QT01SOFT: EQU 1024       ;0.01 sec quantum time @ 2.4 MHz / 24 T-states
KSCALEHF: EQU 38339      ;speed scaling constant half-stepping @ 2.4 MHz
LOWSPDHF: EQU 151        ;minimum low speed half-stepping @ 2.4 MHz
KSCALEMS: EQU 7668       ;speed scaling constant micro-stepping @ 2.4 MHz
LOWSPDMS: EQU 29         ;minimum low speed micro-stepping @ 2.4 MHz
BNCETM:   EQU 2*1230     ;mechanical switch debouncing time
BAUD9600: EQU 8          ;9600 baud rate clock @ 2.4 MHz / 2 / 16 exactly

	  ENDIF

	  IF CLK360M

QT01:     EQU 144        ;0.01 sec quantum time @ 3.6864 MHz / 256 exactly
QT01SOFT: EQU 1536       ;0.01 sec quantum time @ 3.6 MHz / 24 T-states
KSCALEHF: EQU 56160      ;speed scaling constant half-stepping @ 3.6 MHz
LOWSPDHF: EQU 221        ;minimum low speed half-stepping @ 3.6 MHz
KSCALEMS: EQU 11232      ;speed scaling constant micro-stepping @ 3.6 MHz
LOWSPDMS: EQU 44         ;minimum low speed micro-stepping @ 3.6 MHz
BNCETM:   EQU 2*1800     ;mechanical switch debouncing time
BAUD9600: EQU 12         ;9600 baud rate clock @ 3.6 MHz / 2 / 16 exactly
BAUD4800: EQU 24         ;4800 baud rate clock @ 3.6 MHz / 2 / 16 exactly

	  ENDIF

	  IF CLK4MHZ

QT01:     EQU 156        ;0.01 sec quantum time @ 4 MHz / 256
QT01SOFT: EQU 1667       ;0.01 sec quantum time @ 4 MHz / 24 T-states
KSCALEHF: EQU 62400      ;speed scaling constant half-stepping @ 4 MHz
LOWSPDHF: EQU 246        ;minimum low speed half-stepping @ 4 MHz
KSCALEMS: EQU 12480      ;speed scaling constant micro-stepping @ 4 MHz
LOWSPDMS: EQU 49         ;minimum low speed micro-stepping @ 4 MHz
BNCETM:   EQU 2*4000     ;mechanical switch debouncing time
BAUD9600: EQU 13         ;9600 baud rate clock @ 4 MHz / 2 / 16

	  ENDIF

	  IF CLK6MHZ

QT01:     EQU 234        ;0.01 sec quantum time @ 6 MHz / 256
QT01SOFT: EQU 2500       ;0.01 sec quantum time @ 6 MHz / 24 T-states
KSCALEHF: EQU 46800      ;1/2 speed scaling constant half-stepping @ 6 MHz
LOWSPDHF: EQU 369        ;minimum low speed half-stepping @ 6 MHz
KSCALEMS: EQU 18720      ;speed scaling constant micro-stepping @ 6 MHz
LOWSPDMS: EQU 74         ;minimum low speed micro-stepping @ 6 MHz
BNCETM:   EQU 2*6000     ;mechanical switch debouncing time
BAUD9600: EQU 20         ;9600 baud rate clock @ 6 MHz / 2 / 16

	  ENDIF

	  IF CLK8MHZ

QT01:     EQU 312        ;0.01 sec quantum time @ 8 MHz / 256
QT01SOFT: EQU 3333       ;0.01 sec quantum time @ 8 MHz / 24 T-states
KSCALEHF: EQU 62400      ;1/2 speed scaling constant half-stepping @ 8 MHz
LOWSPDHF: EQU 492        ;minimum low speed half-stepping @ 8 MHz
KSCALEMS: EQU 24960      ;speed scaling constant micro-stepping @ 8 MHz
LOWSPDMS: EQU 98         ;minimum low speed micro-stepping @ 8 MHz
BNCETM:   EQU 2*8000     ;mechanical switch debouncing time
BAUD9600: EQU 26         ;9600 baud rate clock @ 8 MHz / 2 / 16

	  ENDIF




; Reset initialization routines.
; Try pulling Input pins High with initial Output byte.

          ORG 0000H

	  IF PROTOTYP
QUIETIO:  EQU 01111111B       ;quiet output: MTRG, MDIR, MEN2, DCUR, MEN1
	  ENDIF

	  IF NOT PROTOTYP
QUIETIO:  EQU 01111111B       ;quiet output: MTRG, MDIR, MEN2, MEN1, DCUR
	  ENDIF

RESET:    LXI SP,STACK        ;(just in case of immediate NMI)

          MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLB
          MVI A,00000111B     ;identify input/output directions
          OUT PIOCNTLB
          MVI A,QUIETIO       ;quiet output lines
          OUT PIOB

          XRA A               ;time delay
WAITRSET: DCR A
          JNZ WAITRSET

          DI
          IM2                 ;Z80 vectored interrupts

          CALL RESETPIO       ;init parallel ports
	  CALL RESETLED       ;init LED display
          CALL RESETCTC       ;init counters / timers
          CALL RESETSIO       ;init serial port
          CALL TEST           ;test output
          CALL RESETMEM       ;init memory registers
          CALL INITIALZ       ;init variables

          MVI A,RAMADDR/256   ;load interrupt vector
          STAI
          EI
          JMP MAIN



; Maskable Interrupt routine.

          ORG 0038H

INT:      EI
          RETI



	  DB '(C) 1989-2002 Ironic Research Labs'

; Non-Maskable Interrupt routine.

          ORG 0066H

NMI:      RETN




; Null interrupt routine.

NULLINT:  EQU INT




; Counter / timer interrupt routines.

          ORG 0070H

; Acceleration 16-bit ramp counts
;  A <-- general
; BC <-- acceleration ramp count
; DE <-- pre-deceleration step count
; HL <-- ramp table step time pointer

ACCLXINT: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
          OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          INX H               ;update step-time pointer
          DCX D               ;update step-count counter
          DCX B               ;update ramp-count counter
          MOV A,B
          ORA C               ;16-bit ramp count over ?
          JNZ EXITACLX

          SHLD MAXPNTR        ;save ramp table pointer
	  LXI H,CONSTINT
          SHLD INTCTCV0

EXITACLX: EXAF
          EXX
          EI
          RETI

; Constant Speed phase of ramping.
; Pulses counted by software counter DE'.
; (Pulses counted by hardware counter CTC1.)
;  A <-- general
; DE <-- pre-deceleration step count

CONSTINT: EXX
          EXAF
          DCX D               ;update pre-decel step count (DE')
          MOV A,D
          ORA E
          JNZ EXITCONS        ;count over ?

          LXI H,DECLXINT      ;then point to deceleration interrupt
          SHLD INTCTCV0
          LHLD MAXPNTR        ;re-load ramp table pointer (HL')
          DCX H
          LBCD RAMPRUN        ;load decel ramp count (BC')

EXITCONS: EXAF
          EXX
          EI
          RETI

; Deceleration 16-bit ramp counts
;  A <-- general
; BC <-- deceleration ramp count (16-bit)
; HL <-- ramp table step time pointer

DECLXINT: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
	  OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          DCX H               ;update step-time pointer 
          DCX B               ;update ramp-count counter
          MOV A,B             ;16-bit ramp count over ?
          ORA C
          JZ STOPNOW

EXITDCLX: EXAF
          EXX
          EI
          RETI

; Stop all timers and counters right now...
; Insure stopping motor at Home switch signal.
; Pre-set torque time-out once stepper motor is stopped.
; CTC1 <-- torque time-out timer (instead of CTC3).
; DE'  <-- time-out 0.01 second multiple.

STOPINT:  EXX
          EXAF

STOPNOW:  LDA SWITMASK        ;check if timed-out stop or switched stop
          ORA A
          JNZ STOPRUN

SENSCAM:  IN SWITCH           ;sense camera home switch ?
          BIT SHME,A          ;(switch active low ... XXXXX110)
          JNZ STOPGAP         ;if not switched, then check for time-out

          IN SWITCH           ;double-check ?
          BIT SHME,A
          JNZ STOPGAP

          IN SWITCH           ;triple-check ?
          BIT SHME,A
          JNZ STOPGAP

STOPRUN:  MVI A,NC000NRC      ;if over, then reset timers
	  OUT CTC0
          OUT CTC1

          LXI H,NULLINT       ;point to null interrupt vectors
          SHLD INTCTCV0
          SHLD INTCTCV1

	  CALL MOTOROFF       ;turn off AC motor enable

	  IF SYNTRGOP
	  CALL TRIGROFF       ;turn off output trigger signal
	  ENDIF

	  XRA A               ;signal motor over
	  STA MOTROVER
	  STA HOMEOVER
	  CMA
	  STA TORQOVER	      ;torque still active

          LDED TORQTIME       ;load torque time-out (DE')

          LXI H,LASTINT       ;point to time-out interrupt vector
          SHLD INTCTCV1

	  MVI A,IT800LRC      ;load torque timer
          OUT CTC1
          MVI A,QT01          ;with multiples of 0.01 seconds
          OUT CTC1

          EXAF
          EXX
          EI 
          RETI

; Insure stopping motor at Home switch signal.

STOPGAP:  MVI A,NC000NRC      ;reset higher-order counters
          OUT CTC1

          LXI H,STOPINT       ;loop any/all interrupts to Stop vector
          SHLD INTCTCV0
          LXI H,NULLINT
          SHLD INTCTCV1

	  EXAF
          EXX
          EI 
          RETI

; Time-out for DC Motor Enable signal after last step pulse.
; DE' <-- Variable-length time-out multiple.
; BC' <-- (general timer interval, for exposure time or lapse time.)

LASTINT:  EXX
          EXAF

          DCX D               ;time-out ?
          MOV A,D
          ORA E
          JNZ EXITLAST

          MVI A,NT800NRC      ;reset time-out timer
          OUT CTC1
          LXI H,NULLINT       ;point to null interrupt vectors
	  SHLD INTCTCV1

	  CALL MOTORNUL       ;turn off DC enable signal

	  XRA A
	  STA TORQOVER	      ;signal torque over

EXITLAST: EXAF
          EXX
          EI
          RETI

; Acceleration routine for multiple revolutions.
; BC <-- acceleration ramp count
; DE <-- pre-deceleration step count
; HL <-- ramp table step time pointer
; Note: Only place allowed for Trigger output for Sync-exposure Trigger.

FRAMEACL: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
	  OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          INX H               ;update step-time pointer
          DCX B               ;update ramp-count counter
          MOV A,B
          ORA C               ;16-bit ramp count over ?
          JNZ EXITFRMX

          SHLD MAXPNTR        ;save ramp table pointer
          LXI H,NULLINT
          SHLD INTCTCV0

	  IF SYNTRGOP
	  CALL TRIGRON        ;turn on output trigger signal now (only here)
	  ENDIF

EXITFRMX: EXAF
          EXX
          EI
          RETI

; Acceleration routine for short multiple revolutions.
; BC <-- acceleration ramp count
; DE <-- pre-deceleration step count
; HL <-- ramp table step time pointer

FRAMEACQ: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
          OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          INX H               ;update step-time pointer
          DCX D               ;update pre-decel step-count counter
          DCX B               ;update accel ramp-count counter
          MOV A,B
          ORA C               ;16-bit ramp count over ?
          JNZ EXITFRMQ

          SHLD MAXPNTR        ;save ramp table pointer
          LXI H,FRAMECON      ;point to constant-phase routine
	  SHLD INTCTCV0

EXITFRMQ: EXAF
          EXX
          EI
          RETI

; Constant Speed phase of ramping for full revolutions.
; Pulses counted by software counter DE'.
; (Pulses counted by hardware counter CTC1.)
; DE <-- pre-deceleration step count
; CTC0 <-- step-time timer/counter.
; CTC1 <-- step-count low-byte counter.
; CTC3 <-- step-count high-byte counter = frames.

FRAMECON: EXX
          EXAF
	  DCX D               ;update pre-decel step count (DE')
	  MOV A,D
	  ORA E
	  JNZ EXITFCON        ;count over ?

	  IF SYNTRGOP
	  CALL TRIGROFF       ;turn off output trigger signal
	  ENDIF

	  LXI H,FRAMEDCL      ;then point to deceleration interrupt
          SHLD INTCTCV0
          LHLD MAXPNTR        ;re-load ramp table pointer (HL')
          DCX H
          LBCD RAMPRUN        ;load decel ramp count (BC')

EXITFCON: EXAF
          EXX
          EI
          RETI

; Deceleration 16-bit ramp counts for full revolutions.
; BC <-- deceleration ramp count (16-bit)
; HL <-- ramp table step time pointer

FRAMEDCL: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
	  OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          DCX H               ;update step-time pointer
          DCX B               ;update ramp-count counter
          MOV A,B             ;16-bit ramp count over ?
          ORA C
          JZ STOPNOW

EXITFDCL: EXAF
          EXX
          EI
          RETI

; Multiple revolution frame count interrupt routine.
; CTC0 <-- step-time timer/counter.
; CTC1 <-- step-count low-byte counter.
; CTC3 <-- step-count high-byte counter = frames.
;  A <-- general
; BC <-- acceleration or deceleration phase ramp count
; DE <-- pre-deceleration constant phase step count
; HL <-- acceleration phase step-time pointer.
; Note run-time frame counters are updated here.
; Frames are detected according to motor revolutions.
; Acceleration and Deceleration timing are handled concurrently.

FRAMEINT: EXX
          EXAF
          PUSH H
          PUSH PSW

          XRA A
          STA HOMEOVER        ;signal revolution over

          CALL UPDTCNTR       ;update total frame counter

          LHLD RUNFRAME
          DCX H               ;update frame revolution counter
          SHLD RUNFRAME
          MOV A,H
	  ORA L
          JNZ EXITFRME

          LDED RUNPRECL       ;change over to step counter for last frame

          LXI H,FRAMECON      ;change over to pre-deceleration phase
          SHLD INTCTCV0

          LXI H,FRAMECRZ      ;continue counting frames
          SHLD INTCTCV3

EXITFRME: POP PSW
          POP H
          EXAF
          EXX
          EI
          RETI

; Continuation of FRAMEINT continuous running interrupt routine.
; CTC0 <-- step-time timer/counter.
; CTC1 <-- step-count low-byte counter.
; CTC3 <-- step-count high-byte counter = frames.

FRAMECRZ: EXX
          EXAF
          PUSH PSW
          PUSH H

          XRA A
          STA HOMEOVER        ;signal revolution over

          CALL UPDTCNTR       ;update total frame counter

EXITFCRZ: POP H
          POP PSW
          EXAF
          EXX
          EI
          RETI

; Wait time delay interrupt routine.
;   BC <-- software time delay counter in multiples of 10000.
; CTC3 <-- hardware time delay interval timer.

WAITINT:  EXX
          EXAF
          DCX B               ;update time multiple counter
          MOV A,B
          ORA C
          JNZ EXITWAIT

          MVI A,NT800NRC      ;if over, then reset timer
          OUT CTC3
          LXI H,NULLINT       ;point to null vector
          SHLD INTCTCV3
          XRA A               ;signal timer over
          STA TIMROVER

EXITWAIT: EXAF
          EXX
	  EI
          RETI

; Real-time clock interrupt free-running on CTC2.
; 0.01 second intervals updated in REALTIME (16-bit).
; Substitute CTC3 if serial baud rate clock used on CTC2.

CLOCKINT: PUSH H
          LHLD REALTIME
          INX H                 ;update real-time clock by 0.01 second
          SHLD REALTIME

EXITCLOK: POP H
          EI
          RETI

; Cursor interrupt routine.

	  IF LEDISPLY

; Flashing cursor on LED display according to timer interrupt CTC3.
; CURSRTME <-- (software) timer multiple of 0.01 seconds.

CURSRINT: EXX
          EXAF
          LDA CURSRTME          ;update flasher timer counter
          DCR A
          STA CURSRTME
          JNZ EXITCURS

          IN CONTROL		;access the LED cursor
          RES DCUR,A
          OUT CONTROL

          LDA CURSRMEM		;load the cursor
          XRI 00000001B         ;toggle it
          OUT LED+0		;flash on 1st digit
          STA CURSRMEM		;save in memory

          BIT 0,A		;cursor ?
	  MVI A,15		;pre-load short duty cycle for cursor
          STA CURSRTME
          JRNZ WINKIT
          MVI A,35		;re-load long duty cycle for digit
          STA CURSRTME

WINKIT:   IN CONTROL		;release the LED cursor
          SETB DCUR,A
          OUT CONTROL

EXITCURS: EXAF
          EXX
          EI
          RETI

	  ENDIF

; Switch sensing interrupt routines.

PIOINTH:  EQU 10110111B       ;enable interrupt lines active high
PIOINTL:  EQU 10010111B       ;enable interrupt lines active low
PIOINTN:  EQU 00010111B       ;disable interrupt lines (active low)
PIOANDM:  EQU 11010111B       ;enable interrupt mask with AND bits
PIOMASK:  EQU 11111111B       ;default interrupt line mask






; Main program loop.
; All keys are 'hot'.


MOK:      DB 'OK '
MOKF:     DB 'OK+'
MOKR:     DB 'OK-'

MAIN:     LXI H,MOK           ;display Ready prompt
	  CALL OUTSIGN        ;with direction
          CALL OUTMUX3

          CALL GETCAMPR       ;get camera or projector ?

	  LHLD COUNTER        ;display frame count
	  CALL OUTNUMX

WAITMAIN: IN SWITCH
	  BIT STRG,A          ;trigger input ?
	  JNZ TRIGIT

	  CALL INMUX          ;get key input ?
	  JNC WAITMAIN

	  LDA KEYBUF
	  CPI PROGRAM         ;Program ?
	  CZ PRGMIT

if SEQROPTN

	  CPI ONE
	  CZ CAM1IT           ;select Camera 1

	  CPI TWO
	  CZ SYNCIT           ;select Sync Camera 1 + 2

	  CPI THREE
	  CZ CAM2IT           ;select Camera 2

	  CPI FOUR
	  CZ FRAMEIT          ;Frame Count ?

	  CPI FIVE
	  CZ EXPIT            ;Exposure Time ?

	  CPI SIX
	  CZ LAPSEIT          ;Lapse Time ?

	  CPI SEVEN
	  CZ COUNTIT          ;Total Count ?

	  CPI EIGHT
	  CZ VEXPIT           ;Variable Exp Time ?

	  CPI NINE
	  CZ VLAPSIT          ;Variable Lapse Time ?

	  CPI ZERO
	  CZ SEQUENIT         ;Sequencer Operation ?

else	  ;NOT SEQROPTN

	  CPI ONE
	  CZ FRAMEIT          ;Frame Count ?

	  CPI TWO
	  CZ COUNTIT          ;Total Count ?

	  CPI THREE
	  CZ OUTFRMIT         ;Out Frame ?

	  CPI FOUR
	  CZ EXPIT            ;Exposure Time ?

	  CPI FIVE
	  CZ LAPSEIT          ;Lapse Time ?

	  CPI SIX
	  CZ VTRIGIT          ;Variable Trigger ?

	  CPI SEVEN
if GEAROPTN
	  CZ FPSPDIT          ;Frames per Sec ?
else
	  CZ VEXPIT           ;Variable Exp Time ?
endif

	  CPI EIGHT
	  CZ VLAPSIT          ;Varaible Lapse Time ?

	  CPI NINE
if GEAROPTN
	  CZ DRIVERIT         ;Drive Ratio ?
else
	  CZ OUTRIGIT	      ;Trigger Overide ?
endif

	  CPI ZERO
	  CZ WEDGEIT
endif
          CPI MINUS
          CZ DIRIT            ;Direction ?

          CPI RUN             ;Run ?
	  CZ RUNIT

          CALL PUTCAMPR       ;remember to update camera or projector...

          JMP MAIN            ;re-loop

; Display direction forward or reverse as + or -.

OUTSIGN:  LDA DIRSTAT         ;check direction ?
          ORA A
          JNZ OUTMINUS

          LXI H,MOKF          ;+ if forward
          RET

OUTMINUS: LXI H,MOKR          ;- if reverse
          RET

; External Trigger input loop.

TRIGIT:   LXI D,BNCETM        ;wait switch debouncing time
	  CALL WAITX

          IN SWITCH           ;trigger input still ?
          BIT STRG,A
          JZ EXITTRIG         ;if not, then forget it

WAITTRIG: IN SWITCH           ;else wait for switch release
          BIT STRG,A
	  JNZ WAITTRIG

	  CALL GETCAMPR	      ;single frame camera or projector or sequencer?

	  LXI H,1             ;preset 1 single frame only
          SHLD FRAMEABS

	  CALL RUNIT          ;then run it...

	  LHLD FRAMECNT       ;re-transfer programmed frame count
          SHLD FRAMEABS
          CALL DIRTOFRM       ;check direction
	  SHLD FRAMEABS       ;insure positive absolute value

	  CALL PUTCAMPR       ;restore preset frame whatever

EXITTRIG: JMP MAIN

; Rack-over switch detection loop.

	  IF RACKOPTN

MRKO:     DB 'RKO'

RACKIT:   LXI D,BNCETM        ;wait switch debouncing time
	  CALL WAITX

          IN SWITCH           ;rack-over switch input ... for sure ?
          BIT SRKO,A
          JZ EXITRACK

RACKPTRN: LXI H,MRKO          ;flash Rack state
          CALL OUTMUX3
	  LXI H,50            ;init display flasher = 0.35 sec
WAITRACK: LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
          CALL WAITX
          IN SWITCH           ;rack-over still ?
          BIT SRKO,A
          JZ EXITRACK
          DCX H
          MOV A,H
          ORA L
	  JNZ WAITRACK

          LXI H,MBLK          ;blank out Hold state
          CALL OUTMUX3
	  LXI H,50            ;re-init display blanker = 0.15 sec
WAITBLKO: LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
	  CALL WAITX
          IN SWITCH           ;rack-over still ?
          BIT SRKO,A
          JZ EXITRACK
          DCX H
          MOV A,H
          ORA L
          JNZ WAITBLKO        ;loop for blanker cycle
          JMP RACKPTRN        ;loop for flasher cycle

EXITRACK: JMP MAIN

	  ENDIF

; Program input loop.

	  IF LEDISPLY
MPGM:     DB 'PGM'
M129:     DB ' 1--9'
	  ENDIF

	  IF LCDISPLY
MPGM:     DB 'PGM'
M129:     DB '  1--9'
	  ENDIF

PRGMIT:   PUSH PSW

	  LXI H,MPGM          ;display Program mode
	  CALL OUTMUX3
	  LXI H,M129          ;with mini menu prompt
	  CALL OUTMUX5

WAITPRGM: CALL INMUX          ;get Program key
	  JNC WAITPRGM

	  LDA KEYBUF
	  CPI PROGRAM
	  CZ MENUIT           ;Menu Selection ?

	  CPI POINT
	  CZ INTERNIT         ;Internal Selections ?

if SEQROPTN

	  CPI ONE
	  CZ CAM1IT           ;select Camera 1

	  CPI TWO
	  CZ SYNCIT           ;select Sync Camera 1 + 2

	  CPI THREE
	  CZ CAM2IT           ;select Camera 2

	  CPI FOUR
	  CZ FRAMEIT          ;Frame Count ?

	  CPI FIVE
	  CZ EXPIT            ;Exposure Time ?

	  CPI SIX
          CZ LAPSEIT          ;Lapse Time ?

          CPI SEVEN
          CZ COUNTIT          ;Total Count ?

	  CPI EIGHT
	  CZ VEXPIT           ;Variable Exp Time ?

	  CPI NINE
	  CZ VLAPSIT          ;Varaible Lapse Time ?

	  CPI ZERO
	  CZ SEQUENIT         ;Sequencer Operation ?

else	  ;NOT SEQROPTN

	  CPI ONE
	  CZ FRAMEIT          ;Frame Count ?

	  CPI TWO
	  CZ COUNTIT          ;Total Count ?

	  CPI THREE
	  CZ OUTFRMIT         ;Out Frame ?

	  CPI FOUR
	  CZ EXPIT            ;Exposure Time ?

	  CPI FIVE
	  CZ LAPSEIT          ;Lapse Time ?

	  CPI SIX
	  CZ VTRIGIT          ;Variable Trigger ?

	  CPI SEVEN
if GEAROPTN
	  CZ FPSPDIT          ;Frames per Sec ?
else
	  CZ VEXPIT           ;Variable Exp Time ?
endif

	  CPI EIGHT
	  CZ VLAPSIT          ;Varaible Lapse Time ?

	  CPI NINE
if GEAROPTN
	  CZ DRIVERIT         ;Drive Ratio ?
else
	  CZ OUTRIGIT	      ;Trigger Overide ?
endif

	  CPI ZERO
	  CZ WEDGEIT	      ;Wedge Exposures ?
endif

	  CPI MINUS
	  CZ DIRIT            ;Direction ?

	  POP PSW
	  RET

; Scroll through range of menu selections.

MENUIT:   PUSH PSW

	  CALL FRAMEIT
	  CALL DIRIT
	  CALL COUNTIT
	  CALL OUTFRMIT
	  CALL EXPIT
	  CALL LAPSEIT
	  CALL VTRIGIT
	  CALL VEXPIT
	  CALL VLAPSIT
*	  CALL OUTRIGIT
	  CALL WEDGEIT

if GEAROPTN
	  CALL DRIVERIT         ;Drive Ratio ?
	  CALL FPSPDIT          ;Frames per Sec ?
endif

	  POP PSW
	  RET

; Allow for internal programming selections.

	  IF LEDISPLY
MINT:     DB 'INT'
MIN2:     DB 'IN2'
M120:     DB ' 0--9'
	  ENDIF

	  IF LCDISPLY
MINT:     DB 'INT'
MIN2:     DB 'IN2'
M120:     DB '  0--9'
	  ENDIF

INTERNIT: PUSH PSW

	  LXI H,MINT          ;display Internal mode
	  CALL OUTMUX3
	  LXI H,M120          ;with mini menu prompt
	  CALL OUTMUX5

WAITINTE: CALL INMUX          ;get Internal Program key
	  JNC WAITINTE

	  LDA KEYBUF
	  CPI POINT           ;Internal Menu #2 ?
	  CZ IMENU2IT

	  CPI PROGRAM         ;Internal Menu ?
	  CZ IMENUIT

	  CPI ZERO
	  CZ VERIT            ;Version ?

	  CPI ONE
	  CZ STEPIT           ;Step Count ?

          CPI TWO
          CZ OPENIT           ;Shutter-Open Angle ?

          CPI THREE
          CZ ANGLEIT          ;Variable Shutter Angle ?

          CPI FOUR
	  CZ MINEXPIT         ;Minimum Exp Time ?

          CPI FIVE
          CZ MINSPDIT         ;Minimum Film Speed ?

          CPI SIX
          CZ WHPSPDIT         ;Whip-open Film Speed ?

          CPI SEVEN
          CZ SPEEDIT          ;Film Speed / Motor Speed ?

          CPI EIGHT
	  CZ RAMPIT           ;Acceleration Ramp ?

          CPI NINE
          CZ VTORQIT          ;Motor Torque Time ?

	  POP PSW
	  RET                 ;else return to main menu

; 2nd level Internal Menu.

IMENU2IT: PUSH PSW

	  LXI H,MIN2          ;display Internal mode
          CALL OUTMUX3
          LXI H,M120          ;with mini menu prompt
          CALL OUTMUX5

WAITINT2: CALL INMUX          ;get Internal Program key
          JNC WAITINT2

          LDA KEYBUF

	  CPI PROGRAM         ;Internal Menu ?
	  CZ IMEN2IT

	  POP PSW
	  RET

; Scroll through Internal Menu selection sequence.

IMENUIT:  PUSH PSW

          CALL VERIT
          CALL STEPIT
	  CALL OPENIT
	  CALL ANGLEIT
	  CALL MINEXPIT
	  CALL MINSPDIT
	  CALL WHPSPDIT
	  CALL SPEEDIT
	  CALL RAMPIT
	  CALL VTORQIT

	  POP PSW
	  RET

; Scroll through Internal menu #2.

IMEN2IT:  PUSH PSW

if GEAROPTN
	  CALL DRIVERIT         ;Drive Ratio ?
	  CALL FPSPDIT          ;Frames per Sec ?
endif

	  POP PSW
	  RET

; Get camera or projector data from memory buffers.

GETCAMPR: LDA CAMXSTAT		;projector ?
	  ORA A
          JNZ GETPROJR

          LHLD CAM1CNTR		;un-buffer camera counter
          SHLD COUNTER
          LHLD CAMFRMCT		;camera frame count
          SHLD FRAMECNT
          LHLD CAMABSCT		;absolute value count
          SHLD FRAMEABS
          LDA  CAMDIRST		;camera direction
          STA  DIRSTAT
          RET

GETPROJR: LHLD CAM2CNTR		;un-buffer projector counter
          SHLD COUNTER 
          LHLD PRJFRMCT		;projector frame count
          SHLD FRAMECNT
          LHLD PRJABSCT		;absolute value count
          SHLD FRAMEABS
          LDA  PRJDIRST		;projector direction
	  STA  DIRSTAT
          RET

; Put camera or projector data into memory buffers.

PUTCAMPR: LDA CAMXSTAT		;projector ?
          ORA A
          JNZ PUTPROJR

          LHLD COUNTER		;buffer camera counter
          SHLD CAM1CNTR
          LHLD FRAMECNT		;camera frame count
          SHLD CAMFRMCT
          LHLD FRAMEABS		;absolute value count
          SHLD CAMABSCT
          LDA  DIRSTAT		;camera direction
          STA  CAMDIRST
          RET

PUTPROJR: LHLD COUNTER		;buffer projector counter
	  SHLD CAM2CNTR
          LHLD FRAMECNT		;projector frame count
          SHLD PRJFRMCT
          LHLD FRAMEABS		;absolute value count
          SHLD PRJABSCT
          LDA  DIRSTAT		;projector direction
          STA  PRJDIRST
          RET

; Select Camera 1 only.

MCAM:     DB 'CAM'
MAUX:     DB 'AUX'
MSYN:     DB 'SYN'

CAM1IT:   PUSH PSW
          LXI H,MCAM
OUTAXIS1: CALL OUTMUX3

          MVI A,TRUE          ;camera 1 active
	  STA CAM1STAT
          MVI A,FALSE
          STA CAM2STAT

          STA CAMXSTAT

          CALL GETCAMPR       ;get camera 1 data from buffer

          LHLD COUNTER        ;display camera 1 counter
          CALL OUTNUMX

WAITCAM1: CALL INMUXST
          JZ WAITCAM1
          POP PSW
          RET

; Select Camera 2 only.

CAM2IT:   PUSH PSW
          LXI H,MAUX
OUTAXIS2: CALL OUTMUX3

          MVI A,FALSE
          STA CAM1STAT
          MVI A,TRUE          ;camera 2 active
          STA CAM2STAT

          STA CAMXSTAT

          CALL GETCAMPR       ;get camera 2 data from buffer

          LHLD COUNTER        ;display camera 2 counter
          CALL OUTNUMX

WAITCAM2: CALL INMUXST
          JZ WAITCAM2
          POP PSW
          RET

; Select Camera 1 + 2 Sync.

SYNCIT:   PUSH PSW
          LXI H,MSYN
          CALL OUTMUX3

          CALL GETCAMPR       ;get last selected camera data from buffer

          LHLD COUNTER        ;display camera counter
          CALL OUTNUMX

          MVI A,TRUE
          STA CAM1STAT        ;camera 1 active
          MVI A,TRUE
          STA CAM2STAT        ;camera 2 active

WAITSYNC: CALL INMUXST
          JZ WAITSYNC
          POP PSW
          RET

; Camera : Projector Sequencer Step : Skip Count Input.
; Both Camera : Projector Counters loaded.
; Option for changing Auxilairy axis step count increment.

	  IF SEQROPTN

MSEQ:     DB 'SEQ'
MTO:      DB '+TO'
MBY:      DB '+BY'

SEQUENIT: PUSH PSW

	  LXI H,MSEQ          ;prompt SEQ
          CALL OUTMUX3

	  LHLD STEPRCNT	      ;camera sequence step count
          CALL MODNUMX
          SHLD STEPRCNT
	  LDA KEYBUF
	  CPI PROGRAM	      ;Escape ?
	  JZ EXITSEQT
	  MOV A,H             ;if 0, then no sequencer
	  ORA L
	  STA SEQSTAT
	  JZ EXITSEQT

	  LXI H,MTO           ;prompt TO
	  CALL OUTMUX3

	  LHLD SKIPRCNT       ;printer sequence skip count
	  CALL MODNUMX
          SHLD SKIPRCNT
	  LDA KEYBUF
	  CPI PROGRAM	      ;Escape ?
	  JZ EXITSEQT
	  MOV A,H             ;if 0, then no sequencer
	  ORA L
	  STA SEQSTAT
	  JZ EXITSEQT

	  LXI H,MBY           ;prompt BY
	  CALL OUTMUX3

*	  LHLD REVLNCNT       ;plus auxiliary axis increments
	  LHLD AUXINCNT
	  SRLR H              ;... / 4 for fraction of 400 steps
          RARR L
          SRLR H
          RARR L
          CALL MODDEC
          DAD H               ;... * 4 for multiple of 400 steps
          DAD H
*	  SHLD REVLNCNT
	  SHLD AUXINCNT

EXITSEQT: POP PSW
          RET

	  ENDIF

; Frame Count input.
; (Any pending wedge sequence is cleared.)

MFRM:     DB 'FRM'

FRAMEIT:  PUSH PSW
          
          LXI H,MFRM          ;prompt FRM
          CALL OUTMUX3

          LHLD FRAMECNT       ;update frame count
          CALL MODNUMX
          SHLD FRAMECNT
          SHLD FRAMEABS

          CALL FRMTODIR       ;set direction
          SHLD FRAMEABS       ;set absolute value

          XRA A
          STA WDGSTAT         ;kill wedge
          STA ETMSTAT
          STA ABSSTAT

EXITFRM:  POP PSW
          RET

; Direction Forward / Reverse input.

	  IF LEDISPLY
MDR:      DB 'DIR'
MFOR:     DB ' FOR+'
MREV:     DB ' REV-'
	  ENDIF

	  IF LCDISPLY
MDR:      DB 'DIR'
MFOR:     DB ' FOR +'
MREV:     DB ' REV -'
	  ENDIF

DIRIT:    PUSH PSW
          CALL CURSRON        ;turn cursor on

LOOPDIRT: LXI H,MDR           ;display present direction
          CALL OUTMUX3
          CALL OUTDIR
          CALL OUTMUX5
          CALL CURSRADJ       ;flash cursor over + / - sign

WAITDIRT: CALL INMUX          ;loop for key input
          JNC WAITDIRT

	  LDA KEYBUF
	  CPI ENTER           ;'Enter' for completion ?
	  JZ EXITDIR
	  CPI PROGRAM         ;'Program' too ?
	  JZ EXITDIR
          CPI MINUS           ;'-' for negative ?
          JNZ WAITDIRT

          LDA DIRSTAT         ;toggle direction status
          CMA
          STA DIRSTAT
          LXI H,0             ;2's complement frame count
          LDED FRAMECNT
          XRA A
          DSBC DE
          SHLD FRAMECNT
          JMP LOOPDIRT

EXITDIR:  CALL CURSROFF       ;turn cursor off
          POP PSW
          RET

; Display forward or reverse direction.

OUTDIR:   LDA DIRSTAT
          ORA A
          JNZ OUTREV

          LXI H,MFOR          ;display 'Forward' status
          RET

OUTREV:   LXI H,MREV          ;display 'Reverse' status
          RET

; Out Frame Number --> Frame Count selection.
; (Any pending wedge sequence is cleared.)

MOUT:     DB 'END'

OUTFRMIT: PUSH PSW

          LXI H,MOUT            ;prompt OUT
          CALL OUTMUX3

          LHLD COUNTER          ;load current counter frame # as out frame #
          LDED FRAMECNT         ;+ current frame count
          ORA A
          DAD D
          CALL MODNUMX
          SHLD OUTFRAME

          LDA KEYBUF            ;Cancel ?
          CPI PROGRAM
          JZ EXITOUT

          LHLD FRAMECNT         ;buffer original frame count and direction
          SHLD FIXCNT

          LHLD OUTFRAME
          LDED COUNTER		;compute frame count
          XRA A
          DSBC DE		;... = out frame # - counter frame #
          SHLD FRAMECNT
          SHLD FRAMEABS

          CALL FRMTODIR         ;set direction
          SHLD FRAMEABS         ;plus absolute value

          XRA A
          STA WDGSTAT           ;kill wedge
          STA ETMSTAT
          CMA
          STA ABSSTAT           ;flag absolute

EXITOUT:  POP PSW
          RET

; Convert frame count to direction.
; Convert negative frame count to positive (absolute value).

FRMTODIR: XRA A               ;pre-set positive direction
          STA DIRSTAT
          BIT 7,H             ;negative number ?
          RZ
          MVI A,0FFH
          STA DIRSTAT         ;then reverse direction
          LXI D,0
          XCHG                ;2's complement positive number
          ORA A
          DSBC DE
          RET

; Convert direction to frame count.
; Convert positive frame count to negative (actual value).

DIRTOFRM: LDA DIRSTAT         ;reverse direction ?
          ORA A
          RZ
          XCHG                ;then 2's complement negative number
          LXI H,0
          ORA A
          DSBC DE
          RET

; Exposure Time input.
; Bottom out at minimum exposure time.
; (Any pending wedge sequence is cleared.)

MEXP:     DB 'EXP'

EXPIT:    PUSH PSW
          
          LXI H,MEXP
          CALL OUTMUX3

          LHLD EXPOSURE         ;update exposure time
          CALL MODDECX          ;modify
          SHLD EXPOSURE

          LDA KEYBUF            ;Cancel ?
          CPI PROGRAM
          JZ EXITEXP

          LDED MINEXPTM         ;compare with min exp time ?
          ORA A
          DSBC DE
          JNC SKIPMEXP
          LHLD MINEXPTM
          SHLD EXPOSURE

SKIPMEXP: CALL SPEEDCMP         ;compute film speed to match
          CALL RAMPCOMP         ;compute speed ramp table
          CALL TIMECOMP         ;compute exp time compensation

          XRA A
          STA WDGSTAT           ;kill wedge
          STA ETMSTAT

EXITEXP:  POP PSW
          RET     

; Lapse Time input.

MLPS:     DB 'LPS'

LAPSEIT:  PUSH PSW

          LXI H,MLPS
          CALL OUTMUX3

          LHLD LAPSE            ;update lapse time
          CALL MODDECX
          SHLD LAPSE

          POP PSW
          RET     

; Total Count input.

MCNT:     DB 'CTR'

COUNTIT:  PUSH PSW
          
          LXI H,MCNT
          CALL OUTMUX3

          LHLD COUNTER          ;update cummulative frame counter
          CALL MODNUMX
          SHLD COUNTER

          POP PSW
          RET

; Specify variable-length Output Trigger time.

	  IF VTRGOPTN

MVTR:     DB 'TRG'

VTRIGIT:  PUSH PSW

          LXI H,MVTR
          CALL OUTMUX3

	  LHLD TRIGTIME         ;update output trigger time
          CALL MODDECX
	  SHLD TRIGTIME
          MOV A,H               ;trigger time = 0 ?
          ORA L
          JNZ EXITVTRG
          LXI H,1
	  SHLD TRIGTIME         ;insure minimum trigger time = 0.01 sec

EXITVTRG: POP PSW
          RET

	  ENDIF

; Specify variable-length Torque time-out.
; Used for Motor High-Power Enable line.

	  IF VTRQOPTN

MTRQ:     DB 'TRQ'

VTORQIT:  PUSH PSW

          LXI H,MTRQ
          CALL OUTMUX3

          LHLD TORQTIME         ;update torque time
          CALL MODDECX
          SHLD TORQTIME
          MOV A,H               ;torque time = 0 ?
          ORA L
          JNZ EXITVTRQ
          LXI H,1
          SHLD TORQTIME         ;insure minimum torque time = 0.01 sec

EXITVTRQ: POP PSW
          RET

	  ENDIF

; Special Lapse Time Acceleration / Deceleration programming.
; Acceleration Frame Count input.

	  IF VLPSOPTN

MVLP:     DB 'VLP'
MVFR:     DB '+FR'

VLAPSIT:  PUSH PSW

          LXI H,MVLP
          CALL OUTMUX3

          LHLD ADJLAPSE       ;variable lapse time 
          CALL MODDECX
          SHLD ADJLAPSE
          MOV A,H
          ORA L
          STA TMRSTAT
          JZ EXITVLAP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITVLAP

          LXI H,MVFR
          CALL OUTMUX3
                              
          LHLD LPACLCNT       ;variable lapse time frame count
          CALL MODNUMX
          SHLD LPACLCNT
          MOV A,H
          ORA L
          STA TMRSTAT
          JZ EXITVLAP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITVLAP

          CALL LAPSOSET       ;compute and buffer variable lapse times

EXITVLAP: POP PSW
          RET

	  ENDIF

; Variable Exposure Time adjustment input.
; Bottom out at minimum exposure time.

	  IF VEXPOPTN

MVEX:     DB 'VEX'

VEXPIT:   PUSH PSW

          LXI H,MVEX
          CALL OUTMUX3

          LHLD ADJEXP         ;variable exposure time
          CALL MODDECX
          SHLD ADJEXP
          MOV A,H
          ORA L
          STA ETMSTAT
          JZ EXITVEXP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITVEXP

          LDED MINEXPTM       ;compare with min exp time ?
          ORA A
          DSBC DE
          JNC SKIPMVEX
          LHLD MINEXPTM
          SHLD ADJEXP

SKIPMVEX: LXI H,MVFR
          CALL OUTMUX3
                              
          LHLD EXACLCNT       ;variable exposure time frame count
          CALL MODNUMX
          SHLD EXACLCNT
          MOV A,H
          ORA L
          STA ETMSTAT
          JZ EXITVEXP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITVEXP

          CALL EXPSOSET       ;compute and buffer variable exp times

EXITVEXP: POP PSW
          RET

	  ENDIF

; Wedge Exposure Time adjustment input.
; Bottom out at minimum exposure time.
; Original exposure time and frame count are saved.
; Insure maximum exposure time within table = 64 seconds.

	  IF VEXPOPTN

MWDG:     DB 'WDG'

WEDGEIT:  PUSH PSW

          LXI H,MWDG
          CALL OUTMUX3

          LHLD ADJEXP         ;variable exposure time
          CALL MODDECX
          SHLD ADJEXP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITWDGT

          MOV A,H             ;0 var exp time ?
          ORA L
          STA ETMSTAT
          STA WDGSTAT
          JZ EXITWDGT
          LDED MINEXPTM       ;compare with min exp time ?
          ORA A
          DSBC DE
          JNC CHKMXWDG
          LHLD MINEXPTM
          SHLD ADJEXP
          JMP SKIPMWDG

CHKMXWDG: LHLD ADJEXP         ;compare with max exp time in table ?
          LXI D,6400+1
          ORA A
          DSBC DE
          JC SKIPMWDG
          LXI H,6400
          SHLD ADJEXP
          JMP SKIPMWDG

SKIPMWDG: MVI A,TRUE
          STA ETMSTAT         ;variable exposure sequence
          STA WDGSTAT         ;wedge sequence

          LHLD EXPOSURE       ;buffer original exp time
          SHLD FIXEXP
          LHLD FRAMECNT       ;plus original frame count
          SHLD FIXCNT

          MVI A,+1            ;acceleration phase
          STA ETMPHZE

          LXI H,12            ;load exp time buffer with wedge values
          SHLD EXPOSBUF
          LXI H,17
          SHLD EXPOSBUF+2
          LXI H,25
          SHLD EXPOSBUF+4
          LXI H,35
          SHLD EXPOSBUF+6
          LXI H,50
          SHLD EXPOSBUF+8
          LXI H,70
          SHLD EXPOSBUF+10
          LXI H,100
          SHLD EXPOSBUF+12
          LXI H,141
          SHLD EXPOSBUF+14
          LXI H,200
          SHLD EXPOSBUF+16
          LXI H,282
          SHLD EXPOSBUF+18
          LXI H,400
          SHLD EXPOSBUF+20
          LXI H,564
          SHLD EXPOSBUF+22
          LXI H,800
          SHLD EXPOSBUF+24
          LXI H,1128
          SHLD EXPOSBUF+26
          LXI H,1600
          SHLD EXPOSBUF+28
          LXI H,2256
          SHLD EXPOSBUF+30
          LXI H,3200
          SHLD EXPOSBUF+32
          LXI H,4512
          SHLD EXPOSBUF+34
          LXI H,6400
          SHLD EXPOSBUF+36
          LXI H,0
          SHLD EXPOSBUF+38
          LXI H,0
          SHLD EXPOSBUF+40

          LXI H,25              ;compare incremental exp time = 0.25 sec
          LDED ADJEXP           ;...to final exp time
          LXI B,3               ;init exp counter = 3 frames
COMPLOG:  DAD H                 ;double exp time (for log_2)
          INX B                 ;double update frame count (for log_2)
          INX B
          PUSH H
          ORA A
          DSBC DE               ;compare exp times...
          POP H
          JC COMPLOG            ;repeat until matched or past buffered time

          SBCD EXACLCNT         ;save buffer frame count
          SBCD FRAMECNT
          SBCD FRAMEABS
          PUSH B
          POP  H
          CALL DIRTOFRM         ;check direction
          SHLD FRAMECNT         ;insure actual value

EXITWDGT: POP PSW
          RET

	  ENDIF

; Variable Lapse Time computations.
; Uses Variable Film Speed computation routines
; and moves Lapse Time values into run-time buffer.

	  IF VLPSOPTN

LAPSOSET: LHLD LPACLCNT       ;non-0 variable lapse time count ?
          MOV A,H
          ORA L
          STA TMRSTAT         ;set/reset variable lapse time status
          RZ

          SHLD RAMPCNT        ;transfer lapse time count as ramp count

          MVI A,+1            ;pre-flag accelerating lapse times
          STA TMRPHZE
          LHLD LAPSE          ;transfer lapse time as low speed
          SHLD LOWSPD
          XCHG
          LHLD ADJLAPSE       ;transfer adjusted lapse time as high speed
          SHLD HIGHSPD
          ORA A
          DSBC DE
	  JNC LAPSDIFF        ;compare high lapse time > low lapse time ?
          LHLD ADJLAPSE
          SHLD LOWSPD         ;else swap adjusted lapse time as low speed
          SDED HIGHSPD        ;and swap original lapse time as high speed
          MVI A,-1            ;re-flag decelerating lapse times
          STA TMRPHZE

LAPSDIFF: CALL COMPDIFF       ;compute lapse times as if film speeds

          LHLD LPACLCNT       ;init buffer transfer count
          INX H
          INX H
          INX H
          MOV C,L
          MOV B,H
          LXI H,ACCLTBL1      ;transfer speed buffer
          LXI D,LAPSEBUF      ;... into lapse time buffer

LAPSLOOP: PUSH B              ;save count
          MOV C,M             ;load speed (2 bytes)
          INX H
          MOV B,M
          INX H
          SRLR B              ;scale down speeds / 8
          RARR C
          SRLR B
          RARR C
          SRLR B
          RARR C
          MOV A,C             ;save lapse time (2 bytes)
          STAX D
          INX D
          MOV A,B
          STAX D
          INX D
          POP B               ;repeat for all buffer count
          DCX B
          MOV A,B
          ORA C
          JNZ LAPSLOOP

          CALL MICROCHK       ;restore motor timing parameters
          CALL RAMPCOMP       ;re-compute and re-buffer motor step times
          RET

	  ENDIF

; Variable exposure time computations.
; Uses same ramp buffer technique as variable lapse time.
; Allow for minimum exposure time to be converted into maximum film speed.

	  IF VEXPOPTN

EXPSOSET: LHLD EXACLCNT       ;non-0 variable exposure time count ?
          MOV A,H
          ORA L
          STA ETMSTAT         ;set/reset variable exposure time status
          RZ

          SHLD RAMPCNT        ;transfer exposure time count as ramp count

          MVI A,+1            ;pre-flag accelerating exposure times
          STA ETMPHZE
          LHLD EXPOSURE       ;transfer exposure time as low speed
          SHLD LOWSPD
          XCHG
          LHLD ADJEXP         ;transfer adjusted exposure time as high speed
          SHLD HIGHSPD
          ORA A
          DSBC DE
	  JNC EXPSDIFF        ;compare high exposure time > low exposure time ?
          LHLD ADJEXP
          SHLD LOWSPD         ;else swap adjusted exposure time as low speed
          SDED HIGHSPD        ;and swap original exposure time as high speed
          MVI A,-1            ;re-flag decelerating exposure times
          STA ETMPHZE

EXPSDIFF: CALL COMPDIFF       ;compute exposure times as if film speeds

          LHLD EXACLCNT       ;init buffer transfer count
          INX H
          INX H
          INX H
          MOV C,L
          MOV B,H
          LXI H,ACCLTBL1      ;transfer speed buffer
          LXI D,EXPOSBUF      ;... into exposure time buffer

EXPSLOOP: PUSH B              ;save count
          MOV C,M             ;load speed (2 bytes)
          INX H
          MOV B,M
          INX H
          SRLR B              ;scale down speeds / 8
          RARR C
          SRLR B
          RARR C
          SRLR B
          RARR C
          MOV A,C             ;save exposure time (2 bytes)
          STAX D
          INX D
          MOV A,B
          STAX D
          INX D
          POP B               ;repeat for all buffer count
          DCX B
          MOV A,B
          ORA C
          JNZ EXPSLOOP

          LHLD EXPOSURE       ;buffer initial exp time
          PUSH H
          CALL MICROCHK       ;restore motor timing parameters
          LHLD HIGHSPD        ;get maximum exp time
          SHLD EXPOSURE
          LHLD MINSPEED       ;get minimum film speed
          SHLD SPEED
          CALL TIMECOMP       ;compute max exp time compensation for min speed

          LHLD LOWSPD         ;get minimum exp time
          SHLD EXPOSURE
          CALL SPEEDCMP       ;compute max film speed for min exp time
          CALL RAMPCOMP       ;re-compute and re-buffer motor step times
          POP H
          SHLD EXPOSURE       ;restore original exp time
          RET

	  ENDIF

; Speed Maximum of motor rotation.
; Selection of Speed changes Initial Ramp Table Address,
; which may also change Ramp Count if too long.
; Special case for Constant Speed = 0 Ramp count,
; where Ramp Table Pointer gets RAM address.

MSPD:     DB 'SPD'

SPEEDIT:  PUSH PSW
          
          LXI H,MSPD
          CALL OUTMUX3

          LHLD SPEED          ;display actual speed
          CALL MODDECX
          SHLD SPEED

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITSPD

          LHLD SPEED          ;compare film speed < minimum low speed ?
          LDED LOWSPDBF
          ORA A
          DSBC DE
          JNC SKPLOWSP
          XCHG                ;if lower, then bottom out at low speed
          SHLD SPEED

SKPLOWSP: CALL RAMPCOMP       ;compute ramp table
          CALL TIMECOMP       ;compute exp + lapse compensation times

EXITSPD:  POP PSW
          RET

; User Speed selection in terms of frames per second.

MFPS:     DB 'FPS'

FPSPDIT:  PUSH PSW
          
          LXI H,MFPS
          CALL OUTMUX3

          LDED SPEED          ;compute current frame-per-sec
          LHLD SPDRATIO       ;... = current speed * speed ratio
          MOV A,L
          CALL MULTIPLY
          SHLD FPSPEED

          LHLD FPSPEED        ;display frames-per-second speed
          CALL MODDECX
          SHLD FPSPEED

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITFPS

          LHLD FPSPEED        ;compute speed = fps / speed ratio
          LBCD SPDRATIO
          CALL FASTDIVD
          SDED SPEED

          LHLD SPEED          ;compare film speed < minimum low speed ?
          LDED LOWSPDBF
          ORA A
          DSBC DE
          JNC SKPLOWS2
          XCHG                ;if lower, then bottom out at low speed
          SHLD SPEED

SKPLOWS2: CALL RAMPCOMP       ;compute ramp table
          CALL TIMECOMP       ;compute exp + lapse compensation times

EXITFPS:  POP PSW
          RET


; Motor speed acceleration in user terms of fraction of revolution.
; Inter-relates with ramp count.

MACL:     DB 'ACL'

ACCELIT:  PUSH PSW

          LXI H,MACL
          CALL OUTMUX3

          LDA MICROST         ;micro-stepping ?
          ORA A
          JNZ COMPACL         ;then compute fraction of revolution
                              ;else presume 400 half-steps per rev

ACLEZ4:   LHLD RAMPABS        ;get ramp count
          SRLR H              ;convert to fraction of revolution
          RARR L
          SRLR H
          RARR L              ;... = ramp count / 4
          CALL MODDEC         ;... / 100 (in decimal)
          DAD H
          DAD H
          SHLD RAMPABS
          SHLD RAMPCNT

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITACLT

          CALL RAMPCOMP       ;compute ramp table

          JMP EXITACLT


COMPACL:  LHLD REVLNCNT       ;compute decimal revolution
          LXI  D,100
          CALL DIVIDE         ;... revolution count / 100
          PUSH B

          MOV  E,C            ;convert ramp count to fraction of revolution
          MOV  D,B
          LHLD RAMPABS
          CALL DIVIDE         ;... = ramp count / revolution count
          MOV  L,C
          MOV  H,B
          CALL MODDECX

          XCHG                ;re-convert fraction to ramp count
          POP  H
          MOV  A,L
          CALL MULTIPLY       ;... = fraction * revolution count
          SHLD RAMPABS
          SHLD RAMPCNT

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITACLT

          CALL RAMPCOMP       ;compute ramp table

EXITACLT: POP PSW
          RET

; Ramp Count Maximum of step time ramping.
; Ramp Count now indexes backwards from High Speed.
; Selection of Ramp Count does NOT change Speed.
; Special case for Constant Speed = 0 Ramp Count.

MRMP:     DB 'RMP'

RAMPIT:   PUSH PSW

          LXI H,MRMP
          CALL OUTMUX3

          LHLD RAMPABS        ;display desired ramp count
          CALL MODNUMX
          SHLD RAMPABS
          SHLD RAMPCNT

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITRMPT

          CALL RAMPCOMP       ;compute ramp table

EXITRMPT: POP PSW
          RET

; Step time determination.
; Step time fetched from ramp table for read only.

MTME:     DB 'TME'

TIMEIT:   PUSH PSW

          LXI H,MTME
          CALL OUTMUX3

          LHLD RAMPNTR        ;compute step time address
          LDED RAMPCNT
          DAD D               ;... = ramp table pointer + ramp count
          MOV A,M
          MOV L,A
          MVI H,0
          CALL OUTNUMX
          CALL WAITMUX

          POP PSW
          RET

; Exposure Time and Lapse Time compensation calculated according to
; Film Speed and Shutter Angle specifications.

TIMECOMP: LXI H,10000         ;compute lapse time compensation
          LDED SPEED
          CALL DIVIDE         ;... = 100 * 100 / film speed
          CALL ROUND
          SBCD LAPCOMP

          MVI A,100           ;compute shutter angle factor
          LDED EXPANGLE
          CALL MULTIPLY       ;... = 100 * decimal shutter angle
          LDED SPEED
          CALL DIVIDE         ;compute exposure time compensation
          CALL ROUND          
          SBCD EXPCOMP        ;... = 100 * angle factor / film speed
          RET

; Exposure Time --> Film Speed conversion.
; Automatically select film speed based on exposure time and shutter angle.
; Change over to time exposure mode at minimum film speed.
; Change over to time-exp film speed at minimum continuous exposure.

SPEEDCMP: CALL MICROCHK       ;get min speed data

          MVI A,100           ;compute shutter angle factor
          LDED EXPANGLE
          CALL MULTIPLY       ;... = 100 * decimal shutter angle
          LDED EXPOSURE
          CALL DIVIDE         ;compute film speed
          CALL ROUND          
          SBCD SPEED          ;... = 100 * angle factor / exposure time

          LHLD MINSPEED       ;compare to minimum film speed ?
          ORA A
          DSBC BC
          RC
          LHLD WHIPSPD        ;if less, then time-exposure at whip speed
          SHLD SPEED
          RET

; Speed --> Step-Time conversion.
; Microprocessor clock speed dependent scale constant K.
; Assume timing data OK for selected micro-stepping or half-stepping.
; Step-Time <-- Scale K / Speed.
; Slow division: BC <-- HL / DE.
; Fast division: DE <-- HL / BC.

CONVSPD:  XCHG           ;input speed <-- HL
          LHLD KSCALEBF
          CALL DIVIDE    ;compute
          CALL ROUND     ;step time <-- scale K / speed
          MOV H,B        ;output step time --> HL
          MOV L,C
          MOV A,H        ;8-bit step-time ?
          ORA A
          RZ
          LXI H,255      ;else max out 8-bit step-time
          RET

; Ramping step time computations buffered in ramp table.

RAMPCOMP: CALL MICROCHK  ;micro-step or half-step speed timing ?

          LHLD LOWSPDBF  ;transfer low speed
          SHLD LOWSPD
          LHLD SPEED     ;transfer high speed
          SHLD HIGHSPD
          LHLD RAMPABS   ;transfer ramp count
          SHLD RAMPCNT

          MOV A,L        ;0 ramp count ?
          ORA H
          JZ  RAMPCONS
          DCX H          ;1 ramp step ?
          MOV A,L
          ORA H
          JZ  RAMPCONS
          DCX H          ;2 ramp steps ?
          MOV A,L
          ORA H
          JZ  RAMPCONS
	  JNZ RAMPDIFF

RAMPCONS: LHLD SPEED     ;then compute constant speed
          CALL CONVSPD   ;... step time = K scale / speed
          MOV A,L
          STA STEPTIME   
          STA RAMPBUF    ;buffer constant-speed step time
          STA RAMPBUF+1
          STA RAMPBUF+2
          STA RAMPBUF+3
          STA RAMPBUF+4
          STA RAMPBUF+5
          STA RAMPBUF-1
          STA RAMPBUF-2
          STA RAMPBUF-3
          LXI H,RAMPBUF  ;point to constant-speed step-time buffer
          SHLD RAMPNTR
          LXI H,2        ;1-step ramp count for constant speed
          SHLD RAMPCNT
          SHLD RAMPRUN
          RET

RAMPDIFF: CALL COMPDIFF  ;compute ramp table of speed differences
          CALL BUFCOMP   ;buffer computed speeds into step times
          RET

; Integer speed increment computation.
; Scale up intermediate speeds by factor of 8.

COMPDIFF: LHLD HIGHSPD   ;compare high speed > low speed ?
          LDED LOWSPD
          XRA A
          DSBC DE
          JNC COMPDELT   ;if higher, then compute speed delta
          SDED HIGHSPD   ;else max out high speed = low speed
          LXI H,0
          SHLD DELTA     ;...and null out speed delta
          JMP COMPTABL

COMPDELT: LHLD HIGHSPD   ;compute speed difference
          DAD H          ;scale up high speed * 8
          DAD H
          DAD H
          LDED LOWSPD
          XCHG
          DAD H          ;scale up low speed * 8
          DAD H
          DAD H
          XCHG
          XRA A
          DSBC DE        ;... = high speed - low speed

          LBCD RAMPCNT
          DCX B
          CALL PREDIVD   ;compute speed increment (integer delta)
          CALL FASTDIVD
          SDED DELTA     ;... = (speed difference) / (ramp count - 1)
          
COMPTABL: LXIX ACCLTBL1  ;buffer pointer
          LBCD RAMPCNT   ;counter
          DCX B
          LHLD LOWSPD    ;initial speed
          DAD H          ;... scaled up * 8
          DAD H
          DAD H
          LDED DELTA     ;initial delta
          
COMPTIME: STX L,0        ;buffer incremental speeds
          STX H,1
          INXIX
          INXIX

          PUSH H
          PUSH B
          XCHG           ;re-compute incremental speed delta
          LHLD HIGHSPD   ;original high speed
          DAD H          ;... scaled up * 8
          DAD H
          DAD H
          XRA A
          DSBC DE        ;... = (high speed - current speed)
          JC TOPOFF
          CALL FASTDIVD  ;... / (remaining ramp count - 1)
          POP B
          POP H
          JMP INCRSPD

TOPOFF:   POP B
          POP H
          LXI D,0        ;null out speed delta
          LHLD HIGHSPD   ;top off at high speed
          DAD H          ;... scaled up * 8
          DAD H
          DAD H

INCRSPD:  DAD D          ;...speed <-- speed + delta
          DCX B          ;repeat for all ramp count
          MOV A,B
          ORA C
          JNZ COMPTIME
          
          STX L,0        ;buffer ultimate high speed
          STX H,1
          STX L,2
          STX H,3
          STX L,4
          STX H,5
          RET

; Buffer incremental speeds into step-times.
; Scale back down intermediate speeds by factor of 8.

BUFCOMP:  LXIX ACCLTBL1  ;speed buffer pointer
          LXIY ACCLTBL2  ;step-time buffer pointer
          LBCD RAMPCNT   ;ramp table counter
          
CONVTIME: LDX L,0        ;convert incremental speeds --> step-times
          LDX H,1
          SRLR H         ;scale down speeds / 8
          RARR L
          SRLR H
          RARR L
          SRLR H
          RARR L

          PUSH B
          CALL CONVSPD   ;compute step time
          POP B

          STY L,0        ;buffer 8-bit step time
          INXIY
          INXIX          ;next 16-bit speed
          INXIX

          DCX B          ;repeat for all ramp
          MOV A,B
          ORA C
          JNZ CONVTIME
          
          STY L,0        ;triple buffer high-speed step-time
          STY L,1
          STY L,2
          STY L,3

          LXIY ACCLTBL2  ;triple buffer low-speed step-time
          LDY L,0
          STY L,-1
          STY L,-2
          STY L,-3

          LXI H,ACCLTBL2 ;point to ramping step-time table
          SHLD RAMPNTR   
          LHLD RAMPCNT   ;transfer run-time ramp count
          SHLD RAMPRUN
          RET

; Step Count per revolution input.

MSTP:     DB 'STP'

STEPIT:   PUSH PSW

          LXI H,MSTP
          CALL OUTMUX3

          LHLD REVLNCNT       ;update revolution step count
          CALL MODNUMX
          SHLD REVLNCNT

          CALL MICROSET       ;micro-stepping ?
          CALL MICROCHK       ;micro-stepping...
          CALL OPENCOMP       ;compute open/closed step counts

          POP PSW
          RET     

; Shutter-Open step count input.

MOPN:     DB 'OPN'

OPENIT:   PUSH PSW
          
          LXI H,MOPN
          CALL OUTMUX3

          LHLD OPNANGLE       ;get open-shutter angle in decimal
          CALL MODDECX
          SHLD OPNANGLE

          CALL OPENCOMP       ;compute open-shutter step count

          POP PSW
          RET     

; Compute open-shutter step count from open-shutter angle.

OPENCOMP: LHLD REVLNCNT       ;compute open-shutter step count
          LXI D,100
          CALL DIVIDE         ;... = full-revolution step count / 100
          MOV D,B
          MOV E,C
          LDA OPNANGLE
          CALL MULTIPLY       ;... * open-shutter angle
          SHLD OPNSHCNT

          XCHG                ;compute close-shutter step count
          LHLD REVLNCNT       ;... = full-revolution step count
          XRA A
          DSBC DE
          SHLD CLOSECNT       ;... - open-shutter step count
          RET

; Variable shutter angle.
; Convert to decimal fraction of 360 degrees.

MANG:     DB 'SHR'

ANGLEIT:  PUSH PSW

          LXI H,MANG
          CALL OUTMUX3

          LHLD VARSHTR        ;get variable shutter angle in degrees
          CALL MODNUMX
          SHLD VARSHTR

          CALL VRSHCOMP       ;compute exposure factor

          POP PSW
          RET     

; Compute exposure factor from variable shutter angle.

VRSHCOMP: LHLD VARSHTR        
          XCHG
          MVI A,100           ;compute decimal shutter angle factor
          CALL MULTIPLY       ;... = 100 * shutter angle degrees
          LXI D,360
          CALL DIVIDE         ;... / 360
          CALL ROUND          
          SBCD EXPANGLE
          RET

; Minimum Exposure Time (for interlinked film speed).

MMEX:     DB 'MEX'

MINEXPIT: PUSH PSW

          LXI H,MMEX
          CALL OUTMUX3

          LHLD MINEXPTM       ;get min exp time
          CALL MODDECX
          SHLD MINEXPTM

          POP PSW
          RET     

; Minimum Film Speed (for time-exposure mode).

MMSP:     DB 'MSP'

MINSPDIT: PUSH PSW

          LXI H,MMSP
          CALL OUTMUX3

          LHLD MINSPEED       ;update min film speed
          CALL MODDECX
          SHLD MINSPEED

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITMSPD

          LDED MINSPDBF       ;compare min film speed < low motor speed ?
          ORA A
          DSBC DE
          JNC COMPMSPD
          XCHG                ;if lower, then bottom out at min low speed
          SHLD MINSPEED

COMPMSPD: CALL RAMPCOMP       ;re-compute speed ramp

EXITMSPD: POP PSW
          RET

; Whip-open Film Speed (for time-exposure mode).

MWSP:     DB 'WSP'

WHPSPDIT: PUSH PSW

          LXI H,MWSP
          CALL OUTMUX3

          LHLD WHIPSPD        ;update whip-open film speed
          CALL MODDECX
          SHLD WHIPSPD

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITWSPD

          LDED MINSPEED       ;compare whip film speed < min film speed ?
          ORA A
          DSBC DE
          JNC COMPWSPD
          XCHG                ;if lower, then bottom out at min speed
          SHLD WHIPSPD

COMPWSPD: CALL RAMPCOMP       ;re-compute speed ramp

EXITWSPD: POP PSW
          RET

; Motor Power enable / disable selection.
; Sense input from latched output line, active High.

	  IF POWROPTN

POWERKEY: SET ZERO

	  IF LEDISPLY
MPWR:     DB 'PWR'
MPWR0:    DB ' OFF-'
MPWR1:    DB '  ON+'
	  ENDIF

	  IF LCDISPLY
MPWR:     DB 'PWR'
MPWR0:    DB ' OFF -'
MPWR1:    DB '  ON +'
	  ENDIF

POWERIT:  PUSH PSW
          CALL CURSRON

LOOPPWRT: LXI H,MPWR          ;display motor power status
          CALL OUTMUX3
          LXI H,MPWR1
          CALL OUTMUX5
          CALL CURSRADJ

          IN MOTRCNTL         ;sense power down ?
          BIT MEN1,A
          JZ WAITPWRT

          LXI H,MPWR0
          CALL OUTMUX5
          CALL CURSRADJ

WAITPWRT: CALL INMUX          ;loop for key press
          JNC WAITPWRT

          LDA KEYBUF
          CPI ENTER
          JZ EXITPWR
          CPI PROGRAM
          JZ EXITPWR

          CPI MINUS           ;toggle power state ?
          JZ FLIPPWRT
          CPI POWERKEY
          JZ FLIPPWRT
          JMP WAITPWRT

FLIPPWRT: IN MOTRCNTL         ;actual power enable state ?
          BIT MEN1,A
          JNZ FLIPBACK

          CALL MOTORDC0       ;if enabled, then disable
          JMP LOOPPWRT

FLIPBACK: CALL MOTORNUL       ;if disabled, then re-enable
          JMP LOOPPWRT

EXITPWR:  CALL CURSROFF
          POP PSW
          RET

	  ENDIF

; Output Trigger Overide enable / disable selection.
; Sense input from latched output line, active Low.
; Use for Half-Step / Full-Step selection.

	  IF TRGXOPTN

TRIGXKEY: SET ZERO

	  IF LEDISPLY
MTRO:     DB 'TRX'
MTRO0:    DB ' OFF-'
MTRO1:    DB '  ON+'
	  ENDIF

	  IF LCDISPLY
MTRO:     DB 'TRX'
MTRO0:    DB ' OFF -'
MTRO1:    DB '  ON +'
	  ENDIF

OUTRIGIT: PUSH PSW
          CALL CURSRON

LOOPTROT: LXI H,MTRO          ;display output trigger status
          CALL OUTMUX3
          LXI H,MTRO0
          CALL OUTMUX5
          CALL CURSRADJ

          IN MOTRCNTL         ;sense output trigger ?
          BIT MTRG,A
          JZ  WAITTROT

          LXI H,MTRO1         ;update output trigger status
          CALL OUTMUX5
          CALL CURSRADJ

WAITTROT: CALL INMUX          ;loop for key press
          JNC WAITTROT

          LDA KEYBUF
          CPI ENTER
          JZ EXITTRO
          CPI PROGRAM
          JZ EXITTRO

          CPI MINUS           ;toggle output trigger state ?
          JZ FLIPTROT
          CPI TRIGXKEY
          JZ FLIPTROT
          JMP WAITTROT

FLIPTROT: IN MOTRCNTL         ;actual output trigger state ?
          BIT MTRG,A
          JZ  FLIPBKTR

	  CALL TRIGROFF       ;if enabled, then disable output trigger
          JMP LOOPTROT

FLIPBKTR: CALL TRIGRON        ;if disabled, then re-enable output trigger
          JMP LOOPTROT

EXITTRO:  CALL CURSROFF
          POP PSW
          RET

	  ENDIF

; Select Motor Drive Settings, for Camera or Projector.
; Camera = Bolex 16mm on 8:1 Drive Shaft.
; Projector = Bell+Howell 16mm on 5:1 or 6:1 Drive Gear Ratio.

          IF DRVROPTN

if GEAROPTN

DRIVEKEY: SET NINE

MDRV:     DB 'DRV'
MDRV0:    DB ' 8:1 -'
MDRV1:    DB ' 1:1 +'

else

DRIVEKEY: SET ZERO

          IF LEDISPLY
MDRV:     DB 'DRV'
MDRV0:    DB ' CAM-'
MDRV1:    DB ' PRJ+'
          ENDIF

          IF LCDISPLY
MDRV:     DB 'DRV'
MDRV0:    DB ' CAM -'
MDRV1:    DB ' PRJ +'
	  ENDIF
endif

DRIVERIT: PUSH PSW
          CALL CURSRON

LOOPDRVT: LXI H,MDRV          ;display motor drive status
          CALL OUTMUX3
          LXI H,MDRV0
          LDA DRVRSTAT        ;camera or projector drive ?
          ORA A
          JZ  OUTDRVIT
          LXI H,MDRV1         ;update motor drive status
OUTDRVIT: CALL OUTMUX5
          CALL CURSRADJ

WAITDRVT: CALL INMUX          ;loop for key press
          JNC WAITDRVT

          LDA KEYBUF
          CPI ENTER
	  JZ EXITDRV
          CPI PROGRAM
          JZ EXITDRV

          CPI MINUS           ;toggle motor drive state ?
          JZ FLIPDRVT
          CPI DRIVEKEY
          JZ FLIPDRVT
          JMP WAITDRVT

FLIPDRVT: LDA DRVRSTAT        ;toggle motor drive status
          CMA
          STA DRVRSTAT
          JMP LOOPDRVT

EXITDRV:  CALL CURSROFF
          CALL RATIOSET       ;set drive ratio parameters
          CALL OPENCOMP       ;compute open/closed step counts
          CALL RAMPCOMP       ;re-compute speed ramp table
          POP PSW
	  RET

; Motor Drive Ratio parameters, for Camera or Projector.

RATIOSET: LDA DRVRSTAT        ;drive ratio for camera or projector ?
          ORA A
          JNZ PRJRATIO

if GEAROPTN
          LXI H,8             ;camera drive at 8:1
          SHLD FRMRATIO
          LXI H,8
          SHLD SPDRATIO
          LXI H,300           ;speed at 8:1
          SHLD SPEED
          LXI H,2400
          SHLD FPSPEED

          LXI H,200
          SHLD RAMPABS        ;Bolex 8:1 ramp
          SHLD RAMPCNT
          LXI H,50
	  SHLD REVLNCNT       ;for frame counting only at 8:1
          MVI A,10
          STA TMRDIVBF        ;CTC1 divider
          MVI A,5
          STA TMRMLTBF        ;CTC2 multiplier

          LXI H,0             ;no time exposures at all
          SHLD EXPOSURE
          SHLD MINEXPTM
          SHLD LAPSE
          XRA A
          STA EXPSTAT
          STA LAPSTAT

          MVI A,TRUE
          STA SWITMASK        ;do not check for Home switch

          RET

PRJRATIO: LXI H,1             ;camera drive at 1:1
          SHLD FRMRATIO
          SHLD SPDRATIO
          LXI H,DSPEED
          SHLD SPEED
          SHLD FPSPEED

          LXI H,DRAMPCNT
          SHLD RAMPABS        ;Bolex 1:1 ramp
          SHLD RAMPCNT
          LXI H,400
          SHLD REVLNCNT       ;for frame counting only at 1:1
	  MVI A,10
          STA TMRDIVBF        ;CTC1 divider
          MVI A,40
          STA TMRMLTBF        ;CTC2 multiplier

          LXI H,DEXPTIME      ;re-init default exposure times
          SHLD EXPOSURE
          SHLD MINEXPTM

          MVI A,FALSE
          STA SWITMASK        ;OK to check for Home switch

          RET

else      ; drive ratio parameters for Goerge Coates

          LXI H,8             ;camera drive at 8:1
          SHLD FRMRATIO
          LXI H,8
          SHLD SPDRATIO
          LXI H,300           ;speed at 8:1
          SHLD SPEED
          LXI H,2400
          SHLD FPSPEED
          LXI H,1200
          SHLD RAMPABS        ;Bolex ramp
          SHLD RAMPCNT
          LXI H,250
	  SHLD REVLNCNT       ;for frame counting only at 8:1
          MVI A,50
          STA TMRDIVBF        ;CTC1 divider
          MVI A,5
          STA TMRMLTBF        ;CTC2 multiplier
          RET

PRJRATIO: LXI H,5             ;projector drive at 6:1
          SHLD FRMRATIO
          LXI H,6
          SHLD SPDRATIO
          LXI H,400           ;speed at 6:1
          SHLD SPEED
          LXI H,2400
          SHLD FPSPEED
          LXI H,2400
          SHLD RAMPABS        ;Bell+Howell ramp
          SHLD RAMPCNT
          LXI H,400
          SHLD REVLNCNT       ;for frame counting only at 6:1
	  MVI A,100
          STA TMRDIVBF        ;CTC1 divider
          MVI A,4
          STA TMRMLTBF        ;CTC2 multiplier
          RET
endif

          ENDIF

; Version identification.

MVER:     DB 'VER'

VERIT:    PUSH PSW

          LXI H,MVER
          CALL OUTMUX3

          LXI H,VERSION       ;display version number
          CALL OUTDECX
          CALL WAITMUX

          POP PSW
          RET

; Run-time stop-motion motor operation.
; Lapse Time clocked according to real-time clock.
; Motor Enable Time-Out on trailing edge of each complete frame.
; CTC3 used for real-time clock, since CTC2 dedicated for baud rate clock.

MRUN:     DB 'RUN'
MHLD:     DB 'HLD'
MBLK:     DB '   '

RUNIT:    LXI H,MRUN          ;display Run mode
          SHLD MSGBUF3
          CALL OUTLED3        ;local only

          LHLD COUNTER        ;display total frame count
          CALL OUTNUM

	  XRA A               ;clear run-time keypad status
          STA KEYSTAT
          STA KEYBUF

          LHLD FRAMEABS       ;0 Frame Count ?
          MOV A,H
          ORA L
          RZ

          LHLD FRAMEABS       ;transfer run-time frame count
          SHLD RUNFRAME

          DI
	  CALL INITCLOK       ;re-init real-time clock (uses CTC3)
          EI

	  LDA SEQSTAT         ;Sequencer ?
          ORA A
          CNZ INITSEQ         ;then init sequencer variables

if GEAROPTN

          LDA FRMRATIO        ;what is drive frame ratio ?
          CPI 1
          JZ  SKIPSTOP        ;if 1:1, then continue
          XRA A
          STA EXPSTAT         ;else clear exp time and lapse time
          STA ETMSTAT
          STA LAPSTAT
          STA TMRSTAT
          CMA                 ;else ignore Home switch
          STA SWITMASK
SKIPSTOP:

endif

	  LHLD REVLNCNT       ;compute shutter-closed step count
          LDED OPNSHCNT
          SDED RUNOPEN
          XRA A
          DSBC DE
          SHLD CLOSECNT       ;... = revolution count - open count
          SHLD RUNCLOSE

          LDA DIRSTAT         ;direction ?
          ORA A
          JZ COMPEXP
          SHLD RUNOPEN        ;if reverse, then swap step counts
          SDED RUNCLOSE

COMPEXP:  LDA ETMSTAT         ;variable exposure time ?
          ORA A
          CNZ EXPSOCHK

          LDA ETMSTAT         ;compute initial variable exposure time ?
          ORA A
	  CNZ EXPSOCMP

          CALL ACOMPEXP       ;adjust exp time

COMPLAP:  LDA TMRSTAT         ;variable lapse time ?
          ORA A
          CNZ LAPSOCHK

          CALL ACOMPLAP       ;adjust lapse time

COMPRUN:  LDA LAPSTAT         ;lapse time ?
          ORA A
          JNZ PRUNLOOP
          LDA TMRSTAT         ;variable lapse time ?
          ORA A
          JNZ PRUNLOOP
          LDA EXPSTAT         ;exposure time ?
          ORA A
          JNZ PRUNLOOP
          LDA ETMSTAT         ;variable exp time ?
	  ORA A
          JNZ PRUNLOOP
	  LDA SEQSTAT         ;sequencer ?
          ORA A
          JNZ PRUNLOOP
          LHLD RUNFRAME       ;single frame ?
          DCX H
          MOV A,H
          ORA L
          JZ PRUNLOOP         ;then run stop-motion
          JNZ CONTLOOP        ;else run continuous motion

PRUNLOOP: LHLD REALTIME       ;mark real time for 1st trigger
          SHLD MARKTIME

	  IF PRETRGOP

	  CALL TRIGRON        ;fire output trigger prior to 1st single frame

	  LHLD TRIGTIME       ;load output trigger pre-exposure delay
	  SHLD WAITIME

WAITPREX: CALL PRECHECK       ;quick check for key press
	  LDED TRIGTIME       ;compare trigger time in real time ?
	  LHLD MARKTIME
	  DAD D
	  XCHG
	  LHLD REALTIME
	  XRA A
	  DSBC DE             ;... trigger time + marked time < real time
	  JC WAITPREX

	  ENDIF

RUNLOOP:  LHLD REALTIME       ;mark present real-time
	  SHLD MARKTIME
	  LXI H,0             ;zero present real-time
	  SHLD REALTIME

	  IF PRETRGOP
	  CALL TRIGRON        ;fire output trigger
	  ENDIF

	  LDA SEQSTAT         ;sequence camera or projector ?
	  ORA A
	  CNZ SEQUENCR        ;select camera or projector

	  LHLD REVLNCNT       ;pre-transfer full revolution step count
	  SHLD STEPCNT

	  LDA SEQSTAT         ;sequencer ?
	  ORA A
	  CNZ SEQUOCHK        ;overide step count if sequencer ?

	  LDA EXPSTAT         ;exposure time ?
	  ORA A
	  JZ SKIPEXP

	  LHLD RUNOPEN        ;then re-transfer shutter-open step count
	  SHLD STEPCNT

	  CALL MOTORON        ;motor control signals on

	  CALL INITMOTR       ;run motor to shutter-open position

	  MVI A,TRUE          ;insure switch mask off for time exposure
	  STA SWITMASK

	  LDA WDGSTAT         ;wedge exposure sequence ?
	  ORA A
	  JNZ SKPFLKEX
	  LHLD MSGBUF3        ;display Run mode
	  CALL OUTLED3        ;local only
	  LHLD COUNTER        ;display updated total frame count
	  CALL OUTNUM

SKPFLKEX: LDA WDGSTAT         ;wedge exposure sequence ?
	  ORA A
	  JZ WAITOPEN
	  LXI H,MWDG          ;then display Wedge mode
	  CALL OUTLED3        ;local only
	  LHLD EXPOSURE       ;plus current exposure time
	  CALL OUTDEC

WAITOPEN: CALL PRECHECK       ;quick check for key press
	  LDA MOTROVER        ;wait until motor over ?
	  ORA A
	  JNZ WAITOPEN

	  LHLD REALTIME       ;mark time when time-exposure pauses
	  SHLD MARKTIME

	  LHLD RUNEXP         ;transfer exposure time count
	  SHLD WAITIME

WAITEXP:  CALL PRECHECK       ;quick check for key press

	  IF POSTRGOP
	  LDED TRIGTIME       ;compare trigger time in real time ?
	  LHLD REALTIME
	  XRA A
	  DSBC DE             ;... trigger time < present real time
	  CNC TRIGRON         ;then fire post-exposure trigger
	  ENDIF

	  LDED RUNEXP         ;compare exposure time in real time ?
	  LHLD MARKTIME
	  DAD D
	  XCHG
	  LHLD REALTIME
	  XRA A
	  DSBC DE             ;... exp time + marked time < present real time
	  JC WAITEXP

	  LHLD RUNCLOSE       ;transfer shutter-closed step count
	  SHLD STEPCNT

	  MVI A,FALSE
	  STA SWITMASK        ;Home switch mask active now

SKIPEXP:  CALL MOTORON        ;motor control signals on

	  CALL INITMOTR       ;run motor to shutter-closed position

WAITOVER: CALL UPDTCNTR       ;update total frame counter

	  LDA WDGSTAT         ;wedge exposure sequence ?
	  ORA A
	  JNZ SKPFLKHM
	  LHLD MSGBUF3        ;display Run mode
	  CALL OUTMUX3        ;local + remote
	  LHLD COUNTER        ;display updated total frame count
	  CALL OUTNUMX

SKPFLKHM: LDA WDGSTAT         ;wedge sequence ?
	  ORA A
	  JZ LOOPOVER
	  LXI H,MWDG          ;then display WDG mode
	  CALL OUTMUX3        ;local + remote
	  LHLD EXPOSURE       ;with current exposure time
	  CALL OUTDECX

LOOPOVER: CALL PRECHECK       ;check for run-time interruption ?
	  CALL CHECKPT

	  IF POSTRGOP
	  LDED TRIGTIME       ;compare trigger time in real time ?
	  LHLD REALTIME
	  XRA A
	  DSBC DE             ;... trigger time < present real time
	  CNC TRIGRON         ;then fire post-exposure trigger
	  ENDIF

	  LDA MOTROVER        ;wait til motor over ?
	  ORA A
	  JNZ LOOPOVER

	  IF POSTRGOP
	  CALL TRIGROFF       ;turn off output trigger signal
	  ENDIF

	  LDA SEQSTAT         ;alternate motor sequencer active ?
	  ORA A
	  JZ SKIPTORQ

WAITTORQ: CALL PRECHECK       ;run-time interruption ?
	  CALL CHECKPT
	  LDA TORQOVER
	  ORA A
	  JNZ WAITTORQ	      ;wait til torque time-out over ?
SKIPTORQ:
	  LDA ETMSTAT         ;compute variable exposure time ?
	  ORA A
	  CNZ EXPSOCMP

	  LDA TMRSTAT         ;compute variable lapse time ?
	  ORA A
	  CNZ LAPSOCMP

	  LDA LAPSTAT         ;lapse time ?
	  ORA A
	  JZ SKIPLAPS

	  LHLD RUNFRAME       ;last single frame ?
	  DCX H
	  MOV A,H
	  ORA L
	  JZ SKIPLAPS

	  IF PRETRGOP
	  LHLD TRIGTIME       ;compare trigger time > lapse time ?
	  LDED RUNLAPSE
	  XRA A
	  DSBC DE
	  JNC WAITLAPS        ;if longer, then skip trigger time-out

	  CALL TRIGROFF       ;turn off output trigger signal
	  ENDIF

WAITLAPS: CALL PRECHECK       ;run-time interruption ?
	  CALL QSTATPT        ;quick status display ?
	  CALL CHECKPT        ;or run-time hold ?
	  LDA LAPSTAT         ;run-time lapse time interruption ?
	  ORA A
	  JZ SKIPLAPS

	  LDED RUNLAPSE       ;compare lapse time in real time ?
          LHLD REALTIME
          XRA A
          DSBC DE             ;... adjusted lapse time < present real time
	  JC WAITLAPS

	  IF PRETRGOP
	  CALL TRIGRON        ;re-fire output trigger prior to Nth frame
	  ENDIF

WAITLAPX: CALL PRECHECK       ;run-time interruption ?
	  CALL QSTATPT        ;quick status display ?
          CALL CHECKPT        ;or run-time hold ?
          LDA LAPSTAT         ;run-time lapse time interruption ?
          ORA A
          JZ SKIPLAPS

          LDED LAPSE          ;compare lapse time in real time ?
          LHLD REALTIME
          XRA A
          DSBC DE             ;... full lapse time < present real time
          JC WAITLAPX

SKIPLAPS: LDA SEQSTAT         ;sequencer operation ?
          ORA A
          JZ SKIPSEQ

          CALL UPDTSEQR       ;update sequencer run-time counters

          LDA PROJSTAT        ;count projector frames during sequence ?
          MOV B,A
          LDA CNTRSTAT
          XRA B               ;...(camera & camera) or (projector & projector)
          JNZ RUNLOOP

SKIPSEQ:  LHLD RUNFRAME       ;frame count over ?
          DCX H
          SHLD RUNFRAME
          MOV A,H
          ORA L
          JNZ RUNLOOP

          LDA ABSSTAT         ;absolute frame count overide ?
          ORA A
          JZ POSTWDG
          LHLD FIXCNT         ;then re-load frame count
	  SHLD FRAMECNT
          SHLD FRAMEABS
          CALL FRMTODIR       ;with direction
          SHLD FRAMEABS

POSTWDG:  LDA WDGSTAT         ;variable exposure time wedge ?
          ORA A
          JZ SKIPFVEX
          LHLD FIXEXP         ;then re-load fixed exposure time
          SHLD EXPOSURE
          CALL SPEEDCMP
          CALL RAMPCOMP
          CALL TIMECOMP
          LHLD FIXCNT         ;re-load frame count
          SHLD FRAMECNT
          SHLD FRAMEABS
          CALL FRMTODIR       ;direction ?
          SHLD FRAMEABS

SKIPFVEX: XRA A               ;nullify variable timer timing
	  STA TMRSTAT
          STA ETMSTAT
          STA WDGSTAT
          STA ABSSTAT

	  CALL TRIGROFF       ;turn off output trigger signal

          CALL STOPWAIT       ;turn off general timer CTC3

          LDA SEQSTAT
          ORA A
          CNZ EXITSEQR        ;exit sequencer

	  RET

; Continuous motion run-time sequence.
; Note run-time frame counters are updated within interrupt routines.

CONTLOOP: LXI H,MRUN          ;display Run mode
          CALL OUTMUX3        ;local + remote

          XRA A
          STA SWITMASK        ;Home switch mask active
          STA HOLDSTAT        ;Hold status inactive

          LHLD REVLNCNT       ;transfer full revolution count per frame
          SHLD STEPCNT

          LHLD RUNFRAME       ;transfer and adjust run-time frame count
          DCX H
          MOV A,H             ;just 1 lousy frame ? (or 1 frame more ??)
          ORA L
          JZ PRUNLOOP         ;then go to single frame loop
          SHLD RUNFRAME       ;else save for continuous frame loop

	  CALL TRIGRON        ;fire output trigger while motor running

	  IF PRETRGOP

	  LHLD TRIGTIME       ;load output trigger pre-exposure delay
	  SHLD WAITIME

	  CALL INITWAIT       ;run trigger time delay

WAITPRCN: CALL PRECHECK       ;quick check for key press
          LDA TIMROVER        ;wait until pre-exposure trigger over ?
          ORA A
	  JNZ WAITPRCN

	  ENDIF

          CALL MOTORON        ;enable motor control signals

          CALL INITCONT       ;initialize continuous-running interrupts


WAITHOME: LHLD COUNTER        ;display pre-updated counter
          CALL OUTNUM         ;local
          CALL OUTEOLN        ;remote
LOOPHOME: CALL PRECHECK       ;check for key press ?
          CALL CHKCONT        ;check for Run-time interruption ?
          LDA HOMEOVER        ;wait until motor home ?
          ORA A
          JNZ LOOPHOME

	  XRA A               ;reset home status
          CMA
          STA HOMEOVER

          LHLD RUNFRAME       ;update revolution counter
          MOV A,H
          ORA L
          JNZ WAITHOME

WAITLAST: LHLD COUNTER        ;update last frame
          CALL OUTNUM         ;local
          CALL OUTEOLN        ;remote
LOOPLAST: LDA HOMEOVER        ;wait until motor home ?
          ORA A
          JNZ LOOPLAST
          XRA A               ;reset home status
          CMA
          STA HOMEOVER

	  LDA MOTROVER        ;wait until last revolution
	  ORA A
          JNZ WAITLAST

	  CALL TRIGROFF       ;turn off output trigger signal

          LXI H,NULLINT       ;CTC interrupt counts last frame
          SHLD INTCTCV3
          LHLD COUNTER
          CALL OUTNUM

          LDA HOLDSTAT        ;Hold state pause ?
          ORA A
          CNZ RERUNPT         ;then wait for further instructions
          LDA HOLDSTAT        ;Hold state re-run ?
          ORA A
          JNZ CONTLOOP        ;then re-run remaining sequence

          LDA ABSSTAT         ;absolute frame count overide ?
          ORA A
          RZ
	  LHLD FIXCNT         ;then re-load frame count
          SHLD FRAMECNT
          SHLD FRAMEABS
          CALL FRMTODIR       ;with direction
          SHLD FRAMEABS

          RET

; Update run-time total frame counter according to direction.
; Update individual counters #1 and #2 for either Sync or Sequencer mode.

UPDTCNTR: LDA DIRSTAT         ;direction ?
          ORA A
          JNZ UPDTREV

          LHLD COUNTER        ;increment for forward
          INX H
          SHLD COUNTER

          LDA CAM1STAT        ;camera 1 forward ?
	  ORA A
          JZ UPDTFWD2
          LHLD CAM1CNTR
          INX H
          SHLD CAM1CNTR
UPDTFWD2: LDA CAM2STAT        ;camera 2 forward ?
          ORA A
          RZ
          LHLD CAM2CNTR
          INX H
          SHLD CAM2CNTR
          RET

UPDTREV:  LHLD COUNTER        ;decrement for reverse
          DCX H
          SHLD COUNTER

          LDA CAM1STAT        ;camera 1 reverse ?
          ORA A
          JZ UPDTREV2
          LHLD CAM1CNTR
          DCX H
          SHLD CAM1CNTR
UPDTREV2: LDA CAM2STAT        ;camera 2 reverse ?
	  ORA A
	  RZ
	  LHLD CAM2CNTR
	  DCX H
	  SHLD CAM2CNTR
	  RET

; Sequencer run-time routines.

	  IF SEQROPTN

; Sequencer run-time preparation routine.

INITSEQ:  LDA CAMXSTAT        ;transfer dual axis status
	  STA PROJSTAT

	  LDA PROJSTAT        ;projector only overide ?
	  STA CNTRSTAT        ;duplicate for counting projector frames

	  LHLD STEPRCNT       ;transfer camera step printer count
	  SHLD RUNSTEPR
	  XCHG
	  LHLD SKIPRCNT       ;transfer projector skip printer count
	  SHLD RUNSKIPR
	  MOV A,D
	  ORA E
	  ORA H
	  ORA L
	  STA SEQSTAT         ;non-zero counters --> sequencer operation
	  JZ SKIPSWAP
	  CALL PUTCAMPR
	  XRA A
	  STA PROJSTAT        ;if sequencer, then start with camera
	  STA CAMXSTAT        ;ditto
	  STA CAM2STAT
	  CMA
	  STA CAM1STAT
	  CALL GETCAMPR       ;...and load camera data accordingly

SKIPSWAP: RET

; Sequencer exit routine.

EXITSEQR: LDA SEQSTAT         ;clean up sequencer stuff ?
          ORA A
          RZ

	  LDA CNTRSTAT        ;restore pre-run camera / projector status
          STA PROJSTAT
	  STA CAMXSTAT        ;ditto

          CALL GETCAMPR       ;...plus data variables

          RET

; Camera : Projector sequencer subroutine.

SEQUENCR: LDA PROJSTAT		;camera or projector ?
          ORA A
          JNZ SEQPROJ

SEQCAMRA: LHLD RUNSTEPR		;check camera step counter
          MOV A,H		;camera over ?
          ORA L
          RNZ

          LHLD STEPRCNT		;then re-load camera step counter
          SHLD RUNSTEPR
          LHLD SKIPRCNT		;and load projector skip counter
          SHLD RUNSKIPR
          MVI A,TRUE		;and toggle to projector sequence
          STA PROJSTAT
	  STA CAMXSTAT
	  STA CAM2STAT
	  CMA
	  STA CAM1STAT
	  LXI H,MAUX
	  SHLD MSGBUF3
	  CALL OUTLED3
	  XRA A			;zero out time exposure
	  STA EXPSTAT
	  LHLD COUNTER		;save camera frame counter
*         SHLD CAMRCNTR
	  SHLD CAM1CNTR
*         LHLD PROJCNTR		;load projector frame counter
	  LHLD CAM2CNTR
	  SHLD COUNTER
	  LDA PRJDIRST		;load projector direction
	  STA DIRSTAT
	  RET

SEQPROJ:  LHLD RUNSKIPR		;check projector skip counter
	  MOV A,H		;projector over ?
	  ORA L
	  RNZ

	  LHLD SKIPRCNT		;then re-load projector skip counter
	  SHLD RUNSKIPR
	  LHLD STEPRCNT		;and load camera step counter
	  SHLD RUNSTEPR
	  MVI A,FALSE		;and toggle back to camera sequence
	  STA PROJSTAT
	  STA CAMXSTAT
	  STA CAM2STAT
	  CMA
	  STA CAM1STAT
	  LXI H,MCAM
	  SHLD MSGBUF3
	  CALL OUTLED3
	  LHLD RUNEXP		;re-load time exposure status, if any
	  MOV A,H
	  ORA L
	  STA EXPSTAT
	  LHLD COUNTER		;save projector frame counter
*         SHLD PROJCNTR
	  SHLD CAM2CNTR
*         LHLD CAMRCNTR		;load camera frame counter
	  LHLD CAM1CNTR
	  SHLD COUNTER
	  LDA CAMDIRST		;load camera direction
	  STA DIRSTAT
	  RET

; Update sequencer counters here at end of single-frame cycle.

UPDTSEQR: LDA PROJSTAT		;camera over or projector over ?
	  ORA A
	  JNZ UPDTPROJ

	  LHLD RUNSTEPR		;update camera step counter
	  DCX H
	  SHLD RUNSTEPR
	  LHLD COUNTER
*         SHLD CAMRCNTR
	  SHLD CAM1CNTR
	  RET

UPDTPROJ: LHLD RUNSKIPR		;update projector skip counter
	  DCX H
	  SHLD RUNSKIPR
	  LHLD COUNTER
*         SHLD PROJCNTR
	  SHLD CAM2CNTR
	  RET

; Check how Sequencer uses step counts for camera or projector.

SEQUOCHK: LDA SEQSTAT         ;sequencer active ?
	  ORA A
	  RZ
*	  LXI H,DREVLNCN      ;pre-load camera step count = 400
	  LHLD REVLNCNT       ;pre-load camera step count
	  SHLD STEPCNT
	  LDA PROJSTAT        ;projector active ?
	  ORA A
	  RZ
*	  LHLD REVLNCNT       ;if so, then re-load with custom step count
	  LHLD AUXINCNT       ;if so, then re-load with custom step count
	  SHLD STEPCNT
	  RET

          ELSE

INITSEQ:  RET

EXITSEQR: RET

SEQUENCR: RET

UPDTSEQR: RET

SEQUOCHK: RET


	  ENDIF               ;SEQROPTN

; Check-Point for run-time key press.
; If key pressed, then key is input quickly and buffered for later reading.

PRECHECK: CALL INMUXST        ;key press at all ?
	  STA KEYSTAT         ;then buffer key press status
	  RZ                  ;...no

          CALL INKEYST        ;keypad ?
          ORA A               ;(save Z-flag, clear C-flag)
          CNZ  INQUIKEY       ;genuine key ? (quick key input)
          RC                  ;...yes key

          CALL INSIOST        ;serial line ?
          ORA A               ;(save Z-flag, clear C-flag)
          CNZ INCHAR          ;then get character-as-key from SIO port
          RC                  ;...yes char

          XRA A               ;else clear key press status
          STA KEYSTAT
          RET

; Check-Point for run-time interruption.
; Check-Point for single-frame run-time operation.
; Flash Hold state locally on LED display while looping for key press.
; Allow output trigger time-out.

CHECKPT:  LDA KEYSTAT         ;key pressed at all ?
          ORA A
          RZ
          XRA A               ;re-clear key status for next time
          STA KEYSTAT

          LDA KEYBUF          ;Run key interruption ?
          CPI RUN
          RNZ

WAITCHEC: LDA MOTROVER        ;wait until running motor is over ?
          ORA A
          JNZ WAITCHEC

	  CALL TRIGROFF       ;turn off output trigger signal

          CALL INMUXST        ;check if quick key still pressed ?
          CNZ  INMUX          ;if so, then wait until released

HOLDPT:   LXI H,MHLD          ;flash Hold state
          CALL OUTMUX3        ;local
          CALL OUTEOLN        ;remote too

          CALL HOLDPTRN       ;wait in Hold pattern

HOLDGO:   CALL INMUX          ;read key
          JNC HOLDPT          ;key for sure ?

          LXI H,MRUN          ;re-display Run state
          CALL OUTLED3        ;local only

          LDA KEYBUF          ;Run key continue ?
          CPI RUN
          RZ

          LXI H,1             ;else stop run-time sequence
          SHLD RUNFRAME
          SHLD RUNLAPSE
          XRA A
          STA LAPSTAT
          STA TMRSTAT
          STA TIMROVER
          RET

; Flash Hold state while looping for keypad input.
; Exit Hold pattern when key pressed.

HOLDPTRN: LXI H,MHLD          ;flash Hold state
          CALL OUTLED3        ;local only
          LXI H,50            ;init display flasher = 0.35 sec
WAITHLD:  LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
          CALL WAITX
          CALL INMUXST        ;wait for next key press ?
          RNZ
          DCX H
          MOV A,H
          ORA L
          JNZ WAITHLD

          LXI H,MBLK          ;blank out Hold state
          CALL OUTLED3
          LXI H,50            ;re-init display blanker = 0.15 sec
WAITBLK:  LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
          CALL WAITX
          CALL INMUXST        ;still wait for next key press ?
          RNZ
          DCX H
          MOV A,H
          ORA L
          JNZ WAITBLK         ;loop for blanker cycle
          JMP HOLDPTRN        ;loop for flasher cycle

; Check-Point for pausing continuous run-time sequence.

CHKCONT:  LDA KEYSTAT         ;key pressed at all ?
          ORA A
          RZ
          XRA A
          STA KEYSTAT

          LDA KEYBUF          ;Run key interruption ?
          CPI RUN
          RNZ

          DI
          LHLD RUNFRAME       ;get remanining run-time frame count
          SHLD REMFRAME       ;and save it
          MOV A,H             ;run frame = 0 ?
          ORA L
          JZ SKPZRUN
          LXI H,1             ;swap in 1 frame to stop run-time sequence
          SHLD RUNFRAME
SKPZRUN:  EI

          LXI H,MHLD          ;display Hold state
          CALL OUTLED3        ;local

          CALL INMUXST        ;check if quick key still pressed ?
          CNZ  INMUX          ;if so, then wait until released

          MVI A,TRUE          ;flag Hold status for pausing sequence
          STA HOLDSTAT
          RET

; Check-point for re-running continuous run-time sequence.
; Flash Hold state locally on LED display while looping for key press.

RERUNPT:  LXI H,MHLD          ;display Hold state
          CALL OUTMUX3        ;local
          CALL OUTEOLN        ;remote

          CALL HOLDPTRN       ;wait in Hold pattern

RERUNGO:  CALL INMUX          ;read key
          JNC RERUNPT         ;key for sure ?

          XRA A               ;pre-null Hold status for quitting sequence
          STA HOLDSTAT

          LDA KEYBUF          ;Run key continue ?
          CPI RUN
          RNZ

          LHLD REMFRAME       ;then swap back remaining run-time frame count
          MOV A,H             ;was it 0 already ?
          ORA L
          RZ
          DCX H               ;or even 1 already ?
          MOV A,H
          ORA L
          RZ
          SHLD RUNFRAME       ;adjust for prior single frame substitution

          LXI H,MRUN          ;else re-display Run state
          CALL OUTLED3        ;local only

          MVI A,TRUE          ;re-flag Hold status to re-run sequence
          STA HOLDSTAT
          RET                 ;and start run-time loop anew

; Special run-time interruption feature.
; Allow quick status report on LCD display.

QSTATPT:  LDA KEYSTAT         ;key pressed at all ?
          ORA A
          RZ
          LDA KEYBUF          ;if so, then Run key interruption ?
          CPI RUN
          RZ

          CPI ONE             ;or else data keys for quick status reports ?
          JZ QSTAT1
          CPI TWO
          JZ QSTAT2
          CPI THREE
          JZ QSTAT3
          CPI FOUR
          JZ QSTAT4
          CPI FIVE
          JZ QSTAT5
          CPI SIX
          JZ QSTAT6
          CPI SEVEN
          JZ QSTAT7
          CPI EIGHT
          JZ QSTAT8
          CPI NINE
          JZ QSTAT9
          CPI MINUS
          JZ QSTATM
          CPI ZERO
          JZ QSTAT0
          CPI POINT
          JZ QSTATD

          RET

if SEQROPTN

QSTAT1:   RET

QSTAT2:   RET

QSTAT3:   RET

QSTAT4:   LXI H,MFRM          ;Preset Frame Count ?
	  CALL OUTMUX3
	  LHLD FRAMECNT
	  CALL OUTNUMX
	  RET

QSTAT5:   LXI H,MEXP          ;Exposure Time ? (current)
	  CALL OUTMUX3
	  LHLD EXPOSURE
	  CALL OUTDECX
	  RET

QSTAT6:   LXI H,MLPS          ;Lapse Time ? (current)
	  CALL OUTMUX3
	  LHLD LAPSE
	  CALL OUTDECX
	  RET

QSTAT7:   LXI H,MCNT          ;Counter ?
	  CALL OUTMUX3
	  LHLD COUNTER
	  CALL OUTNUMX
	  RET

QSTAT8:   LXI H,MVEX          ;Variable Exposure Time ?
	  CALL OUTMUX3
	  LHLD ADJEXP
	  CALL OUTDECX
	  RET

QSTAT9:   LXI H,MVLP          ;Variable Lapse Time ?
	  CALL OUTMUX3
	  LHLD ADJLAPSE
	  CALL OUTDECX
	  RET

QSTAT0:   LXI H,MVTR          ;Variable Trigger Time ?
	  CALL OUTMUX3
	  LHLD TRIGTIME
	  CALL OUTDECX
	  RET

QSTATM:   LXI H,MDR           ;Direction ?
	  CALL OUTMUX3
	  CALL OUTDIR
	  CALL OUTMUX5
	  RET

QSTATD:   LXI H,MSPD          ;Film Speed ?
	  CALL OUTMUX3
	  LHLD SPEED
	  CALL OUTDECX
	  RET

else	  ;NOT SEQROPTN

QSTAT1:   LXI H,MFRM          ;Preset Frame Count ?
	  CALL OUTMUX3
	  LHLD FRAMECNT
	  CALL OUTNUMX
	  RET

QSTAT2:   LXI H,MCNT          ;Counter ?
	  CALL OUTMUX3
	  LHLD COUNTER
	  CALL OUTNUMX
	  RET

QSTAT3:   LXI H,MOUT          ;Out Frame?
	  CALL OUTMUX3
	  LHLD OUTFRAME
	  CALL OUTNUMX
	  RET

QSTAT4:   LXI H,MEXP          ;Exposure Time ? (current)
	  CALL OUTMUX3
	  LHLD EXPOSURE
	  CALL OUTDECX
	  RET

QSTAT5:   LXI H,MLPS          ;Lapse Time ? (current)
	  CALL OUTMUX3
	  LHLD LAPSE
	  CALL OUTDECX
	  RET

QSTAT6:   LXI H,MVTR          ;Variable Trigger Time ?
	  CALL OUTMUX3
	  LHLD TRIGTIME
	  CALL OUTDECX
	  RET

QSTAT7:   LXI H,MVEX          ;Variable Exposure Time ?
	  CALL OUTMUX3
	  LHLD ADJEXP
	  CALL OUTDECX
	  RET

QSTAT8:   LXI H,MVLP          ;Variable Lapse Time ?
	  CALL OUTMUX3
	  LHLD ADJLAPSE
	  CALL OUTDECX
	  RET

QSTAT9:   RET

QSTAT0:   RET

QSTATM:   LXI H,MDR           ;Direction ?
	  CALL OUTMUX3
	  CALL OUTDIR
	  CALL OUTMUX5
	  RET

QSTATD:   RET

endif

; Variable Exposure and Lapse Times.

; Variable Lapse Time pre-run check-point.
; Use IY table for variable lapse time table.

          IF NOT VLPSOPTN
LAPSOCHK: RET
          ENDIF

          IF VLPSOPTN

LAPSOCHK: LDA TMRSTAT         ;variable lapse time at all ?
          ORA A
          RZ
          STA LAPSTAT

          LXIY LAPSEBUF       ;initialize run-time lapse time pointer
          LHLD LAPSEBUF       ;transfer initial lapse time
          SHLD LAPSE
          CALL ACOMPLAP

          LHLD LPACLCNT       ;transfer run-time acceleration count
          SHLD RUNACLCT
          SHLD RUNDCLCT

          LDA TMRPHZE          ;accelerating lapse times ?
          ORA A
          RP

          LXIY LAPSEBUF        ;else re-init buffer to top of ramp table
          LHLD LPACLCNT
          DCX H
          DAD H
          XCHG
          DADY DE              ;... = base address + (decel count -1) * 2
          LDY L,0
          LDY H,1
          SHLD LAPSE
          CALL ACOMPLAP
          RET

          ENDIF

; Variable Lapse Time run-time computations.
; Only acceleration or deceleration phases of ramping are necessary.

          IF NOT VLPSOPTN
LAPSOCMP: RET
          ENDIF

          IF VLPSOPTN

LAPSOCMP: LDA TMRSTAT         ;variable lapse time computation ?
          ORA A
          RZ

          LDY L,0             ;get variable lapse time from buffer
          LDY H,1
          SHLD LAPSE          ;update actual lapse time
          CALL ACOMPLAP       ;compensate for run-time lapse time

          LDA TMRPHZE         ;which lapse time phase ?
          ORA A
          JM LAPSODCL         ;deceleration phase ?

LAPSOACL: INXIY               ;increment lapse time pointer for acceleration
          INXIY
          LHLD RUNACLCT       ;update acceleration counter
          DCX H
          MOV A,H             ;acceleration over ?
          ORA L
          SHLD RUNACLCT
          RNZ
          XRA A               ;change over to constant time phase
          STA TMRPHZE
          STA TMRSTAT
          RET

LAPSODCL: DCXIY               ;decrement lapse time pointer for deceleration
          DCXIY
          LHLD RUNDCLCT       ;update deceleration counter
          DCX H
          MOV A,H             ;deceleration over ?
          ORA L
          SHLD RUNDCLCT
          RNZ
          XRA A               ;change back to constant time phase
          STA TMRPHZE
          STA TMRSTAT
          RET

          ENDIF

; Variable Exposure Time pre-run check-point.
; Use IX pointer for variable exposure table.
; May use either scaled film speed or time exposure mode.

          IF NOT VEXPOPTN
EXPSOCHK: RET
          ENDIF

          IF VEXPOPTN

EXPSOCHK: LDA ETMSTAT         ;variable exposure time at all ?
          ORA A
          RZ
          STA EXPSTAT

          LXIX EXPOSBUF       ;initialize run-time exposure time pointer
          LHLD EXPOSBUF       ;transfer initial exposure time
          SHLD EXPOSURE

          LHLD EXACLCNT       ;transfer run-time acceleration count
          SHLD RUNEACLT
          SHLD RUNEDCLT

          LDA ETMPHZE          ;accelerating exposure times ?
          ORA A
          RP

          LXIX EXPOSBUF        ;else re-init buffer to top of ramp table
          LHLD EXACLCNT
          DCX H
          DAD H
          XCHG
          DADX DE              ;... = base address + (decel count -1) * 2
          LDX L,0
          LDX H,1
          SHLD EXPOSURE
          RET

          ENDIF

; Variable Exposure Time run-time computations.
; Uses IX pointer.
; May use either scaled film speed or time exposure mode.

          IF NOT VEXPOPTN
EXPSOCMP: RET
          ENDIF

          IF VEXPOPTN

EXPSOCMP: LDA ETMSTAT         ;variable exposure time computation ?
          ORA A
          RZ

          LDX L,0             ;get variable exposure time from buffer
          LDX H,1
          SHLD EXPOSURE       ;update actual exposure time
          CALL QSPDCHK        ;compensate for run-time

          LDA ETMPHZE         ;which exposure time phase ?
          ORA A
          JM EXPSODCL         ;deceleration phase ?

EXPSOACL: INXIX               ;increment exposure time pointer for acceleration
          INXIX
          LHLD RUNEACLT       ;update acceleration counter
          DCX H
          MOV A,H             ;acceleration over ?
          ORA L
          SHLD RUNEACLT
          RNZ
          XRA A               ;change over to constant time phase
          STA ETMPHZE
          STA ETMSTAT
          RET

EXPSODCL: DCXIX               ;decrement exposure time pointer for deceleration
          DCXIX
          LHLD RUNEDCLT       ;update deceleration counter
          DCX H
          MOV A,H             ;deceleration over ?
          ORA L
          SHLD RUNEDCLT
          RNZ
          XRA A               ;change back to constant time phase
          STA ETMPHZE
          STA ETMSTAT
          RET

          ENDIF

; Quick exposure time --> film speed check.
; If film speed > min low speed, then scale ramp to reach high speed.
; Else use time exposure mode with exp time compensation.

QSPDCHK:  CALL SPEEDCMP       ;convert exposure time --> film speed

          PUSHIX
          PUSHIY
          CALL RAMPCOMP       ;compute new ramp speed table to match
          CALL TIMECOMP       ;convert to new exposure time compensation
          POPIY
          POPIX

QSPDSLOW: CALL ACOMPEXP       ;if time exposure, then compensate for exp time
          RET

; Run through high speed ramp table to search for matching film speed,
; and adjust ramp count to match.

QSPDRAMP: LHLD SPEED          ;get computed film speed
          CALL CONVSPD        ;convert speed to step time
          MOV E,L             ;copy step time (8-bit)
          LHLD RAMPNTR        ;init ramp table pointer
          LBCD RAMPABS        ;init ramp table counter

QSPDLOOP: MOV A,E             ;get copy of step time
          CMP M               ;compare with step time in ramp table
          JZ QSPDADJ          ;step times = ?
          JNC QSPDADJ         ;computed step time > ramped step time ?
          INX H               ;update ramp pointer
          DCX B               ;update ramp counter
          MOV A,B
          ORA C
          JNZ QSPDLOOP        ;repeat for all ramp table

QSPDADJ:  LHLD RAMPABS        ;adjust ramp count
          XRA A
          DSBC BC
          SHLD RAMPCNT        ;... = max ramp count - search counter
          LXI D,2             ;compare adjusted ramp count > 2 ?
          XRA A
          DSBC DE
          RNC
          SDED RAMPCNT        ;if less, then max out at 2 ramp steps
          RET
          
; Exposure Time compensation for motor rotation time.

ACOMPEXP: LHLD EXPOSURE       ;compute run-time exposure time
          SHLD RUNEXP
          MOV A,H
          ORA L
          STA EXPSTAT
          RZ

          LHLD EXPOSURE       ;compute run-time exposure time
          LDED EXPCOMP        ;adjust for exp time compensation
          INX D
          ORA A
          DSBC DE             ; ... = (exp time + 1) - (exp comp + 1)
          INX H
          SHLD RUNEXP
          RNC
          XRA A
          STA EXPSTAT
          STA RUNEXP
          STA RUNEXP+1
          RET

; (Lapse time compensation according to running real-time clock).
; Compensate for pre-exposure trigger time delay.

ACOMPLAP: LHLD LAPSE          ;compute run-time lapse time
          SHLD RUNLAPSE
          MOV A,H
          ORA L
          STA LAPSTAT
          RZ

	  IF PRETRGOP

	  LHLD LAPSE          ;adjust for pre-trigger time
	  LDED TRIGTIME
          INX D
          ORA A
          DSBC DE
          INX H
          SHLD RUNLAPSE       ;... = (lapse time + 1) - (trigger time + 1)
          RNC
          XRA A
          STA LAPSTAT
          STA RUNLAPSE
	  STA RUNLAPSE+1

	  ENDIF

          RET



; Motor Control Signals.

; Output motor control signals on.

MOTORON:  LDA DIRSTAT         ;camera direction forward or reverse ?
          ORA A
          JNZ CAMREVON

CAMFWDON: IN MOTRCNTL         ;camera forward
          SETB MDIR,A         ;motor forward
          OUT MOTRCNTL
          SETB MEN1,A         ;motor 1 disable
          OUT MOTRCNTL
          SETB MEN2,A         ;motor 2 disable
          OUT MOTRCNTL
          MVI A,FALSE         ;check switch mask when steps run out...
          STA SWITMASK

if GEAROPTN

          LDA FRMRATIO        ;what is drive frame ratio ?
          CPI 1
          JZ  SKIPFWD1        ;if 1:1, then continue
          MVI A,TRUE          ;else ignore Home switch
          STA SWITMASK
SKIPFWD1:

endif

          LDA CAM1STAT        ;camera 1 active ?
          ORA A
          JZ  CAMFWD2
          IN MOTRCNTL
          RES  MEN1,A         ;motor 1 enable
          OUT MOTRCNTL

CAMFWD2:  LDA CAM2STAT        ;camera 2 active ?
          ORA A
          RZ
          IN MOTRCNTL
          RES  MEN2,A         ;motor 2 enable
          OUT MOTRCNTL
          RET

CAMREVON: IN MOTRCNTL         ;camera reverse
          RES  MDIR,A         ;motor reverse
          OUT MOTRCNTL
          SETB MEN1,A         ;motor 1 disable
          OUT MOTRCNTL
          SETB MEN2,A         ;motor 2 disable
          OUT MOTRCNTL
          MVI A,FALSE
          STA SWITMASK

if GEAROPTN

          LDA FRMRATIO        ;what is drive frame ratio ?
          CPI 1
          JZ  SKIPREV1        ;if 1:1, then continue
          MVI A,TRUE          ;else ignore Home switch
          STA SWITMASK
SKIPREV1:

endif

          LDA CAM1STAT        ;camera 1 active ?
          ORA A
          JZ  CAMREV2
          IN MOTRCNTL
          RES  MEN1,A         ;motor 1 enable
          OUT MOTRCNTL

CAMREV2:  LDA CAM2STAT        ;camera 2 active ?
          ORA A
          RZ
          IN MOTRCNTL
          RES  MEN2,A         ;motor 2 enable
          OUT MOTRCNTL
          RET

; Output motor control signals off.
; Effective for AC motor enable signals immediately.

MOTOROFF: IN MOTRCNTL
          RET

; Output motor control signals null.
; Effective for DC motor enable signals after final time-out.

MOTORNUL: IN MOTRCNTL	      ;all motors off
          SETB MEN1,A         ;DC motor 1 OFF
          OUT MOTRCNTL
          SETB MEN2,A         ;DC motor 2 OFF
          OUT MOTRCNTL
          RET

; Output motor control signals for no torque.

MOTORDC0: IN MOTRCNTL
          SETB MEN2,A         ;DC motor 2 OFF
          OUT MOTRCNTL
          SETB MEN1,A         ;DC motor 1 OFF
          OUT MOTRCNTL
          RET

; Output trigger signals.
; Trigger on.

TRIGRON:  IN MOTRCNTL
          SETB MTRG,A         ;trigger on
          OUT MOTRCNTL
          RET

; Trigger off.

TRIGROFF: IN MOTRCNTL
	  RES  MTRG,A         ;trigger off
	  OUT MOTRCNTL
	  RET

; Timer and Counter commands.

IC000LRC: EQU 11000111B ;interrupt + counter + load + reset + control
IC000LNC: EQU 11000101B ;interrupt + counter + load + no reset + control
NC000NRC: EQU 01000011B ;no int + counter + no load + reset + control
NC000NNC: EQU 01000001B ;no int + counter + no load + no reset + control

IT400LRC: EQU 10000111B ;interrupt + timer/16 + load + reset + control
IT400LNC: EQU 10000101B ;interrupt + timer/16 + load + no reset + control
NT400NRC: EQU 00000011B ;no int + timer/16 + no load + reset + control

IT800LRC: EQU 10100111B ;interrupt + timer/256 + load + reset + control
IT800LNC: EQU 10100101B ;interrupt + timer/256 + load + no reset + control
NT800NRC: EQU 00100011B ;no int + timer/256 + no load + reset + control

; Initialize timers / counters with interrupts.

INITIMER: LXI H,NULLINT       ;load interrupt vectors in RAM
	  SHLD INTCTCV0
	  SHLD INTCTCV1
	  SHLD INTCTCV2
          SHLD INTCTCV3

          LXI H,INTCTCV0      ;interrupt vector for all CTCs
          MOV A,L
          OUT CTC0
          MOV A,H
          STAI
          RET

; Initialize step motor timing.
; CTC0 <-- Timer for step pulse timing.
; CTC1 <-- Counter for counting CTC0 steps.
; BC'  <-- acceleration phase ramp count
; DE'  <-- pre-deceleration phase step count
; HL'  <-- acceleration phase step-time pointer.

INITMOTR: DI
          CALL MICROCHK       ;select micro- or half-stepping stuff

	  XRA A
          CMA                 ;motor running status
	  STA MOTROVER

          LXI H,NULLINT       ;but point to null vector initially
          SHLD INTPIOVB

          LHLD RAMPCNT
          SHLD RAMPRUN
          CALL STEPOCHK       ;insure ramp count < step count 

          EXX
          LBCD RAMPRUN        ;load ramp count --> BC'
          LHLD STEPCNT        ;adjust step count for pre-deceleration
          XRA A
          DSBC BC             ;... = step count - decel count
          XCHG                ;load pre-decel step count --> DE'
          PUSH D

          LHLD RAMPNTR        ;load ramp table step time pointer --> HL'
	  MOV A,M             ;load step time
          STA STEPTIME
          INX H               ;update pointer for 2nd ramp step
          EXX
          POP D               ;double check pre-decel step count 

          LXI H,ACCLXINT      ;load acceleration interrupt vector 
          SHLD INTCTCV0
          LXI H,NULLINT
          SHLD INTCTCV1

          LDA TMRLDRBF        ;start timer CTC0 with interrupts
          OUT CTC0
          LDA STEPTIME        ;time constant low byte
          OUT CTC0

          EI
          RET

; Initialize step motor timing for multiple revolutions.
; CTC0 <-- Timer for step pulse timing.
; CTC1 <-- Counter for counting CTC0 steps.
; CTC2 <-- (reserved for SIO baud rate clock.)
; CTC3 <-- Counter for counting CTC1 step multiples.
; BC'  <-- acceleration phase ramp count
; DE'  <-- multiple revolution frame count
; HL'  <-- acceleration phase step-time pointer.
; Allow ramp counting independent of step counting.
; 2 cases for ramp counts <= or > total step counts.

INITCONT: DI
          CALL MICROCHK       ;select micro- or half-stepping stuff

          XRA A
          CMA                 ;motor running status
	  STA MOTROVER
          STA HOMEOVER        ;home sensing status

          LXI H,NULLINT       ;but point to null vector initially
          SHLD INTPIOVB

          LHLD RAMPCNT        ;transfer run-time ramp count
          SHLD RAMPRUN

          LHLD REVLNCNT       ;pre-compute pre-deceleration step count
          LDED RAMPRUN
          XRA A
          DSBC DE             ;... = frame step count - decel ramp count
          SHLD RUNPRECL

          JC RMPMREV          ;ramp count > frame step count ?
          JZ RMPNREV          ;ramp count = frame step count ?
          JNC RMP1REV         ;ramp count < frame step count ?

                              ;case if ramp count > frame step count...
RMPMREV:  LHLD RAMPRUN        ;compare ramp count >> frame step count
          DAD H
          LDED REVLNCNT
          XRA A
          DSBC DE             ;... = 2*ramp count - frame step count
          LBCD RUNFRAME
          SBCD REMFRAME
RMPMCHK:  DCX B               ;decrement run frame count - 1
          MOV A,B
          ORA C
          JZ  RMPSHORT        ;run out of multiple run frames ?
          XRA A
          DSBC DE             ;2*ramp count - frame step count (again)
          JNC RMPMCHK         ;repeat until modulo ramp count < 0

          LHLD RAMPRUN        ;compute ramp count MODULO frame step count
          LDED REVLNCNT
          XRA A
          DSBC DE             ;... = ramp count - frame step count
          LBCD RUNFRAME
          SBCD REMFRAME
RMPMFIT:  DCX B               ;decrement run frame count - 1
          SBCD RUNFRAME
          MOV A,B
          ORA C
          JZ  RMPSHORT        ;run out of multiple run frames ?
          XRA A
          DSBC DE             ;ramp count - frame step count (again)
          JNC RMPMFIT         ;repeat until modulo ramp count < 0
          JZ RMPNFIT          ;modulo ramp count = 0 ?

          DAD D               ;re-adjust for modulo ramp count > 0
          XCHG                ;... = ramp count + frame step count
          LHLD REVLNCNT
          XRA A
          DSBC DE             ;frame step count - modulo ramp count
          SHLD RUNPRECL       ;... = pre-decel step count
          JMP GORMPREV

RMPNFIT:                      ;case if modulo ramp count = 0...
RMPNREV:  LXI H,1             ;insure at least 1 pre-decel step count
          SHLD RUNPRECL
          LHLD RAMPRUN        ;adjust decel step count - 1 to match
          DCX H
          SHLD RAMPRUN
          JMP GORMPREV

                              ;case if not enough run frames...
RMPSHORT: LHLD FRAMEABS       ;compute frame count * step count
          MOV A,L
          LDED REVLNCNT
          CALL MULTIPLY       ;... = total frame step count
          PUSH H
          SRLR H              ;split total frame steps / 2
          RARR L              ;... = ramp count
          DCX H
          SHLD RAMPRUN
          LDED RAMPCNT        ;compare run ramp count > max ramp count ?
          ORA A
          DSBC DE
          JC SKPRMAX
          SDED RAMPRUN        ;...then max out at original ramp count

SKPRMAX:  POP H               ;total frame steps
          LDED RAMPRUN
          ORA A
          DSBC DE             ;... - decel ramp steps
          SHLD RUNPRECL       ;... = pre-decel ramp steps
          LXI H,0
          SHLD RUNFRAME       ;... for 1 single frame

          LXI H,FRAMEACQ      ;load special acceleration interrupt vector
          SHLD INTCTCV0
          LXI H,NULLINT       ;load special step counter interrupt vectors
          SHLD INTCTCV1
          LXI H,FRAMECRZ      ;...for frame counting only
          SHLD INTCTCV3

          JMP LDRMPREV


RMP1REV:  JMP GORMPREV        ;case if ramp count < frame step count

GORMPREV: LXI H,FRAMEACL      ;load acceleration interrupt vector
          SHLD INTCTCV0
          LXI H,NULLINT       ;load step counter interrupt vectors
          SHLD INTCTCV1
          LXI H,FRAMEINT
          SHLD INTCTCV3


LDRMPREV: EXX
          LDED RUNPRECL       ;load run pre-decel count --> DE'
          LBCD RAMPRUN        ;load run ramp count  --> BC'
          LHLD RAMPNTR        ;load ramp table step time pointer --> HL'
          MOV A,M             ;load step time
          STA STEPTIME
          INX H               ;update pointer for 2nd ramp step
          EXX

          MVI A,IC000LRC      ;load high counter CTC2 with interrupts
          OUT CTC3
          LDA TMRMLTBF        ;counter high byte = multiple * 100
          OUT CTC3

          MVI A,IC000LRC      ;load low counter CTC1 with interrupts
          OUT CTC1
          LDA TMRDIVBF        ;counter low byte = multiplier
          OUT CTC1

          LDA TMRLDRBF        ;start timer CTC0 with interrupts
          OUT CTC0
          LDA STEPTIME        ;time constant low byte
          OUT CTC0

          EI
          RET

; Initialize exposure time or lapse time pause timing.
; CTC3 <-- Timer for pause interval timing.
; Microprocessor clock speed dependent quantum time QT.

INITWAIT: LHLD WAITIME       ;check for 0 wait time ?
          MOV A,H
          ORA L
          STA TIMROVER
          RZ

          DI
          XRA A
          CMA                 ;timer running status
          STA TIMROVER

          EXX
	  LBCD WAITIME        ;load wait count
          EXX

          LXI H,WAITINT       ;point to wait interrupt vector
          SHLD INTCTCV3

          MVI A,IT800LRC      ;load timer
          OUT CTC3
          MVI A,QT01          ;with multiples of 0.01 seconds
          OUT CTC3

          EI
          RET

; Stop the running timer in progress.

STOPWAIT: DI
          MVI A,NT800NRC      ;reset timer
          OUT CTC3
          LXI H,NULLINT       ;point to null interrupt vector
          SHLD INTCTCV3
          XRA A               ;clear timer running status
          STA TIMROVER
          EI
          RET

; Check how ramp counts compare with step count.

STEPOCHK: LHLD STEPCNT        ;load step count
          XCHG
          LHLD RAMPRUN        ;load ramp count
          DAD H               ;double for accel count + decel count
          INX H               ;(plus 1 for safety) 
          INX H
          INX H
          XCHG
          XRA A
          DSBC DE             ;step count > accel count + decel count ?
          RNC

          LHLD STEPCNT        ;else re-load step count
          SRLR H              ;split step count in half
          RARR L
          DCX H               ;(less 1 for safety)
          DCX H
          DCX H
          SHLD RAMPRUN        ;re-compute ramp count = half step count
          RET

; Check ramp counts for either 8-bit or 16-bit run-time ramping.

RAMPOCHK: LXI H,0             ;pre-null high-order ramp count
          SHLD RAMPRUNH
          LHLD RAMPRUN        ;pre-transfer low-order ramp count
          SHLD RAMPRUNL
          MOV A,H             ;8-bit only ?
          ORA A
          RZ

          LXI D,255           ;else max out low-order ramp count
          SDED RAMPRUNL
          XRA A
          DSBC DE             ;adjust remainder for high-order ramp count
          SHLD RAMPRUNH
          RET

; Set parameters relevant for micro-stepping.
; NOTE: Default always to micro-stepping timing for Coates application.
; REVLNCNT will be used for frame counting purposes only.

MICROSET: LHLD REVLNCNT       ;compare revolution count < half-step count
          LXI D,801
          XRA A               ;if less, then no micro-stepping
          STA MICROST
          DSBC DE
          JC SKPMICRO
          CMA                 ;else yes micro-stepping
          STA MICROST

SKPMICRO: CALL MICROCMP       ;compute revolution count multiplier
          CALL MICROTME       ;compute micro-stepping time base
          RET

; Compute full-revolution counter timing for micro-stepping.
; NOTE: (Coates) computational problem if REVLNCNT = 250...

MICROCMP: LHLD REVLNCNT       ;compare revolution count < 100 ?
          LXI D,100
          ORA A
          DSBC DE
          JC SHORTREV

          LHLD REVLNCNT       ;compute revolution count / 100
          LXI D,100
          CALL DIVIDE
          MOV A,C
          STA TMRMLTBF        ;save as 100x multiplier value
          MVI A,100
          STA TMRDIVBF        ;100x multiplier
          RET

SHORTREV: LHLD REVLNCNT       ;use revolution count exactly as multiplier
          MOV A,L
          STA TMRDIVBF
          MVI A,1
          STA TMRMLTBF
          RET

; Load minimum time base stuff for micro-stepping or half-stepping.

MICROTME: LDA MICROST         ;micro-stepping ?
          ORA A
          JNZ MICROTMS

          LXI H,KSCALEHF      ;speed scaling constant for half-stepping
          SHLD KSCALEBF
          LXI H,LOWSPDHF      ;minimum low speed for half-stepping
          SHLD LOWSPDBF
          SHLD MINSPDBF
          RET

MICROTMS: LXI H,KSCALEMS      ;speed scaling constant for micro-stepping
          SHLD KSCALEBF
          LXI H,LOWSPDMS      ;minimum low speed for micro-stepping
          SHLD LOWSPDBF
          SHLD MINSPDBF
          RET

; Check for parameters relevant for micro-stepping.
; Micro-stepping = 2000 steps per revolution.

MICROCHK: LDA MICROST         ;micro-stepping ?
          ORA A
          JNZ MICROGO

          MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF
          LXI H,KSCALEHF      ;speed scaling constant for half-stepping
          SHLD KSCALEBF
          LHLD MINSPEED       ;minimum low speed (user-defined)
          SHLD LOWSPDBF
          RET

MICROGO:  MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF
          LXI H,KSCALEMS      ;speed scaling constant for micro-stepping
          SHLD KSCALEBF
          LHLD MINSPEED       ;minimum low speed (user-defined)
          SHLD LOWSPDBF
          RET




; Keypad input and LED output display routines.
; 16 keys represented in order of appearance
; on 4-row by 4-column keypad XY matrix.

; Calculator style keypad layout:

;    < PRGRM >      < SEVEN > < EIGHT > <  NINE >
;    <  RUN  >      <  FOUR > <  FIVE > <  SIX  >
;    < CLEAR >      <  ONE  > <  TWO  > < THREE >
;    < ENTER >      < MINUS > <  ZERO > < POINT >

          IF NOT PHONEKEY

ZERO:     EQU 13
ONE:      EQU 10
TWO:      EQU 9
THREE:    EQU 8
FOUR:     EQU 6
FIVE:     EQU 5
SIX:      EQU 4
SEVEN:    EQU 2
EIGHT:    EQU 1
NINE:     EQU 0

POINT:    EQU 12
MINUS:    EQU 14

ENTER:    EQU 15
CLEAR:    EQU 11

PROGRAM:  EQU 3
RUN:      EQU 7

          ENDIF

; Telephone style keypad layout:

;    < PRGRM >      <  ONE  > <  TWO  > < THREE >
;    <  RUN  >      <  FOUR > <  FIVE > <  SIX  >
;    < CLEAR >      < SEVEN > < EIGHT > < NINE  >
;    < ENTER >      < MINUS > <  ZERO > < POINT >

          IF PHONEKEY

ZERO:     EQU 13
ONE:      EQU 2
TWO:      EQU 1
THREE:    EQU 0
FOUR:     EQU 6
FIVE:     EQU 5
SIX:      EQU 4
SEVEN:    EQU 10
EIGHT:    EQU 9
NINE:     EQU 8

POINT:    EQU 12
MINUS:    EQU 14

ENTER:    EQU 15
CLEAR:    EQU 11

PROGRAM:  EQU 3
RUN:      EQU 7

          ENDIF

; Serial input port character-to-keycode map table.
; Ascii character codes are mapped in same order as row/column codes.

CR:       EQU 0DH
BS:       EQU 08H

          IF NOT PHONEKEY

SIOCODE:  DB CR
          DB '-'
          DB '0'
          DB '.'
          DB BS
          DB '1'
          DB '2'
          DB '3'
          DB 'R'
          DB '4'
          DB '5'
          DB '6'
          DB 'P'
          DB '7'
          DB '8'
          DB '9'

          ENDIF

          IF PHONEKEY

SIOCODE:  DB CR
          DB '-'
          DB '0'
          DB '.'
          DB BS
          DB '7'
          DB '8'
          DB '9'
          DB 'R'
          DB '4'
          DB '5'
          DB '6'
          DB 'P'
          DB '1'
          DB '2'
          DB '3'

          ENDIF

; Generally useful data input/output routines:
; GETNUM gets a number from the keypad, displays it, and converts it to hex.
; OUTNUM gets a hex value from memory, and displays it.
; MODNUM gets a previous value from memory, displays it, and waits for
; possible modification from the keypad.
; GETDEC, OUTDEC, and MODDEC do the same thing for decimal numbers.
; Numbers are passed via register HL.

GETNUM:   CALL INPUTNUM  ;input number only
          CALL CONVERT
          LHLD CONVACCM
          RET

OUTNUM:   CALL RECONVRT  ;output number only
          CALL XFERDSPL
          CALL OUTDISPL
          RET
          
MODNUM:   PUSH H         ;buffer old number
          CALL RECONVRT
          CALL XFERDSPL
          CALL OUTDISPL
          CALL CURSRON
          CALL MODFYNUM  ;modify number
          CALL CONVERT
          CALL CURSROFF
          LHLD CONVACCM  ;return new number
          POP D
          LDA KEYBUF     ;forget it ?
          CPI PROGRAM
          RNZ
          XCHG           ;restore old number
          RET

GETDEC:   CALL INPUTNUM  ;input decimal number
          CALL CONVERT
          CALL CONVDEC
          LHLD CONVACCM
          RET

OUTDEC:   CALL RECONVRT  ;output decimal number
          CALL RECONDEC          
          CALL XFERDSPL
          CALL OUTDISPL
          RET

MODDEC:   PUSH H         ;modify decimal number
          CALL RECONVRT
          CALL RECONDEC
          CALL XFERDSPL
          CALL OUTDISPL
          CALL CURSRON
          CALL MODFYNUM
          CALL CONVERT
          CALL CONVDEC
          CALL CURSROFF
          LHLD CONVACCM
          POP D
          LDA KEYBUF
          CPI PROGRAM
          RNZ
          XCHG
          RET

; Data number input routine INPUTNUM
; Numeral digits are input into buffer INDIGBUF until the ENTER key
; is pressed. CLEAR key zeroes out the buffer and re-starts the routine.
; Each digit entry is echoed out to the display via routine OUTDISPL.
; Re-adjust LCD cursor position after each Output-Display call. 
; Input is multiplexed from either keypad or serial port.

EOS:      EQU 0FFH       ;end-of-string marker

INPUTNUM: MVI A,0        ;zero out the input buffer
          STA INDIGBUF
          MVI A,EOS
          STA INDIGBUF+1
          CALL OUTDISPL  ;and display
          CALL CURSRADJ  ;with adjusted cursor

MODFYNUM: LXI H,INDIGBUF ;initialize input digit buffer pointer
          SHLD DIGPNTR

INNUM:    CALL INMUX     ;get a key, any key..., from KEY or SIO ports
          JNC INNUM

          LDA KEYBUF
          CPI PROGRAM    ;PROGRAM ?
          JZ ENTERIN

          CPI ENTER      ;ENTER ?
          JZ ENTERIN

          CPI CLEAR      ;CLEAR ?
          JZ CLEAROUT

          CALL IFNUM     ;number at all ?
          JZ ECHOUT
          JMP INNUM
          
ECHOUT:   LHLD DIGPNTR
          MOV M,A        ;transfer digit into input buffer
          INX H
          MVI M,EOS      ;append end-of-string marker
          SHLD DIGPNTR
          CALL OUTDISPL  ;echo output current digit string
          CALL CURSRADJ  ;with adjusted cursor
          JMP INNUM
          
CLEAROUT: MVI A,0        ;zero out current data entry
          STA INDIGBUF
          MVI A,EOS
          STA INDIGBUF+1
          CALL OUTDISPL  ;display 0
          CALL CURSRADJ  ;with adjusted cursor
          LXI H,INDIGBUF ;and start again...
          SHLD DIGPNTR
          JMP INNUM
          
ENTERIN:  RET

; IFNUM checks the keypad input code for valid numerals 0 to 9. If matched,
; it additionally replaces the code with the corresponding BCD value.
; Includes additional decoding for decimal point and negative sign.

DECPT:    EQU 10         ;quasi-BCD 'decimal point' code
NEGSN:    EQU 11         ;quasi-BCD 'negative sign' code

IFNUM:    LXI H,NUMCODE
          LXI B,12
          CCIR           ;search numeral code table for match
          RNZ

          MOV A,C        ;if match, then substitute actual value
          RET
          
NUMCODE:  DB MINUS
          DB POINT
          DB NINE
          DB EIGHT
          DB SEVEN
          DB SIX
          DB FIVE
          DB FOUR
          DB THREE
          DB TWO
          DB ONE
          DB ZERO
          
; Keypad input scanning routine.
; X rows energized one at a time (4 bits).
; Y columns sensed in one group of four (4 bits).
; Carry flag set if key pressed and decoded.

ROWSCAN:  EQU 11101110B  ;keypad output row scanning pattern

ROWMASK:  EQU 11110000B  ;keypad row output port mask
COLMASK:  EQU 00001111B  ;keypad column input port mask

KEYCODE:  DB  11101110B  ;keypad row/column code de-mulitplexing table
          DB  11101101B
          DB  11101011B
          DB  11100111B
          DB  11011110B  ;row #2
          DB  11011101B
          DB  11011011B
          DB  11010111B
          DB  10111110B  ;row #3
          DB  10111101B
          DB  10111011B
          DB  10110111B
          DB  01111110B  ;row #4
          DB  01111101B
          DB  01111011B
          DB  01110111B
          
; Wait until key is pressed.

WAITKEY:  CALL INKEYST        ;key pressed ?
          JZ WAITKEY

          CALL INKEY          ;then get key
          RET

; Check for key press at all.
; Return with Non-Zero flag if key pressed.

INKEYST:  MVI A,00000000B     ;output energize all rows
          OUT KEYSCAN
          NOP
          IN KEYSENS          ;input sense all columns
          ANI COLMASK
          XRI COLMASK         ;any key pressed ?
          RET

; Check for key press, then Input key if pressed.
; Return with Carry flag if key input successful.

INKEY:    CALL INKEY1    ;check column group #1
          RET

; Quick check for key press, then Input key if pressed.
; Return with Carry flag if key input successful.

INQUIKEY: CALL INKEYQ    ;quick check column group #1
          RET

; Input key for group #1.

INKEY1:   MVI B,ROWSCAN  ;set row scanning pattern
          MVI A,ROWSCAN
          
SCAN1:    ANI ROWMASK
          OUT KEYSCAN    ;energize...
          NOP
          IN KEYSENS     ;sense...
          ANI COLMASK
          XRI COLMASK
          JNZ DEBNCE1    ;if key press, then debounce it
          
SHIFT1:   MOV A,B        ;update row scanning pattern
          RLC
          MOV B,A
          RNC            ;until 4 rows completed
          JMP SCAN1
          
DEBNCE1:  LXI D,BNCETM   ;wait debounce time
          CALL WAITX
          
          IN KEYSENS     ;re-sense...
          ANI COLMASK
          MOV C,A
          XRI COLMASK
          JZ SHIFT1      ;noise?...
          
          MOV A,B        ;assemble row scanning pattern
          ANI ROWMASK
          ORA C          ;with column sensing pattern

          LXI B,16       ;search key code table for match
          LXI H,KEYCODE
          CCIR
          MOV A,C
          STA KEYBUF     ;save key code #
          
RELEASE1: IN KEYSENS     ;wait for key release
          ANI COLMASK
          XRI COLMASK
          JNZ RELEASE1

          LXI D,BNCETM   ;and debounce that one too
          CALL WAITX

          STC            ;got one...
          RET

; Input key with quick scanning.
; No wait for debounce and no wait for release.

INKEYQ:   MVI B,ROWSCAN  ;set row scanning pattern
          MVI A,ROWSCAN
          
SCANQ:    ANI ROWMASK
          OUT KEYSCAN    ;energize...
          NOP
          IN KEYSENS     ;sense...
          ANI COLMASK
          MOV C,A        ;save actual sensing input
          XRI COLMASK
          JNZ DECODEQ    ;if key press, then decode it
          
SHIFTQ:   MOV A,B        ;update row scanning pattern
          RLC
          MOV B,A
          RNC            ;until 4 rows completed
          JMP SCANQ
          
DECODEQ:  MOV A,B        ;assemble row scanning pattern
          ANI ROWMASK
          ORA C          ;with column sensing pattern

          LXI B,16       ;search key code table for match
          LXI H,KEYCODE
          CCIR
          MOV A,C
          STA KEYBUF     ;save key code #
          
          STC            ;got one...
          RET

; CONVERT takes the numeral digit string assembled in the input buffer,
; and converts it into the corresponding 16-bit binary number it represents.
; A fractional portion is denoted by the number of decimal places logged
; in FRACTION, for subsequent conversion processing.
; Number is returned in register HL.

CONVERT:  LXI B,INDIGBUF ;initialize input digit buffer pointer
          LXI D,0        ;initialize whole & fractional digit counters

          XRA A          ;assume positive number
          STA NEGSTAT
                    
CNTWHOLE: LDAX B         ;count each whole digit
          INX B
          CPI NEGSN      ;...except negative sign
          JZ NEGCNT
          CPI DECPT      ;...unless decimal point
          JZ CNTFRACT
          CPI EOS        ;...or until end of string
          JZ STOPCNT
          INR D
          JMP CNTWHOLE

NEGCNT:   MVI A,0FFH     ;flag negative number
          STA NEGSTAT
          JMP CNTWHOLE
          
CNTFRACT: LDAX B         ;continue counting each fractional digit
          INX B
          CPI DECPT      ;...(except more decimal points)
          JZ CNTFRACT
          CPI EOS        ;...until end of string
          JZ STOPCNT
          INR E
          JMP CNTFRACT
          
STOPCNT:  MOV A,E        ;get fractional count
          STA FRACTION
          ADD D          ;with whole number count
          STA CONVCNTR   ;for total digit count
          
          DCX B          ;adjust pointer before end-of-string
          DCX B
          LXI H,1        ;initialize decimal weight
          SHLD DECWT
          DCX H          ;initialize conversion accumulator value
          SHLD CONVACCM
          
NUMST:    LDAX B         ;fetch digit onto Number Street
          DCX B
          CPI DECPT      ;(except for decimal point)
          JZ NUMST
          CPI NEGSN      ;(or negative sign)
          JZ NUMST

          LDED DECWT
          CALL MULTIPLY  ;mulitply by decimal weight
          XCHG
          LHLD CONVACCM
          DAD D          ;and add to accumulated value
          SHLD CONVACCM  ;(just like on Number St.)

          LDA CONVCNTR   ;more digits to pick up ?
          DCR A
          STA CONVCNTR
          JZ STOPCONV

          MVI A,10       ;adjust decimal weight multiplier for next house
          LDED DECWT
          CALL MULTIPLY
          SHLD DECWT     ;weight <-- weight * 10
          JMP NUMST
          
STOPCONV: LDA NEGSTAT    ;negative value ?
          ORA A
          RZ

          LHLD CONVACCM
          LXI D,0        ;then 2's complement negative
          XCHG
          XRA A
          DSBC DE        ;... = 0 - number
          SHLD CONVACCM
          RET

; CONVDEC further converts a number into its decimal equivalent
; according to its number of decimal places.
; Assume 2 decimal places.

CONVDEC:  LDA FRACTION   ;number of decimal places =
          CPI 2          ;... 2 --> OK
          RZ
          JM SCALEUP     ;... 1 or less --> scale up by 10

SCALEDN:  LHLD CONVACCM  ;... 3 or more --> scale down by 10
          LXI D,10
          CALL DIVIDE
          CALL ROUND
          SBCD CONVACCM
          RET

SCALEUP:  CPI 0          ;... 0 --> scale up max by 100
          JZ SCALEMAX

          LDED CONVACCM  ;... 1 --> scale up by 10
          MVI A,10
          CALL MULTIPLY
          SHLD CONVACCM
          RET

SCALEMAX: LDED CONVACCM
          MVI A,100
          CALL MULTIPLY
          SHLD CONVACCM
          RET

; RECONVERT takes a 16-bit value from memory and reconverts the number
; into its BCD digit string representation to be subsequently output.
; Number passed via register HL.
; Assume 5 BCD digits max for 64k.
; Assume 2's-complement for +/-32k.

RECONVRT: XRA A               ;pre-flag positive
          STA NEGSTAT
          BIT 7,H             ;sign bit ?
          JZ RCONPLUS

          LXI D,0
          XCHG                ;then 2's-complement positive
          XRA A
          DSBC DE             ;... = 0 - number
          CMA
          STA NEGSTAT         ;flag negative

RCONPLUS: LXI D,10000         ;proceed back down Number St.
          CALL DIVIDE
          MOV A,C
          STA XFERBUF         ;10000's

          LXI D,1000
          CALL DIVIDE
          MOV A,C
          STA XFERBUF+1       ;1000's

          LXI D,100
          CALL DIVIDE
          MOV A,C
          STA XFERBUF+2       ;100's

          LXI D,10
          CALL DIVIDE
          MOV A,C
          STA XFERBUF+3       ;10's
          MOV A,L
          STA XFERBUF+4       ;1's
          MVI A,EOS
          STA XFERBUF+5
          STA XFERBUF+6
          RET

; RECONDEC adjusts the reconverted value to include 2 decimal places.
; Assume 5 digits (max) in transfer buffer.
; Decimal Point gets inserted in transfer buffer here.

RECONDEC: LDA XFERBUF+4       ;relocate 2 least sig digits
          STA XFERBUF+5
          LDA XFERBUF+3
          STA XFERBUF+4
          MVI A,DECPT         ;and insert dec pt
          STA XFERBUF+3
          RET

; XFERDSPL transfers a re-assembled BCD digit string into the LED display
; buffer and outputs it. Leading zeros are blanked out.
; Assume 5 BCD digits max = 4 digits to check for leading zeroes.
; Special leading zero check for fixed decimal point at 2 LSD digits.
; Assume 5 digits (max) + 1 dec pt (maybe) in transfer buffer.
; Negative sign gets inserted in transfer buffer here.

XFERDSPL: CALL FILLIN         ;fill in input digit string with EOS

          MVI B,4             ;initialize leading 0 counter
          LXI H,XFERBUF       ;initialize transfer digit buffer pointer
          
LEAD0:    MOV A,M             ;scan digit buffer for leading 0s
          CPI 0
          JNZ LEADP
          INX H               ;move pointer past leading 0s
          DJNZ LEAD0

LEADP:    MOV A,M             ;unless followed by a dec pt
          CPI DECPT
          JNZ NON0
          DCX H
          INR B
          
NON0:     LXI D,INDIGBUF      ;initialize digit buffer pointer
          INR B               ;adjust transfer counter

          LDA XFERBUF+3       ;explicitly check for dec pt
          CPI DECPT
          JNZ NEG0
          INR B               ;adjust counter one more for dec pt

NEG0:     LDA NEGSTAT         ;negative number ?
          ORA A
          JZ XFERNON0
          MVI A,NEGSN         ;insert negative sign
          STAX D
          INX D

XFERNON0: MOV A,M             ;transfer digits
          STAX D              ;to 'input' buffer
          INX H
          INX D
          DJNZ XFERNON0

          RET

; FILLIN pads the input digit buffer with EOS markers.

FILLIN:   MVI B,8
          LXI H,INDIGBUF

FILLNULL: MVI M,EOS           ;fill in with End-of-String
          INX H
          DJNZ FILLNULL
          RET

; LED Digit output routine preparation
; Digits available in BCD form in input buffer
; Digits transferred and recoded with addresses in output buffer
; Assume 5-6 characters (max) to be transferred into Output buffer.

OUTDISPL: CALL BLANKOUT  ;blank out the output buffer

          MVI C,0        ;initialize digit counter
          LXI D,INDIGBUF ;initialize input buffer pointer
          LXI H,OUTDIGBF ;initialize output buffer pointer
          
CNTDIG:   LDAX D         ;count the digits in the input buffer
          INX D
          CPI EOS        ;...until end of string
          JZ ALNDIG
          INR C
          JMP CNTDIG
          
ALNDIG:   MVI A,5+XD     ;align output pointer according to # of digits
          SUB C
          ADD L
          MOV L,A
          
          LXI D,INDIGBUF
XFERDIG:  LDAX D         ;transfer digits from input to output buffers
          MOV M,A
NEXTDIG:  INX D
          INX H
          CPI EOS
          JNZ XFERDIG
          
          CALL XLATOUT   ;translate to ASCII
          CALL OUTLED    ;output to LED latch
          RET
          
; BLANKOUT pads the output digit buffer with blanks.
; Assume 5-6 characters (max) in output buffer.

BLANKOUT: MVI B,5+XD
          LXI H,OUTDIGBF
         
FILLBLNK: MVI M,' '      ;fill all locations with blanks
          INX H
          DJNZ FILLBLNK
          RET

; XLATOUT translates output digits in OUTDIGBF into ASCII characters. 
; Assume 5-6 characters (max) in output buffer.

XLATOUT:  LXI H,OUTDIGBF ;output buffer pointer
          MVI B,5+XD     ;output buffer counter

XLATDIG:  MOV A,M
          CPI EOS        ;end of string ?
          JZ XLATES
          CPI 10         ;in 0..9 ?
          JP XLATDP
          ADI '0'        ;convert to ASCII
          MOV M,A
          JMP NEXTCHR

XLATDP:   CPI DECPT      ;decimal point ?
          JNZ XLATNS
          MVI M,'.'      ;insert ASCII point
          JMP NEXTCHR

XLATNS:   CPI NEGSN      ;negative sign ?
          JNZ NEXTCHR
          MVI M,'-'      ;insert ASCII minus

NEXTCHR:  INX H          ;repeat for all of output buffer
          DJNZ XLATDIG

XLATES:   MVI M,' '      ;insert ASCII blank at end of string
          RET

; OUTLED outputs digits buffered in OUTDIGBF to the latched LED display.

OUTLED:   LXI H,OUTDIGBF ;initialize output buffer address
          CALL OUTLED5   ;output 5 buffered digits to LED display (only)
          RET



; LED / LCD Output Display routines...

; Output 3-character prompt to LED display.
; (3-character string pointer loaded in HL.)

          IF LEDISPLY

OUTLED3:  MOV A,M               ;1st char
          OUT LED+7
          INX H
          MOV A,M               ;2nd char
          OUT LED+6
          INX H
          MOV A,M               ;3rd char
          OUT LED+5
          RET

          ENDIF

; Output 3 buffered characters to somewhere.

          IF LCDISPLY

OUTLED3:  CALL OUTLCD3
          RET

          ENDIF

; Output 5-digit string to LED display.
; (5-character string pointer loaded in HL.)

          IF LEDISPLY

XD:       EQU 0          ;extra digit = +0 for 5 buffered digits for LED

OUTLED5:  MVI C,LED+4    ;initialize LED port address
          MVI B,5        ;number of bytes to transfer

XLED:     MOV A,M        ;transfer byte out of buffer
          OUTP A         ;output to LED port
          INX H
          DCR C
          DJNZ XLED      ;repeat for all bytes
          RET

          ENDIF

; Output 5 or 6 buffered characters to somewhere.

          IF LCDISPLY

XD:       EQU 1          ;extra digit = +1 for 6 buffered digits for LCD

OUTLED5:  CALL OUTLCD5
          RET

          ENDIF



; LCD buffered output routines.

          IF LCDISPLY

; Output 3-character prompts in left-hand display.
; Adjust 2 positions from left edge of display for centering text.
; HL <-- pointer to string

OUTLCD3:  CALL WAITLCD
          MVI A,LCDADDRL+2      ;set left-hand display address
          OUT LCDCNTL
          MVI B,3               ;count 3 characters for output
XFEROUT3: MOV A,M               ;load from memory
	  CALL OUTLCD           ;output to LCD
          INX H
          DJNZ XFEROUT3
          RET

; Output 5-character data in right-hand display.
; Output total of 6 characters for centering text from right edge of display.
; HL <-- pointer to string

OUTLCD5:  CALL WAITLCD
          MVI A,LCDADDRR        ;set right-hand display address
          OUT LCDCNTL
          MVI B,6               ;count 6 characters for output
XFEROUT5: MOV A,M               ;load from memory
	  CALL OUTLCD           ;output to LCD
          INX H
          DJNZ XFEROUT5
          RET

          ENDIF




; Cursor display control routines for LED display.
; Flashing cursor automatically on timer CTC3 interrupt.
; For peaceful co-existance of cursor timer and torque timer:
; DE'  <-- torque time-out multiplier.
; CTC1 <-- torque time-out timer.
; (M)  <-- cursor flasher multiplier in memory.
; CTC3 <-- cursor flasher timer.

          IF LEDISPLY

CURSRON:  DI
          XRA A			;init cursor flasher memory off
          STA CURSRMEM
          MVI A,50
          STA CURSRTME

          LXI H,CURSRINT	;point to cursor timer interrupt
          SHLD INTCTCV3
          MVI A,IT800LRC	;load cursor timer on CTC3
          OUT CTC3
          MVI A,QT01
          OUT CTC3
          EI
          RET

; Turn cursor timer flasher routine off.

CURSROFF: DI
          MVI A,NT800NRC	;reset cursor timer and interrupt
          OUT CTC3
          LXI H,NULLINT 	;point to null interrupt
          SHLD INTCTCV3
          CALL RESETLED         ;reset cursor LED display memory
          EI
          RET

; Null cursor adjustment (for LCD compatibility).

CURSRADJ: RET

          ENDIF



; Cursor display control routines for LCD display.
; Flashing cursor automatically inside LCD chip.

          IF LCDISPLY

CURSRON:  CALL WAITLCD
          MVI A,LCDADDRR+5      ;select LSD digit address
          OUT LCDCNTL
	  CALL WAITLCD
          MVI A,00001101B       ;enable character blinker on
          OUT LCDCNTL
          RET

; Disable cursor timer interrupt routine, and clear the cursor.

CURSROFF: CALL WAITLCD
          MVI A,LCDADDRR+5      ;select LSD digit address
          OUT LCDCNTL
	  CALL WAITLCD
          MVI A,00001100B       ;clear cursor and char blinker
          OUT LCDCNTL
          RET

; Adjust LCD cursor position back to LSD digit address.

CURSRADJ: CALL WAITLCD
          MVI A,LCDADDRR+5      ;select LSD digit address
          OUT LCDCNTL
          RET

          ENDIF




; LCD input / output routines.

          IF LCDISPLY

LCDADDRL: EQU 80H+00H           ;LCD buffer address for left-hand display
LCDADDRR: EQU 80H+40H           ;LCD buffer address for right-hand display

; Wait until LCD status indicates Not-Busy.

WAITLCD:
	  if LCDREAD

	  IN LCDCNTL            ;input LCD status register
	  BIT 7,A               ;busy flag ?
	  JNZ WAITLCD           ;wait until not busy

	  else

	  LXI D,QT01SOFT/10     ;wait 120 micro seconds minimum
	  CALL WAITX

	  endif

	  RET

; Output character to LCD.
; Address of next character position is automatically incremented.

OUTLCD:   PUSH PSW
	  CALL WAITLCD          ;wait until not busy
          POP PSW
          OUT LCDDATA           ;output data character
          RET

; Software reset of LCD display.

RESETLCD: LXI H,15              ;wait 15 msec after hardware reset
WTLCDFN1: LXI D,QT01SOFT
          CALL WAITX
          DCX H
          MOV A,H
          ORA L
          JNZ WTLCDFN1
          MVI A,00110000B       ;function set for software reset
          OUT LCDCNTL

          LXI H,5               ;wait 4.1 msec more
WTLCDFN2: LXI D,QT01SOFT
          CALL WAITX
          DCX H
          MOV A,H
          ORA L
          JNZ WTLCDFN2
          MVI A,00110000B       ;function set again
          OUT LCDCNTL

          LXI D,100             ;wait 100 usec more
          CALL WAITX
          MVI A,00110000B       ;function set again
          OUT LCDCNTL

          CALL WAITLCD
          MVI A,00111000B       ;function set for dual-line display
          OUT LCDCNTL

          CALL WAITLCD
          MVI A,00001000B       ;display off
          OUT LCDCNTL

          CALL WAITLCD
          MVI A,00000001B       ;display clear
          OUT LCDCNTL

          CALL WAITLCD
          MVI A,00000110B       ;entry mode set
          OUT LCDCNTL

          CALL WAITLCD
          MVI A,00001100B       ;display on
          OUT LCDCNTL
          RET

          ENDIF



; Multiplexed Keypad / Display and Serial Input / Output.

          IF NOT MUXIO

WAITMUX:  CALL WAITKEY          ;wait for keypad input only
          RET

INMUXST:  CALL INKEYST          ;input key status only
          RET

INMUX:    CALL INKEY            ;input key only
          RET

OUTMUX3:  CALL OUTLED3          ;output prompt
          RET

OUTMUX5:  CALL OUTLED5          ;output integer number
          RET

OUTNUMX:  CALL OUTNUM           ;output integer number
          RET

OUTDECX:  CALL OUTDEC           ;output decimal number
          RET

MODNUMX:  CALL MODNUM           ;modify and output integer number
          RET

MODDECX:  CALL MODDEC           ;modify and output decimal number
          RET

OUTEOLN:  RET                   ;output End-of-Line

          ENDIF


          IF MUXIO

CR:       EQU 0DH               ;carriage return
LF:       EQU 0AH               ;line feed
BS:       EQU 08H               ;back space

; Wait until key is pressed or input from serial port.

WAITMUX:  CALL INMUXST          ;key pressed or serial input ?
          JZ WAITMUX

          CALL INMUX            ;then get key from wherever...
          RET

; Query input status from either Keypad or Serial port.

INMUXST:  CALL INKEYST          ;input from keypad ?
          MOV C,A               ;save status
          CALL INSIOST          ;input from SIO port ?
          ORA C                 ;keypad status OR serial port status ?
          RET

; Input from either Keypad or Serial port.

INMUX:    CALL INKEYST          ;input from keypad ?
          ORA A                 ;(save Z-flag, clear C-flag)
          CNZ INKEY             ;then get key from keypad
          RC

          CALL INSIOST          ;input from SIO port ?
          ORA A
          CNZ INCHAR            ;then get character-as-key from SIO port
          RC

          RET

; Multiplex output 3-character prompt to LED display and SIO port.
; (3-character string pointer loaded in HL.)

OUTMUX3:  CALL OUTLED3          ;output 3 buffered characters to LED display
          DCX H                 ;reset buffer pointer
          DCX H
          DCX H
          CALL OUTSIO3          ;echo out 3 buffered characters to SIO port
          RET

; Multiplex output 5-character string to LED display and SIO port.
; (5-character string already assembled in LED buffer)

OUTMUX5:  PUSH H                ;save pointer
          CALL OUTLED5          ;transfer 5 characters to LED display
          POP H                 ;re-point
          CALL OUTSIO5          ;echo 5 buffered characters to SIO port
          CALL OUTEOLN          ;send end of line
          RET

; Multiplex output 5-digit string to LED display and SIO port.
; Multiplexer shell routine for OUTNUM.
; (16-bit integer already loaded in HL.)
; (5-digit string assembled in LED buffer)

OUTNUMX:  PUSH H                ;save value
          CALL OUTNUM           ;transfer 5 characters to LED display
          LXI H,OUTDIGBF        ;re-init output digit buffer address
          CALL OUTSIO5          ;echo 5 buffered characters to SIO port
          CALL OUTEOLN          ;send end of line
          POP H                 ;restore value
          RET

; Multiplex output 5-digit decimal string to LED display and SIO port.
; Multiplexer shell routine for OUTDEC.
; (16-bit fixed-point integer already loaded in HL)
; (5-digit string assembled in LED buffer)

OUTDECX:  PUSH H                ;save value
          CALL OUTDEC           ;transfer 5 characters to LED display
          LXI H,OUTDIGBF        ;re-init output digit buffer address
          CALL OUTSIO5          ;echo 5 buffered characters to SIO port
          CALL OUTEOLN          ;send end of line
          POP H                 ;restore value
          RET

; Modify & Multiplex output 5-digit string to LED display and SIO port.
; Multiplexer shell routine for MODNUM.
; (16-bit integer already loaded in HL.)

MODNUMX:  CALL OUTNUMX          ;convert and output original value
          CALL MODNUM           ;modify updated value
          RET

; Modify & Multiplex output 5-digit decimal string to LED display and SIO port.
; Multiplexer shell routine for MODDEC.
; (16-bit fixed-point integer already loaded in HL)

MODDECX:  CALL OUTDECX          ;convert and output original value
          CALL MODDEC           ;modify updated value
          RET

; Get character from SIO port and map according to keypad code.
; Carry flag is set and mapped key code is buffered, as in INKEY routine.

INCHAR:   CALL INSIOST          ;input from SIO port ?
          ORA A                 ;pre-clear Carry flag
          RZ

          CALL INSIO            ;get input character from SIO port
          LXI B,16              ;search SIO code table for match
          LXI H,SIOCODE
          CCIR
          MOV A,C               ;counter = table index
          STA KEYBUF            ;save key code #
          STC                   ;set Carry flag
          RZ                    ;...if as long as match was actually found
          CMC                   ;...else re-clear Carry flag
          RET

; Output 3-character string to SIO port.
; (3-character string pointer loaded in HL.)

OUTSIO3:  MOV A,M               ;1st char
          CALL OUTSIO
          INX H
          MOV A,M               ;2nd char
          CALL OUTSIO
          INX H
          MOV A,M
          CALL OUTSIO           ;3rd char
          RET

; Output 5-digit string to SIO port.
; (5-character string pointer loaded in HL.)
; (6 characters if LCD display.)

OUTSIO5:  MVI B,5+XD            ;number of bytes to transfer
XSIO:     MOV A,M               ;transfer byte out of buffer
          CALL OUTSIO           ;output to SIO port
          INX H
          DJNZ XSIO             ;repeat for all bytes
          RET

; Output a carriage return to the serial port.

OUTEOLN:  MVI A,CR
          CALL OUTSIO
          RET

          ENDIF




; Serial Interface routines...

; Null input/output routines if no serial interface.

          IF NOT SERIALIO

RESETSIO: RET            ; Reset serial interface.

INSIOST:  XRA A          ; Sample input status from serial port.
          RET

INSIO:    XRA A          ; Input byte from serial port.
          RET

OUTSIO:   RET            ; Output byte to serial port.

          ENDIF

; Real Serial Interface routines.

          IF SERIALIO

; Z80 SIO / DART constants.

WR0       EQU 00H        ;DART Write-Command Registers
WR1       EQU 01H
WR2       EQU 02H
WR3       EQU 03H
WR4       EQU 04H
WR5       EQU 05H

RSETXCVR  EQU 00011000B  ;reset DART transceiver
RSETHAND  EQU 00010000B  ;reset DART external handshake inputs
NOINT     EQU 00000000B  ;disable DART interrupts
NEXTINT   EQU 00100000B  ;enable DART interrupt on next received byte
FIRSTINT  EQU 00001000B  ;enable DART interrupt on first received byte
RCVRINT   EQU 00011000B  ;enable DART interrupts on all received bytes
SIOCHAR   EQU 01000100B  ;SIO format  X16 clock, 1 stop bit
RCVRENBL  EQU 11000001B  ;enable DART receiver
XMTRENBL  EQU 01101000B  ;enable DART transmitter
DTRENBL   EQU 11101000B  ;enable DTR (add to enabled transmitter)
DTRDSBL   EQU 01101000B  ;disable DTR
RTSENBL   EQU 01101010B  ;enable RTS (add to enabled transmitter)
RTSDSBL   EQU 01101000B  ;disable RTS 
RCVRDY	  EQU 00000001B	 ;receiver ready status
XMTRDY	  EQU 00000100B	 ;transmitter ready status

DTR       EQU 7          ;DTR control bit
RTS       EQU 1          ;RTS control bit
DCD       EQU 3          ;DCD status bit
DSR       EQU DCD        ;DSR status bit (Zilog "DCD")
CTS       EQU 5          ;CTS status bit
RIN       EQU 4          ;RI status bit (Zilog "Ring Indicator")
EXT       EQU 1          ;external status bit
RCV       EQU 0          ;receiver ready
XMT       EQU 2          ;transmitter ready

BAUDSET   EQU 01000111B  ;CTC counter = CLK/2 for baud clock generation

; Reset serial interface.

RESETSIO: MVI A,BAUDSET  ;generate SIO baud clock
          OUT BAUDCLK
          MVI A,BAUD9600 ;at 9600 baud
          OUT BAUDCLK

          MVI A,RSETXCVR ;reset SIO transceivers
          OUT SIOCMD
          NOP

          MVI A,RSETHAND ;reset SIO handshake input sensing
          OUT SIOCMD

          MVI A,WR4      ;set up SIO characters
          OUT SIOCMD
          MVI A,SIOCHAR
          OUT SIOCMD

          MVI A,WR1      ;no interrupts on SIO
          OUT SIOCMD
          MVI A,NOINT
          OUT SIOCMD

          MVI A,WR3      ;enable SIO receivers
          OUT SIOCMD
          MVI A,RCVRENBL
          OUT SIOCMD

          MVI A,WR5      ;enable SIO transmitters with DTR and RTS
          OUT SIOCMD
          MVI A,XMTRENBL
          SETB DTR,A
          SETB RTS,A
          OUT SIOCMD
          RET

          ENDIF

; Input / Ouput routines for Serial Interface.

          IF SERIALIO

; Sample input status from serial port.

INSIOST:  IN SIOSTAT     ;get SIO status
          ANI RCVRDY     ;byte received ?
          RET

; Input byte from serial port.

INSIO:    IN SIOSTAT     ;receiver ready ?
          BIT RCV,A
          JZ INSIO

          IN SIODATA     ;then input byte
          RET

; Output byte to serial port.

OUTSIO:   PUSH PSW
WAITSIO:  IN SIOSTAT     ;transmitter ready ?
          BIT XMT,A
          JZ WAITSIO

          POP PSW
          OUT SIODATA    ;then output byte
          RET

          ENDIF




; Utility routines.

          MULTPLYM

          DIVIDEM

          FASTDIVM

          WAITXM




; Control board initialization
; and parameter initialization routines...

; Reset LED display with all blanks.

          IF LEDISPLY

RESETLED: IN CONTROL          ;get active I/O signals
          RES DCUR,A          ;cursor active low
          OUT CONTROL

          XRA A
          MVI B,8
          MVI C,LED
BLANKURS: OUTP A              ;blank all 8 digit positions
          INR C
          DJNZ BLANKURS

          IN CONTROL
          SETB DCUR, A        ;cursor inactive high
          OUT CONTROL
          RET

          ENDIF

; Reset LCD display with all blanks.

          IF LCDISPLY

RESETLED: CALL RESETLCD
          RET

          ENDIF

; Reset and initialize hardware.
; Reset Parallel Input / Output chips.
 
RESETPIO: MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLA
          MVI A,00001111B     ;identify input/output directions
          OUT PIOCNTLA

          MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLB
          MVI A,00000111B     ;identify input/output directions
          OUT PIOCNTLB

          MVI A,QUIETIO
          OUT MOTRCNTL
          RET

; Reset Counter / Timer chips. 

RESETCTC: MVI A,NC000NRC      ;reset timers
          OUT CTC0
          OUT CTC1
          OUT CTC2
          OUT CTC3
          RET

; Initialize real-time clock using CTC2 timer interrupts.
; Substitute CTC3 if serial baud rate clock needed for CTC2.

INITCLOK: MVI A,IT800LRC      ;load clock timer on CTC2
          OUT CTC3
          MVI A,QT01          ;with multiples of 0.01 seconds
          OUT CTC3
          MVI A,100           ;initialize clock ticker = 100
          STA TICKTOCK
          LXI H,CLOCKINT      ;point to real-time clock interrupt
          SHLD INTCTCV3
          RET

; Initialize switch sensing interrupts.

INITSWCH: LXI H,NULLINT       ;null interrupt vector for keypad
          SHLD INTPIOVA
          LXI H,NULLINT
          SHLD INTPIOVB

          LXI H,INTPIOVA      ;load interrupt vector low bytes in PIO
          MOV A,L
          OUT PIOCNTLA
          LXI H,INTPIOVB
          MOV A,L
          OUT PIOCNTLB
          MOV A,H
          STAI                ;load interrupt vector high byte in CPU
          RET

; Initialize memory registers for detection of 1st, 2nd, or Nth Reset.

RESETMEM: CALL CHECK1ST       ;check memory for 1st-time Reset
          STA RESETBUF
          STA RESETBUF+1
          PUSH PSW
          CNZ SET1ST          ;if 1st Reset, then set 1st block of memory
          POP PSW
          RNZ                 ;if 1st Reset, then ignore 2nd block of memory

          RET

; Check 1st 8 bytes of memory for Reset pattern.

CHECK1ST: MVI A,11H           ;init code
          LXI H,MEMBUF
          MVI B,8
          MVI C,11H
CHKMEM1:  CMP M               ;compare memory
          RNZ
          INX H
          ADD C               ;update code
          DJNZ CHKMEM1 
          XRA A
          RET

; Set 1st 8 bytes of memory for Reset pattern.

SET1ST:   MVI A,11H           ;init code
          LXI H,MEMBUF
          MVI B,8
          MVI C,11H
SETMEM1:  MOV M,A             ;store in memory
          INX H
          ADD C               ;update code
          DJNZ SETMEM1
          RET

; Check 2nd 8 bytes of memory for Reset pattern.

CHECK2ND: MVI A,88H
          LXI H,MEMBUF+8
          MVI B,8
          MVI C,11H
CHKMEM2:  CMP M               ;test memory ?
          RNZ
          INX H
          ADD C
          DJNZ CHKMEM2
          XRA A
          RET

; Set 2nd 8 bytes of memory for Reset pattern.

SET2ND:   MVI A,88H
          LXI H,MEMBUF+8
          MVI B,8
          MVI C,11H
SETMEM2:  MOV M,A             ;set memory...
          INX H
          ADD C
          DJNZ SETMEM2
          RET

; Initialize software variables.

INITIALZ: LHLD RESETBUF       ;check memory 
          MOV A,L             ;for 1st-time Reset
          ORA H               ;and 2nd-time Reset
          CNZ INITVARS        ;if new, then init all variables
          CALL INITCOMP       ;always init computations
          CALL INITIMER       ;init timer interrupts
          CALL INITSWCH       ;init switch sensing interrupts
          CALL INITCLOK       ;init real-time clock
          RET

; Initialize data variables only at 1st Reset.
; Default initialization for 400 half-steps per revolution.
; Custom setting for 180 degree shutter-open rotation on 35mm Bell+Howell.

* DSPEED:   EQU 120           ;1.20 frames per second for 72 RPM
* DSPEED:   EQU 200           ;2.00 frames per second
* DSPEED:   EQU 260           ;2.40 frames per second
* DSPEED:   EQU 300           ;3.00 frames per second
* DSPEED:   EQU 334           ;3.33 frames per second for 200 RPM
* DSPEED:   EQU 392           ;3.92 frames per second
* DSPEED:   EQU 400           ;4.00 frames per second

DSPEED:     EQU 350           ;3.50 frames per second for 0.08 sec @ 100 deg
DEXPTIME:   EQU 8             ;0.08 seconds exposure time

DOPNANGL:   EQU 31            ;110 degrees for Bolex
* DOPNANGL: EQU 35            ;125 degrees for Mitchell
* DOPNANGL: EQU 50            ;shutter-open rotation angle = 180 deg

DEXPANGL:   EQU 28            ;shutter-open exposure angle = 135 deg * 75%
* DEXPANGL: EQU 47            ;shutter-open exposure angle = 170 deg
* DEXPANGL: EQU 50            ;shutter-open exposure angle = 180 deg
* DEXPANGL: EQU 65            ;shutter-open exposure angle = 235 deg

DVARSHTR:   EQU 100           ;shutter angle = 135 degrees for 16mm Bolex
* DVARSHTR: EQU 170           ;shutter angle = 170 degrees for 35mm Mitchell
* DVARSHTR: EQU 180           ;shutter angle = 180 degrees for 35mm Bell+Howell
* DVARSHTR: EQU 235           ;shutter angle = 235 degrees for 16mm Mitchell

* DMINEXPT: EQU 25            ;minimum exposure time for 2 FPS at 235 deg
* DMINEXPT: EQU 12            ;minimum exposure time for 4 FPS at 170 deg
* DMINEXPT: EQU  6            ;minimum exposure time for 4 FPS at 135 deg
DMINEXPT:   EQU  8            ;minimum exposure time for 3.5 FPS at 135 deg
* DMINEXPT: EQU  1            ;minimum exposure time for 12+ FPS at 135 deg
* DMINEXPT: EQU  0            ;minimum exposure time for any FPS speed

* DMINSPD:  EQU 93            ;minimum film speed for time-exposure mode
DMINSPD:    EQU 100           ;minimum film speed for time-exposure mode
* DMINSPD:  EQU 111           ;minimum film speed for time-exposure mode
* DMINSPD:  EQU 200           ;minimum film speed for time-exposure mode
DWHIPSPD:   EQU 200           ;whip-open film speed for time-exposure mode

* DTORQTME: EQU 100           ;default torque time-out
DTORQTME:   EQU 50            ;default torque time-out

* DREVLNCN: EQU 25000         ;revolution step count = 25000 micro-steps
* DREVLNCN: EQU 2000          ;2000 micro-steps
DREVLNCN: EQU 400             ;400 half-steps

* DRAMPCNT: EQU 250           ;ramp count for 2000 micro-steps
* DRAMPCNT: EQU 1000          ;ramp count for 2000 micro-steps
* DRAMPCNT: EQU 2000          ;ramp count for 2000 micro-steps
* DRAMPCNT: EQU 200           ;for 400 half-steps 35mm open loop
* DRAMPCNT: EQU 108           ;for 400 half-steps 35mm
DRAMPCNT:   EQU 100           ;for 400 half-steps 35mm
* DRAMPCNT: EQU 80            ;for 400 half-steps 35mm
* DRAMPCNT: EQU 64            ;for 400 half-steps 35mm + 16mm
* DRAMPCNT: EQU 48            ;for 400 half-steps 16mm
* DRAMPCNT: EQU 0             ;no ramping for constant speed 72 RPM

INITVARS: LXI H,0
          SHLD COUNTER        ;zero counter
          SHLD EXPOSURE       ;exposure time
          SHLD LAPSE          ;lapse time
          SHLD OUTFRAME       ;out-frame counter #
          SHLD REALTIME       ;real-time clock
          SHLD ADJLAPSE       ;variable lapse time
          SHLD LPACLCNT       ;lapse acceleration count
          SHLD ADJEXP         ;variable exposure time
          SHLD EXACLCNT       ;exposure acceleration count
          SHLD CAM1CNTR       ;camera 1 counter
          SHLD CAM2CNTR       ;camera 2 counter

          SHLD CAMRCNTR       ;camera counter
          SHLD PROJCNTR       ;projector counter
          SHLD STEPRCNT       ;camera step count
          SHLD SKIPRCNT       ;projector skip count

          LXI H,1
          SHLD FRAMECNT       ;single frame count
          SHLD FRAMEABS
          SHLD TRIGTIME       ;trigger time-out
          SHLD TORQTIME       ;torque time-out
          SHLD TEXQTIME

          SHLD CAMFRMCT       ;camera frame count
          SHLD CAMABSCT
          SHLD PRJFRMCT       ;projector frame count
          SHLD PRJABSCT

          LXI H,DSPEED
          SHLD SPEED          ;film speed

          XRA A
          STA DIRSTAT         ;direction forward
          STA EXPSTAT         ;no time exposure
          STA LAPSTAT         ;no time lapse
          STA TMRSTAT         ;variable lapse status
          STA ETMSTAT         ;variable exposure status
          STA WDGSTAT         ;wedge sequence status
          STA ABSSTAT         ;absolute frame overide
          STA TICKTOCK        ;clock ticker

          STA SEQSTAT         ;no sequencer
          STA PROJSTAT        ;no projector overide
          STA CNTRSTAT        ;no projector counting
          STA CAMDIRST        ;forward camera
          STA PRJDIRST        ;forward projector

          CMA
          STA CAM1STAT
          STA CAM2STAT
          STA SYNCSTAT
          STA CAMXSTAT
          STA DRVRSTAT

	  LXI H,DREVLNCN
          SHLD STEPCNT        ;step count
	  SHLD REVLNCNT       ;full revolution step count
	  SHLD AUXINCNT	      ;auxiliary increment count
          LXI H,DRAMPCNT
          SHLD RAMPCNT        ;ramp count
          SHLD RAMPABS        ;absolute ramp count

          LXI H,DOPNANGL
          SHLD OPNANGLE       ;rotation angle to open shutter
          LXI H,DEXPANGL      
          SHLD EXPANGLE       ;open shutter exposure angle (decimal)
          LXI H,DVARSHTR
          SHLD VARSHTR        ;variable shutter angle (degrees)
          LXI H,DMINEXPT
          SHLD MINEXPTM       ;minimum exposure time
          LXI H,DEXPTIME
          SHLD EXPOSURE       ;default exposure time
          LXI H,DSPEED
          SHLD SPEED          ;default film speed
          LXI H,DMINSPD
          SHLD MINSPEED       ;minimum film speed
          LXI H,DWHIPSPD
          SHLD WHIPSPD        ;whip-open film speed
          LXI H,DTORQTME
          SHLD TORQTIME       ;default torque time
          SHLD TEXQTIME

          RET

; Initialize variable-dependent computations each Reset time.

INITCOMP: CALL MICROSET       ;set micro-stepping status
          CALL MICROCHK       ;check micro-stepping stuff
          CALL RATIOSET       ;set motor drive ratio stuff
          CALL RAMPCOMP       ;compute initial ramp table
          CALL TIMECOMP       ;compute compensation times
          CALL OPENCOMP       ;compute open-shutter step count
          CALL VRSHCOMP       ;compute exposure factor

          LHLD RAMPNTR        ;get initial step time
          LDED RAMPCNT
          DAD D
          MOV A,M
          MOV L,A
          MVI H,0
          SHLD STEPTIME
          SHLD RAMPBUF
          RET

; ThingM Test procedure.

          IF LEDISPLY

TESTSIGN: DB '*THINGM*'

TEST:     LXI D,BNCETM        ;wait
          CALL WAITX

          LXI H,TESTSIGN      ;pointer to sign-on string
          MVI C,LED+7         ;pointer to LED hardware addresses
          MVI B,8             ;all 8 chars
TESTOUT:  MOV A,M
          OUTP A              ;local LED display
          CALL OUTSIO         ;remote serial display
          INX H
          DCR C
          DJNZ TESTOUT
          CALL OUTEOLN        ;remote trailing End-of-Line

          LXI D,0             ;pause
          CALL WAITX
          RET

          ENDIF

; ThingM Test procedure.

          IF LCDISPLY

; LCD display output across left and right sections.
; Echo output to serial port 1 character at a time.

TESTSIGN: DB '***THINGM***'

TEST:     LXI D,BNCETM        ;wait
          CALL WAITX

          CALL WAITLCD
          MVI A,LCDADDRL+2    ;set left-hand display address
          OUT LCDCNTL
          LXI H,TESTSIGN      ;pointer to sign-on string
          MVI B,6             ;1st 6 chars
TESTOUTL: MOV A,M
          CALL OUTLCD         ;local LCD display
          CALL OUTSIO         ;remote serial display
          INX H
          DJNZ TESTOUTL

          CALL WAITLCD
          MVI A,LCDADDRR+0    ;set right-hand display address
          OUT LCDCNTL
          MVI B,6             ;2nd 6 chars
TESTOUTR: MOV A,M
          CALL OUTLCD         ;local
          CALL OUTSIO         ;remote
          INX H
          DJNZ TESTOUTR

          CALL OUTEOLN        ;remote trailing End-of-Line

          LXI D,0             ;pause
          CALL WAITX

          CALL WAITLCD
          MVI A,LCDADDRL      ;set left-hand display address
          OUT LCDCNTL
          MVI B,8             ;all 8 left blanks
TBLANKL:  MVI A,' '
          CALL OUTLCD
          DJNZ TBLANKL

          CALL WAITLCD
          MVI A,LCDADDRR      ;set right-hand display address
          OUT LCDCNTL
          MVI B,8             ;all 8 right blanks
TBLANKR:  MVI A,' '
          CALL OUTLCD
          DJNZ TBLANKR
          RET

          ENDIF




*         DB '(C) 1989-2002 Dave Milici'




; RAM stuff...

          ORG RAMADDR

INTCTCV0: DS 2           ;interrupt vector addresses
INTCTCV1: DS 2
INTCTCV2: DS 2
INTCTCV3: DS 2
INTPIOVA: DS 2
INTPIOVB: DS 2
HOMEPNTR: DS 2

RESETBUF: DS 2           ;reset status buffer
MEMBUF:   DS 16          ;reset memory buffer

TICKTOCK: DS 1           ;clock ticker
REALTIME: DS 2           ;real-time clock
MARKTIME: DS 2           ;time marker

FRAMECNT: DS 2           ;frame count
EXPOSURE: DS 2           ;exposure time
LAPSE:    DS 2           ;lapse time
SPEED:    DS 2           ;film speed
COUNTER:  DS 2           ;display counter 

DIRSTAT:  DS 1           ;direction 
FRAMEABS: DS 2           ;absolute frame count

REVLNCNT: DS 2           ;full revolution step count
OPNSHCNT: DS 2           ;shutter-open step count
CLOSECNT: DS 2           ;shutter-closed step count
OPNANGLE: DS 2           ;shutter-open rotation angle (decimal)
EXPANGLE: DS 2           ;shutter-open exposure angle (decimal)

MINEXPTM: DS 2           ;minimum exposure time
VARSHTR:  DS 2           ;variable shutter angle (degrees)
MINSPEED: DS 2           ;minimum speed for time-exposures
WHIPSPD:  DS 2           ;whip-open speed for time-exposures
MINSPDBF: DS 2           ;minimum speed buffer for micro- or half-stepping
FPSPEED:  DS 2           ;frames-per-second speed for geared drive

RUNFRAME: DS 2           ;run-time frame count
REMFRAME: DS 2           ;run-time remaining frame count
RUNEXP:   DS 2           ;run-time exposure time count
RUNLAPSE: DS 2           ;run-time lapse time count
EXPSTAT:  DS 1           ;exposure time status
LAPSTAT:  DS 1           ;lapse time status
WAITIME:  DS 2           ;wait time delay counter
RUNOPEN:  DS 2           ;run-time shutter-open step count
RUNCLOSE: DS 2           ;run-time shutter-closed step count
RUNPRECL: DS 2           ;run-time pre-deceleration step count
EXPCOMP:  DS 2           ;exposure time compensation
LAPCOMP:  DS 2           ;lapse time compensation
HOLDSTAT: DS 1           ;run-time Hold status
MSGBUF3:  DS 2           ;run-time Message display

SWITMASK: DS 1           ;switch sensing mask
SWITSTAT: DS 1           ;switch sensing check-point status
SWITCNT:  DS 2           ;switch sensing check-point count

MOTROVER: DS 1           ;motor over
TIMROVER: DS 1           ;timer over
HOMEOVER: DS 1           ;home over
TORQOVER: DS 1		 ;torque over

CAM1STAT: DS 1           ;camera 1 active status
CAM2STAT: DS 1           ;camera 2 active status
SYNCSTAT: DS 1           ;camera 1+2 sync status
CAMXSTAT: DS 1           ;camera 1 or 2 counter selection status
CAM1CNTR: DS 2           ;camera 1 counter
CAM2CNTR: DS 2           ;camera 2 counter
DRVRSTAT: DS 1           ;camera or projector selection status
FRMRATIO: DS 2           ;motor drive ratio for counting frames
SPDRATIO: DS 2           ;motor drive ratio for running speeds

SEQSTAT:  DS 1           ;sequencer status
PROJSTAT: DS 1           ;projector motor active status
CNTRSTAT: DS 1           ;projector overide run-time counter status
PRJDIRST: DS 1           ;projector direction
CAMDIRST: DS 1           ;camera direction
PRJFRMCT: DS 2           ;projector frame count
CAMFRMCT: DS 2           ;camera frame count
PRJABSCT: DS 2           ;projector absolute frame count
CAMABSCT: DS 2           ;camera absolute frame count
PROJCNTR: DS 2           ;projector cummulative counter
CAMRCNTR: DS 2           ;camera cummulative counter
STEPRCNT: DS 2           ;camera step printing counter
SKIPRCNT: DS 2           ;projector skip printing counter
RUNSTEPR: DS 2           ;run-time camera step counter
RUNSKIPR: DS 2           ;run-time projector skip counter

TRIGTIME: DS 2           ;output trigger time-out delay
OUTFRAME: DS 2           ;out-frame counter #
TORQTIME: DS 2           ;motor torque time-out
TEXQTIME: DS 2           ;torque time-out during time exposures
AUXINCNT: DS 2		 ;auxiliary motor increment step count

STEPTIME: DS 2           ;step time
STEPCNT:  DS 2           ;step count
RAMPCNT:  DS 2           ;ramp count
RAMPABS:  DS 2           ;absolute ramp count
RAMPRUN:  DS 2           ;run-time ramp count
RAMPRUNL: DS 2           ;8-bit run-time ramp count
RAMPRUNH: DS 2           ;16-bit remaining ramp count
RUNDECEL: DS 2           ;run-time decel count
MAXPNTR:  DS 2           ;max ramp pointer
RAMPNTR:  DS 16          ;ramp table pointer
RAMPBUF:  DS 16          ;ramp table buffer (constant speed)

MICROST:  DS 1           ;micro-stepping status
TMRLDRBF: DS 1           ;timer loader buffer
TMRCMDBF: DS 1           ;timer command buffer
TMRMLTBF: DS 1           ;timer multiplier buffer
KSCALEBF: DS 2           ;step-time scaler buffer
LOWSPDBF: DS 2           ;min low speed buffer
TMRDIVBF: DS 1           ;timer pre-multiplier buffer

KEYSTAT:  DS 1           ;input key status
KEYBUF:   DS 1           ;input key buffer
DIGPNTR:  DS 2           ;input digit string pointer
DIGADDR:  DS 2           ;composite LED digit/address code pointer
DIGCNTR:  DS 1           ;LED digit counter
INDIGBUF: DS 16          ;input digit string buffer
OUTDIGBF: DS 16          ;output digit string buffer
XFERBUF:  DS 16          ;input-to-output digit string transfer buffer

CONVACCM: DS 2           ;digit string --> number value conversion accum
DECWT:    DS 2           ;decimal weight multiplier
FRACTION: DS 1           ;fractional decimal place counter
CONVCNTR: DS 1           ;total digit counter
NEGSTAT:  DS 1           ;negative number status
CURSRMEM: DS 1           ;flashing cursor memory
CURSRTME: DS 2           ;cursor software timer in multiples of 0.01 seconds

ADJLAPSE: DS 2           ;variable lapse time
LPACLCNT: DS 2           ;lapse time acceleration count
TMRSTAT:  DS 1           ;run-time variable lapse status
TMRPHZE:  DS 1           ;run-time variable lapse phase

ADJEXP:   DS 2           ;variable exposure time
EXACLCNT: DS 2           ;exposure time acceleration count
ETMSTAT:  DS 1           ;run-time variable exposure status
ETMPHZE:  DS 1           ;run-time variable exposure phase

WDGSTAT:  DS 1           ;wedge exposure sequence
FIXEXP:   DS 2           ;fixed exposure time
FIXCNT:   DS 2           ;preset frame count
ABSSTAT:  DS 1           ;absolute frame overide

RUNEACLT: DS 2           ;run-time exposure acceleration count
RUNEDCLT: DS 16          ;run-time exposure decleration count
EXPOSBUF: DS 1016        ;variable exposure time buffer

RUNACLCT: DS 2           ;run-time lapse acceleration count
RUNDCLCT: DS 16          ;run-time lapse decleration count
LAPSEBUF: DS 1016        ;variable lapse time buffer

LOWSPD:   DS 2           ;ramping Low Speed
HIGHSPD:  DS 2           ;ramping High Speed
DELTA:    DS 16          ;ramping speed difference
ACCLTBL2: DS 1016        ;ramp table for step times
ACCLTBL1: DS 2016        ;ramp table for speeds

STACK:    EQU RAMADDR+8100



          END
          
