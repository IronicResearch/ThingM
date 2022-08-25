* ThingM-LX / ThingM-LC.
* ThingM-LX: Frontlight/Backlight Exposure feature set.
*            Motor Power manual overide for Low Power at standstill.
* ThingM-LC: Time Lapse and Time Exposure feature set.
*            No Motor Power at standstill using Low Power control line
*            and driver board wiring option.

* 08-17-99
* Copyright 1989-99 Dave Milici,
* aka Penguin Associates and Ironic Research Labs, San Francisco.

* Telephone / Calculator Keypad layout option.
* Liquid Crystal Display / LED Display option.
* LCD module with read/write or write-only interface option.

* 400 ppr half-stepper / 2000 ppr micro-stepper.
* 16-bit run-time ramping.
* Open-loop operation counts stepper pulses.
* Closed-loop operation senses switch interrupts.

* Mitchell 35mm camera installation.
* DC stepping motor @ 4 revs/sec.
* Home switch sensing inverted = Low.
* Auxiliary DC enable line for Low-Power / High-Power operation.

* Real-time clock.
* Variable Lapse Time.
* Variable Exposure Time.
* Variable Motor High-Power Enable Time.
* User-definable Minimum Motor Speed.

* Measure lapse times according to real-time clock.
* Allow quick status displays of data at run-time.
* Convert Exposure Times to Film Speeds.
* Rack-Over switch sensing.
* Wedge exposure times.
* Absolute (Goto) Frame Counts.
* Whip-open Film Speed for Time-Exposures.
* Trigger time-out before exposures.
* Trigger output High / Low overide.
* Torque time-out whenever motor stops.
* Approximate 1 FPS speed for 0.50 SEC exposure.
* Sequenced Exposures for Frontlight/Backlight accessory.
* Timed Exposures via Remote Trigger Input ("Bulb" mode).



FALSE:    EQU 0
TRUE:     EQU NOT FALSE

VERSION:  EQU 272        ;Version Number

THINGMLX: EQU true       ;ThingM-LX feature set
THINGMLC: EQU false      ;ThingM-LC feature set

CLK1MHZ:  EQU FALSE      ;1 MHz
CLK125M:  EQU FALSE      ;1.2288 MHz
CLK180M:  EQU false      ;1.8432 MHz
CLK2MHZ:  EQU FALSE      ;2 MHz
CLK250M:  EQU FALSE      ;2.4576 MHz
CLK360M:  EQU true       ;3.6864 MHz
CLK4MHZ:  EQU FALSE      ;4 MHz
CLK6MHZ:  EQU FALSE      ;6 MHz
CLK8MHZ:  EQU FALSE      ;8 MHz

PROTOTYPE EQU FALSE      ;Prototype

DUALPORT  EQU false      ;extended dual PIO port

LEDISPLAY EQU FALSE      ;LED display
LCDISPLAY EQU TRUE       ;LCD display
LCDLONG   EQU true       ;LCD longer than 16 chars
LCD2ROW   EQU true       ;LCD with 2nd row
LCDREAD   EQU false      ;LCD module is read/write or write-only ?

PHONEKEY  EQU TRUE       ;Telephone keypad layout
KEYLONG   EQU false      ;extended keypad

SERIALIO  EQU false      ;Serial interface
SERIALINT EQU false      ;interrupt-driven serial input

DEBUGGER  EQU FALSE      ;Remote Debugger






          MACLIB Z80
          MACLIB UTILITY

	  MACLIB THINGM
	  MACLIB KEYIO
	  MACLIB LCDIO
	  MACLIB LEDIO
	  MACLIB SERIO
	  MACLIB MUXIO


MTRG:     EQU 7          ;motor run trigger output line
MDIR:     EQU 6          ;motor direction output line
MNLP:     EQU 5          ;motor enable DC Low-Power standby
MNDC:     EQU 4          ;motor enable DC

          IF LEDISPLAY
DCUR:     EQU 3          ;display cursor enable line
          ENDIF

SHME:     EQU 0          ;switch home input
SRKO:     EQU 1          ;switch count input
STRG:     EQU 2          ;switch trigger input


          IF LCD2ROW

D3:       EQU 2          ;default data display index
D6:       EQU 8
C3:       EQU 0          ;camera display index
A3:       EQU C3+16      ;auxiliary display index

          ENDIF


; Reset initialization routines.
; Try pulling Input pins High with initial Output byte.

          ORG 0000H

          IF PROTOTYPE
QUIETIO:  EQU 01111111B       ;quiet output: MTRG, MDIR, MNLP, DCUR, MNDC
          ELSE
QUIETIO:  EQU 01111111B       ;quiet output: MTRG, MDIR, MNLP, MNDC, DCUR
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
          CALL TEST           ;test output
          CALL RESETMEM       ;init memory registers
          CALL INITIALZ       ;init variables

          MVI A,RAMADDR/256   ;load interrupt vector
          STAI
          EI
          JMP PREMAIN



; Maskable Interrupt routine.

          ORG 0038H

INT:      EI
          RETI



          DB '(C) 1989-98 Ironic Research Labs'

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
          SHLD INTCTCV3

          CALL MOTOROFF       ;turn off AC motor enable

          XRA A               ;signal motor over
          STA MOTROVER

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
          SHLD INTCTCV3

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

; Acceleration routine for multiple revolutions.

FRAMEACL: EXX
          EXAF
          LDA TMRCMDBF        ;re-load timer
          OUT CTC0
          MOV A,M
          OUT CTC0            ;load acceleration step-time interval
          INX H               ;update step-time pointer
          DCX B               ;update ramp-count counter
          MOV A,B
          ORA C             ;16-bit ramp count over ?
          JNZ EXITFRMX

          SHLD MAXPNTR      ;save ramp table pointer
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

          LXI H,CONSTINT
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

CLOCKINT: PUSH H
          LHLD REALTIME
          INX H                 ;update real-time clock by 0.01 second
          SHLD REALTIME

EXITCLOK: POP H
          EI
          RETI

; Cursor interrupt routine.

          IF LEDISPLAY

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
; Leave program selection on display.
; Hot-key selections only:
; Frame Count, Exposure Time, Direction.

MOK:      DB 'OK '
MOKF:     DB 'OK+'
MOKR:     DB 'OK-'

          IF LCD2ROW
MSGBLANK: DB ';'
          ENDIF

PREMAIN:  LHLD COUNTER        ;display current frame counter at reset
          CALL OUTNUM

MAIN:
          IF LCD2ROW
          LXI H,MSGBLANK      ;blank help string
          CALL OUTMSG
          ENDIF

          LXI H,MOK           ;display Ready prompt
          CALL OUTSIGN        ;with direction
          CALL OUTLED3

          LHLD COUNTER        ;display frame counter total
          CALL OUTNUM

          LHLD COUNTER        ;compute current frame
          LDED FRAMECNT       ;+ preset frame count
          ORA A
          DADC DE             
          SHLD OUTFRAME       ;= end frame

WAITMAIN: IN SWITCH
          BIT SRKO,A          ;rack-over switch input ?
          JNZ RACKIT

          IN SWITCH           
          BIT STRG,A          ;trigger input ?
          JNZ TRIGIT

          CALL INKEY          ;get key input ?
          JNC WAITMAIN

          LDA KEYBUF
          CPI PROGRAM         ;Program ?
          CZ PRGMIT

          CPI ONE             
          CZ FRAMEIT          ;Frame Count ?

          CPI MINUS
          CZ DIRIT            ;Direction ?

          CPI RUN             ;Run ?
          CZ RUNIT

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

          LHLD EXPOSURE       ;negative exposure time ?
          BIT 7,H
          JNZ SKIPWTRG        ;then run timed exposure

WAITTRIG: IN SWITCH           ;else wait for switch release
          BIT STRG,A
          JNZ WAITTRIG

SKIPWTRG: LXI H,1             ;preset 1 single frame only
          SHLD FRAMEABS

          CALL RUNIT          ;then run it...

          LHLD FRAMECNT       ;re-transfer programmed frame count
          SHLD FRAMEABS
          CALL DIRTOFRM       ;check direction
          SHLD FRAMEABS       ;insure positive absolute value

EXITTRIG: JMP MAIN

; Rack-over switch detection loop.

MRKO:     DB 'RKO'

RACKIT:   LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          IN SWITCH           ;rack-over switch input ... for sure ?
          BIT SRKO,A
          JZ EXITRACK

RACKPTRN: LXI H,MRKO          ;flash Rack state
          CALL OUTLED3
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
          CALL OUTLED3
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

; Program input loop.

          IF LEDISPLAY
