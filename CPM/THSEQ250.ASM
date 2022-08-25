
* The birth of a new ThingM.
* Production version IRL 3+4.

* 06-17-94
* Copyright 1990 Penguin Associates,
* Ironic Research Labs, San Francisco.

* Option for LED Display or Liquid Crystal Display.
* Dual 8-character buffers for left and right display addressing.
* Use center 12 characters of 16-character positions for display.

* Null RS-232 Serial Interface.
* Multiplexed input/output via remote terminal.
* Output to LED displays echoed to serial output port.
* Input polled from both keypad and serial input port.

* 400 ppr half-stepper. 
* 16-bit run-time ramping.
* Open-loop operation counts stepper pulses.
* Closed-loop operation senses switch interrupts.

* Bolex camera installation.
* DC stepping motor @ 120 rpm.
* Home switch sensing inverted = Low.

* Additional axis sequencer.
* DC stepping motor @ 120 rpm.
* Home switch sensing inverted = Low.

* Sequence Camera and 1 Projector for SFAI.
* Both camera and projector use DC stepping and direction signals.
* Motor enable lines are used to defeat one motor or the other.
* Both Camera and Projector Home switch signals are used.
* Step Camera and Skip Projector Sequencing.
* Separate speed ramp tables for camera and projector.
* Time exposure mode restored for camera only.
* Film Speed selection affects projector only.
* Open-loop safety detection for Projector Home.



FALSE:    EQU 0
TRUE:     EQU NOT FALSE

VERSION:  EQU 250        ;Version Number

CLK1MHZ:  EQU FALSE      ;1 MHz
CLK125M:  EQU TRUE       ;1.2288 MHz
CLK180M:  EQU FALSE      ;1.8432 MHz
CLK2MHZ:  EQU FALSE      ;2 MHz
CLK250M:  EQU FALSE      ;2.4576 MHz
CLK360M:  EQU FALSE      ;3.6864 MHz
CLK4MHZ:  EQU FALSE      ;4 MHz
CLK6MHZ:  EQU FALSE      ;6 MHz
CLK8MHZ:  EQU FALSE      ;8 MHz

PROTOTYPE EQU FALSE      ;Prototype

LEDISPLAY EQU TRUE       ;LED display
LCDISPLAY EQU FALSE      ;LCD display

PHONEKEY: EQU TRUE       ;Telephone keypad

SERIALIO: EQU FALSE      ;Serial interface




          IF PROTOTYPE

ROMADDR:  EQU 0000H      ;ROM code space
RAMADDR:  EQU 8000H      ;RAM data space

CTCADDR:  EQU 80H        ;CTC counters
PIOADDR:  EQU 40H        ;PIO ports
SIOADDR:  EQU 20H        ;SIO ports
LEDADDR:  EQU 10H        ;LED displays

          ENDIF

          IF NOT PROTOTYPE

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

          IF LEDISPLAY
LED:      EQU LEDADDR+0  ;LED output display port
          ENDIF

          IF LCDISPLAY

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




; Prototype or production version pin-outs.

          IF PROTOTYPE

MTRG:     EQU 7          ;motor run trigger output line
MDIR:     EQU 6          ;motor direction output line
MNPR:     EQU 5          ;motor enable projector
MNCM:     EQU 3          ;motor enable camera

DCUR:     EQU 4          ;display cursor enable line

SHMC:     EQU 0          ;switch home camera input
SHMP:     EQU 1          ;switch home projector input
STRG:     EQU 2          ;switch trigger input

          ENDIF

          IF NOT PROTOTYPE

MDIR:     EQU 6          ;motor direction output line
MNCM:     EQU 4          ;motor enable camera
MNPR:     EQU 5          ;motor enable projector

DCUR:     EQU 3          ;display cursor enable line

SHMC:     EQU 0          ;switch home camera input
SHMP:     EQU 1          ;switch home projector input
STRC:     EQU 2          ;switch trigger camera input
STRP:     EQU 7          ;switch trigger projector input

          ENDIF

; External Trigger definitions.

TRIGPORT: EQU SWITCH

TRCM:     EQU STRC
TRP1:     EQU STRP



; Serial Interface definitions.

          IF SERIALIO

SIOA:     EQU SIOADDR+0  ;SIO data port A
SIOCNTLA: EQU SIOADDR+1  ;SIO control port A

SIOB:     EQU SIOADDR+2  ;SIO data port B
SIOCNTLB: EQU SIOADDR+3  ;SIO control port B

SIOCMD:   EQU SIOCNTLB   ;SIO command output port
SIODATA:  EQU SIOB       ;SIO data input/output port
SIOSTAT:  EQU SIOCNTLB   ;SIO status input port
BAUDCLK:  EQU CTC2       ;SIO baud clock generator

          ENDIF




; Microprocessor clock speed dependent constants.

          IF CLK1MHZ

QT01:     EQU 39         ;0.01 sec quantum time @ 1 MHz / 256
QT01SOFT: EQU 417        ;0.01 sec quantum time @ 1 MHz / 24 T-states
KSCALEHF: EQU 15600      ;speed scaling constant half-stepping @ 1 MHz
LOWSPDHF: EQU 62         ;minimum low speed half-stepping @ 1 MHz
KSCALEMS: EQU 3120       ;speed scaling constant micro-stepping @ 1 MHz
LOWSPDMS: EQU 12         ;minimum low speed micro-stepping @ 1 MHz
BNCETM:   EQU 500*2      ;mechanical switch debouncing time
BAUD9600: EQU 3          ;9600 baud rate clock @ 1 MHz / 2 / 16
BAUD4800: EQU 6          ;4800 baud rate clock @ 1 MHz / 2 / 16

          ENDIF

          IF CLK125M

QT01:     EQU 48         ;0.01 sec quantum time @ 1.2288 MHz / 256 exactly
QT01SOFT: EQU 512        ;0.01 sec quantum time @ 1.2 MHz / 24 T-states
KSCALEHF: EQU 19170      ;speed scaling constant half-stepping @ 1.2 MHz
LOWSPDHF: EQU 76         ;minimum low speed half-stepping @ 1.2 MHz
KSCALEMS: EQU 3834       ;speed scaling constant micro-stepping @ 1.2 MHz
LOWSPDMS: EQU 15         ;minimum low speed micro-stepping @ 1.2 MHz
BNCETM:   EQU 620*2      ;mechanical switch debouncing time
BAUD9600: EQU 4          ;9600 baud rate clock @ 1.2 MHz / 2 / 16 exactly
BAUD4800: EQU 8          ;4800 baud rate clock @ 1.2 MHz / 2 / 16 exactly

          ENDIF

          IF CLK180M

QT01:     EQU 72         ;0.01 sec quantum time @ 1.8432 MHz / 256 exactly
QT01SOFT: EQU 768        ;0.01 sec quantum time @ 1.8 MHz / 24 T-states
KSCALEHF: EQU 28080      ;speed scaling constant half-stepping @ 1.8 MHz
LOWSPDHF: EQU 111        ;minimum low speed half-stepping @ 1.8 MHz
KSCALEMS: EQU 5616       ;speed scaling constant micro-stepping @ 1.8 MHz
LOWSPDMS: EQU 22         ;minimum low speed micro-stepping @ 1.8 MHz
BNCETM:   EQU 900*2      ;mechanical switch debouncing time
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
BNCETM:   EQU 1000*2     ;mechanical switch debouncing time
BAUD9600: EQU 7          ;9600 baud rate clock @ 2 MHz / 2 / 16
BAUD4800: EQU 13         ;4800 baud rate clock @ 2 MHz / 2 / 16

          ENDIF

          IF CLK250M

QT01:     EQU 96         ;0.01 sec quantum time @ 2.4576 MHz / 256 exactly
QT01SOFT: EQU 1024       ;0.01 sec quantum time @ 2.4 MHz / 24 T-states
KSCALEHF: EQU 38339      ;speed scaling constant half-stepping @ 2.4 MHz
LOWSPDHF: EQU 151        ;minimum low speed half-stepping @ 2.4 MHz
KSCALEMS: EQU 7668       ;speed scaling constant micro-stepping @ 2.4 MHz
LOWSPDMS: EQU 29         ;minimum low speed micro-stepping @ 2.4 MHz
BNCETM:   EQU 1230*2     ;mechanical switch debouncing time
BAUD9600: EQU 8          ;9600 baud rate clock @ 2.4 MHz / 2 / 16 exactly
BAUD4800: EQU 16         ;4800 baud rate clock @ 2.4 MHz / 2 / 16 exactly

          ENDIF

          IF CLK360M

QT01:     EQU 144        ;0.01 sec quantum time @ 3.6864 MHz / 256 exactly
QT01SOFT: EQU 1536       ;0.01 sec quantum time @ 3.6 MHz / 24 T-states
KSCALEHF: EQU 56160      ;speed scaling constant half-stepping @ 3.6 MHz
LOWSPDHF: EQU 221        ;minimum low speed half-stepping @ 3.6 MHz
KSCALEMS: EQU 11232      ;speed scaling constant micro-stepping @ 3.6 MHz
LOWSPDMS: EQU 44         ;minimum low speed micro-stepping @ 3.6 MHz
BNCETM:   EQU 1800*2     ;mechanical switch debouncing time
BAUD9600: EQU 12         ;9600 baud rate clock @ 3.6 MHz / 2 / 16 exactly
BAUD4800: EQU 24         ;4800 baud rate clock @ 3.6 MHz / 2 / 16 exactly

          ENDIF

          IF CLK4MHZ

QT01:     EQU 156        ;0.01 sec quantum time @ 4 MHz / 256
QT01SOFT: EQU 1667       ;0.01 sec quantum time @ 4 MHz / 24 T-states
KSCALEHF: EQU 62400      ;speed scaling constant half-stepping @ 4 MHz
LOWSPDHF: EQU 245        ;minimum low speed half-stepping @ 4 MHz
KSCALEMS: EQU 12480      ;speed scaling constant micro-stepping @ 4 MHz
LOWSPDMS: EQU 49         ;minimum low speed micro-stepping @ 4 MHz
BNCETM:   EQU 2000*2     ;mechanical switch debouncing time
BAUD9600: EQU 13         ;9600 baud rate clock @ 4 MHz / 2 / 16

          ENDIF

          IF CLK6MHZ

QT01:     EQU 234        ;0.01 sec quantum time @ 6 MHz / 256
QT01SOFT: EQU 2500       ;0.01 sec quantum time @ 6 MHz / 24 T-states
KSCALEHF: EQU 46800      ;1/2 speed scaling constant half-stepping @ 6 MHz
LOWSPDHF: EQU 369        ;minimum low speed half-stepping @ 6 MHz
KSCALEMS: EQU 18720      ;speed scaling constant micro-stepping @ 6 MHz
LOWSPDMS: EQU 74         ;minimum low speed micro-stepping @ 6 MHz
BNCETM:   EQU 3000*2     ;mechanical switch debouncing time
BAUD9600: EQU 20         ;9600 baud rate clock @ 6 MHz / 2 / 16

          ENDIF

          IF CLK8MHZ

QT01:     EQU 312        ;0.01 sec quantum time @ 8 MHz / 256
QT01SOFT: EQU 3333       ;0.01 sec quantum time @ 8 MHz / 24 T-states
KSCALEHF: EQU 62400      ;1/2 speed scaling constant half-stepping @ 8 MHz
LOWSPDHF: EQU 492        ;minimum low speed half-stepping @ 8 MHz
KSCALEMS: EQU 24960      ;speed scaling constant micro-stepping @ 8 MHz
LOWSPDMS: EQU 98         ;minimum low speed micro-stepping @ 8 MHz
BNCETM:   EQU 4000*2     ;mechanical switch debouncing time
BAUD9600: EQU 26         ;9600 baud rate clock @ 8 MHz / 2 / 16

          ENDIF