MPGM:     DB 'PGM'
M129:     DB ' 1--9'
          ENDIF

          IF LCDISPLAY
MPGM:     DB 'PGM'
M129:     DB '  1--9'
          ENDIF

          IF LCD2ROW
          DB 'Program Menu;'
          ENDIF

PRGMIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MPGM+9        ;display Program help string
          CALL OUTMSG
          ENDIF

          LXI H,MPGM          ;display Program mode
          CALL OUTLED3
          LXI H,M129          ;with mini menu prompt
          CALL OUTLED5

WAITPRGM: CALL INKEY          ;get Program key
          JNC WAITPRGM

          LDA KEYBUF
          CPI PROGRAM
          CZ MENUIT           ;Menu Selection ?

          CPI POINT
          CZ INTERNIT         ;Internal Selections ?

          IF THINGMLX

          CPI ONE
          CZ FRAMEIT          ;Frame Count ?

          CPI TWO
          CZ OUTFRMIT         ;Out Frame Number ?

          CPI THREE            
          CZ COUNTIT          ;Total Count ?

          CPI FOUR             
          CZ EXPIT            ;Exposure Time ?

          CPI FIVE
          CZ WEDGEIT          ;Wedge Exposures ?

          CPI SIX           
          CZ LAPSEIT          ;Lapse Time ?

          CPI SEVEN
          CZ FRTBAKIT         ;Frontlight/Backlight ?

          CPI EIGHT
          CZ OUTRIGIT         ;Output Trigger Overide ?

          CPI NINE
          CZ VTRIGIT          ;Output Trigger Delay ?

          CPI ZERO
          CZ POWERIT          ;Motor Power ?

          CPI MINUS
          CZ DIRIT            ;Direction ?

          ELSE                ;THINGMLC

          CPI ONE
          CZ FRAMEIT          ;Frame Count ?

          CPI TWO
          CZ COUNTIT          ;Total Count ?
          
          CPI THREE
          CZ OUTFRMIT         ;Out Frame Number ?

          CPI FOUR
          CZ EXPIT            ;Exposure Time ?

          CPI FIVE
          CZ LAPSEIT          ;Lapse Time ?

          CPI SIX
          CZ VTRIGIT          ;Output Trigger Delay ?

          CPI SEVEN
          CZ VEXPIT           ;Variable Exposures Times ?

          CPI EIGHT
          CZ VLAPSIT          ;Varaiable Lapse Times ?

          CPI NINE
          CZ OUTRIGIT         ;Output Trigger Overide ?

          CPI ZERO
          CZ WEDGEIT          ;Wedge Exposures ?

          CPI MINUS
          CZ DIRIT            ;Direction ?

          ENDIF               ;THINGMLX

          POP PSW
          RET

; Scroll through range of menu selections.

MENUIT:   PUSH PSW

          IF THINGMLX

          CALL FRAMEIT
          CALL DIRIT
          CALL OUTFRMIT
          CALL COUNTIT
          CALL EXPIT
          CALL WEDGEIT
          CALL LAPSEIT
          CALL FRTBAKIT
          CALL OUTRIGIT
          CALL VTRIGIT
          CALL POWERIT

          ELSE

          CALL FRAMEIT
          CALL DIRIT
          CALL COUNTIT
          CALL OUTFRMIT
          CALL EXPIT
          CALL LAPSEIT
          CALL VTRIGIT
          CALL VEXPIT
          CALL VLAPSIT
          CALL OUTRIGIT

          ENDIF

          POP PSW
          RET

; Allow for internal programming selections.

          IF LEDISPLAY
MINT:     DB 'INT'
M125:     DB ' 0--9'
          ENDIF

          IF LCDISPLAY
MINT:     DB 'INT'
M125:     DB '  0--9'
          ENDIF

          IF LCD2ROW
          DB 'Internal Menu;'
          ENDIF

INTERNIT: PUSH PSW

          IF LCD2ROW
          LXI H,MINT+9        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MINT          ;display Internal mode
          CALL OUTLED3
          LXI H,M125          ;with mini menu prompt
          CALL OUTLED5

WAITINTE: CALL INKEY          ;get Internal Program key
          JNC WAITINTE

          LDA KEYBUF
          CPI POINT           ;Internal Menu ?
          CZ IMENUIT

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
          CZ MINEXPIT         ;Minimum Exposure Time ?

          CPI FIVE            
          CZ MINSPDIT         ;Minimum Film Speed ?

          CPI SIX
          CZ WHPSPDIT         ;Whip-open Film Speed ?

          CPI SEVEN
          CZ SPEEDIT          ;Film Speed / Motor Speed ?

          CPI EIGHT           
          CZ ACCELIT          ;Speed Ramp ?

          CPI NINE
          CZ VTORQIT          ;Motor Torque Time ?

          POP PSW
          RET                 ;else return to main menu

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
          CALL ACCELIT
          CALL VTORQIT

          POP PSW
          RET

; Frame Count input.
; (Any pending wedge sequence is cleared.)

MFRM:     DB 'FRM'
MFR2:     DB 'FR2'

          IF LCD2ROW
          DB 'Frame Count;'
          ENDIF

FRAMEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MFRM+6        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MFRM          ;prompt FRM
          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JZ WHATFRM
          LXI H,MFR2
WHATFRM:  CALL OUTLED3

          LHLD FRAMECNT       ;update frame count -- same for either mode
          CALL MODNUM
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

          IF LEDISPLAY
MDR:      DB 'DIR'
MFOR:     DB ' FOR+'
MREV:     DB ' REV-'
          ENDIF

          IF LCDISPLAY
MDR:      DB 'DIR'
MFOR:     DB ' FOR +'
MREV:     DB ' REV -'
          ENDIF

          IF LCD2ROW
          DB 'Direction;'
          ENDIF

DIRIT:    PUSH PSW

          IF LCD2ROW
          LXI H,MDR+15        ;help string
          CALL OUTMSG
          ENDIF

          CALL CURSRON        ;turn cursor on

LOOPDIRT: LXI H,MDR           ;display present direction
          CALL OUTLED3
          CALL OUTDIR
          CALL OUTLED5
          CALL CURSRADJ       ;flash cursor over + / - sign

WAITDIRT: CALL INKEY          ;loop for key input
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
; ThingM-LX: Initial End Frame value = Counter Total.
; ThingM-LC: Initial End Frame value = Frame Count + Counter Total.

          IF THINGMLX
MOUT:     DB 'ABS'
MOU2:     DB 'AB2'
          IF LCD2ROW
          DB 'Absolute Goto;'
          ENDIF
          ELSE
MOUT:     DB 'END'
MOU2:     DB 'EN2'
          IF LCD2ROW
          DB 'End Frame Goto;'
          ENDIF
          ENDIF


OUTFRMIT: PUSH PSW

          IF LCD2ROW
          LXI H,MOUT+6        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MOUT            ;prompt OUT
          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ WHATOUT
          LXI H,MOU2
WHATOUT:  CALL OUTLED3

          IF THINGMLX

          LHLD COUNTER          ;load current counter frame # as out frame #
          CALL MODNUM
          SHLD OUTFRAME

          ELSE                  ;THINGMLC

          LHLD COUNTER          ;load current counter frame # as out frame #
          LDED FRAMECNT         ;+ current preset frame count
          ORA A
          DADC DE
          CALL MODNUM
          SHLD OUTFRAME

          ENDIF                 ;THINGMLX

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
; Converts to matching film speed.
; Bottom out at minimum exposure time.
; (Any pending wedge sequence is cleared.)

MEXP:     DB 'EXP'
MEX1:     DB 'EX1'
MEX2:     DB 'EX2'

          IF LCD2ROW
          DB 'Exposure Time;'
          ENDIF

EXPIT:    PUSH PSW

          IF LCD2ROW
          LXI H,MEXP+9          ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MEXP
          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ WHATEXP
          LXI H,MEX1
WHATEXP:  CALL OUTLED3

          LHLD EXPOSURE         ;update exposure time
          LHLD EXPOSUR1
          CALL MODDEC           ;modify
          SHLD EXPOSURE
          SHLD EXPOSUR1

          LDA KEYBUF            ;Cancel ?
          CPI PROGRAM
          JZ EXITEXP1

          LDED MINEXPTM         ;compare with min exp time ?
          ORA A
          DSBC DE
          JNC SKIPMEXP
          LHLD MINEXPTM
          SHLD EXPOSURE
          SHLD EXPOSUR1

SKIPMEXP: CALL SPEEDCMP         ;compute film speed to match
          CALL RAMPCOMP         ;compute speed ramp table
          CALL TIMECOMP         ;compute exp time compensation

          XRA A
          STA WDGSTAT           ;kill wedge
          STA ETMSTAT

EXITEXP1: LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ EXITEXP

          LXI H,MEX2            ;2nd exp time
          CALL OUTLED3

          LHLD EXPOSUR2         ;update exposure time
          CALL MODDEC           ;modify
          SHLD EXPOSUR2

          LDA KEYBUF            ;Cancel ?
          CPI PROGRAM
          JZ EXITEXP2

          LDED MINEXPTM         ;compare with min exp time ?
          ORA A
          DSBC DE
          JNC EXITEXP2
          LHLD MINEXPTM
          SHLD EXPOSUR2
EXITEXP2: CALL MINLAPST         ;compute min lapse times

EXITEXP:  POP PSW
          RET     

; Lapse Time input.

MLPS:     DB 'LPS'
MLP1:     DB 'LP1'
MLP2:     DB 'LP2'

          IF LCD2ROW
          DB 'Lapse Time;'
          ENDIF

LAPSEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MLPS+9          ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MLPS
          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ WHATLPS
          LXI H,MLP1
WHATLPS:  CALL OUTLED3

          LHLD LAPSE            ;update lapse time
          LHLD LAPSE1
          CALL MODDEC
          SHLD LAPSE
          SHLD LAPSE1

          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ EXITLPS

          LXI H,MLP2
          CALL OUTLED3

          LHLD LAPSE2           ;update lapse time #2
          CALL MODDEC
          SHLD LAPSE2

          CALL MINLAPST         ;insure minimum lapse times to match triggers

EXITLPS:  POP PSW
          RET

; Total Count input.

MCNT:     DB 'CTR'
MCT2:     DB 'CT2'

          IF LCD2ROW
          DB 'Counter Total;'
          ENDIF

COUNTIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MCNT+6          ;help string
          CALL OUTMSG
          ENDIF

          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JNZ COUNTIT2

          LXI H,MCNT
          CALL OUTLED3

          LHLD COUNTER1         ;update cummulative frame counter
          CALL MODNUM
          SHLD COUNTER1
          SHLD COUNTER
          POP PSW
          RET

COUNTIT2: LXI H,MCT2
          CALL OUTLED3
          LHLD COUNTER2         ;update cummulative frame counter
          CALL MODNUM
          SHLD COUNTER2
          SHLD COUNTER
          POP PSW
          RET

; Specify variable-length Output Trigger time.

MVTR:     DB 'TRG'
MVT1:     DB 'TR1'
MVT2:     DB 'TR2'

          IF LCD2ROW
          DB 'Trigger Delay;'
          ENDIF

VTRIGIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MVTR+9          ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MVTR
          LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ WHATTRG
          LXI H,MVT1
WHATTRG:  CALL OUTLED3

          LHLD TRIGTIME         ;update output trigger time
          LHLD TRIGTME1
          CALL MODDEC
          SHLD TRIGTIME
          SHLD TRIGTME1

          MOV A,H               ;trigger time = 0 ?
          ORA L
          JNZ SKIPMTRG
          LXI H,1
          SHLD TRIGTIME         ;insure minimum trigger time = 0.01 sec
          SHLD TRIGTME1

SKIPMTRG: LDA FRBKSTAT          ;frontlight/backlight ?
          ORA A
          JZ EXITVTRG

          LXI H,MVT2
          CALL OUTLED3

          LHLD TRIGTME2         ;update output trigger time
          CALL MODDEC
          SHLD TRIGTME2
          MOV A,H               ;trigger time = 0 ?
          ORA L
          JNZ SKIPMTR2
          LXI H,1
          SHLD TRIGTME2         ;insure minimum trigger time = 0.01 sec

SKIPMTR2: CALL MINLAPST         ;insure minimum lapse times to match

EXITVTRG: POP PSW
          RET

; Special routine for minimizing lapse times = trigger times + exposure times

MINLAPST: LDA FRBKSTAT
          ORA A
          RZ

          LHLD LAPSE1           ;compare lapse time > trigger delay time
          LDED TRIGTME2
          LHLD EXPOSUR1         ;... + exposure time
          DAD D
          LXI D,50              ;... + 0.50 sec revolution time
          DAD D
          XCHG
          LHLD LAPSE1
          ORA A
          DSBC DE
          JNC SKPMINL1
          INX D
          SDED LAPSE1           ;if short, min lapse time = trig time... + 1

SKPMINL1: LHLD LAPSE2
          LDED TRIGTME1
          LHLD EXPOSUR2
          DAD D
          LXI D,50
          DAD D
          XCHG
          LHLD LAPSE2
          ORA A
          DSBC DE
          JNC SKPMINL2
          INX D
          SDED LAPSE2
SKPMINL2: RET

; Specify variable-length Torque time-out.
; Used for Motor High-Power Enable line.

MTRQ:     DB 'TRQ'

          IF LCD2ROW
          DB 'Torque Timeout;'
          ENDIF

VTORQIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MTRQ+3          ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MTRQ
          CALL OUTLED3

          LHLD TORQTIME         ;update torque time
          CALL MODDEC
          SHLD TORQTIME
          MOV A,H               ;torque time = 0 ?
          ORA L
          JNZ EXITVTRQ
          LXI H,1
          SHLD TORQTIME         ;insure minimum torque time = 0.01 sec

EXITVTRQ: POP PSW
          RET

; Special Lapse Time Acceleration / Deceleration programming.
; Acceleration Frame Count input.

          IF THINGMLC

MVLP:     DB 'VLP'
MVFR:     DB '+FR'

          IF LCD2ROW
          DB 'Variable Lapse;'
          ENDIF

VLAPSIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MVLP+6        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MVLP
          CALL OUTLED3

          LHLD ADJLAPSE       ;variable lapse time 
          CALL MODDEC
          SHLD ADJLAPSE
          MOV A,H
          ORA L
          STA TMRSTAT
          JZ EXITVLAP

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITVLAP

          LXI H,MVFR
          CALL OUTLED3
                              
          LHLD LPACLCNT       ;variable lapse time frame count
          CALL MODNUM
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

          ENDIF               ;THINGMLC

; Variable Exposure Time adjustment input.
; Bottom out at minimum exposure time.

          IF THINGMLC

MVEX:     DB 'VEX'

          IF LCD2ROW
          DB 'Variable Exposure;'
          ENDIF

VEXPIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MVEX+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MVEX
          CALL OUTLED3

          LHLD ADJEXP         ;variable exposure time
          CALL MODDEC
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
          CALL OUTLED3
                              
          LHLD EXACLCNT       ;variable exposure time frame count
          CALL MODNUM
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

          ENDIF               ;THINGMLC

; Wedge Exposure Time adjustment input.
; Bottom out at minimum exposure time.
; Original exposure time and frame count are saved.
; Insure maximum exposure time within table = 64 seconds.

MWDG:     DB 'WDG'

          IF LCD2ROW
          DB 'Wedge Exposure;'
          ENDIF

TWDG:     DW 6, 8
          DW 12, 17
          DW 25, 35
          DW 50, 70
          DW 100, 141
          DW 200, 282
          DW 400, 564
          DW 800, 1128
          DW 1600, 2256
          DW 3200, 4512
          DW 6400, 0

WEDGEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MWDG+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MWDG
          CALL OUTLED3

          LHLD ADJEXP         ;variable exposure time
          CALL MODDEC
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

          LXIX TWDG           ;init timing data as source table
          LXIY EXPOSBUF       ;init var exp data as destination
          LXI B,0             ;init count for wedge exposures
          LDED MINEXPTM
WDGMIN:   LDX L,0
          LDX H,1
          ORA A
          DSBC DE             ;compare wedge exp < min exp ?
          JNC WDGCNT
          INXIX
          INXIX
          JMP WDGMIN          ;then re-loop for min wedge exp

WDGCNT:   LDED ADJEXP
WDGMAX:   LDX L,0             ;load exp time from ROM
          LDX H,1
          STY L,0             ;save it to RAM
          STY H,1
          INXIX
          INXIX
          INXIY
          INXIY
          INX B               ;count number of var exposures in wedge
          ORA A
          DSBC DE             ;compare wedge exp > max wedge ?
          JC WDGMAX

          SBCD EXACLCNT       ;save buffer frame count
          SBCD FRAMECNT
          SBCD FRAMEABS
          PUSH B
          POP  H
          CALL DIRTOFRM       ;check direction
          SHLD FRAMECNT       ;insure actual value

EXITWDGT: POP PSW
          RET

; Variable Lapse Time computations.
; Uses Variable Film Speed computation routines
; and moves Lapse Time values into run-time buffer.

          IF THINGMLC

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

          ENDIF               ;THINGMLC