; Reset initialization routines.

          ORG 0000H

          IF PROTOTYPE
QUIETIO:  EQU 01111000B       ;quiet output: MTRG, MDIR, MNPR, DCUR, MNCM
          ENDIF

          IF NOT PROTOTYPE
QUIETIO:  EQU 01111000B       ;quiet output: MTRG, MDIR, MNPR, MNCM, DCUR
          ENDIF

RESET:    MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLB
          MVI A,10000111B     ;identify input/output directions
          OUT PIOCNTLB
          MVI A,QUIETIO       ;quiet output lines
          OUT PIOB

          XRA A               ;time delay
WAITRSET: DCR A
          JNZ WAITRSET

          DI
          IM2                 ;Z80 vectored interrupts

          LXI SP,STACK
          CALL RESETPIO       ;init parallel ports
          CALL RESETLED       ;init LED or LCD display
          CALL RESETCTC       ;init counters / timers
          CALL RESETSIO       ;init serial interface
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



          DB '(C) 1992 Penguin Associates'

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
          ORA C             ;16-bit ramp count over ?
          JNZ EXITACLX

          SHLD MAXPNTR      ;save ramp table pointer
          LXI H,CONSTINT
          SHLD INTCTCV0

EXITACLX: EXAF
          EXX
          EI
          RETI

; Constant Speed phase of ramping.
; (Pulses counted by hardware counter CTC1.)
; DE <-- pre-deceleration step count

CONSTINT: EXX
          EXAF
          DCX D               ;update pre-decel step count (DE')
          MOV A,D
          ORA E
          JNZ EXITCONS        ;count over ?

          LXI H,DECLXINT      ;then point to deceleration interrupt
          SHLD INTCTCV0
          LXI H,NULLINT
          SHLD INTCTCV1
          SHLD INTCTCV3
          LHLD MAXPNTR        ;re-load ramp table pointer (HL')
          DCX H
          LBCD RAMPRUN        ;load decel ramp count (BC')

EXITCONS: EXAF
          EXX
          EI
          RETI

; Stop all timers and counters right now...
; Allow for DC stepper motor enable time-out.
; Insure stopping motor at Home switch signal.
; (1) Mask for Camera Home ?
; (2) Mask for Main Projector Home ?

STOPINT:  EXX
          EXAF

STOPNOW:  LDA SWITMASK        ;check if timed-out stop or switched stop
          ORA A
          JNZ STOPRUN

          LDA WHSWITCH        ;which switch...camera or projector ?
          BIT SHMC,A
          JZ SENSCAM

          BIT SHMP,A          ;or...main projector or aerial projector ?
          JZ SENSPROJ

          JMP STOPRUN

SENSPROJ: IN SWITCH	      ;sense projector home switch ?
          BIT SHMP,A          ;(switch active low ... XXXXX110)
          JNZ STOPGAP         ;if not switched, then check for time-out

          JMP STOPRUN         ;if projector switch home, then stop it

SENSCAM:  IN SWITCH           ;sense camera home switch ?
          BIT SHMC,A          ;(switch active low ... XXXXX110)
          JNZ STOPGAP         ;if not switched, then check for time-out

STOPRUN:  MVI A,NC000NRC      ;if over, then reset timers
          OUT CTC0
          OUT CTC1
          MVI A,IT800LRC      ;load DC motor enable time-out
          OUT CTC3
          MVI A,QT01          ;0.01 second intervals
          OUT CTC3

          LXI H,NULLINT       ;point to null interrupt vectors
          SHLD INTCTCV0
          SHLD INTCTCV1
          LXI H,LASTINT       ;point to final time-out interrupt
          SHLD INTCTCV3

          LDA TORQTIME        ;torque time-out interval

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
          SHLD INTCTCV3

          EXAF
          EXX
          EI
          RETI

; Time-out for DC Motor Enable signal after last step pulse.
;    A <-- software time-out interval multiple.
; CTC3 <-- hardware time-out interval base.

LASTINT:  EXX
          EXAF

          DCR A               ;time-out ?
          JNZ EXITLAST

          MVI A,NT800NRC      ;reset time-out timer
          OUT CTC3

          LXI H,NULLINT       ;point to null interrupt vectors
          SHLD INTCTCV3

          CALL MOTORNUL       ;de-energize motor

          XRA A               ;signal motor over
          STA MOTROVER

EXITLAST: EXAF
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

; Acceleration routine for multiple revoltions.

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

EXITFRMX: EXAF
          EXX
          EI
          RETI

; Multiple revolution frame count interrupt routine.
; CTC0 <-- step-time timer/counter.
; CTC1 <-- step-count low-byte counter.
; CTC3 <-- step-count high-byte counter.
;  A <-- control byte constant
;  B <-- acceleration phase ramp count
;  C <-- timer port address
; DE <-- run-time frame count
; HL <-- acceleration phase step-time pointer.
; Note run-time frame counters are updated here.
; Frames are detected according to motor revolutions.

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

          LXI H,NULLINT       ;if last revolution, do nothing yet 
          SHLD INTCTCV3
          SHLD INTPIOVB

          LDED RUNPRECL       ;change over to step counter for last frame

          MVI A,NC000NRC      ;reset high-order counter CTC2
          OUT CTC3

          LXI H,NULLINT
          SHLD INTCTCV3
          SHLD INTCTCV1

          LXI H,CONSTINT      ;point to Constant-Speed Int for last frame
          SHLD INTCTCV0

EXITFRME: POP PSW
          POP H
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
          XRA A               ;signal timer over
          STA TIMROVER
          LXI H,NULLINT       ;point to null vector
          SHLD INTCTCV3

EXITWAIT: EXAF
          EXX
          EI
          RETI

; Cursor interrupt routine.

          IF LEDISPLAY

; Flashing cursor on LED display according to timer interrupt CTC3.

CURSRINT: EXX
          EXAF
          DCR B                 ;update flasher timer counter
          JNZ EXITCURS

          IN CONTROL		;access the LED cursor
          RES DCUR,A
          OUT CONTROL

          LDA CURSRMEM		;load the cursor
          XRI 00000001B         ;toggle it
          OUT LED+0		;flash on 1st digit
          STA CURSRMEM		;save in memory

          MVI B,15		;pre-load short duty cycle for cursor
          BIT 0,A		;cursor ?
          JRNZ WINKIT
          MVI B,35		;re-load long duty cycle for digit

WINKIT:   IN CONTROL		;release the LED cursor
          SETB DCUR,A
          OUT CONTROL

EXITCURS: EXAF
          EXX
          EI
          RETI

          ENDIF

; Motor revolution counter interrupt routine.
; Interrupts ping-pong between Count switch sensing and Home switch sensing.

PIOINTH:  EQU 10110111B       ;enable interrupt lines active high
PIOINTL:  EQU 10010111B       ;enable interrupt lines active low
PIOINTN:  EQU 00010111B       ;disable interrupt lines (active low)
PIOMASK:  EQU 11111111B       ;default interrupt line mask




; Main program loop.
; All branches via subroutines only.

          ORG 0300H
         
MOKF:     DB 'OK+'
MOKR:     DB 'OK-'

MAIN:     CALL GETCAMPR       ;camera or projector ?

          LXI H,MOKF          ;display Ready prompt
          CALL OUTSIGN        ;with direction
          CALL OUTMUX3        ;echo out SIO

          LHLD COUNTER        ;display frame count
          CALL OUTMUX5        ;echo output SIO

WAITMAIN: IN TRIGPORT         ;trigger input ?
          BIT TRCM,A          ;Camera Trigger ?
          JNZ TRGCAMIT
          BIT TRP1,A          ;Projector Trigger ?
          JNZ TRGPRJIT

          CALL INMUX          ;get key from KEY or SIO port
          JNC WAITMAIN

          LDA KEYBUF
          CPI PROGRAM         ;Program ?
          CZ PRGMIT

          CPI ONE             
          CZ CAMERAIT         ;Camera Selection ?

          CPI TWO             
          CZ PROJCTIT         ;Projector Selection ?

          CPI THREE
          CZ PROJCTIT         ;Projector Selection ?

          CPI FOUR            
          CZ FRAMEIT          ;Frame Count ?

          CPI FIVE            
          CZ COUNTIT          ;Total Count ?

          CPI SIX             
          CZ OUTFRMIT         ;Out Frame ?

          CPI SEVEN           
          CZ STPSEQIT         ;Step Camera Sequence ?

          CPI EIGHT
          CZ ALTSEQIT         ;Alternate Sequence ?

          CPI NINE            
          CZ SKPSEQIT         ;Skip Projector Sequence ?

          CPI ZERO
          CZ SEQIT            ;Sequence Camera + Projectors ?

          CPI MINUS           
          CZ DIRIT            ;Direction ?

          CPI RUN             
          CZ RUNIT            ;Run ?

          CALL PUTCAMPR       ;remember to update camera or projector...

          JMP MAIN            ;re-loop

; External Trigger input loop.
; Sub-branch from Main Loop (not subroutine).
; Run only 1 single Camera frame here.

TRGCAMIT: LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          IN TRIGPORT         ;trigger input still ?
          BIT TRCM,A
          JZ EXITTRGC         ;if not, then forget it

WAITTRIG: IN TRIGPORT         ;else wait for switch release
          BIT TRCM,A
          JNZ WAITTRIG

          LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          LDA SEQSTAT         ;buffer sequencer status
          PUSH PSW
          LDA PROJSTAT        ;and projector status
          PUSH PSW

          MVI A,FALSE
          STA SEQSTAT         ;no sequencer
          STA PROJSTAT        ;no projector

          CALL GETCAMPR       ;get camera data

          LHLD FRAMEABS       ;save preset frame counts and status
          PUSH H

          LXI H,1             ;preset 1 single frame only
          SHLD FRAMEABS

          CALL RUNIT          ;then run it...

          CALL PUTCAMPR       ;update all data as is

          POP H               ;restore preset values
          SHLD FRAMEABS
          POP PSW
          STA PROJSTAT
          POP PSW
          STA SEQSTAT

          CALL GETCAMPR       ;get all data

          CALL PUTCAMPR       ;update all data

EXITTRGC: JMP MAIN

; Run only 1 single Projector frame here.

TRGPRJIT: LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          IN TRIGPORT         ;trigger input still ?
          BIT TRP1,A
          JZ EXITTRGP         ;if not, then forget it

WAITTRGP: IN TRIGPORT         ;else wait for switch release
          BIT TRP1,A
          JNZ WAITTRGP

          LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          LDA SEQSTAT         ;buffer sequencer status
          PUSH PSW
          LDA PROJSTAT        ;and projector status
          PUSH PSW

          MVI A,FALSE
          STA SEQSTAT         ;no sequencer
          MVI A,TRUE
          STA PROJSTAT        ;yes projector

          CALL GETCAMPR       ;get projector data

          LHLD FRAMEABS       ;save preset frame counts and status
          PUSH H

          LXI H,1             ;preset 1 single frame only
          SHLD FRAMEABS

          CALL RUNIT          ;then run it...

          CALL PUTCAMPR       ;update all data as is

          POP H               ;restore preset values
          SHLD FRAMEABS
          POP PSW
          STA PROJSTAT
          POP PSW
          STA SEQSTAT

          CALL GETCAMPR       ;get all data

          CALL PUTCAMPR       ;update all data

EXITTRGP: JMP MAIN

; Display direction forward or reverse as + or -.

OUTSIGN:  LDA DIRSTAT         ;check direction ?
          ORA A
          JNZ OUTMINUS

          LXI H,MOKF          ;+ if forward
          RET

OUTMINUS: LXI H,MOKR          ;- if reverse
          RET

; Get camera or projector data from memory buffers.
; Distinguish between main projector and aerial projector data.

GETCAMPR: LDA PROJSTAT		;projector ?
          ORA A
          JNZ GETPROJR

          LHLD CAMRCNTR		;un-buffer camera counter
          SHLD COUNTER 
          LHLD CAMFRMCT		;camera frame count
          SHLD FRAMECNT
          CALL FRMTODIR         ;select camera direction
          SHLD FRAMEABS         ;and absolute value count
          LHLD CAMOUTFR         ;camera out frame
          SHLD OUTFRAME 
          RET

GETPROJR: LHLD PROJCNTR		;un-buffer projector counter
          SHLD COUNTER 
          LHLD PRJFRMCT		;projector frame count
          SHLD FRAMECNT
          CALL FRMTODIR         ;select projector direction
          SHLD FRAMEABS         ;and absolute value count
          LHLD PRJOUTFR         ;projector out frame
          SHLD OUTFRAME 
          RET

; Put camera or projector data into memory buffers.
; Distinguish between main projector and aerial projector data.

PUTCAMPR: LDA PROJSTAT		;projector ?
          ORA A
          JNZ PUTPROJR

          LHLD COUNTER		;buffer camera counter
          SHLD CAMRCNTR
          LHLD FRAMECNT		;camera frame count
          SHLD CAMFRMCT
          LDA  DIRSTAT		;camera direction
          STA  CAMDIRST
          LHLD OUTFRAME         ;camera out frame
          SHLD CAMOUTFR 
          RET

PUTPROJR: LHLD COUNTER		;buffer projector counter
          SHLD PROJCNTR
          LHLD FRAMECNT		;projector frame count
          SHLD PRJFRMCT
          LDA  DIRSTAT		;projector direction
          STA  PRJDIRST
          LHLD OUTFRAME         ;projector out frame
          SHLD PRJOUTFR 
          RET

; Program input loop.

          IF LEDISPLAY
MPGM:     DB 'PGM'
M029:     DB ' 0--9'
          ENDIF

          IF LCDISPLAY
MPGM:     DB 'PGM'
M029:     DB '  0--9'
          ENDIF

PRGMIT:   PUSH PSW

          LXI H,MPGM          ;display Program mode
          CALL OUTMUX3
          LXI H,M029          ;with mini menu prompt
          CALL OUTLED5
          LXI H,M029
          CALL OUTSIO5
          CALL OUTEOLN

WAITPRGM: CALL INMUX          ;get Program key
          JNC WAITPRGM

          LDA KEYBUF
          CPI PROGRAM         ;Menu Selection ?
          CZ MENUIT

          CPI ONE             
          CZ CAMERAIT         ;Camera ?

          CPI TWO             
          CZ PROJCTIT         ;Projector ?

          CPI THREE
          CZ PROJCTIT         ;Projector ?

          CPI FOUR            
          CZ FRAMEIT          ;Frame Count ?

          CPI FIVE            
          CZ COUNTIT          ;Total Count ?

          CPI SIX             
          CZ OUTFRMIT         ;Out Frame ?

          CPI SEVEN           
          CZ STPSEQIT         ;Step Camera Sequence ?

          CPI EIGHT
          CZ ALTSEQIT         ;Alternate Sequence ?

          CPI NINE            
          CZ SKPSEQIT         ;Skip Projector Sequence ?

          CPI ZERO
          CZ SEQIT            ;Sequence Camera + Projectors ?

          CPI MINUS           
          CZ DIRIT            ;Direction ?

          CPI POINT           
          CZ INTERNIT         ;Internal Selections ?

          CALL PUTCAMPR       ;remember to update camera or projector...

          POP PSW             ;otherwise return to main menu
          RET

; Scroll through range of menu selections.

; Menu selections may be 1 of 3 series,
; depending on Camera, Projector, or Sequencer.

MENUIT:   PUSH PSW

          LDA PROJSTAT        ;Camera or Projector menu ?
          ORA A
          JNZ MENUPRJT

          CALL CAMERAIT       ;Camera menu...
          CALL INMUX
          XRA A
          STA KEYSTAT
          STA KEYBUF
          CALL FRAMEIT        
          CALL PUTCAMPR
          CALL DIRIT
          CALL PUTCAMPR
          CALL SEQIT
          JMP MENUSEQT

MENUPRJT: CALL PROJCTIT       ;Projector menu...
          CALL INMUX
          XRA A
          STA KEYSTAT
          STA KEYBUF
          CALL FRAMEIT
          CALL PUTCAMPR
          CALL DIRIT
          CALL PUTCAMPR
          CALL SEQIT
          JMP MENUSEQT

MENUSEQT: LDA SEQSTAT         ;Sequencer menu too ?
          ORA A
          JZ EXITMENU

          LDA SKIPSTAT        ;Skip Projector ?
          ORA A
          PUSH PSW
          CNZ SKPSEQIT        ;then Skip Projector menu
          POP PSW
          JNZ EXITMENU

          LDA STEPSTAT        ;else Step Camera ?
          ORA A
          PUSH PSW
          CNZ STPSEQIT        ;then Step Camera menu
          POP PSW
          JNZ EXITMENU

          CALL ALTSEQIT       ;else Alternate menu

EXITMENU: POP PSW
          RET

; Allow for internal programming selections.

          IF LEDISPLAY
MINT:     DB 'INT'
M125:     DB ' 1--9'
          ENDIF

          IF LCDISPLAY
MINT:     DB 'INT'
M125:     DB '  1--9'
          ENDIF

INTERNIT: PUSH PSW
          
          LXI H,MINT          ;display Internal mode
          CALL OUTMUX3
          LXI H,M125
          CALL OUTLED5
          LXI H,M125
          CALL OUTSIO5
          CALL OUTEOLN

WAITINTE: CALL INMUX          ;get Internal Program key
          JNC WAITINTE

          LDA KEYBUF
          CPI POINT           
          CZ IMENUIT          ;Internal Menu ?

          CPI PROGRAM         
          CZ IMENUIT          ;Internal Menu ?

          CPI ZERO
          CZ VERIT            ;Version ?

          CPI ONE             
          CZ EXPIT            ;Exposure Time ?

          CPI TWO
          CZ LAPSEIT          ;Lapse Time ?

          CPI THREE
          CZ ADJUSTIT         ;Projector Adjustment ?

          CPI FOUR
          CZ STEPIT           ;Step Count ?

          CPI FIVE
          CZ OPENIT           ;Shutter-Open ?

          CPI SIX
          CZ MINSPDIT         ;Minimum Speed ?

          CPI SEVEN
          CZ SPEEDIT          ;Film Speed ?

          CPI EIGHT
          CZ ACCELIT          ;Acceleration Ramp ?

          CPI NINE
          CZ TORQIT           ;Torque Time-out ?

          POP PSW
          RET                 ;else return to main menu

; Scroll through Internal Menu selection sequence.

IMENUIT:  PUSH PSW

          CALL VERIT
          CALL EXPIT
          CALL LAPSEIT
          CALL ADJUSTIT
          CALL STEPIT
          CALL OPENIT
          CALL MINSPDIT
          CALL SPEEDIT
          CALL ACCELIT
          CALL TORQIT

          POP PSW
          RET

; Camera Data Selection.
; Used as prefix to other data selections.

MCAM:     DB 'CAM'

CAMERAIT: PUSH PSW

          LXI H,MCAM            ;prompt CAM
          CALL OUTMUX3

          MVI A,FALSE		;select camera
          STA PROJSTAT

          CALL GETCAMPR         ;get camera data from buffer

          LHLD CAMRCNTR		;camera counter
          SHLD COUNTER
          CALL OUTMUX5          ;out LED + SIO

WAITCAMD: CALL INMUXST          ;display until key press
          JZ WAITCAMD

          POP PSW
          RET     

; Projector Overide Frame Count Input.
; Used as prefix to other data selections.
; Distinction between Main Projector and Aerial Projector.

MPRJ:     DB 'PRJ'

PROJCTIT: PUSH PSW

          LXI H,MPRJ            ;prompt PRJ
          CALL OUTMUX3

          MVI A,TRUE		;select projector
          STA PROJSTAT

          CALL GETCAMPR         ;get projector data from buffer

          LHLD PROJCNTR		;projector counter
          SHLD COUNTER
          CALL OUTMUX5          ;out LED + SIO

WAITPRJD: CALL INMUXST          ;display until key press
          JZ WAITPRJD

          POP PSW
          RET

; Sequence Camera : Projector selection.
; Note: SEQ selection does not affect CAM/PRJ selection.

SEQKEY:   SET ZERO            ;SEQ toggle key (defined later)

          IF LEDISPLAY
MSEQ:     DB 'SEQ'
MSEQ0:    DB ' OFF-'
MSEQ1:    DB '  ON+'
          ENDIF

          IF LCDISPLAY
MSEQ:     DB 'SEQ'
MSEQ0:    DB '  OFF-'
MSEQ1:    DB '   ON+'
          ENDIF

SEQIT:    PUSH PSW

          LXI H,MSEQ          ;prompt SEQ
          CALL OUTMUX3

LOOPSEQT: LXI H,MSEQ          ;prompt SEQ status
          CALL OUTMUX3
          CALL OUTSEQ         ;display SEQ status
          CALL OUTLED5
          CALL OUTSEQ
          CALL OUTSIO5        ;echo out SIO
          CALL OUTEOLN
          CALL CURSRON        ;flash cursor (locally)

WAITSEQT: CALL INMUX          ;loop for key input
          JNC WAITSEQT

          LDA KEYBUF
          CPI ENTER           ;'Enter' for completion ?
          JZ EXITSEQ
          CPI PROGRAM         ;'Program' too ?
          JZ EXITSEQ
          CPI MINUS           ;'-' for toggle ?
          JZ FLOPSEQ
          CPI SEQKEY
          JNZ WAITSEQT

FLOPSEQ:  LDA SEQSTAT         ;toggle SEQ status
          CMA
          STA SEQSTAT
          JMP LOOPSEQT

EXITSEQ:  CALL CURSROFF
          POP PSW
          RET

; Display sequencer SEQ status.

OUTSEQ:   LDA SEQSTAT         ;SEQ status ?
          ORA A
          JNZ OUTSEQ1

          LXI H,MSEQ0
          RET

OUTSEQ1:  LXI H,MSEQ1
          RET

; Camera : Projector Sequencer Step : Skip Count Input.
; Both Camera : Projector Counters loaded.
; Note: ALT/STP/SKP selections do not affect SEQ selection.

; Sequencer input for Alternate Camera & Projector operation.

MALT:     DB 'ALT'
MTO:      DB '+TO'

ALTSEQIT: PUSH PSW

          MVI A,FALSE
          STA STEPSTAT        ;no step camera
          STA SKIPSTAT        ;no skip projector

          LXI H,MALT
          CALL OUTMUX3

          LHLD STEPRCNT       ;update alternate camera count
          CALL OUTMUX5
          CALL MODNUM
          SHLD STEPRCNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ NEXTALT
          LXI H,1
          SHLD STEPRCNT

NEXTALT:  LXI H,MTO
          CALL OUTMUX3

          LHLD SKIPRCNT       ;update alternate projector count
          CALL OUTMUX5
          CALL MODNUM
          SHLD SKIPRCNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ EXITALT
          LXI H,1
          SHLD SKIPRCNT

EXITALT:  POP PSW
          RET

; Sequencer input for Step Camera operation.

STPSEQIT: PUSH PSW

          MVI A,TRUE
          STA STEPSTAT       ;yes step camera
          MVI A,FALSE
          STA SKIPSTAT       ;no skip projector

          LXI H,MSTP
          CALL OUTMUX3

          LHLD STEPRCNT      ;update step camera count
          CALL OUTMUX5
          CALL MODNUM
          SHLD STEPRCNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ NEXTSTPT
          LXI H,1
          SHLD STEPRCNT

NEXTSTPT: LXI H,MTO
          CALL OUTMUX3

          LHLD CYCLECNT       ;update step cycle count
          CALL OUTMUX5
          CALL MODNUM
          SHLD CYCLECNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ EXITSTPT
          LXI H,1
          SHLD CYCLECNT

EXITSTPT: POP PSW
          RET

; Sequencer input for Skip Projector operation.

MSKP:     DB 'SKP'

SKPSEQIT: PUSH PSW

          MVI A,TRUE
          STA SKIPSTAT       ;yes skip projector
          MVI A,FALSE
          STA STEPSTAT       ;no step camera

          LXI H,MSKP
          CALL OUTMUX3

          LHLD CYCLECNT      ;update skip cycle count
          CALL OUTMUX5
          CALL MODNUM
          SHLD CYCLECNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ NEXTSKPT
          LXI H,1
          SHLD CYCLECNT

NEXTSKPT: LXI H,MTO
          CALL OUTMUX3

          LHLD SKIPRCNT       ;update skip projector count
          CALL OUTMUX5
          CALL MODNUM
          SHLD SKIPRCNT
          MOV A,H             ;if 0, then min out
          ORA L
          JNZ EXITSKPT
          LXI H,1
          SHLD SKIPRCNT

EXITSKPT: POP PSW
          RET

; Individual data selections.
; Frame Count input.

MFRM:     DB 'FRM'

FRAMEIT:  PUSH PSW

          LXI H,MFRM          ;prompt FRM
          CALL OUTMUX3

          LHLD FRAMECNT       ;update frame count
          CALL OUTMUX5        ;out LED + SIO
          CALL MODNUM
          SHLD FRAMECNT
          SHLD FRAMEABS

          CALL FRMTODIR
          SHLD FRAMEABS

EXITFRM:  POP PSW
          RET     

; Direction Forward / Reverse input.

          IF LEDISPLAY
MDRN:     DB 'DIR'
MFOR:     DB ' FOR+'
MREV:     DB ' REV-'
          ENDIF

          IF LCDISPLAY
MDRN:     DB 'DIR'
MFOR:     DB '  FOR+'
MREV:     DB '  REV-'
          ENDIF

DIRIT:    PUSH PSW

LOOPDIRT: LXI H,MDRN          ;prompt DIR direction
          CALL OUTMUX3
          CALL OUTDIR         ;display FOR or REV direction
          CALL OUTLED5
          CALL OUTDIR
          CALL OUTSIO5        ;echo out SIO
          CALL OUTEOLN
          CALL CURSRON        ;flash cursor (locally)

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

EXITDIR:  CALL CURSROFF
          POP PSW
          RET

; Display forward or reverse direction.

OUTDIR:   LDA DIRSTAT
          ORA A
          JNZ OUTREV

          LXI H,MFOR
          RET

OUTREV:   LXI H,MREV
          RET

; Out Frame Number --> Frame Count selection.

MOUT:     DB 'END'

OUTFRMIT: PUSH PSW

          LXI H,MOUT            ;prompt OUT
          CALL OUTMUX3

          LHLD OUTFRAME         ;update out frame #
          CALL OUTMUX5          ;output LED + SIO
          CALL MODNUM
          SHLD OUTFRAME

          LDED COUNTER		;compute frame count
          XRA A
          DSBC DE		;... = out frame # - counter frame #
          SHLD FRAMECNT

          CALL FRMTODIR         ;... and direction
          SHLD FRAMEABS

EXITOUT:  POP PSW
          RET     

; Convert frame count to direction.
; Convert negative frame count to positive (absolute value).
; HL <-- frame count value, initially positive or negative.

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
; HL <-- frame count value, initially positive.

DIRTOFRM: LDA DIRSTAT         ;reverse direction ?
          ORA A
          RZ
          XCHG                ;then 2's complement negative number
          LXI H,0
          ORA A
          DSBC DE
          RET

; Exposure Time input.

MEXP:     DB 'EXP'

EXPIT:    PUSH PSW
          
          LXI H,MEXP            ;prompt EXP
          CALL OUTMUX3

          LHLD EXPOSURE         ;update exposure time
          CALL OUTMDX5          ;mux out decimal to LED + SIO
          CALL MODDEC           ;modify
          SHLD EXPOSURE

          POP PSW
          RET     

; Lapse Time input.

MLPS:     DB 'LPS'

LAPSEIT:  PUSH PSW

          LXI H,MLPS
          CALL OUTMUX3

          LHLD LAPSE            ;update lapse time
          CALL OUTMDX5
          CALL MODDEC
          SHLD LAPSE

          POP PSW
          RET     

; Total Count input.

MCNT:     DB 'CTR'

COUNTIT:  PUSH PSW
          
          LXI H,MCNT
          CALL OUTMUX3

          LHLD COUNTER          ;update counter
          CALL OUTMUX5
          CALL MODNUM
          SHLD COUNTER

          POP PSW
          RET     

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
          CALL OUTMDX5
          CALL MODDEC
          SHLD SPEED

          CALL RAMPCOMP       ;compute ramp table
          CALL TIMECOMP       ;compute compensation times

          POP PSW
          RET

; Minimum Speed for ramping base.

MMSP:     DB 'MSP'

MINSPDIT: PUSH PSW

          LXI H,MMSP
          CALL OUTLED3

          LHLD MINSPEED       ;update min speed
          CALL MODDEC
          SHLD MINSPEED

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITMSPD

          LDED LOWSPDBF       ;compare min speed < lowest motor speed ?
          ORA A
          DSBC DE
          JNC COMPMSPD
          XCHG                ;if lower, then bottom out at min low speed
          SHLD MINSPEED

COMPMSPD: CALL RAMPCOMP       ;re-compute speed ramp

EXITMSPD: POP PSW
          RET

; Motor speed acceleration in user terms of fraction of revolution.
; Inter-relates with ramp count.

MACL:     DB 'RMP'

ACCELIT:  PUSH PSW

          LXI H,MACL
          CALL OUTMUX3

          LHLD RAMPABS        ;get ramp count
          SRLR H              ;convert to fraction of revolution
          RARR L
          SRLR H
          RARR L              ;... = ramp count / 4
          CALL OUTMDX5
          CALL MODDEC         ;... / 100 (in decimal)
          DAD H
          DAD H
          SHLD RAMPABS
          SHLD RAMPCNT

          CALL RAMPCOMP       ;compute ramp table

          POP PSW
          RET

; Ramp Count Maximum of step time ramping.
; Ramp Count now indexes backwards from High Speed.
; Selection of Ramp Count does NOT change Speed.
; Special case for Constant Speed = 0 Ramp Count.

MRMP:     DB 'RMC'

RAMPIT:   PUSH PSW

          LXI H,MRMP
          CALL OUTMUX3

          LHLD RAMPABS        ;display desired ramp count
          CALL OUTMUX5
          CALL MODNUM
          SHLD RAMPABS
          SHLD RAMPCNT

          CALL RAMPCOMP       ;compute ramp table

          POP PSW
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
          CALL OUTMUX5
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
          LXI D,DSPEED        ;(camera speed default)
          CALL DIVIDE         ;compute exposure time compensation
          CALL ROUND          
          SBCD EXPCOMP        ;... = 100 * angle factor / film speed
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

*         LHLD LOWSPDBF  ;transfer low speed
          LHLD MINSPEED
          SHLD LOWSPD
          LHLD SPEED     ;transfer high speed
          SHLD HIGHSPD
          LHLD RAMPABS   ;transfer ramp count
          SHLD RAMPCNT

          MOV A,L        ;0 ramp count ?
          ORA H
          JNZ COMPDIFF

COMPCONS: LHLD SPEED     ;then compute constant speed
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
          LXI H,3        ;1-step ramp count for constant speed
          SHLD RAMPCNT
          SHLD RAMPRUN
          RET

; Integer speed increment computation.
; Scale up intermediate speeds by factor of 8.

COMPDIFF: LHLD HIGHSPD   ;compute speed difference
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
          JC COMPCONS
          
          LBCD RAMPCNT
          DCX B
          CALL PREDIVD   ;compute speed increment (integer delta)
          CALL FASTDIVD
          SDED DELTA     ;... = (speed difference) / (ramp count - 1)
          
          LXIX ACCLTBL1  ;buffer pointer
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
          DCX B
          MOV A,B
          ORA C
          JNZ COMPTIME
          
          STX L,0        ;buffer ultimate high speed
          STX H,1
          STX L,2
          STX H,3
          STX L,4
          STX H,5

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
          CALL OUTMUX5
          CALL MODNUM
          SHLD REVLNCNT

          CALL MICROSET       ;micro-stepping ?
          CALL MICROCHK       ;micro-stepping...

          POP PSW
          RET     

; Step Count Adjustment for Projector Home sensing.

MADJ:     DB 'ADJ'

ADJUSTIT: PUSH PSW

          LXI H,MADJ
          CALL OUTMUX3

          LHLD ADJSTPCT       ;update adjustment step count
          CALL OUTMUX5
          CALL MODNUM
          SHLD ADJSTPCT

          POP PSW
          RET     

; Shutter-Open step count input.

MOPN:     DB 'OPN'

OPENIT:   PUSH PSW
          
          LXI H,MOPN
          CALL OUTMUX3

          LHLD OPNANGLE       ;get open-shutter angle in decimal
          CALL OUTMDX5
          CALL MODDEC
          SHLD OPNANGLE

          CALL OPENCOMP       ;compute open-shutter step counts

          POP PSW
          RET     

; Compute open-shutter step count from open-shutter angle.

OPENCOMP: LHLD REVLNCNT       ;compute open-shutter step count
          LXI D,100
          CALL DIVIDE         ;... = full-revolution step count / 100
          CALL ROUND          ;(round up to the nearest 100th...)
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

; Torque time-out delay for motor enable line.

MTRQ:     DB 'TRQ'

TORQIT:   PUSH PSW
          
          LXI H,MTRQ
          CALL OUTMUX3

          LHLD TORQTIME       ;update torque time-out
          CALL OUTMDX5
          CALL MODDEC
          SHLD TORQTIME

          MOV A,H             ;0 time-out ?
          ORA L
          JNZ EXITTRQ
          LXI H,1             ;then minimum time-out
          SHLD TORQTIME

EXITTRQ:  POP PSW
          RET

; Version identification.

MVER:     DB 'VER'

VERIT:    PUSH PSW

          LXI H,MVER
          CALL OUTMUX3

          LXI H,VERSION
          CALL OUTMDX5
          CALL WAITMUX

          POP PSW
          RET

; Run-time stop-motion motor operation.
; Subroutine to Main Loop.

MRUN:     DB 'RUN'
MHLD:     DB 'HLD'
MBLK:     DB '   '
MPIN:     DB 'PIN'

RUNIT:    LXI H,MRUN          ;display Run mode
          SHLD MSGBUF3
          CALL OUTMUX3

          XRA A               ;clear run-time keypad status
          STA KEYSTAT
          STA KEYBUF
          STA KILLSTAT

          LHLD FRAMECNT       ;0 Frame Count ?
          MOV A,H
          ORA L
          RZ

          LHLD FRAMEABS       ;transfer run-time frame count
          SHLD RUNFRAME

          LDA PROJSTAT        ;projector only overide ?
          STA CNTRSTAT        ;duplicate for counting projector frames

          LXI H,MPRJ          ;pre-buffer PRJ tag run-time display
          SHLD RUNDISBF

          LHLD PROJCNTR       ;buffer both projector counters
          SHLD PRJCNTBF

          LDA PROJSTAT        ;either projector selected ?
          ORA A
          JZ SKIPSYNC

          LDA PRJDIRST        ;buffer projector direction (for counting)
          STA PRJDIRBF

SKIPSYNC: LHLD STEPRCNT       ;transfer camera step printer count
          SHLD RUNSTEPR
          LHLD SKIPRCNT       ;transfer projector skip printer count
          SHLD RUNSKIPR

          LHLD CYCLECNT       ;transfer step/skip cycle count
          SHLD RUNCYCLR

          LDA SEQSTAT         ;sequencer ?
          ORA A
          JZ SKIPSWAP
          CALL PUTCAMPR       ;re-buffer camera or projector data
          XRA A
          STA PROJSTAT        ;if sequencer, then start with camera
          CALL GETCAMPR       ;...and load camera data accordingly

          LDA STEPSTAT        ;step camera ?
          MOV B,A
          LDA SKIPSTAT        ;... OR skip projector ?
          ORA B
          JZ SKIPSWAP
          LXI H,1
          SHLD RUNSTEPR       ;then overide at 1:1
          SHLD RUNSKIPR

SKIPSWAP: LHLD COUNTER        ;display total frame count
          CALL OUTNUM

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

COMPEXP:  LHLD EXPOSURE       ;compute run-time exposure time
          SHLD RUNEXP
          MOV A,H
          ORA L
          STA EXPSTAT
          JZ COMPLAP

          LDED EXPCOMP        ;adjust for exp time compensation
          INX D
          ORA A
          DSBC DE             ; ... = (exp time + 1) - (exp comp + 1)
          INX H
          SHLD RUNEXP
          JNC COMPLAP
          XRA A
          STA EXPSTAT
          STA RUNEXP
          STA RUNEXP+1

COMPLAP:  LHLD LAPSE          ;compute run-time lapse time
          SHLD RUNLAPSE
          MOV A,H
          ORA L
          STA LAPSTAT
          JZ COMPRUN

          LDED LAPCOMP        ;adjust for lapse time compensation
          LHLD RUNEXP
          DAD D
          XCHG
          LHLD RUNLAPSE       ;... = (lapse time + 1)
          INX D
          ORA A
          DSBC DE             ;... - (lapse comp + adj exp time + 1)
          INX H
          SHLD RUNLAPSE
          JNC COMPRUN
          XRA A
          STA LAPSTAT          
          STA RUNLAPSE
          STA RUNLAPSE+1

COMPRUN:  LDA SEQSTAT         ;sequencer ?
          ORA A
          JNZ RUNLOOP
          LDA PROJSTAT        ;projector ?
          ORA A
          JNZ RUNLOOP
          LDA LAPSTAT         ;lapse time ?
          ORA A
          JNZ RUNLOOP
          LDA EXPSTAT         ;exposure time ?
          ORA A
          JNZ RUNLOOP
          LHLD RUNFRAME       ;single frame ?
          DCX H
          MOV A,H
          ORA L
          JZ RUNLOOP          ;then run stop-motion
          JNZ CONTLOOP        ;else run continuous motion

RUNLOOP:  LDA SEQSTAT         ;sequence camera or projector ?
          ORA A
          CNZ SEQUENCR

          CALL UPDTCNTR       ;pre-update total frame counter

          CALL TRIGRON        ;fire output trigger during single frame

          LHLD REVLNCNT       ;pre-transfer full revolution step count
          SHLD STEPCNT

          CALL SEQUOCHK       ;overide step count if sequencer ?

          LDA PROJSTAT        ;projector ?
          ORA A
          JNZ SKIPEXP

          LDA EXPSTAT         ;exposure time ?
          ORA A
          JZ SKIPEXP

          LHLD RUNOPEN        ;then re-transfer shutter-open step count
          SHLD STEPCNT

          CALL MOTORON        ;motor control signals on

          CALL INITMOTR       ;run motor to shutter-open position

          MVI A,TRUE          ;insure switch mask off for time exposure
          STA SWITMASK

WAITOPEN: CALL PRECHECK       ;quick check for key press
          LDA MOTROVER        ;wait until motor over ?
          ORA A
          JNZ WAITOPEN

          LHLD COUNTER        ;display updated total frame count
          CALL OUTNUM

          LHLD RUNEXP         ;transfer exposure time count
          SHLD WAITIME

          CALL INITWAIT       ;run exposure time delay

WAITEXP:  CALL PRECHECK       ;quick check for key press
          LDA TIMROVER        ;wait until exposure time over ?
          ORA A
          JNZ WAITEXP

          LHLD RUNCLOSE       ;transfer shutter-closed step count
          SHLD STEPCNT

          XRA A
          STA SWITMASK        ;Home switch mask active now

SKIPEXP:  CALL MOTORON        ;motor control signals on

          CALL INITMOTR       ;run motor to shutter-closed position

WAITOVER: LHLD MSGBUF3        ;display whatever Run mode
          CALL OUTMUX3        ;local + remote
          LHLD COUNTER        ;display updated total frame count
          CALL OUTMUX5        ;echo out LED + SIO

LOOPOVER: CALL PRECHECK       ;check for run-time interruption ?
          CALL CHECKPT
          LDA MOTROVER        ;wait til motor over ?
          ORA A
          JNZ LOOPOVER

          LDA PROJSTAT        ;special projector procedure ?
          ORA A
          CNZ CHECKPRJ        ;check projector for sensing home ?

          CALL TRIGROFF       ;release output trigger after single frame

          LDA LAPSTAT         ;lapse time ?
          ORA A
          JZ SKIPLAPS

          LHLD RUNFRAME       ;last single frame ?
          DCX H
          MOV A,H
          ORA L
          JZ SKIPLAPS

          LHLD RUNLAPSE       ;then transfer lapse time count
          SHLD WAITIME

          CALL INITWAIT       ;run lapse time delay

WAITLAPS: CALL PRECHECK       ;run-time interruption ?
          CALL CHECKPT
          LDA TIMROVER        ;wait until lapse time over ?
          ORA A
          JNZ WAITLAPS

SKIPLAPS: LDA SEQSTAT         ;sequencer operation ?
          ORA A
          JZ SKIPSEQ

          CALL UPDTSEQR       ;update sequencer run-time counters

          LDA KILLSTAT        ;get out of the loop ???
          ORA A
          JNZ EXITLOOP

          LDA PROJSTAT        ;count projector frames during sequence ?
          MOV B,A
          LDA CNTRSTAT
          XRA B               ;...(camera & camera) or (projector & projector)
          JNZ RUNLOOP

SKIPSEQ:  LDA KILLSTAT        ;get out of the loop ???
          ORA A
          JNZ EXITLOOP

          LHLD RUNFRAME       ;frame count over ?
          DCX H
          SHLD RUNFRAME
          MOV A,H
          ORA L
          JNZ RUNLOOP

EXITLOOP: LDA CNTRSTAT        ;either projector active at all ?
          ORA A
          JZ SKIPDUPE

          LDA SEQSTAT         ;sequencer active at all ??
          ORA A
          JNZ SKPCNTSW

          LDA PROJSTAT        ;projector most recently active ???
          ORA A
          JZ SKPCNTSW

          LHLD COUNTER        ;...then explicitly update projector counter
          SHLD PROJCNTR

SKPCNTSW:
SKIPDUPE: LDA SEQSTAT         ;clean up sequencer stuff ?
          ORA A
          RZ

          LDA CNTRSTAT        ;restore pre-run camera / projector status
          STA PROJSTAT
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
          LHLD RUNDISBF         ;un-buffer PRJ or AER id tag
          SHLD MSGBUF3
          CALL OUTMUX3
          XRA A			;zero out time exposure
          STA EXPSTAT
          LHLD COUNTER		;save camera frame counter
          SHLD CAMRCNTR
          LHLD PROJCNTR		;load projector frame counter
          SHLD COUNTER
          LDA PRJDIRST		;load projector direction
          STA DIRSTAT

          LDA STEPSTAT          ;step camera sequence ?
          ORA A
          RZ
          LXI H,1
          SHLD RUNSKIPR         ;then overide projector count for 1:1
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
          LXI H,MCAM
          SHLD MSGBUF3
          CALL OUTMUX3
          LHLD RUNEXP		;re-load time exposure status, if any
          MOV A,H
          ORA L
          STA EXPSTAT
          LHLD COUNTER		;save projector frame counter
          SHLD PROJCNTR
          LHLD CAMRCNTR		;load camera frame counter
          SHLD COUNTER
          LDA CAMDIRST		;load camera direction
          STA DIRSTAT

          LDA SKIPSTAT          ;skip projector sequence ?
          ORA A
          RZ
          LXI H,1
          SHLD RUNSTEPR         ;then overide step camera count for 1:1
          RET

; Update sequencer counters here at end of single-frame cycle.

UPDTSEQR: LDA PROJSTAT		;camera over or projector over ?
          ORA A
          JNZ UPDTPROJ

          LHLD RUNSTEPR		;update camera step counter
          DCX H
          SHLD RUNSTEPR
          LHLD COUNTER
          SHLD CAMRCNTR

          CALL UPDTALTR
          RET

UPDTPROJ: LHLD RUNSKIPR		;update projector skip counter
          DCX H
          SHLD RUNSKIPR
          LHLD COUNTER
          SHLD PROJCNTR

          CALL UPDTALTR
          RET

; Adjust sequencer for Alternate, Step Camera, or Skip Projector operation.

UPDTALTR: LDA STEPSTAT          ;neither Step Camera nor Skip Projector ?
          MOV B,A
          LDA SKIPSTAT
          MOV C,A
          ORA B
          RZ                    ;then Alternate mode

          MOV A,C
          ORA A                 ;else Skip Projector mode ?
          JNZ UPDTSKPR

; Step Camera cycling:

UPDTSTPR: LDA PROJSTAT          ;count projector cycles only ?
          ORA A
          JZ CHEKSTPR

          LHLD RUNCYCLR         ;then update 1:1 cycle counter only
          DCX H
          SHLD RUNCYCLR
          RET

CHEKSTPR: LHLD RUNCYCLR         ;else check 1:1 cycle counter ?
          MOV A,H
          ORA L
          JZ UPDTCYCC           ;cycle counter NOT over yet ?

          LXI H,0               ;then overide Step counters at 1:1
          SHLD RUNSTEPR
          RET

UPDTCYCC: LHLD RUNSTEPR         ;else real Step counter over ?
          MOV A,H
          ORA L
          RNZ
          LHLD CYCLECNT         ;then re-load cycle counter
          SHLD RUNCYCLR
          RET

; Skip Projector cycling:

UPDTSKPR: LDA PROJSTAT          ;count camera cycles only ?
          ORA A
          JNZ CHEKSKPR

          LHLD RUNCYCLR         ;then update 1:1 cycle counter only
          DCX H
          SHLD RUNCYCLR
          RET

CHEKSKPR: LHLD RUNCYCLR         ;else check 1:1 cycle counter ?
          MOV A,H
          ORA L
          JZ UPDTCYCP           ;cycle counter NOT over yet ?

          LXI H,0               ;then overide Skip counters at 1:1
          SHLD RUNSKIPR
          RET

UPDTCYCP: LHLD RUNSKIPR         ;else real skip counter over ?
          MOV A,H
          ORA L
          RNZ
          LHLD CYCLECNT         ;then re-load cycle counter
          SHLD RUNCYCLR
          RET
                    
; Continuous motion run-time sequence.
; Note run-time frame counters are updated within interrupt routines.
; Note motor revolutions are counted according to Home Switch interrupts.
; Output End-of-Lines to SIO port for each cycle through run-time loop.

CONTLOOP: XRA A
          STA SWITMASK        ;Home switch mask active
          STA HOLDSTAT        ;Hold status inactive

          LHLD REVLNCNT       ;transfer full revolution count per frame
          SHLD STEPCNT
          
          CALL SEQUOCHK       ;overide step count if sequencer ?

          LHLD RUNFRAME       ;transfer and adjust run-time frame count
          DCX H
          MOV A,H             ;just 1 lousy frame ? (or 1 frame more ??)
          ORA L
          JZ RUNLOOP          ;then go to single frame loop
          SHLD RUNFRAME       ;else save for continuous frame loop

          CALL TRIGRON        ;fire output trigger during continuous frames

          CALL MOTORON        ;enable motor control signals

          CALL INITCONT       ;initialize continuous-running interrupts

WAITHOME: LHLD COUNTER        ;display pre-updated counter
          CALL OUTNUM
          CALL OUTEOLN        ;single EOLN to SIO
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

WAITLAST: LHLD COUNTER
          CALL OUTNUM
          CALL OUTEOLN
LOOPLAST: LDA MOTROVER        ;wait until last revolution
          ORA A
          JNZ LOOPLAST

          CALL UPDTCNTR       ;update last frame count
          LHLD COUNTER
          CALL OUTNUM

          CALL TRIGROFF       ;release output trigger

          LDA HOLDSTAT        ;Hold state pause ?
          ORA A
          CNZ RERUNPT         ;then wait for further instructions
          LDA HOLDSTAT        ;Hold state re-run ?
          ORA A
          JNZ CONTLOOP        ;then re-run remaining sequence

          RET

; Update run-time total frame counter according to direction.

UPDTCNTR: LDA DIRSTAT         ;direction ?
          ORA A
          JNZ UPDTREV

          LHLD COUNTER        ;increment for forward
          INX H
          SHLD COUNTER
          RET

UPDTREV:  LHLD COUNTER        ;decrement for reverse
          DCX H
          SHLD COUNTER
          RET

; Check-Point for run-time key press.

PRECHECK: CALL INMUXST        ;key press at all ?
          STA KEYSTAT         ;then buffer key press status
          RZ

          CALL INMUX          ;genuine key ?
          RC
          XRA A               ;else clear key press status
          STA KEYSTAT
          RET

; Check-Point for run-time interruption.
; Check-Point for single-frame run-time operation.
; Flash Hold state locally on LED display while looping for key press.
; Kill status byte for quitting single-frame loop immediately

CHECKPT:  LDA KEYSTAT         ;key pressed at all ?
          ORA A
          RZ
          XRA A
          STA KEYSTAT

          LDA KEYBUF          ;Run key interruption ?
          CPI RUN
          RNZ

          LXI H,MHLD          ;display Hold state
          SHLD FLASHPTR
          CALL OUTMUX3        ;out both LED + SIO
          CALL OUTEOLN

HOLDPT:   CALL HOLDPTRN       ;flash Hold state while looping for input

          CALL INMUX          ;key press ?
          JNC HOLDPT

          LXI H,MRUN          ;re-display Run state
          CALL OUTMUX3        ;locally and remotely
          CALL OUTEOLN

          LDA KEYBUF          ;Run key continue ?
          CPI RUN
          RZ

          LXI H,1             ;else stop run-time sequence
          SHLD RUNFRAME
          SHLD RUNLAPSE
          XRA A
          STA LAPSTAT
          STA TIMROVER
          CMA
          STA KILLSTAT        ;...immediately
          RET

; Flash Hold state while looping for input.
; Exit Hold pattern when key pressed or serial input.
; Pointer to message prompt in FLASHPTR.

HOLDPTRN: LHLD FLASHPTR       ;flash Hold state (locally)
          CALL OUTLED3
          LXI H,50            ;init display flasher = 0.35 sec
WAITHLD:  LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
          CALL WAITX
          CALL INKEYST        ;wait for next key press ?
          RNZ
          CALL INSIOST        ;or serial input ?
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
          CALL INKEYST        ;still wait for next key press ?
          RNZ
          CALL INSIOST        ;or serial input ?
          RNZ
          DCX H
          MOV A,H
          ORA L
          JNZ WAITBLK         ;loop for blanker cycle

          LDA PROJSTAT        ;projector ?
          ORA A
          JZ  HOLDPTRN
          LDA ADJSTPCT        ;adjustment ?
          ORA A
          JZ  HOLDPTRN
          IN SWITCH           ;pin NOT home ?
          BIT SHMP,A
          JNZ HOLDPTRN
          LXI H,MHLD          ;else change flasher
          SHLD FLASHPTR
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
          LXI H,1             ;stop run-time sequence
          SHLD RUNFRAME
          EI

          LXI H,MHLD          ;display Hold state
          SHLD FLASHPTR
          CALL OUTMUX3

          MVI A,TRUE          ;flag Hold status for pausing sequence
          STA HOLDSTAT
          RET

; Check-point for re-running continuous run-time sequence.
; Flash Hold state locally on LED display while looping for key press.

RERUNPT:  CALL HOLDPTRN       ;flash Hold state while looping for input

RERUNGO:  CALL INMUX          ;key press ?
          JNC RERUNPT

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
          CALL OUTMUX3        ;locally and remotely

          MVI A,TRUE          ;re-flag Hold status to re-run sequence
          STA HOLDSTAT
          RET                 ;and start run-time loop anew

; Checkpoint for projector home sensing switches.
; If projector not at home sensing position, then loop
; until user has adjusted projector and pressed key to continue.

CHECKPRJ: LDA PROJSTAT        ;projector to check at all ?
          ORA A
          RZ

          LDA ADJSTPCT        ;adjustment to check at all ?
          ORA A
          RZ

          IN SWITCH           ;projector home OK ?
          BIT SHMP,A
          RZ

          LXI H,MADJ          ;Flash 'Adj' message for Hold state
          SHLD FLASHPTR
          CALL OUTMUX3        ;out both LED + SIO
          CALL OUTEOLN

          LHLD ADJSTPCT       ;try adjusting for so many single steps
          SHLD RUNADJCT

ADJPT:    CALL MOTORON        ;prepare to enable motor on

          CALL INITSSTP       ;run for 1 single step

          MVI A,TRUE          ;ignore switches for single step
          STA SWITMASK

WAITADJ:  LDA MOTROVER        ;single step over ?
          ORA A
          JNZ WAITADJ

          LXI H,MRUN          ;re-buffer Run state
          SHLD MSGBUF3

          IN SWITCH           ;check projector home again ?
          BIT SHMP,A
          RZ                  ;...self-adjustment OK

          LHLD RUNADJCT
          DCX H               ;...else try again
          SHLD RUNADJCT
          MOV A,H
          ORA L
          JNZ ADJPT

          LXI H,MPIN          ;Flash 'Pin' message for Hold state
          SHLD FLASHPTR
          CALL OUTMUX3        ;out both LED + SIO
          CALL OUTEOLN

PREGPT:   CALL HOLDPTRN       ;flash Hold state while looping for input

          CALL INMUX          ;user key press ?
          JNC PREGPT

          IN SWITCH           ;user adjusted projector home ?
          BIT SHMP,A
          JNZ PREGPT

          LXI H,MRUN          ;re-display Run state
          SHLD MSGBUF3
          CALL OUTMUX3        ;locally and remotely
          CALL OUTEOLN

          LDA KEYBUF          ;Run key continue ?
          CPI RUN
          RZ

          LXI H,1             ;else stop run-time sequence
          SHLD RUNFRAME
          SHLD RUNLAPSE
          XRA A
          STA LAPSTAT
          STA TIMROVER
          CMA
          STA KILLSTAT        ;...immediately
          RET

; Output motor control signals on.
; (1) Camera or Projector on ?
; (2) Main Projector or Aerial Projector on ?
; (3) Both Projectors on in Sync ?
; Select Camera or Projector Speed Ramp tables here.
 
MOTORON:  LDA PROJSTAT        ;camera or projector motor ?
          ORA A
          JNZ PROJON

          LXI H,ACCLTBL3      ;default to exclusive ramp table for camera
          SHLD RAMPNTR
          LHLD CAMRMPCT       ;with dedicated ramp count
          SHLD RAMPRUN

          LDA CAMDIRST        ;camera direction forward or reverse ?
          ORA A
          JNZ CAMREVON

CAMFWDON: IN MOTRCNTL         ;camera forward
          SETB MNPR,A         ;projector disable
          SETB MDIR,A         ;motor forward
          RES  MNCM,A         ;camera enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMC,A
          STA WHSWITCH
          MVI A,FALSE         ;check switch mask when steps run out...
          STA SWITMASK
          RET

CAMREVON: IN MOTRCNTL         ;camera reverse
          SETB MNPR,A         ;projector disable
          RES  MDIR,A         ;motor reverse
          RES  MNCM,A         ;camera enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMC,A
          STA WHSWITCH
          MVI A,FALSE
          STA SWITMASK
          RET

; Projector ? ... which Projector ?

PROJON:   LXI H,ACCLTBL2      ;use variable ramp table for projector
          SHLD RAMPNTR
          LHLD RAMPCNT        ;with computed ramp count
          SHLD RAMPRUN

          LDA PRJDIRST        ;projector direction forward or reverse ?
          ORA A
          JNZ PRJREVON

; Main Projector on only.

PRJFWDON: IN MOTRCNTL	      ;projector forward
          SETB MNCM,A         ;camera disable
          SETB MDIR,A         ;motor forward
          RES  MNPR,A         ;projector enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMP,A
          STA WHSWITCH
*           MVI A,FALSE         ;sense YES
*           MVI A,TRUE          ;sense NO
            LDA ADJSTPCT        ;sense if 0 adjustment
          STA SWITMASK        ;ignore projector sensing switches NOT
          RET

PRJREVON: IN MOTRCNTL         ;projector reverse
          SETB MNCM,A         ;camera disable
          RES  MDIR,A         ;motor reverse
          RES  MNPR,A         ;projector enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMP,A
          STA WHSWITCH
*           MVI A,FALSE
*           MVI A,TRUE
            LDA ADJSTPCT
          STA SWITMASK
          RET

; Output motor control signals off.
; Effective for AC motor enable signals immediately.

MOTOROFF: RET

; Output motor control signals null.
; Effective for DC motor enable signals after final time-out.

MOTORNUL: IN MOTRCNTL	;all motors off
          SETB MNCM,A   ;camera disable
          SETB MNPR,A   ;projector disable
          OUT MOTRCNTL
          RET

; Output trigger signals.
; Trigger on.

TRIGRON:  RET

; Trigger off.

TRIGROFF: RET

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

; Initialize single step pulse timing.
; CTC0 <-- Timer for step pulse timing.
; Modified 10/23/95 single step pulse generation.

INITSSTP: DI
          XRA A
          CMA                 ;motor running status
          STA MOTROVER

          LXI H,STOPINT       ;only 1 interrupt point
          SHLD INTCTCV0

*           MVI A,IC000LRC      ;load counter CTC0 with interrupts
*           OUT CTC0
*           MVI A,1             ;counter byte = 1 single step
*           OUT CTC0
          MVI A,IT400LRC      ;load timer CTC0 with interrupts
          OUT CTC0
          MVI A,0FFH          ;timer byte = max time interval
          OUT CTC0
          STA SWITMASK        ;ignore switches for single step

          EI
          RET

; Initialize step motor timing.
; CTC0 <-- Timer for step pulse timing.
; CTC1 <-- Counter for counting CTC0 steps.
; BC'  <-- acceleration phase ramp count
; DE'  <-- pre-deceleration phase step count
; HL'  <-- acceleration phase step-time pointer.
; Camera or Projector Speed Ramp tables are pre-selected.

INITMOTR: DI
          CALL MICROCHK       ;select micro- or half-stepping stuff

          XRA A
          CMA                 ;motor running status
          STA MOTROVER

          LXI H,NULLINT       ;but point to null vector initially
          SHLD INTPIOVB

          CALL STEPOCHK       ;insure ramp count < step count
          CALL RAMPOCHK       ;select 8-bit or 16-bit ramping stuff

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
          SHLD INTCTCV3
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
; Note motor revolutions are counted according to Home Switch interrupts.

INITCONT: DI
          CALL MICROCHK       ;select micro- or half-stepping stuff

          XRA A
          CMA                 ;motor running status
          STA MOTROVER
          STA HOMEOVER        ;home sensing status

          LXI H,NULLINT       ;but point to null vector initially
          SHLD INTPIOVB

          CALL STEPOCHK       ;insure ramp count < step count
          CALL RAMPOCHK       ;select 8-bit or 16-bit ramping stuff

          LHLD STEPCNT        ;pre-compute pre-deceleration step count
          LDED RAMPRUN
          XRA A
          DSBC DE             ;... = step count - decel count
          SHLD RUNPRECL

          EXX
          LDED RUNFRAME       ;load frame count --> DE'
          LBCD RAMPRUN        ;load ramp count  --> BC'
          LHLD RAMPNTR        ;load ramp table step time pointer --> HL'
          MOV A,M             ;load step time
          STA STEPTIME
          INX H               ;update pointer for 2nd ramp step
          EXX

          LXI H,FRAMEACL      ;load acceleration interrupt vector
          SHLD INTCTCV0
          LXI H,NULLINT       ;load step counter interrupt vectors
          SHLD INTCTCV1
          LXI H,FRAMEINT
          SHLD INTCTCV3

          MVI A,IC000LRC      ;load high counter CTC2 with interrupts
          OUT CTC3
          LDA TMRMLTBF        ;counter high byte = multiple * 100
          OUT CTC3

          MVI A,IC000LRC      ;load low counter CTC1 with interrupts
          OUT CTC1
          MVI A,100           ;counter low byte = 100
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

INITWAIT: DI
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

MICROSET: LHLD REVLNCNT       ;compare revolution count < half-step count
          LXI D,401
          XRA A               ;if less, then no micro-stepping
          STA MICROST
          DSBC DE
          RC
          CMA                 ;else yes micro-stepping
          STA MICROST
          RET

; Check for parameters relevant for micro-stepping.
; Micro-stepping = 2000 steps per revolution.

MICROCHK: LDA MICROST         ;micro-stepping ?
          ORA A
          JNZ MICROCMP

          MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF
          MVI A,4             ;4 * 100 multiplier
          STA TMRMLTBF
          LXI H,KSCALEHF      ;speed scaling constant for half-stepping
          SHLD KSCALEBF
          LXI H,LOWSPDHF      ;minimum low speed for half-stepping
          SHLD LOWSPDBF
          RET

MICROCMP: MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF
          MVI A,20            ;20 * 100 multiplier
          STA TMRMLTBF
          LXI H,KSCALEMS      ;speed scaling constant for micro-stepping
          SHLD KSCALEBF
          LXI H,LOWSPDMS      ;minimum low speed for micro-stepping
          SHLD LOWSPDBF
          RET

; Check how Sequencer uses step counts for camera or projector.
; NOTE: This code artifact indicates less-than-perfect step pulse interface.
; SFAI JK appears to run extra steps in sequencer mode vs overide mode.
; SFAI JK is +/-2 steps out of alignment in sequencer mode. (NOV 95)

SEQUOCHK:
          LXI H,396           ;pre-load camera step count = 400
          SHLD STEPCNT
          LDA PROJSTAT        ;projector active ?
          ORA A
          RZ
          LHLD REVLNCNT       ;...then re-load with custom step count
          SHLD STEPCNT
IF 1
          LDA SEQSTAT         ;sequencer active ?
          ORA A
          RZ
          DCX H               ;...then adjust step count for sequencing
          DCX H
          SHLD STEPCNT
 IF 0
          LDA DIRSTAT         ;direction reverse ?
          ORA A
          RZ
          INX H               ;...then re-adjust for opposite direction
          INX H
          INX H
          INX H
          SHLD STEPCNT
 ENDIF
ENDIF
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
          CALL OUTLED5   ;output 5 buffered digits to LED display
          RET





; Multiplexed Keypad / Display and Serial Input / Output.

CR:       EQU 0DH               ;carriage return
LF:       EQU 0AH               ;line feed
BS:       EQU 08H               ;back space

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

; Wait until key is pressed or input from serial port.

WAITMUX:  CALL INMUXST          ;key pressed or serial input ?
          JZ WAITMUX

          CALL INMUX            ;then get key from wherever...
          RET

; Output 3-character prompt to LED display.
; (3-character string pointer loaded in HL.)

          IF LEDISPLAY

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

          IF LCDISPLAY

OUTLED3:  CALL OUTLCD3
          RET

          ENDIF

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

; Multiplex output 3-character prompt to LED display and SIO port.
; (3-character string pointer loaded in HL.)

OUTMUX3:  CALL OUTLED3          ;output 3 buffered charcters to LED display
          DCX H                 ;reset buffer pointer
          DCX H
          DCX H
          CALL OUTSIO3          ;echo out 3 buffered charcters to SIO port
          RET

; Output 5-digit string to LED display.
; (5-character string pointer loaded in HL.)

          IF LEDISPLAY

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

          IF LCDISPLAY

XD:       EQU 1          ;extra digit = +1 for 6 buffered digits for LCD

OUTLED5:  CALL OUTLCD5
          RET

          ENDIF

; Output 5-digit string to SIO port.
; (5-character string pointer loaded in HL.)
; (6 characters if LCD display.)

OUTSIO5:  MVI B,5+XD            ;number of bytes to transfer
XSIO:     MOV A,M               ;transfer byte out of buffer
          CALL OUTSIO           ;output to SIO port
          INX H
          DJNZ XSIO             ;repeat for all bytes
          RET

; Multiplex output 5-digit string to LED display and SIO port.
; (16-bit integer already loaded in HL.)
; (5-digit string assembled in LED buffer)

OUTMUX5:  PUSH H                ;save value
          CALL OUTNUM           ;transfer 5 characters to LED display
          LXI H,OUTDIGBF        ;re-init output digit buffer address
          CALL OUTSIO5          ;echo 5 buffered characters to SIO port
          CALL OUTEOLN          ;send end of line
          POP H                 ;restore value
          RET

; Multiplex output 5-digit decimal string to LED display and SIO port.
; (16-bit fixed-point integer already loaded in HL)
; (5-digit string assembled in LED buffer)

OUTMDX5:  PUSH H                ;save value
          CALL OUTDEC           ;transfer 5 characters to LED display
          LXI H,OUTDIGBF        ;re-init output digit buffer address
          CALL OUTSIO5          ;echo 5 buffered characters to SIO port
          CALL OUTEOLN          ;send end of line
          POP H                 ;restore value
          RET

; Output a carriage return to the serial port.

OUTEOLN:  MVI A,CR
          CALL OUTSIO
          RET




; LCD buffered output routines.

          IF LCDISPLAY

; Output 3-character prompts in left-hand display.
; Adjust 2 positions from left edge of display for centering text.

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

          IF LEDISPLAY

CURSRON:  DI
          XRA A			;init cursor flasher memory off
          STA CURSRMEM
          EXX
          MVI B,50
          EXX

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

          IF LCDISPLAY

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

          IF LCDISPLAY

LCDADDRL: EQU 80H+00H           ;LCD buffer address for left-hand display
LCDADDRR: EQU 80H+40H           ;LCD buffer address for right-hand display

; Wait until LCD status indicates Not-Busy.

WAITLCD:  IN LCDCNTL            ;input LCD status register
          BIT 7,A               ;busy flag ?
          JNZ WAITLCD           ;wait until not busy
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




; Serial Interface routines.

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




          IF NOT SERIALIO

; Reset serial interface.

RESETSIO: RET

          ENDIF




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




; Null input/output routines if no serial interface.

          IF NOT SERIALIO

; Sample input status from serial port.

INSIOST:  XRA A
          RET

; Input byte from serial port.

INSIO:    XRA A
          RET

; Output byte to serial port.

OUTSIO:   RET

          ENDIF




; Utility routines.

          MULTPLYM

          DIVIDEM

          FASTDIVM

          WAITXM




; Control board initialization
; and parameter initialization routines...

; Reset and initialize hardware.
; Reset Parallel Input / Output chips.
 
RESETPIO: MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLA
          MVI A,00001111B     ;identify input/output directions
          OUT PIOCNTLA

          MVI A,11001111B     ;select multi-input/output
          OUT PIOCNTLB
          MVI A,10000111B     ;identify input/output directions
          OUT PIOCNTLB

          MVI A,QUIETIO
          OUT MOTRCNTL
          RET

; Reset LED display with all blanks.

          IF LEDISPLAY

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

          IF LCDISPLAY

RESETLED: CALL RESETLCD
          RET

          ENDIF

; Reset Counter / Timer chips. 

RESETCTC: MVI A,NC000NRC      ;reset timers
          OUT CTC0
          OUT CTC1
          OUT CTC2
          OUT CTC3
          RET

; Initialize switch sensing interrupts for automatic revolution counting.

INITSENS: LXI H,NULLINT       ;null interrupt vector for keypad
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
; Only initialize all variables for 1st Reset = Power-on Reset.

RESETMEM: CALL CHECK1ST       ;check memory for 1st-time Reset
          STA RESETBUF
          STA RESETBUF+1
          CNZ SET1ST          ;if 1st Reset, then set 1st block of memory
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

; Initialize software variables.
; Default initialization for 400 half-steps per revolution.

INITIALZ: LHLD RESETBUF       ;check memory 
          MOV A,L             ;for 1st-time Reset
          ORA H               ;and 2nd-time Reset
          CNZ INITVARS        ;if new, then init all variables
          CALL INITCOMP       ;always init computations
          CALL INITIMER       ;init timer interrupts
          CALL INITSENS       ;init switch sensing interrupts
          RET

; Initialize data variables only at 1st Reset.
; NOTE: less-than-perfect steps-per-revolution for SFAI JK printer.

* DSPEED:   EQU 120           ;1.20 frames per second for 72 RPM
* DSPEED:   EQU 200           ;2.00 frames per second for 120 RPM
DSPEED:     EQU 240           ;2.40 frames per second
* DSPEED:   EQU 334           ;3.33 frames per second for 200 RPM
* DSPEED:   EQU 400           ;4.00 frames per second

* DMINSPD:  EQU LOWSPDHF      ;lowest min speed for half-stepping
DMINSPD:    EQU 100           ;1.00 frames per second min speed

* DTORQTME: EQU 5             ;0.05 second torque time-out
DTORQTME:   EQU 25            ;0.25 second torque time-out

* DEXPCOMP: EQU 14            ;exposure compensation time = 0.14 sec Bolex
DEXPCOMP:   EQU 12            ;exposure compensation time = 0.12 sec Bolex

* DEXPANGL: EQU 47            ;shutter-open exposure angle = 170 deg
* DEXPANGL: EQU 65            ;shutter-open exposure angle = 235 deg
DEXPANGL:   EQU 28            ;135 degrees * 75% prism for Bolex

* DOPNANGL: EQU 50            ;shutter-open rotation angle = 180 deg
* DOPNANGL: EQU 35            ;125 degrees for Mitchell
DOPNANGL:   EQU 31            ;110 degrees for Bolex

* DREVLNCN: EQU 25000         ;revolution step count = 25000 micro-steps
* DREVLNCN: EQU 2000          ;2000 micro-steps
DREVLNCN:   EQU 400           ;400 half-steps
* DREVLNCN: EQU 398           ;400 half-steps (short)
* DREVLNCN: EQU 396           ;400 half-steps (short)

* DRAMPCNT: EQU 250           ;ramp count for 2000 micro-steps
DRAMPCNT:   EQU 48            ;for 400 half-steps 16mm
* DRAMPCNT: EQU 0             ;no ramping for constant speed 72 RPM

INITVARS: LXI H,0
          SHLD COUNTER        ;zero counter
          SHLD EXPOSURE       ;exposure time
          SHLD LAPSE          ;lapse time
          SHLD CAMRCNTR       ;camera counter
          SHLD PROJCNTR       ;projector counter
          SHLD AERLCNTR       ;aerial projector counter
          SHLD OUTFRAME       ;out-frame counter #
          SHLD CAMOUTFR       ;camera out frame
          SHLD PRJOUTFR       ;main projector out frame
          SHLD AEROUTFR       ;aerial projector out frame
          SHLD ADJSTPCT       ;adjustment step count

          LXI H,1
          SHLD FRAMECNT       ;single frame count
          SHLD FRAMEABS
          SHLD CAMFRMCT       ;camera frame count
          SHLD CAMABSCT
          SHLD PRJFRMCT       ;projector frame count
          SHLD PRJABSCT
          SHLD AERFRMCT       ;aerial projector frame count
          SHLD AERABSCT
          SHLD CYCLECNT       ;step / skip cycle count
          SHLD STEPRCNT       ;camera step count
          SHLD SKIPRCNT       ;projector skip count
          SHLD TORQTIME       ;torque time-out

          XRA A
          STA DIRSTAT         ;direction forward
          STA EXPSTAT         ;no time exposure
          STA LAPSTAT         ;no time lapse
          STA SEQSTAT         ;no sequencer
          STA PROJSTAT        ;no projector overide
          STA CNTRSTAT        ;no projector counting
          STA CAMDIRST        ;forward camera
          STA PRJDIRST        ;forward projector
          STA AERDIRST        ;forward aerial projector
          STA WHSWITCH        ;no switch sensing (yet)
          STA AERLSTAT        ;no aerial projector
          STA SYNCSTAT        ;no sync projectors
          STA STEPSTAT        ;no step camera sequencing
          STA SKIPSTAT        ;no skip projector sequencing

          LXI H,DSPEED
          SHLD SPEED          ;film speed
          LXI H,DMINSPD
          SHLD MINSPEED       ;min speed

          LXI H,DREVLNCN
          SHLD STEPCNT        ;step count
          SHLD REVLNCNT       ;full revolution step count
          LXI H,DRAMPCNT
          SHLD RAMPCNT        ;ramp count
          SHLD RAMPABS        ;absolute ramp count
          SHLD CAMRMPCT       ;dedicated camera ramp count

          LXI H,DEXPCOMP
          SHLD EXPOSURE       ;default min exp time
          SHLD EXPCOMP
          LXI H,DOPNANGL      ;rotation angle to open shutter
          SHLD OPNANGLE
          LXI H,DEXPANGL      ;open shutter exposure angle
          SHLD EXPANGLE
          LXI H,DTORQTME      ;torque time-out
          SHLD TORQTIME

*           LXI H,3
*           SHLD ADJSTPCT       ;adjustment steps for projector home
*           LXI H,398
*           SHLD REVLNCNT       ;compensated revolution step count
          RET

; Initialize variable-dependent computations each Reset time.

INITCOMP: CALL MICROSET       ;set micro-stepping status
          CALL MICROCHK       ;check micro-stepping stuff
          CALL RAMPCOMP       ;compute initial ramp table
          CALL RAMPXFER       ;transfer ramp table for camera
          CALL TIMECOMP       ;compute compensation times
          CALL OPENCOMP       ;compute open-shutter counts

          LHLD RAMPNTR        ;get initial step time
          LDED RAMPCNT
          DAD D
          MOV A,M
          MOV L,A
          MVI H,0
          SHLD STEPTIME
          SHLD RAMPBUF
          RET

; Transfer copy of default ramp table for exclusive camera usage.

RAMPXFER: LXI H,ACCLTBL2-3    ;init source table address
          LXI D,ACCLTBL3-3    ;init destination table address
          LBCD RAMPCNT        ;init ramp count
          INX B               ;adjust for extra transfer bytes
          INX B
          INX B
          INX B
          INX B
          INX B

RAMPXFR1: MOV A,M             ;get byte
          STAX D              ;put byte
          INX H               ;update pointers
          INX D
          DCX B               ;update counters
          MOV A,B
          ORA C
          JNZ RAMPXFR1        ;repeat for all table
          RET

; ThingM Test procedure.

          IF LEDISPLAY

TEST:     LXI D,BNCETM   ;wait
          CALL WAITX

          MVI A,'*'      ;output test string
          OUT LED+7
          CALL OUTSIO    ;echo output to serial port
          MVI A,'T'
          OUT LED+6
          CALL OUTSIO
          MVI A,'H'
          OUT LED+5
          CALL OUTSIO
          MVI A,'I'
          OUT LED+4
          CALL OUTSIO
          MVI A,'N'
          OUT LED+3
          CALL OUTSIO
          MVI A,'G'
          OUT LED+2
          CALL OUTSIO
          MVI A,'M'
          OUT LED+1
          CALL OUTSIO
          MVI A,'*'
          OUT LED+0
          CALL OUTSIO
          CALL OUTEOLN

          LXI D,0        ;pause
          CALL WAITX
          RET

          ENDIF

; ThingM Test procedure.

          IF LCDISPLAY

; LCD display output across left and right sections.
; Echo output to serial port 1 character at a time.

TEST:     LXI D,BNCETM        ;wait
          CALL WAITX

          CALL WAITLCD
          MVI A,LCDADDRL+2    ;set left-hand display address
          OUT LCDCNTL
          MVI A,'*'           ;output test string
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'*'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'*'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'T'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'H'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'I'
          CALL OUTLCD
          CALL OUTSIO

          CALL WAITLCD
          MVI A,LCDADDRR+0    ;set right-hand display address
          OUT LCDCNTL
          MVI A,'N'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'G'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'M'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'*'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'*'
          CALL OUTLCD
          CALL OUTSIO
          MVI A,'*'
          CALL OUTLCD
          CALL OUTSIO

          LXI D,0               ;pause
          CALL WAITX

          CALL WAITLCD
          MVI A,LCDADDRL        ;set left-hand display address
          OUT LCDCNTL
          MVI B,8
TBLANKL:  MVI A,' '
          CALL OUTLCD
          DJNZ TBLANKL

          CALL WAITLCD
          MVI A,LCDADDRR        ;set right-hand display address
          OUT LCDCNTL
          MVI B,8
TBLANKR:  MVI A,' '
          CALL OUTLCD
          DJNZ TBLANKR
          RET

          ENDIF




*         DB '(C) 1990 Penguin Associates'




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
KILLSTAT: DS 1           ;run-time Kill status for single-frame loop

SWITMASK: DS 1           ;switch sensing mask
SWITSTAT: DS 1           ;switch sensing check-point status
SWITCNT:  DS 2           ;switch sensing check-point count
WHSWITCH: DS 1           ;switch sensing selection for camera or projector
ADJSTPCT: DS 2           ;adjustment step count for projector home sensing
RUNADJCT: DS 2           ;run-time adjustment single-step count

MOTROVER: DS 1           ;motor over
TIMROVER: DS 1           ;timer over
HOMEOVER: DS 1           ;home over
TORQTIME: DS 2           ;torque time-out for motor enable line

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
OUTFRAME: DS 2           ;out-frame counter #

STEPSTAT: DS 1           ;step camera sequencing
SKIPSTAT: DS 1           ;skip projector sequencing
CYCLECNT: DS 2           ;step/skip cycle count
RUNCYCLR: DS 2           ;run-time step/skip cycle count

SYNCSTAT: DS 1           ;sync main projector & aerial projector status
AERLSTAT: DS 1           ;aerial projector status
AERDIRST: DS 1           ;aerial projector direction
AERFRMCT: DS 2           ;aerial projector frame count
AERABSCT: DS 2           ;aerial projector absolute frame count
AERLCNTR: DS 2           ;aerial projector cummulative counter
PRJCNTBF: DS 2           ;main projector counter buffer
AERCNTBF: DS 2           ;aerial projector counter buffer
PRJDIRBF: DS 1           ;run-time main projector direction buffer
CAMRMPCT: DS 2           ;dedicated camera ramp count
RUNDISBF: DS 2           ;run-time display buffer for PRJ or AER pointer
MSGBUF3:  DS 2           ;run-time display buffer pointer for whatever

CAMOUTFR: DS 2           ;camera out frame buffer
PRJOUTFR: DS 2           ;main projector out frame buffer
AEROUTFR: DS 2           ;aerial projector out frame buffer

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
MINSPEED: DS 2           ;user-defined min low speed for ramping base

KEYSTAT:  DS 1           ;input key status
KEYBUF:   DS 1           ;input key buffer
DIGPNTR:  DS 2           ;input digit string pointer
DIGADDR:  DS 2           ;composite LED digit/address code pointer
DIGCNTR:  DS 1           ;LED digit counter
INDIGBUF: DS 16          ;input digit string buffer
OUTDIGBF: DS 16          ;output digit string buffer
XFERBUF:  DS 16          ;input-to-output digit string transfer buffer
FLASHPTR: DS 2           ;output string pointer for flashing routine

CONVACCM: DS 2           ;digit string --> number value conversion accum
DECWT:    DS 2           ;decimal weight multiplier
FRACTION: DS 1           ;fractional decimal place counter
CONVCNTR: DS 1           ;total digit counter
NEGSTAT:  DS 1           ;negative number status
CURSRMEM: DS 1           ;flashing cursor memory

LOWSPD:   DS 2           ;ramping Low Speed
HIGHSPD:  DS 2           ;ramping High Speed
DELTA:    DS 16          ;ramping speed difference
ACCLTBL3: DS 1016        ;ramp table for camera step times
ACCLTBL2: DS 1016        ;ramp table for step times
ACCLTBL1: DS 2016        ;ramp table for speeds

STACKBUF: DS 200         ;stack buffer
STACK:    DS 2



          END
          