; Variable exposure time computations.
; Uses same ramp buffer technique as variable lapse time.
; Allow for minimum exposure time to be converted into maximum film speed.

          IF THINGMLC

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

          ENDIF               ;THINGMLC

; Speed Maximum of motor rotation.
; Selection of Speed changes Initial Ramp Table Address,
; which may also change Ramp Count if too long.
; Special case for Constant Speed = 0 Ramp count,
; where Ramp Table Pointer gets RAM address.

MSPD:     DB 'SPD'

          IF LCD2ROW
          DB 'Speed (Rev/Sec);'
          ENDIF

SPEEDIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MSPD+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MSPD
          CALL OUTLED3

          LHLD SPEED          ;display actual speed
          CALL MODDEC
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

; Motor speed acceleration in user terms of fraction of revolution.
; Inter-relates with ramp count.

MACL:     DB 'RMP'

          IF LCD2ROW
          DB 'Speed Ramp (Rev);'
          ENDIF

ACCELIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MACL+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MACL
          CALL OUTLED3

          LHLD REVLNCNT       ; compare revolution count = 400 ?
          LXI D,400
          ORA A
          DSBC DE
          JZ ACLEZ4           ; if 400, then use easy arithmetic
          LHLD REVLNCNT       ; else compute revolution count / 100
          LXI D,100
          CALL DIVIDE
          PUSH B
          POP D
          PUSH D              ; save for re-scaling
          LHLD RAMPABS        ; compute ramp count / (rev count / 100)
          CALL DIVIDE
          MOV L,C
          MOV H,B
          CALL MODDEC         ; = fraction (scaled / 100 for decimal)
          MOV A,L
          POP D               ; restore (rev count / 100)
          CALL MULTIPLY       ; compute (fraction * 100) * (rev count / 100)
          SHLD RAMPABS        ; = ramp count
          SHLD RAMPCNT
          JMP ACLCMP

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

ACLCMP:   LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITACLT

          CALL RAMPCOMP       ;compute ramp table

EXITACLT: POP PSW
          RET

; Ramp Count Maximum of step time ramping.
; Ramp Count now indexes backwards from High Speed.
; Selection of Ramp Count does NOT change Speed.
; Special case for Constant Speed = 0 Ramp Count.

MRMP:     DB 'RMC'

RAMPIT:   PUSH PSW

          LXI H,MRMP
          CALL OUTLED3

          LHLD RAMPABS        ;display desired ramp count
          CALL MODNUM
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
          CALL OUTLED3

          LHLD RAMPNTR        ;compute step time address
          LDED RAMPCNT
          DAD D               ;... = ramp table pointer + ramp count
          MOV A,M
          MOV L,A
          MVI H,0
          CALL OUTNUM
          CALL WAITKEY

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

          IF LCD2ROW
          DB 'Steps / Rev;'
          ENDIF

STEPIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MSTP+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MSTP
          CALL OUTLED3

          LHLD REVLNCNT       ;update revolution step count
          CALL MODNUM
          SHLD REVLNCNT

          CALL MICROSET       ;micro-stepping ?
          CALL MICROCHK       ;micro-stepping...

          POP PSW
          RET

; Shutter-Open step count input.

MOPN:     DB 'OPN'

          IF LCD2ROW
          DB 'Open Shutter Rev;'
          ENDIF

OPENIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MOPN+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MOPN
          CALL OUTLED3

          LHLD OPNANGLE       ;get open-shutter angle in decimal
          CALL MODDEC
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

          IF LCD2ROW
          DB 'Shutter Angle;'
          ENDIF

ANGLEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MANG+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MANG
          CALL OUTLED3

          LHLD VARSHTR        ;get variable shutter angle in degrees
          CALL MODNUM
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

          IF LCD2ROW
          DB 'Minimum Exposure;'
          ENDIF

MINEXPIT: PUSH PSW

          IF LCD2ROW
          LXI H,MMEX+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MMEX
          CALL OUTLED3

          LHLD MINEXPTM       ;get min exp time
          CALL MODDEC
          SHLD MINEXPTM

          POP PSW
          RET

; Minimum Film Speed (for time-exposure mode).

MMSP:     DB 'MSP'

          IF LCD2ROW
          DB 'Minimum Speed;'
          ENDIF

MINSPDIT: PUSH PSW

          IF LCD2ROW
          LXI H,MMSP+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MMSP
          CALL OUTLED3

          LHLD MINSPEED       ;update min film speed
          CALL MODDEC
          SHLD MINSPEED

          LDA KEYBUF          ;Cancel ?
          CPI PROGRAM
          JZ EXITMSPD

IF 0
          LDED LOWSPDBF       ;compare min film speed < low motor speed ?
          ORA A
          DSBC DE
          JNC COMPMSPD
          XCHG                ;if lower, then bottom out at min low speed
          SHLD MINSPEED
ENDIF

COMPMSPD: CALL RAMPCOMP       ;re-compute speed ramp

EXITMSPD: POP PSW
          RET

; Whip-open Film Speed (for time-exposure mode).

MWSP:     DB 'WSP'

          IF LCD2ROW
          DB 'Whip-Open Speed;'
          ENDIF

WHPSPDIT: PUSH PSW

          IF LCD2ROW
          LXI H,MWSP+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MWSP
          CALL OUTLED3

          LHLD WHIPSPD        ;update whip-open film speed
          CALL MODDEC
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

          IF THINGMLX

          IF LEDISPLAY
MPWR:     DB 'PWR'
MPWR0:    DB ' OFF-'
MPWR1:    DB '  ON+'
          ENDIF

          IF LCDISPLAY
MPWR:     DB 'PWR'
MPWR0:    DB ' OFF -'
MPWR1:    DB '  ON +'
          ENDIF

          IF LCD2ROW
          DB 'Power Overide;'
          ENDIF

PWRKEY:   SET ZERO            ;power toggle key

POWERIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MPWR+15       ;help string
          CALL OUTMSG
          ENDIF

          CALL CURSRON

LOOPPWRT: LXI H,MPWR          ;display motor power status
          CALL OUTLED3
          LXI H,MPWR1
          CALL OUTLED5
          CALL CURSRADJ

          IN MOTRCNTL         ;sense power down ?
          BIT MNDC,A
          JZ WAITPWRT

          LXI H,MPWR0
          CALL OUTLED5
          CALL CURSRADJ

WAITPWRT: CALL INKEY          ;loop for key press
          JNC WAITPWRT

          LDA KEYBUF
          CPI ENTER
          JZ EXITPWR
          CPI PROGRAM
          JZ EXITPWR

          CPI MINUS           ;toggle power state ?
          JZ FLIPPWRT
          CPI PWRKEY
          JZ FLIPPWRT
          JMP WAITPWRT

FLIPPWRT: IN MOTRCNTL         ;actual power enable state ?
          BIT MNDC,A
          JNZ FLIPBACK

          CALL MOTORDC0       ;if enabled, then disable
          JMP LOOPPWRT

FLIPBACK: CALL MOTORNUL       ;if disabled, then re-enable (at low-power)
          JMP LOOPPWRT

EXITPWR:  CALL CURSROFF
          POP PSW
          RET

          ENDIF               ;THINGMLX

; Output Trigger Overide enable / disable selection.
; Sense input from latched output line, active Low.

          IF LEDISPLAY
MTRO:     DB 'TRX'
MTRO0:    DB ' OFF-'
MTRO1:    DB '  ON+'
          ENDIF

          IF LCDISPLAY
MTRO:     DB 'TRX'
MTRO0:    DB ' OFF -'
MTRO1:    DB '  ON +'
          ENDIF

          IF LCD2ROW
          DB 'Trigger Overide;'
          ENDIF

          IF THINGMLX
TRXKEY:   SET EIGHT           ;trigger action toggle key
          ELSE
TRXKEY:   SET NINE            ;trigger action toggle key
          ENDIF

OUTRIGIT: PUSH PSW

          IF LCD2ROW
          LXI H,MTRO+15       ;help string
          CALL OUTMSG
          ENDIF

          CALL CURSRON

LOOPTROT: LXI H,MTRO          ;display output trigger status
          CALL OUTLED3
          LXI H,MTRO0
          CALL OUTLED5
          CALL CURSRADJ

          IN MOTRCNTL         ;sense output trigger ?
          BIT MTRG,A
          JZ  WAITTROT

          LXI H,MTRO1         ;update output trigger status
          CALL OUTLED5
          CALL CURSRADJ

WAITTROT: CALL INKEY          ;loop for key press
          JNC WAITTROT

          LDA KEYBUF
          CPI ENTER
          JZ EXITTRO
          CPI PROGRAM
          JZ EXITTRO

          CPI MINUS           ;toggle output trigger state ?
          JZ FLIPTROT
          CPI TRXKEY
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

; Special Frontlight/Backlight enable / disable selection.

          IF THINGMLX

          IF LEDISPLAY
MFBX:     DB 'FBX'
MFBX0:    DB ' OFF-'
MFBX1:    DB '  ON+'
          ENDIF

          IF LCDISPLAY
MFBX:     DB 'FBX'
MFBX0:    DB ' OFF -'
MFBX1:    DB '  ON +'
          ENDIF

          IF LCD2ROW
          DB 'Front/Backlight;'
          ENDIF

FBXKEY:   SET SEVEN           ;frontlight/backlight toggle key

FRTBAKIT: PUSH PSW

          IF LCD2ROW
          LXI H,MFBX+15       ;help string
          CALL OUTMSG
          ENDIF

          CALL CURSRON

LOOPFBXT: LXI H,MFBX          ;display output trigger status
          CALL OUTLED3
          LXI H,MFBX0
          CALL OUTLED5
          CALL CURSRADJ

          LDA FRBKSTAT        ;what is frontlight/backlight status ?
          ORA A
          JZ WAITFBXT

          LXI H,MFBX1         ;update frontlight/backlight status
          CALL OUTLED5
          CALL CURSRADJ

WAITFBXT: CALL INKEY          ;loop for key press
          JNC WAITFBXT

          LDA KEYBUF
          CPI ENTER
          JZ EXITFBXT
          CPI PROGRAM
          JZ EXITFBXT

          CPI MINUS           ;toggle frontlight/backlight mode ?
          JZ FLIPFBXT
          CPI FBXKEY
          JZ FLIPFBXT
          JMP WAITFBXT

FLIPFBXT: LDA FRBKSTAT        ;toggle frontlight/backlight mode
          CMA
          STA FRBKSTAT
          JMP LOOPFBXT

EXITFBXT: CALL CURSROFF
          CALL WHATFRBK       ;frontlight/backlight data ?
          POP PSW
          RET

; Select frontlight/backlight data

WHATFRBK: LDA FRBKSTAT
          ORA A
          JNZ DOUBLCNT
          LHLD COUNTER1       ;single frame total counter
          SHLD COUNTER
          RET

DOUBLCNT: LHLD COUNTER2       ;double frame total counter
          SHLD COUNTER
          CALL MINLAPST       ;match lapse times to trigger delays
          RET

          ENDIF               ;THINGMLX

; Version identification.

MVER:     DB 'VER'

          IF LCD2ROW
          DB 'Software Version;'
          ENDIF

VERIT:    PUSH PSW

          IF LCD2ROW
          LXI H,MVER+3        ;help string
          CALL OUTMSG
          ENDIF

          LXI H,MVER
          CALL OUTLED3

          LXI H,VERSION       ;display version number
          CALL OUTDEC
          CALL WAITKEY

          POP PSW
          RET

; Run-time stop-motion motor operation.
; Lapse Time clocked according to real-time clock.
; Motor Enable Time-Out on trailing edge of each complete frame.

MRUN:     DB 'RUN'
MHLD:     DB 'HLD'
MBLK:     DB '   '
MRN1:     DB 'RX1'
MRN2:     DB 'RX2'

RUNIT:    LXI H,MRUN          ;display Run mode
          SHLD MSGBUF3
          CALL OUTLED3

          XRA A               ;clear run-time keypad status
          STA KEYSTAT
          STA KEYBUF
          STA RUNFRBKS

          LHLD FRAMEABS       ;0 Frame Count ?
          MOV A,H
          ORA L
          RZ

          LHLD FRAMEABS       ;transfer run-time frame count
          SHLD RUNFRAME

          LHLD COUNTER        ;display total frame count
          CALL OUTNUM

          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          CNZ FRBKCHK

          DI
          CALL INITCLOK       ;re-init real-time clock
          EI

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
          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JNZ PRUNLOOP
          LHLD RUNFRAME       ;single frame ?
          DCX H
          MOV A,H
          ORA L
          JZ PRUNLOOP         ;then run stop-motion
          JNZ CONTLOOP        ;else run continuous motion

PRUNLOOP: CALL TRIGROFF       ;start with trigger off

          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JZ PRUNTRIG
          STA RUNFRBKS        ;start with frontlight=1
          LHLD TRIGTME1
          SHLD TRIGTIME
          JNZ WAITNTRG

PRUNTRIG: CALL TRIGRON        ;fire output trigger prior to 1st single frame

WAITNTRG: LHLD TRIGTIME       ;load output trigger pre-exposure delay
          SHLD WAITIME

          CALL INITWAIT       ;run trigger time delay

WAITPREX: CALL PRECHECK       ;quick check for key press
          LDA TIMROVER        ;wait until pre-exposure trigger over ?
          ORA A
          JNZ WAITPREX

RUNLOOP:  LHLD REALTIME       ;mark present real-time
          SHLD MARKTIME
          LXI H,0             ;zero present real-time
          SHLD REALTIME

          LHLD MSGBUF3        ;display whatever
          CALL OUTLED3
          LHLD COUNTER
          CALL OUTNUM

          LHLD REVLNCNT       ;pre-transfer full revolution step count
          SHLD STEPCNT

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
          LHLD MSGBUF3
          CALL OUTLED3
          LHLD COUNTER        ;display updated total frame count
          CALL OUTNUM
          JMP WAITOPEN

SKPFLKEX: LDA WDGSTAT         ;wedge exposure sequence ?
          ORA A
          JZ WAITOPEN
          LXI H,MWDG          ;then display Wedge mode
          CALL OUTLED3
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

          BIT 7,H             ;negative exposure time ?
          JZ SKIPBULB         ;then run timed exposure bulb mode
WAITBULB: IN SWITCH           ;wait until input trigger goes inactive
          BIT STRG,A
          JNZ WAITBULB
          JMP CLOSEXP         ;close shutter to complete exposure

SKIPBULB: CALL INITWAIT       ;run exposure time delay

WAITEXP:  CALL PRECHECK       ;quick check for key press
          LDA TIMROVER        ;wait until exposure time over ?
          ORA A
          JNZ WAITEXP

CLOSEXP:  LHLD RUNCLOSE       ;transfer shutter-closed step count
          SHLD STEPCNT

          MVI A,FALSE
          STA SWITMASK        ;Home switch mask active now

SKIPEXP:  CALL MOTORON        ;motor control signals on

          CALL INITMOTR       ;run motor to shutter-closed position 

WAITOVER: CALL UPDTCNTR       ;update total frame counter
          LDA FRBKSTAT
          ORA A
          CNZ  UPDTCNT2       ;update frontlight/backlight frame counter

          LDA WDGSTAT         ;wedge exposure sequence ?
          ORA A
          JNZ SKPFLKHM
          LHLD MSGBUF3
          CALL OUTLED3
          LHLD COUNTER        ;display updated total frame count
          CALL OUTNUM

SKPFLKHM: LDA WDGSTAT         ;wedge sequence ?
          ORA A
          JZ LOOPOVER
          LXI H,MWDG          ;then display WDG mode
          CALL OUTLED3
          LHLD EXPOSURE       ;with current exposure time
          CALL OUTDEC

LOOPOVER: CALL PRECHECK       ;check for run-time interruption ?
          CALL CHECKPT
          LDA MOTROVER        ;wait til motor over ?
          ORA A
          JNZ LOOPOVER

          LDA ETMSTAT         ;compute variable exposure time ?
          ORA A
          CNZ EXPSOCMP

          LDA TMRSTAT         ;compute variable lapse time ?
          ORA A
          CNZ LAPSOCMP

          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JNZ ENDTRIG

          LDA LAPSTAT         ;lapse time ?
          ORA A
          JZ SKIPLAPS

          LHLD RUNFRAME       ;last single frame ?
          DCX H
          MOV A,H
          ORA L
          JZ SKIPLAPS

ENDTRIG:  CALL TRIGROFF       ;turn off output trigger signal

WAITLAPS: CALL PRECHECK       ;run-time interruption ?
          CALL QSTATPT        ;quick status display ?
          CALL CHECKPT        ;or run-time hold ?
          LDA LAPSTAT         ;run-time lapse time interruption ?
          ORA A
          JZ SKIPLAPS

          LDED RUNLAPSE       ;compare pre-trigger lapse time in real time ?
          LHLD REALTIME
          XRA A
          DSBC DE             ;... adjusted lapse time < present real time
          JC WAITLAPS

          LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JZ RUNTRIG
          LDA RUNFRBKS        ;frontlight=1 or backlight=0 now ?
          ORA A
          JZ  WAITLAPX        ;(skip if backlight now)
RUNTRIG:  CALL TRIGRON        ;re-fire output trigger prior to Nth frame

WAITLAPX: CALL PRECHECK       ;run-time interruption ?
          CALL QSTATPT        ;quick status display ?
          CALL CHECKPT        ;or run-time hold ?
          LDA LAPSTAT         ;run-time lapse time interruption ?
          ORA A
          JZ SKIPLAPS

          LDED LAPSE          ;compare rest of lapse time in real time ?
          LHLD REALTIME
          XRA A
          DSBC DE             ;... full lapse time < present real time
          JC WAITLAPX

SKIPLAPS: LDA FRBKSTAT        ;frontlight/backlight ?
          ORA A
          JZ RERUNLP
          LDA RUNFRBKS
          CMA                 ;toggle now
          STA RUNFRBKS
          CALL FRBKCOMP       ;compute next seq
          LDA RUNFRBKS        ;1st or 2nd exposure ?
          ORA A
          JZ RUNLOOP          ;1 = frontlight, 0 = backlight

RERUNLP:  LHLD RUNFRAME       ;frame count over ?
          DCX H
          SHLD RUNFRAME
          MOV A,H
          ORA L
          JNZ RUNLOOP

EXITRUNL: LDA ABSSTAT         ;absolute frame count overide ?
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
          STA RUNFRBKS

          CALL TRIGROFF       ;turn off output trigger signal

          RET

; Continuous motion run-time sequence.
; Note run-time frame counters are updated within interrupt routines.

CONTLOOP: XRA A
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

          LHLD TRIGTIME       ;load output trigger pre-exposure delay
          SHLD WAITIME

          CALL INITWAIT       ;run trigger time delay

WAITPRCN: CALL PRECHECK       ;quick check for key press
          LDA TIMROVER        ;wait until pre-exposure trigger over ?
          ORA A
          JNZ WAITPRCN

          CALL MOTORON        ;enable motor control signals

          CALL INITCONT       ;initialize continuous-running interrupts

WAITHOME: LHLD COUNTER        ;display pre-updated counter
          CALL OUTNUM
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
LOOPLAST: LDA MOTROVER        ;wait until last revolution
          ORA A
          JNZ LOOPLAST

          CALL TRIGROFF       ;turn off output trigger signal

          CALL UPDTCNTR       ;update last frame count
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

UPDTCNTR: LDA DIRSTAT         ;direction ?
          ORA A
          JNZ UPDTREV

          LHLD COUNTER1       ;increment for forward
          INX H
          SHLD COUNTER1
          SHLD COUNTER
          RET

UPDTREV:  LHLD COUNTER1       ;decrement for reverse
          DCX H
          SHLD COUNTER1
          SHLD COUNTER
          RET

; update counter for frontlight/backlight operation

UPDTCNT2: LDA DIRSTAT         ;direction ?
          ORA A
          JNZ UPDTREV2

          LDA FRBKSTAT        ;frontlight/backlight
          ORA A
          RZ
          LHLD COUNTER2
          SHLD COUNTER
          LDA RUNFRBKS
          ORA A
          RZ
          INX H               ;update for frontlight only
          SHLD COUNTER2
          SHLD COUNTER
          RET

UPDTREV2: LDA FRBKSTAT        ;frontlight/backlight
          ORA A
          RZ
          LHLD COUNTER2
          SHLD COUNTER
          LDA RUNFRBKS
          ORA A
          RZ
          DCX H
          SHLD COUNTER2
          SHLD COUNTER
          RET

; Check-Point for run-time key press.
; If key pressed, then key is input quickly and buffered for later reading.

PRECHECK: CALL INKEYST        ;key press at all ?
          RZ

          CALL INKEYQ         ;genuine key ? (quick key input)
          RNC
          MVI A,TRUE          ;if key press, then update status
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

          CALL INKEYST        ;check if quick key still pressed ?
          CNZ  INKEY          ;if so, then wait until released

HOLDPT:   LXI H,MHLD          ;flash Hold state
          CALL OUTLED3

          CALL HOLDPTRN       ;wait in Hold pattern

HOLDGO:   CALL INKEY          ;read key
          JNC HOLDPT          ;key for sure ?

          LXI H,MRUN          ;re-display Run state
          CALL OUTLED3

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
          CALL OUTLED3
          LXI H,50            ;init display flasher = 0.35 sec
WAITHLD:  LXI D,QT01SOFT      ;init software wait loop = 0.01 sec
          CALL WAITX
          CALL INKEYST        ;wait for next key press ?
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
          LXI H,1             ;swap in 1 frame to stop run-time sequence
          SHLD RUNFRAME
          EI

          LXI H,MHLD          ;display Hold state
          CALL OUTLED3

          CALL INKEYST        ;check if quick key still pressed ?
          CNZ  INKEY          ;if so, then wait until released

          MVI A,TRUE          ;flag Hold status for pausing sequence
          STA HOLDSTAT
          RET

; Check-point for re-running continuous run-time sequence.
; Flash Hold state locally on LED display while looping for key press.

RERUNPT:  LXI H,MHLD          ;display Hold state
          CALL OUTLED3

          CALL HOLDPTRN       ;wait in Hold pattern

RERUNGO:  CALL INKEY          ;read key
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
          CALL OUTLED3

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
          CPI ZERO
          JZ QSTAT0
          CPI MINUS
          JZ QSTATM
          CPI POINT
          JZ QSTATP
          RET

          IF THINGMLX

QSTAT1:   LXI H,MFRM          ;Preset Frame Count ?
          CALL OUTLED3
          LHLD FRAMECNT
          CALL OUTNUM
          RET

QSTAT2:   LXI H,MOUT          ;Preset Out Frame ?
          CALL OUTLED3
          LHLD OUTFRAME
          CALL OUTNUM
          RET

QSTAT3:   LXI H,MCNT          ;Counter ?
          CALL OUTLED3
          LHLD COUNTER
          CALL OUTNUM
          RET

QSTAT4:   LXI H,MEXP          ;Exposure Time ? (current)
          CALL OUTLED3
          LHLD EXPOSURE
          CALL OUTDEC
          RET

QSTAT5:   LXI H,MWDG          ;Variable Exposure Time ? (final)
          CALL OUTLED3
          LHLD ADJEXP
          CALL OUTDEC
          RET

QSTAT6:   LXI H,MLPS          ;Lapse Time ? (current)
          CALL OUTLED3
          LHLD LAPSE
          CALL OUTDEC
          RET

QSTAT7:   LXI H,MFBX          ;Frontlight / Backlight ?
          CALL OUTLED3
          LXI H,MFBX0
          LDA FRBKSTAT
          ORA A
          JZ  QS7
          LXI H,MFBX1
QS7:      CALL OUTLED5
          RET

QSTAT8:   LXI H,MTRO          ;Output Trigger ?
          CALL OUTLED3
          LXI H,MTRO0
          IN MOTRCNTL
          BIT MTRG,A
          JZ  QS8
          LXI H,MTRO1
QS8:      CALL OUTLED5
          RET

QSTAT9:   LXI H,MVTR          ;Trigger Time ?
          CALL OUTLED3
          LHLD TRIGTIME
          CALL OUTDEC
          RET

QSTAT0:   LXI H,MPWR          ;Motor Power ?
          CALL OUTLED3
          LXI H,MPWR0
          IN MOTRCNTL
          BIT MNLP,A
          JNZ QS0
          LXI H,MPWR1
QS0:      CALL OUTLED5
          RET

QSTATP:   LXI H,MSPD          ;Film Speed ?
          CALL OUTLED3
          LHLD SPEED
          CALL OUTDEC
          RET

QSTATM:   LXI H,MDR           ;Direction ?
          CALL OUTLED3
          CALL OUTDIR
          CALL OUTLED5
          RET

          ELSE                ;THINGMLC

QSTAT1:   LXI H,MFRM          ;Preset Frame Count ?
          CALL OUTLED3
          LHLD FRAMECNT
          CALL OUTNUM
          RET

QSTAT2:   LXI H,MCNT          ;Counter ?
          CALL OUTLED3
          LHLD COUNTER
          CALL OUTNUM
          RET

QSTAT3:   LXI H,MOUT          ;Preset Out Frame ?
          CALL OUTLED3
          LHLD OUTFRAME
          CALL OUTNUM
          RET

QSTAT4:   LXI H,MEXP          ;Exposure Time ? (current)
          CALL OUTLED3
          LHLD EXPOSURE
          CALL OUTDEC
          RET

QSTAT5:   LXI H,MLPS          ;Lapse Time ? (current)
          CALL OUTLED3
          LHLD LAPSE
          CALL OUTDEC
          RET

QSTAT6:   LXI H,MVTR          ;Trigger Time ?
          CALL OUTLED3
          LHLD TRIGTIME
          CALL OUTDEC
          RET

QSTAT7:   LXI H,MVEX          ;Variable Exposure Time ? (final)
          CALL OUTLED3
          LHLD ADJEXP
          CALL OUTDEC
          RET

QSTAT8:   LXI H,MVLP          ;Variable Lapse Time ? (final)
          CALL OUTLED3
          LHLD ADJLAPSE
          CALL OUTDEC
          RET

QSTAT9:   LXI H,MTRO          ;Output Trigger ?
          CALL OUTLED3
          LXI H,MTRO0
          IN MOTRCNTL
          BIT MTRG,A
          JZ  QS9
          LXI H,MTRO1
QS9:      CALL OUTLED5
          RET

QSTAT0:   LXI H,MWDG          ;Variable Exposure Time ? (final)
          CALL OUTLED3
          LHLD ADJEXP
          CALL OUTDEC
          RET

QSTATM:   LXI H,MDR           ;Direction ?
          CALL OUTLED3
          CALL OUTDIR
          CALL OUTLED5
          RET

QSTATP:   LXI H,MSPD          ;Film Speed ?
          CALL OUTLED3
          LHLD SPEED
          CALL OUTDEC
          RET

          ENDIF               ;THINGMLX

; Variable Exposure Times, Lapse Times, and Trigger Times.

; Init frontlight/backlight mode of operation.

FRBKCHK:  LDA FRBKSTAT
          ORA A
          RZ

          XRA A               ;0 = backlight = default
          CMA                 ;1 = frontlight
          STA RUNFRBKS
          CALL MINLAPST       ;get lapse times right
          CALL FRBKCOMP       ;compute 1st frontlight seq
          RET

; Transfer Exposure, Lapse, and Trigger Times for frontlight/backlight mode.

FRBKCOMP: LDA FRBKSTAT        ;frontlight/backlight at all ?
          ORA A
          RZ

          LDA RUNFRBKS        ;frontlight=1 or backlight=0 ?
          ORA A
          JZ FRBKCMP2

          LXI H,MRN1          ;frontlight data
          SHLD MSGBUF3
          LHLD EXPOSUR1
          SHLD EXPOSURE
          LHLD LAPSE1
          SHLD LAPSE
          LHLD TRIGTME2
          SHLD TRIGTIME
          CALL SPEEDCMP       ;convert exposure time --> film speed
          CALL RAMPCOMP       ;compute new ramp speed table to match
          CALL TIMECOMP       ;convert to new exposure time compensation
          CALL ACOMPEXP
          CALL ACOMPLAP
          RET

FRBKCMP2: LXI H,MRN2          ;backlight data
          SHLD MSGBUF3
          LHLD EXPOSUR2
          SHLD EXPOSURE
          LHLD LAPSE2
          SHLD LAPSE
          LHLD TRIGTME1
          SHLD TRIGTIME
          CALL SPEEDCMP       ;convert exposure time --> film speed
          CALL RAMPCOMP       ;compute new ramp speed table to match
          CALL TIMECOMP       ;convert to new exposure time compensation
          CALL ACOMPEXP
          CALL ACOMPLAP
          RET

; Variable Lapse Time pre-run check-point.
; Use IY table for variable lapse time table.

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

; Variable Lapse Time run-time computations.
; Only acceleration or deceleration phases of ramping are necessary.

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

; Variable Exposure Time pre-run check-point.
; Use IX pointer for variable exposure table.
; May use either scaled film speed or time exposure mode.

EXPSOCHK: LDA ETMSTAT         ;variable exposure time at all ?
          ORA A
          RZ
          STA EXPSTAT

          LXIX EXPOSBUF       ;initialize run-time exposure time pointer
          LHLD EXPOSBUF       ;transfer initial exposure time
          SHLD EXPOSURE
IF 0
          CALL QSPDCHK        ;quick match speed to exposure time
ENDIF

          LHLD EXACLCNT       ;transfer run-time acceleration count
          SHLD RUNEACLT
          SHLD RUNEDCLT

          LDA ETMPHZE         ;accelerating exposure times ?
          ORA A
          RP

          LXIX EXPOSBUF       ;else re-init buffer to top of ramp table
          LHLD EXACLCNT
          DCX H
          DAD H
          XCHG
          DADX DE             ;... = base address + (decel count -1) * 2
          LDX L,0
          LDX H,1
          SHLD EXPOSURE
IF 0
          CALL QSPDCHK        ;quick match speed to exposure time
ENDIF
          RET

; Variable Exposure Time run-time computations.
; Uses IX pointer.
; May use either scaled film speed or time exposure mode.

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

IF 0
          LHLD SPEED          ;compare speed > min low speed ?
          LDED MINSPEED
          XRA A
          DSBC DE
          JC QSPDSLOW         ;if slower, then time exposure at min low speed
          JZ QSPDSLOW
          XRA A
          STA EXPSTAT
IF 0
          CALL QSPDRAMP       ;else compute ramp to adjust high speed
ENDIF
          RET
ENDIF

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
          RET



; Motor Control Signals.

; Pre-Output motor control signals.
; Effective for DC motor enable signals before initial run.
; Original DC enable signal stays active all the time now.
; Modified DC Low-Power signal gets enabled instead.
 
MOTORPRE: IN MOTRCNTL
          RES  MNDC,A         ;DC stepper enable
          OUT MOTRCNTL
          RES  MNLP,A         ;DC low-power enable
          OUT MOTRCNTL
          RET

; Output motor control signals on.

MOTORON:  LDA DIRSTAT         ;camera direction forward or reverse ?
          ORA A
          JNZ CAMREVON

CAMFWDON: IN MOTRCNTL         ;camera forward
          SETB MDIR,A         ;motor forward
          OUT MOTRCNTL
          RES  MNDC,A         ;DC motor enable
          OUT MOTRCNTL
          RES  MNLP,A         ;LP motor enable
          OUT MOTRCNTL
          MVI A,FALSE         ;check switch mask when steps run out...
          STA SWITMASK          
          RET

CAMREVON: IN MOTRCNTL         ;camera reverse
          RES  MDIR,A         ;motor reverse
          OUT MOTRCNTL
          RES  MNDC,A         ;DC motor enable
          OUT MOTRCNTL
          RES  MNLP,A         ;LP motor enable
          OUT MOTRCNTL
          MVI A,FALSE
          STA SWITMASK          
          RET

; Output motor control signals off.
; Effective for AC motor enable signals immediately.

MOTOROFF: IN MOTRCNTL
          RET

; Output motor control signals null.
; Effective for DC motor enable signals after final time-out.
; Original DC enable signal stays active all the time now.
; Modified DC Low-Power signal gets disabled instead.

MOTORNUL: IN MOTRCNTL	      ;all motors off
          RES  MNDC,A         ;DC stepper enable YES
          OUT MOTRCNTL
          SETB MNLP,A         ;DC low-power YES
          OUT MOTRCNTL
          RET

; Output motor control signals for no torque.

MOTORDC0: IN MOTRCNTL
          SETB MNLP,A         ;DC low-power YES
          OUT MOTRCNTL
          SETB MNDC,A         ;DC enable NO
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

          LHLD RAMPCNT
          SHLD RAMPRUN
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
; Micro-stepping = 2000 steps per revolution.

MICROSET: LHLD REVLNCNT       ;compare revolution count < half-step count
          LXI D,2000
          XRA A               ;if less, then no micro-stepping
          STA MICROST
          DSBC DE
          RC
          CMA                 ;else yes micro-stepping
          STA MICROST
          RET

; Check for parameters relevant for micro-stepping.
; Micro-stepping = 2000 steps per revolution.
; Half-stepping = 400 steps per revolution.
; Special case for other steps per revolution,
; such as 1200 steps per frame for Will Vinton 3:1 motor mount.

MICROCHK: LDA MICROST         ;micro-stepping ?
          ORA A
          JNZ MICROCMP

          LHLD REVLNCNT
          LXI D,400           ;half-stepping ?
          ORA A
          DSBC DE
          JZ HALFCMP

EXACTCMP: MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF

          LHLD REVLNCNT       ;compute 100x multiplier
          LXI B,100
          CALL FASTDIVD       ; = revolution count / 100
          MOV A,E
          STA TMRMLTBF

          LHLD REVLNCNT       ;compute speed scaling constant
          LXI B,400           ;relative to 400 steps per revolution
          CALL FASTDIVD       ;ratio = X steps per rev / 400
          PUSH D
          POP B
          LXI H,KSCALEHF      ;400 steps per rev scaling constant
          CALL FASTDIVD       ; / ratio
          SDED KSCALEBF       ; = scaling constant for X steps per rev

          LHLD MINSPEED       ;minimum low speed (user-defined)
          SHLD LOWSPDBF
          RET

HALFCMP:  MVI A,IT400LRC      ;use timer <-- clock / 16
          STA TMRLDRBF
          MVI A,IT400LNC
          STA TMRCMDBF
          MVI A,4             ;4 * 100 multiplier
          STA TMRMLTBF
          LXI H,KSCALEHF      ;speed scaling constant for half-stepping
          SHLD KSCALEBF
          LHLD MINSPEED       ;minimum low speed (user-defined)
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





; Keypad Interface

	  KEYIOM

; LCD Interface

	  LCDIOM

; LED Interface

	  LEDIOM

; Serial IO Interface

	  SERIOM

; Multiplexed IO Interface

	  MUXIOM

; Utility routines.

	  MULTPLYM

	  DIVIDEM

	  FASTDIVM

	  WAITXM




; Control board initialization
; and parameter initialization routines...

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

INITCLOK: MVI A,IT800LRC      ;load clock timer on CTC2
          OUT CTC2
          MVI A,QT01          ;with multiples of 0.01 seconds
          OUT CTC2
          MVI A,100           ;initialize clock ticker = 100
          STA TICKTOCK
          LXI H,CLOCKINT      ;point to real-time clock interrupt
          SHLD INTCTCV2
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

* DSPEED:   EQU 120           ;1.20 frames per second for 72 RPM
* DSPEED:   EQU 188           ;1.88 frames per second (0.25 exp @170 deg)
* DSPEED:   EQU 200           ;2.00 frames per second
* DSPEED:   EQU 233           ;2.33 frames per second (0.12 exp @100 deg)
* DSPEED:   EQU 334           ;3.33 frames per second for 200 RPM
DSPEED:     EQU 392           ;3.92 frames per second (0.125 exp @170 deg)
* DSPEED:   EQU 400           ;4.00 frames per second

DOPNANGL:   EQU 50            ;shutter-open rotation angle = 180 deg
* DOPNANGL: EQU 35            ;125 degrees for Mitchell
* DOPNANGL: EQU 31            ;110 degrees for Bolex

DEXPANGL:   EQU 47            ;shutter-open exposure angle = 170 deg Mitchell
* DEXPANGL: EQU 65            ;shutter-open exposure angle = 235 deg Mitchell
* DEXPANGL: EQU 28            ;shutter-open exposure angle = 100 deg Bolex

DVARSHTR:   EQU 170           ;shutter angle = 170 degrees for 35mm Mitchell
* DVARSHTR: EQU 235           ;shutter angle = 235 degrees for 16mm Mitchell
* DVARSHTR: EQU 100           ;shutter angle = 100 degrees for 16mm Bolex

DEXPTIME:   EQU 12            ;exposure time = 0.12 sec for 4 FPS
* DEXPTIME: EQU 50            ;exposure time = 0.50 sec
* DEXPTIME: EQU 100           ;exposure time = 1.00 sec for time-exposure

DMINEXPT:   EQU 12            ;minimum exposure time for 4 FPS at 170 deg
* DMINEXPT: EQU 25            ;minimum exposure time for 2 FPS at 170 deg
* DMINEXPT: EQU 08            ;minimum exposure time for 3.5 FPS at 100 deg

DMINSPD:    EQU 93            ;minimum film speed for time-exposure mode
DWHIPSPD:   EQU 200           ;whip-open film speed for time-exposure mode
DTORQTME:   EQU 50            ;default torque time-out

* DREVLNCN: EQU 25000         ;revolution step count = 25000 micro-steps
* DREVLNCN: EQU 2000          ;2000 micro-steps
* DREVLNCN: EQU 1200          ;1200 half-steps for 3:1 gear ratio
DREVLNCN:   EQU 400           ;400 half-steps

* DRAMPCNT: EQU 250           ;ramp count for 2000 micro-steps
* DRAMPCNT: EQU 324           ;for 1200 half-steps 35mm (cheat)
* DRAMPCNT: EQU 200           ;for 400 half-steps 35mm open loop
DRAMPCNT:   EQU 108           ;for 400 half-steps 35mm (cheat)
* DRAMPCNT: EQU 100           ;for 400 half-steps 35mm
* DRAMPCNT: EQU 64            ;for 400 half-steps 35mm + 16mm
* DRAMPCNT: EQU 48            ;for 400 half-steps 16mm
* DRAMPCNT: EQU 0             ;no ramping for constant speed 72 RPM

INITVARS: LXI H,0
          SHLD COUNTER        ;zero counter
          SHLD COUNTER1
          SHLD COUNTER2
          SHLD EXPOSURE       ;exposure time
          SHLD EXPOSUR1
          SHLD EXPOSUR2
          SHLD LAPSE          ;lapse time
          SHLD LAPSE1
          SHLD LAPSE2
          SHLD OUTFRAME       ;out-frame counter #
          SHLD REALTIME       ;real-time clock
          SHLD ADJLAPSE       ;variable lapse time
          SHLD LPACLCNT       ;lapse acceleration count
          SHLD ADJEXP         ;variable exposure time
          SHLD EXACLCNT       ;exposure acceleration count
          LXI H,1
          SHLD FRAMECNT       ;single frame count
          SHLD FRAMEABS
          SHLD TRIGTIME       ;trigger time-out
          SHLD TRIGTME1
          SHLD TRIGTME2
          SHLD TORQTIME       ;torque time-out
          SHLD TEXQTIME
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
          STA FRBKSTAT        ;frontlight/backlight mode

          LXI H,DREVLNCN
          SHLD STEPCNT        ;step count
          SHLD REVLNCNT       ;full revolution step count
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
          SHLD EXPOSUR1
          SHLD EXPOSUR2
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
          CALL SPEEDCMP       ;compute film speed for exp time
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

	  IF LEDISPLAY

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

	  CALL BLANKLED       ;blank out display
	  RET

          ENDIF               ;LEDISPLAY

; ThingM Test procedure.

	  IF LCDISPLAY

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

	  CALL BLANKLCD       ;blank out display
	  RET

          ENDIF               ;LCDISPLAY





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

SWITMASK: DS 1           ;switch sensing mask
SWITSTAT: DS 1           ;switch sensing check-point status
SWITCNT:  DS 2           ;switch sensing check-point count

MOTROVER: DS 1           ;motor over
TIMROVER: DS 1           ;timer over
HOMEOVER: DS 1           ;home over

TRIGTIME: DS 2           ;output trigger time-out delay
OUTFRAME: DS 2           ;out-frame counter #
TORQTIME: DS 2           ;motor torque time-out
TEXQTIME: DS 2           ;torque time-out during time exposures

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

LOWSPD:   DS 2           ;ramping Low Speed
HIGHSPD:  DS 2           ;ramping High Speed
DELTA:    DS 16          ;ramping speed difference
ACCLTBL2: DS 1016        ;ramp table for step times
ACCLTBL1: DS 2016        ;ramp table for speeds

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
ABSSTAT:  DS 1           ;absololute frame overide

FRBKSTAT: DS 1           ;frontlight/backlight sequence
RUNFRBKS: DS 1           ;run-time frontlight/backlight status
EXPOSUR1: DS 2           ;exposure time for frontlight
EXPOSUR2: DS 2           ;exposure time for backlight
LAPSE1:   DS 2           ;lapse time for frontlight
LAPSE2:   DS 2           ;lapse time for backlight
TRIGTME1: DS 2           ;trigger delay time for frontlight
TRIGTME2: DS 2           ;trigger delay time for backlight
COUNTER1: DS 2           ;counter for normal single-frame operation
COUNTER2: DS 2           ;counter for double-exposure sequence
MSGBUF3:  DS 2           ;run-time message buffer pointer

RUNACLCT: DS 2           ;run-time lapse acceleration count
RUNDCLCT: DS 16          ;run-time lapse decleration count
LAPSEBUF: DS 1016        ;variable lapse time buffer

RUNEACLT: DS 2           ;run-time exposure acceleration count
RUNEDCLT: DS 16          ;run-time exposure decleration count
EXPOSBUF: DS 1016        ;variable exposure time buffer

STACK:    EQU RAMADDR+8000



          END
          
