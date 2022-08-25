* The birth of a new ThingM.
* Production version for ThingM II extended keypad and display.
* Includes option for DSD80 Remote Debugger patch.

* 09-08-98
* Copyright 1990-98 Penguin Associates &
* Ironic Research Labs, San Francisco.

* Option for LED Display or Liquid Crystal Display.
* Dual 40-character buffers for top and bottom display addressing.
* 2nd character row for extended help string prompts.
* LCD module with read/write or write-only interface option.

* RS-232 Serial Interface.
* Multiplexed input/output via remote terminal.
* Output to LED displays echoed to serial output port.
* Input polled from both keypad and serial input port.

* 400 ppr half-stepper.
* 16-bit run-time ramping.
* Open-loop operation counts stepper pulses.
* Closed-loop operation senses switch interrupts.

* Mitchell 16mm camera installation.
* DC stepping motor @ 200 rpm.
* Home switch sensing inverted = Low.

* Additional axis sequencer.
* DC stepping motor @ 200 rpm.
* Home switch sensing inverted = Low.

* Sequence Camera and 1 Alternate Axis for JK Printer.
* Both camera and projector use DC stepping and direction signals.
* Motor enable lines are used to defeat one motor or the other.
* Both Camera and Projector Home switch signals are used.
* Step Camera and Skip Projector Sequencing.
* Separate speed ramp tables for camera and projector.
* Time exposure mode restored for camera only.
* Film Speed selection affects projector only.
* Open-loop safety detection for Projector Home.
* Low-power enable line always leaves aux axis energized.




FALSE:    EQU 0
TRUE:     EQU NOT FALSE

VERSION:  EQU 410        ;Version Number

CLK1MHZ:  EQU FALSE      ;1 MHz
CLK125M:  EQU False      ;1.2288 MHz
CLK180M:  EQU True       ;1.8432 MHz
CLK2MHZ:  EQU FALSE      ;2 MHz
CLK250M:  EQU FALSE      ;2.4576 MHz
CLK360M:  EQU FALSE      ;3.6864 MHz
CLK4MHZ:  EQU FALSE      ;4 MHz
CLK6MHZ:  EQU FALSE      ;6 MHz
CLK8MHZ:  EQU FALSE      ;8 MHz

PROTOTYPE EQU FALSE      ;Prototype

DUALPORT  EQU True       ;extended dual PIO port

LEDISPLAY EQU FALSE      ;LED display
LCDISPLAY EQU TRUE       ;LCD display
LCDLONG   EQU True	 ;LCD longer than 16 chars
LCD2ROW   EQU True       ;LCD with 2nd row
LCDREAD   EQU False      ;LCD module is read/write or write-only ?

PHONEKEY  EQU TRUE       ;Telephone keypad layout
KEYLONG   EQU True       ;extended keypad

SERIALIO  EQU TRUE       ;Serial interface

DEBUGGER  EQU False      ;Remote Debugger



	  MACLIB Z80
	  MACLIB UTILITY

	  MACLIB THINGM
	  MACLIB KEYIO
	  MACLIB LCDIO
	  MACLIB LEDIO
	  MACLIB SERIO
	  MACLIB MUXIO

; Debugger has to be separately assembled and linked in.
; (Debugger macro library causes symbol table overflow.)

ROMDBUG	  SET	1D80H		;debugger code memory
RAMDBUG	  SET	9F80H		;debugger data memory

*	  MACLIB RDEBUG




DUALPROJ  EQU False             ;dual projector

; Extra Motor Control port definitions.

          IF DUALPORT

XNPR:     EQU XNDC              ;enable main projector
XNAR:     EQU XNLP              ;enable aerial projector

XHMP:     EQU SHMP              ;input switch home projector
XHMA:     EQU SHMX              ;input switch home aerial

          ENDIF

; External Trigger definitions.

TRIGPORT: EQU SWITCH

          IF DUALPORT

TRCM:     EQU STRC              ;input trigger camera
TRPR:     EQU STRP              ;input trigger projector
TRAX:     EQU STRX              ;input trigger aerial

          ELSE

TRCM:     EQU STRC
TRPR:     EQU STRP

          ENDIF




; Reset initialization routines.

	  ORG 0000H

	  IF PROTOTYPE
QUIETIO:  EQU 01111000B       ;quiet output: MDIR, MNPR, DCUR, MNCM
	  ELSE
QUIETIO:  EQU 01111000B       ;quiet output: MDIR, MNPR, MNCM, DCUR
          ENDIF

          IF DUALPORT
QUIETIOX: EQU 11110000B       ;quiet output: XSTP, XDIR, XEN1, XEN2
          ENDIF

RESET:    MVI A,11001111B     ;select multi-input/output
	  OUT PIOCNTLB
          MVI A,10000111B     ;identify input/output directions
	  OUT PIOCNTLB
          MVI A,QUIETIO       ;quiet output lines
          OUT PIOB
	  LXI SP,STACK
	  JMP RESETSEQ


	  ORG 0080H

RESETSEQ: XRA A               ;time delay
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

	  IF DEBUGGER
	  JMP RSETDBUG        ;goto debugger
	  ENDIF
RSETNORM:

	  EI
          JMP MAIN



; Debugger breakpoint interrupt.

          IF DEBUGGER

          ORG 0030H
          JMP ROMDBUG+3

          ENDIF




; Maskable Interrupt routine.

          ORG 0038H

INT:      EI
          RETI



	  DB '(C) 1990-98 Penguin Associates'

; Non-Maskable Interrupt routine.

          ORG 0066H

          IF DEBUGGER
NMI:      JMP ROMDBUG+6                 ;debugger emergency interrupt
          ELSE

NMI:      RETN

          ENDIF




; Null interrupt routine.

NULLINT:  EQU INT




; Counter / timer interrupt routines.

	  ORG 0100H

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
; Check dual switch ports for Camera, Projector, and Aerial

STOPINT:  EXX
          EXAF

STOPNOW:  LDA SWITMASK        ;timed-out stop or switched stop ?
          ORA A
          JNZ STOPRUN         ;...timed-out stop

          LDA WHSWITCH        ;which switch...camera or projector ?
          BIT SHMC,A
          JZ SENSCAM

          BIT SHMP,A          ;or...main projector or aerial projector ?
          JZ SENSPROJ

          IF DUALPORT

          IN SWITCHX          ;aerial home ?
          BIT XHMA,A
          JNZ STOPGAP         ;wait until home
          JMP STOPRUN         ;stop now

SENSPROJ: IN SWITCHX          ;projector home ?
          BIT XHMP,A
          JNZ STOPGAP         ;wait
          JMP STOPRUN         ;stop

          ELSE

SENSPROJ: IN SWITCH	      ;sense projector home switch ?
          BIT SHMP,A          ;(switch active low ... XXXXX110)
          JNZ STOPGAP         ;if not switched, then check for time-out
          JMP STOPRUN         ;if projector switch home, then stop it

          ENDIF

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

          CALL MOTORNUL       ;de-energize motor to standby power

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

          IF LCD2ROW
          DB 'READY TO PROGRAM/RUN:'
          ENDIF

MAIN:     CALL OUTCNTRS       ;display all frame counters

          CALL GETCAMPR       ;camera or projector ?

          IF LCD2ROW
          LXI H,MOKR+3        ;display Ready message string
          CALL OUTMSG
          ENDIF

          LXI H,MOKF          ;display Ready prompt
          CALL OUTSIGN        ;with direction
          CALL OUTMUX3        ;echo out SIO

          LHLD COUNTER        ;display frame count
          CALL OUTMUX5        ;echo output SIO

WAITMAIN: IN TRIGPORT         ;trigger input ?
          BIT TRCM,A          ;Camera Trigger ?
          JNZ TRGCAMIT
          BIT TRPR,A          ;Projector Trigger ?
          JNZ TRGPRJIT

          IF DUALPROJ
          BIT TRAX,A          ;Aerial Trigger ?
          JNZ TRGAERIT
          ENDIF

          CALL INMUX          ;get key from KEY or SIO port
          JNC WAITMAIN

          LDA KEYBUF
          CPI PROGRAM         ;Program ?
          CZ PRGMIT

          IF KEYLONG          ;Extended Function Keys:

          CPI XONE
          CZ CAMERAIT         ;Camera Selection ?

          CPI XTWO
          CZ PROJCTIT         ;Projector Selection ?

          CPI XTHREE
          IF DUALPROJ
          CZ AERIALIT         ;Aerial Projector ?
          ELSE
          CZ PROJCTIT         ;Projector ?
          ENDIF

          CPI XFOUR
          IF DUALPROJ
          CZ SYNCIT           ;Sync Main + Aerial Projectors ?
          ELSE
          ENDIF

          CPI XFIVE
          CZ FRAMEIT          ;Frame Count ?

          CPI XSIX
          CZ COUNTIT          ;Total Count ?

          CPI XSEVEN
          CZ ALTSEQIT         ;Alternate Sequence ?

          CPI XEIGHT
          CZ SEQIT            ;Sequence Camera + Projectors ?

          ELSE                ;default to hot Program keys:

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

          ENDIF               ;KEYLONG

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
          LDA AERLSTAT
          PUSH PSW
          LDA SYNCSTAT
          PUSH PSW

          MVI A,FALSE
          STA SEQSTAT         ;no sequencer
          STA PROJSTAT        ;no projector
          STA AERLSTAT
          STA SYNCSTAT

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
          STA SYNCSTAT
          POP PSW
          STA AERLSTAT
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
          BIT TRPR,A
          JZ EXITTRGP         ;if not, then forget it

WAITTRGP: IN TRIGPORT         ;else wait for switch release
          BIT TRPR,A
          JNZ WAITTRGP

          LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          LDA SEQSTAT         ;buffer sequencer status
          PUSH PSW
          LDA PROJSTAT        ;and projector status
          PUSH PSW
          LDA AERLSTAT
          PUSH PSW
          LDA SYNCSTAT
          PUSH PSW

          MVI A,FALSE
          STA SEQSTAT         ;no sequencer
          STA AERLSTAT
          STA SYNCSTAT
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
          STA SYNCSTAT
          POP PSW
          STA AERLSTAT
          POP PSW
          STA PROJSTAT
          POP PSW
          STA SEQSTAT

          CALL GETCAMPR       ;get all data

          CALL PUTCAMPR       ;update all data

EXITTRGP: JMP MAIN

; Run only 1 single Aerial Projector frame here.

          IF DUALPROJ

TRGAERIT: LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          IN TRIGPORT         ;trigger input still ?
          BIT TRAX,A
          JZ EXITTRGA         ;if not, then forget it

WAITTRGA: IN TRIGPORT         ;else wait for switch release
          BIT TRAX,A
          JNZ WAITTRGA

          LXI D,BNCETM        ;wait switch debouncing time
          CALL WAITX

          LDA SEQSTAT         ;buffer sequencer status
          PUSH PSW
          LDA PROJSTAT        ;and projector status
          PUSH PSW
          LDA AERLSTAT
          PUSH PSW
          LDA SYNCSTAT
          PUSH PSW

          MVI A,FALSE
          STA SEQSTAT         ;no sequencer
          STA SYNCSTAT
          MVI A,TRUE
          STA AERLSTAT        ;yes Aerial
          STA PROJSTAT

          CALL GETCAMPR       ;get Aerial data

          LHLD FRAMEABS       ;save preset frame counts and status
          PUSH H

          LXI H,1             ;preset 1 single frame only
          SHLD FRAMEABS

          CALL RUNIT          ;then run it...

          CALL PUTCAMPR       ;update all data as is

          POP H               ;restore preset values
          SHLD FRAMEABS
          POP PSW
          STA SYNCSTAT
          POP PSW
          STA AERLSTAT
          POP PSW
          STA PROJSTAT
          POP PSW
          STA SEQSTAT

          CALL GETCAMPR       ;get all data

          CALL PUTCAMPR       ;update all data

EXITTRGA: JMP MAIN

          ENDIF

; Display direction forward or reverse as + or -.

OUTSIGN:  LDA DIRSTAT         ;check direction ?
          ORA A
          JNZ OUTMINUS

          LXI H,MOKF          ;+ if forward
          RET

OUTMINUS: LXI H,MOKR          ;- if reverse
          RET

; Display all cummulative frame counters.
; Note: This routine must be followed by a default counter display,
; because it uses the OUTDIGBF display routines.

          IF LCDLONG

          IF LCD2ROW

C3:       EQU 3               ;camera display index
C6:       EQU C3+4
P3:       EQU 15              ;projector display index
P6:       EQU P3+4
A3:       EQU 27              ;auxiliary display index
A6:       EQU A3+4
D3:       EQU 40H+27          ;default data display index
D6:       EQU D3+4

          ELSE

C3:       EQU 4               ;camera display index
C6:       EQU C3+3
P3:       EQU 15              ;projector display index
P6:       EQU P3+3
A3:       EQU 15              ;auxiliary display index
A6:       EQU A3+3
D3:       EQU 26              ;default data display index
D6:       EQU D3+4

          ENDIF               ;LCD2ROW

OUTCNTRS: CALL PUTCNTRS       ;update all counters
          CALL OUTCAMCT       ;display camera counter
          CALL OUTPRJCT       ;display projector counter
          CALL OUTAERCT       ;display aerial counter
          RET

; Display only currently effective counter already in OUTDIGBF buffer.

OUTCNTRQ: LXI H,OUTDIGBF      ;digit string for counter
          MVI B,6
          MVI C,C6            ;point to camera field
          LDA PROJSTAT        ;camera or projector ?
          ORA A
          JRZ OCQ
          MVI C,P6            ;point to projector field

          IF DUALPROJ

          LDA AERLSTAT        ;main or aerial projector ?
          ORA A
          JRZ OCQ
          MVI C,A6            ;point to aerial field

          ENDIF

OCQ:      CALL OUTLCDN
          RET

; Display camera counter total.

OUTCAMCT: LXI H,MCAM          ;display camera identifier
          MVI B,3
          MVI C,C3
          CALL OUTLCDN
          LHLD CAMRCNTR       ;display camera counter
          CALL OUTNUM
          LXI H,OUTDIGBF
          MVI B,6
          MVI C,C6
          CALL OUTLCDN
          LDA CAMDIRST        ;display camera direction
          ORA A
          LXI H,MOKF+2
          JRZ OCD
          LXI H,MOKR+2
OCD:      MVI B,1
          MVI C,C3+3
          CALL OUTLCDN
          RET

; Display projector counter total.

OUTPRJCT: LXI H,MPRJ          ;display projector id
          MVI B,3
          MVI C,P3
          CALL OUTLCDN
          LHLD PROJCNTR       ;display projector counter
          CALL OUTNUM
          LXI H,OUTDIGBF
          MVI B,6
          MVI C,P6
          CALL OUTLCDN
          LDA PRJDIRST        ;display projector direction
          ORA A
          LXI H,MOKF+2
          JRZ OPD
          LXI H,MOKR+2
OPD:      MVI B,1
          MVI C,P3+3
          CALL OUTLCDN
          RET

; Display aerial projector counter total.

          IF DUALPROJ

OUTAERCT: LXI H,MAER          ;display projector id
          MVI B,3
          MVI C,A3
          CALL OUTLCDN
          LHLD AERLCNTR       ;display aerial counter
          CALL OUTNUM
          LXI H,OUTDIGBF
          MVI B,6
          MVI C,A6
          CALL OUTLCDN
          LDA AERDIRST        ;display aerial direction
          ORA A
          LXI H,MOKF+2
          JRZ OAD
          LXI H,MOKR+2
OAD:      MVI B,1
          MVI C,A3+3
          CALL OUTLCDN
          RET

          ELSE

OUTAERCT: LXI H,MSEQ          ;display sequencer id
          MVI B,3
          MVI C,A3
          CALL OUTLCDN
          CALL OUTSEQ         ;display sequencer state
          MVI B,6
          MVI C,A6
          CALL OUTLCDN
          RET

          ENDIF               ;DUALPROJ

          ELSE

OUTCNTRS: RET

OUTCNTRQ: RET

          ENDIF               ;LCDLONG

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

GETPROJR: LDA AERLSTAT          ;aerial projector ?
          ORA A
          JNZ GETAERPR

          LHLD PROJCNTR		;un-buffer projector counter
          SHLD COUNTER 
          LHLD PRJFRMCT		;projector frame count
          SHLD FRAMECNT
          CALL FRMTODIR         ;select projector direction
          SHLD FRAMEABS         ;and absolute value count
          LHLD PRJOUTFR         ;projector out frame
          SHLD OUTFRAME
          RET

GETAERPR: LHLD AERLCNTR		;un-buffer projector counter
          SHLD COUNTER 
          LHLD AERFRMCT		;projector frame count
          SHLD FRAMECNT
          CALL FRMTODIR         ;select projector direction
          SHLD FRAMEABS         ;and absolute value count
          LHLD AEROUTFR         ;projector out frame
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

PUTPROJR: LDA AERLSTAT          ;aerial projector ?
          ORA A
          JNZ PUTAERPR

          LHLD COUNTER		;buffer projector counter
          SHLD PROJCNTR
          LHLD FRAMECNT		;projector frame count
          SHLD PRJFRMCT
          LDA  DIRSTAT		;projector direction
          STA  PRJDIRST
          LHLD OUTFRAME         ;projector out frame
          SHLD PRJOUTFR 
          RET

PUTAERPR: LHLD COUNTER		;buffer projector counter
          SHLD AERLCNTR
          LHLD FRAMECNT		;projector frame count
          SHLD AERFRMCT
          LDA  DIRSTAT		;projector direction
          STA  AERDIRST
          LHLD OUTFRAME         ;projector out frame
          SHLD AEROUTFR 
          RET

; Put effective counter into camera or projector memory buffers.
; Distinguish between main projector and aerial projector data.

PUTCNTRS: LDA PROJSTAT		;projector ?
          ORA A
          JNZ PUTPROJC

          LHLD COUNTER		;buffer camera counter
          SHLD CAMRCNTR
          RET

PUTPROJC: LDA AERLSTAT          ;aerial projector ?
          ORA A
          JNZ PUTAERCT

          LHLD COUNTER		;buffer projector counter
          SHLD PROJCNTR
          RET

PUTAERCT: LHLD COUNTER		;buffer projector counter
          SHLD AERLCNTR
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

          IF LCD2ROW
HPGM:     DB 'PROGRAM SELECTIONS:'
          ENDIF

PRGMIT:   PUSH PSW

          IF LCD2ROW
          LXI H,HPGM          ;display Program help string
          CALL OUTMSG
          ENDIF

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

          IF KEYLONG          ;2nd-level Extended Function Keys:

          CPI XONE
          CZ EXPIT            ;Exposure Time ?

          CPI XTWO
          CZ LAPSEIT          ;Lapse Time ?

          CPI XTHREE
          CZ SPEEDIT          ;Film Speed ?

          CPI XFOUR
          CZ ADJUSTIT         ;Projector Adjustment ?

          CPI XFIVE
          CZ OUTFRMIT         ;Out Frame ?

          CPI XSIX
          CZ STPSEQIT         ;Step Camera Sequence ?

          CPI XSEVEN
          CZ ALTSEQIT         ;Alternate Sequence ?

          CPI XEIGHT
          CZ SKPSEQIT         ;Skip Projector Sequence ?

          ENDIF               ;default to normal Program keys:

          CPI ONE
          CZ CAMERAIT         ;Camera ?

          CPI TWO
          CZ PROJCTIT         ;Projector ?

          CPI THREE
          IF DUALPROJ
          CZ AERIALIT         ;Aerial Projector ?
          ELSE
          CZ PROJCTIT         ;Projector ?
          ENDIF

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
          CALL FRAMEIT        ;Frame Count
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL DIRIT          ;Direction
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL SEQIT          ;Sequencer
          CALL OUTCNTRS
          JMP MENUSEQT

MENUPRJT:
          IF DUALPROJ
          LDA AERLSTAT        ;Projector or Aerial menu ?
          ORA A
          JNZ MENUAERT
          ENDIF

          CALL PROJCTIT       ;Projector menu...
          CALL INMUX
          XRA A
          STA KEYSTAT
          STA KEYBUF
          CALL FRAMEIT        ;Frame Count
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL DIRIT          ;Direction
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL SEQIT          ;Sequencer
          CALL OUTCNTRS
          JMP MENUSEQT

          IF DUALPROJ

MENUAERT: CALL AERIALIT       ;Aerial menu...
          CALL INMUX
          XRA A
          STA KEYSTAT
          STA KEYBUF
          CALL FRAMEIT        ;Frame Count
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL DIRIT          ;Direction
          CALL PUTCAMPR
          CALL OUTCNTRS

          CALL SYNCIT         ;Sync Projectors
          CALL SEQIT          ;Sequencer
          CALL OUTCNTRS

          ENDIF               ;DUALPROJ

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

          IF LCD2ROW
HINT:     DB 'INTERNAL SELECTIONS:'
          ENDIF

INTERNIT: PUSH PSW

          IF LCD2ROW
          LXI H,HINT          ;Internal Program message
          CALL OUTMSG
          ENDIF

          LXI H,MINT          ;display Internal Program mode
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

          IF LCD2ROW
HCAM:     DB 'CAMERA SELECTED:'
          ENDIF

CAMERAIT: PUSH PSW

          IF LCD2ROW
          LXI H,HCAM            ;CAM message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
HPRJ:     DB 'PROJECTOR SELECTED:'
          ENDIF

PROJCTIT: PUSH PSW


          IF LCD2ROW
          LXI H,HPRJ            ;PRJ message
          CALL OUTMSG
          ENDIF

          LXI H,MPRJ            ;prompt PRJ
          CALL OUTMUX3

          MVI A,TRUE		;select projector
          STA PROJSTAT
          CMA
          STA AERLSTAT          ;not aerial

          CALL GETCAMPR         ;get projector data from buffer

          LHLD PROJCNTR		;projector counter
          SHLD COUNTER
          CALL OUTMUX5          ;out LED + SIO

WAITPRJD: CALL INMUXST          ;display until key press
          JZ WAITPRJD

          POP PSW
          RET

; Aerial Projector Overide Frame Count Input.
; Used as prefix to other data selections.

          IF DUALPROJ

MAER:     DB 'AER'

          IF LCD2ROW
HAER:     DB 'AERIAL SELECTED:'
          ENDIF

AERIALIT: PUSH PSW

          IF LCD2ROW
          LXI H,HAER            ;AER message
          CALL OUTMSG
          ENDIF

          LXI H,MAER            ;prompt AER
          CALL OUTMUX3

          MVI A,TRUE		;select projector
          STA PROJSTAT
          STA AERLSTAT          ;aerial

          CALL GETCAMPR         ;get projector data from buffer

          LHLD AERLCNTR		;aerial projector counter
          SHLD COUNTER
          CALL OUTMUX5          ;out LED + SIO

WAITPRJ2: CALL INMUXST          ;display until key press
          JZ WAITPRJ2

          POP PSW
          RET

          ENDIF                 ;DUALPROJ

; Synchronize Main Projector : Aerial Projector selection.

          IF DUALPROJ

SYNKEY:   SET POINT           ;SYN toggle key (defined later)
SYNKEYX:  SET XFOUR           ;SYN toggle key (defined later)

MSYN:     DB 'SYN'
MSYN0:    DB '  OFF-'
MSYN1:    DB '   ON+'

          IF LCD2ROW
HSYN:     DB 'SYNC PROJECTORS:'
          ENDIF

SYNCIT:   PUSH PSW

          IF LCD2ROW
          LXI H,HSYN          ;SYN message
          CALL OUTMSG
          ENDIF

          LXI H,MSYN          ;prompt SYN
          CALL OUTLED3

IF FALSE
          MVI A,TRUE	      ;default projector
          STA PROJSTAT
          CALL GETCAMPR       ;get projector data from buffer
ENDIF

LOOPSYNT: LXI H,MSYN          ;prompt SYN status
          CALL OUTMUX3
          CALL OUTSYN         ;display SYN status
          CALL OUTLED5
          CALL OUTSYN
          CALL OUTSIO5        ;echo out SIO
          CALL OUTEOLN
          CALL CURSRON        ;flash cursor (locally)

WAITSYNT: CALL INMUX          ;loop for key input
          JNC WAITSYNT

          LDA KEYBUF
          CPI ENTER           ;'Enter' for completion ?
          JZ EXITSYN
          CPI PROGRAM         ;'Program' too ?
          JZ EXITSYN
          CPI MINUS           ;'-' for toggle ?
          JZ FLOPSYN
          CPI SYNKEYX
          JZ FLOPSYN
          CPI SYNKEY
          JNZ WAITSYNT

FLOPSYN:  LDA SYNCSTAT        ;toggle SYNC status
          CMA
          STA SYNCSTAT
          JMP LOOPSYNT

EXITSYN:  CALL CURSROFF
          POP PSW
          RET

; Display projector SYNC status.

OUTSYN:   LDA SYNCSTAT        ;SYNC status ?
          ORA A
          JNZ OUTSYN1

          LXI H,MSYN0
          RET

OUTSYN1:  LXI H,MSYN1
          RET

          ENDIF               ;DUALPROJ

; Sequence Camera : Projector selection.
; Note: SEQ selection does not affect CAM/PRJ selection.

SEQKEY:   SET ZERO            ;SEQ toggle key (defined later)
SEQKEYX:  SET XEIGHT          ;SEQ toggle key (defined later)

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

          IF LCD2ROW
HSEQ:     DB 'SEQUENCER ON/OFF:'
          ENDIF

SEQIT:    PUSH PSW

          IF LCD2ROW
          LXI H,HSEQ          ;SEQ message
          CALL OUTMSG
          ENDIF

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
          CPI SEQKEYX
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
MBY:      DB '+BY'

          IF LCD2ROW
HALT:     DB 'ALTERNATE SEQUENCE:'
          ENDIF

ALTSEQIT: PUSH PSW

          MVI A,FALSE
          STA STEPSTAT        ;no step camera
          STA SKIPSTAT        ;no skip projector

          IF LCD2ROW
          LXI H,HALT          ;ALT message
          CALL OUTMSG
          ENDIF

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

MSTP:     DB 'STP'

          IF LCD2ROW
HSTP:     DB 'STEP-FRAME SEQUENCE:'
          ENDIF

STPSEQIT: PUSH PSW

          MVI A,TRUE
          STA STEPSTAT       ;yes step camera
          MVI A,FALSE
          STA SKIPSTAT       ;no skip projector

          IF LCD2ROW
          LXI H,HSTP         ;STP message
          CALL OUTMSG
          ENDIF

          LXI H,MSTP
          CALL OUTMUX3

          LHLD STEPRCNT      ;update step camera count
          CALL OUTMUX5
          CALL MODNUM
          SHLD STEPRCNT
          MOV A,H            ;if 0, then min out
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

          IF LCD2ROW
HSKP:     DB 'SKIP-FRAME SEQUENCE:'
          ENDIF

SKPSEQIT: PUSH PSW

          MVI A,TRUE
          STA SKIPSTAT       ;yes skip projector
          MVI A,FALSE
          STA STEPSTAT       ;no step camera

          IF LCD2ROW
          LXI H,HSKP         ;SKP message
          CALL OUTMSG
          ENDIF

          LXI H,MSKP
          CALL OUTMUX3

          LHLD CYCLECNT      ;update skip cycle count
          CALL OUTMUX5
          CALL MODNUM
          SHLD CYCLECNT
          MOV A,H            ;if 0, then min out
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

          IF LCD2ROW
HFRM:     DB 'FRAME COUNT:'
          ENDIF

FRAMEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,HFRM          ;help FRM message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
HDRN:     DB 'DIRECTION FORWARD/REV:'
          ENDIF

DIRIT:    PUSH PSW

          IF LCD2ROW
          LXI H,HDRN          ;DIR message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
          DB 'END FRAME #:'
          ENDIF

OUTFRMIT: PUSH PSW

          IF LCD2ROW
          LXI H,MOUT+3          ;OUT message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
          DB 'EXPOSURE TIME:'
          ENDIF

EXPIT:    PUSH PSW

          IF LCD2ROW
          LXI H,MEXP+3          ;EXP message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
          DB 'LAPSE TIME:'
          ENDIF

LAPSEIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MLPS+3          ;LPS message
          CALL OUTMSG
          ENDIF

          LXI H,MLPS            ;prompt LPS
          CALL OUTMUX3

          LHLD LAPSE            ;update lapse time
          CALL OUTMDX5
          CALL MODDEC
          SHLD LAPSE

          POP PSW
          RET

; Total Count input.

MCNT:     DB 'CTR'

          IF LCD2ROW
          DB 'TOTAL COUNTER:'
          ENDIF

COUNTIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MCNT+3          ;CTR message
          CALL OUTMSG
          ENDIF

          LXI H,MCNT            ;prompt CTR
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

          IF LCD2ROW
          DB 'PROJECTOR FILM SPEED:'
          ENDIF

SPEEDIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MSPD+3        ;SPD message
          CALL OUTMSG
          ENDIF

          LXI H,MSPD          ;prompt SPD
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

          IF LCD2ROW
          DB 'MINIMUM MOTOR SPEED:'
          ENDIF

MINSPDIT: PUSH PSW

          IF LCD2ROW
          LXI H,MMSP+3        ;MSP message
          CALL OUTMSG
          ENDIF

          LXI H,MMSP          ;prompt MSP
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

          IF LCD2ROW
          DB 'ACCEL/DECEL SPEED RAMP:'
          ENDIF

ACCELIT:  PUSH PSW

          IF LCD2ROW
          LXI H,MACL+3        ;RMP message
          CALL OUTMSG
          ENDIF

          LXI H,MACL          ;prompt RMP
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


IF FALSE

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

ENDIF

; Step time determination.
; Step time fetched from ramp table for read only.

IF FALSE

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

ENDIF

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
          LHLD MINSPEED  ;transfer low speed (user-defined)
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

MSPR:     DB 'CPR'
MPPR:     DB 'PPR'

          IF LCD2ROW
          DB 'STEPS PER REVOLUTION:'
          ENDIF

STEPIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MPPR+3        ;PPR message
          CALL OUTMSG
          ENDIF

          LXI H,MSPR          ;camera steps per revolution
          CALL OUTMUX3

          LHLD REVSHCNT       ;update revolution step count
          CALL OUTMUX5
          CALL MODNUM
          SHLD REVSHCNT

          LXI H,MPPR          ;projector steps per revolution
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

          IF LCD2ROW
          DB 'PROJECTOR ADJUSTMENT:'
          ENDIF

ADJUSTIT: PUSH PSW

          IF LCD2ROW
          LXI H,MADJ+3        ;ADJ message
          CALL OUTMSG
          ENDIF

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

          IF LCD2ROW
          DB 'CAMERA SHUTTER OPEN:'
          ENDIF

OPENIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MOPN+3        ;OPN message
          CALL OUTMSG
          ENDIF

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

OPENCOMP: LHLD REVSHCNT       ;compute open-shutter step count
          LXI D,100
          CALL DIVIDE         ;... = full-revolution step count / 100
          CALL ROUND
          MOV D,B
          MOV E,C
          LDA OPNANGLE
          CALL MULTIPLY       ;... * open-shutter angle
          SHLD OPNSHCNT

          XCHG                ;compute close-shutter step count
          LHLD REVSHCNT       ;... = full-revolution step count
          XRA A
          DSBC DE
          SHLD CLOSHCNT       ;... - open-shutter step count
          RET

; Torque time-out delay for motor enable line.

MTRQ:     DB 'TRQ'

          IF LCD2ROW
          DB 'MOTOR TORQUE TIME-OUT:'
          ENDIF

TORQIT:   PUSH PSW

          IF LCD2ROW
          LXI H,MTRQ+3        ;TRQ message
          CALL OUTMSG
          ENDIF

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

IF DUALPORT

; Motor Power enable / disable selection.
; Sense input from latched output line, active High.
; Only valid for second motor control port.

PWRKEY:   SET ZERO            ;PWR toggle key (defined later)
PWRKEYX:  SET XTHREE          ;PWR toggle key (defined later)

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
HPWR:     DB 'MOTOR POWER ON/OFF:'
          ENDIF

POWERIT:  PUSH PSW
          CALL CURSRON

          IF LCD2ROW
          LXI H,HPWR          ;PWR message
          CALL OUTMSG
          ENDIF

LOOPPWRT: LXI H,MPWR          ;display motor power status
          CALL OUTLED3
          LXI H,MPWR1
          CALL OUTLED5
          CALL CURSRADJ

          IN MOTRCNTX         ;sense power down ?
          BIT XNDC,A
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
          CPI PWRKEYX
          JZ FLIPPWRT
          JMP WAITPWRT

FLIPPWRT: IN MOTRCNTX         ;actual power enable state ?
          BIT XNDC,A
          JNZ FLIPBACK

          CALL MOTORDC0       ;if enabled, then disable
          JMP LOOPPWRT

FLIPBACK: CALL MOTORNUL       ;if disabled, then re-enable (at low-power)
          JMP LOOPPWRT

EXITPWR:  CALL CURSROFF
          POP PSW
          RET

ENDIF     ;DUALPORT

; Version identification.

MVER:     DB 'VER'

          IF LCD2ROW
          DB 'SOFTWARE VERSION:'
          ENDIF

VERIT:    PUSH PSW

          IF LCD2ROW
          LXI H,MVER+3        ;VER message
          CALL OUTMSG
          ENDIF

          LXI H,MVER
          CALL OUTMUX3

          LXI H,VERSION       ;display version id
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

          IF LCD2ROW
HRUN:     DB 'RUNNING PROGRAM...:'
          ENDIF

RUNIT:    LXI H,MRUN          ;display Run mode
          SHLD MSGBUF3
          CALL OUTLED3

          IF LCD2ROW
          LXI H,HRUN          ;display RUN message
          CALL OUTMSG
          ENDIF

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

          LHLD PROJCNTR       ;buffer projector counter for run-time sequencing
          SHLD PROJCTBF
          LDA PRJDIRST        ;buffer projector direction for run-time counting
          STA PRJDIRBF

          LDA PROJSTAT        ;either projector selected ?
          ORA A
          JZ SKIPSYNC

          IF DUALPROJ

          LDA AERLSTAT        ;aerial projector explicitly selected ?
          ORA A
          JZ SKIPSYNC

          LHLD AERLCNTR       ;then swap aerial counter into run-time proj counter
          SHLD PROJCTBF
          LDA AERDIRST        ;...plus aerial direction
          STA PRJDIRBF

          LXI H,MAER          ;and re-buffer AER tag for run-time display
          SHLD RUNDISBF

          ENDIF

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
          CALL OUTCNTRQ       ;+ full counter display too

          LHLD REVSHCNT       ;compute shutter-closed step count
          LDED OPNSHCNT
          SDED RUNOPEN
          XRA A
          DSBC DE
          SHLD CLOSHCNT       ;... = revolution count - open count
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

          CALL UPDTCNTS       ;+ update all sequencer / sync counters

          CALL TRIGRON        ;fire output trigger during single frame

          LHLD REVLNCNT       ;pre-transfer full revolution step count
          SHLD STEPCNT

          CALL SEQUOSTP       ;overide step count if sequencer ?

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
          CALL OUTCNTRQ       ;+ full counter display too

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

WAITOVER: CALL OUTCNTRS       ;display all frame counters

          LHLD MSGBUF3        ;display whatever Run mode
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
          SHLD PROJCTBF

SKPCNTSW:
SKIPDUPE: LDA SEQSTAT         ;clean up sequencer stuff ?
          ORA A
          RZ

          LDA CNTRSTAT        ;restore pre-run camera / projector status
          STA PROJSTAT
          CALL GETCAMPR       ;...plus data variables

          RET

; Camera : Projector sequencer subroutine.
; Main or Aerial Projector counter buffered for run-time.

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
          CALL OUTLED3
          XRA A			;zero out time exposure
          STA EXPSTAT
          LHLD COUNTER		;save camera frame counter
          SHLD CAMRCNTR
          LHLD PROJCTBF		;load projector frame counter
          SHLD COUNTER
          LDA PRJDIRBF		;load projector direction
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
          CALL OUTLED3
          LHLD RUNEXP		;re-load time exposure status, if any
          MOV A,H
          ORA L
          STA EXPSTAT
          LHLD COUNTER		;save projector frame counter
          SHLD PROJCTBF
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
          SHLD PROJCTBF

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

          CALL SEQUOSTP       ;overide step count if sequencer ?

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
          CALL OUTCNTRQ       ;+ extended counter display too
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
          CALL OUTCNTRQ       ;+ extended counter display too
          CALL OUTEOLN
LOOPLAST: LDA MOTROVER        ;wait until last revolution
          ORA A
          JNZ LOOPLAST

          CALL UPDTCNTR       ;update last frame count

          CALL OUTCNTRS       ;display all frame counters
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

; Update all run-time total frame counters according to directions.
; Distinguish between Camera, Projector, Aerial, and Sync-Proj.

          IF DUALPROJ

UPDTCNTS: LDA PROJSTAT        ;update camera or projector ?
          ORA A
          JNZ UPDTPRS

          LDA CAMDIRST        ;update camera forward or reverse ?
          ORA A
          LHLD CAMRCNTR
          JRNZ UPCREV
          INX H
          SHLD CAMRCNTR
          RET
UPCREV:   DCX H
          SHLD CAMRCNTR
          RET

UPDTPRS:  LDA SYNCSTAT        ;update both projectors in sync ?
          ORA A
          JNZ UPDTBOTH

          LDA AERLSTAT        ;update aerial or main projector ?
          ORA A
          JNZ UPDTAER

UPDTPRJ:  LDA PRJDIRST        ;update main projector forward or reverse ?
          ORA A
          LHLD PROJCNTR
          JRNZ UPPREV
          INX H
          SHLD PROJCNTR
          RET
UPPREV:   DCX H
          SHLD PROJCNTR
          RET

UPDTAER:  LDA AERDIRST        ;update aerial projector forward or reverse ?
          ORA A
          LHLD AERLCNTR
          JRNZ UPAEREV
          INX H
          SHLD AERLCNTR
          RET
UPAEREV:  DCX H
          SHLD AERLCNTR
          RET

UPDTBOTH: CALL UPDTPRJ        ;update main proj
          CALL UPDTAER        ;update aerial proj
          RET

          ELSE
UPDTCNTS: RET
          ENDIF

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
          CALL OUTLED3        ;locally and remotely

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

          IF DUALPORT

          IN SWITCHX          ;pin NOT home ?
          BIT XHMP,A
          JNZ HOLDPTRN
          ELSE
          IN SWITCH           ;pin NOT home ?
          BIT SHMP,A
          JNZ HOLDPTRN

          ENDIF

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
          CALL OUTEOLN

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

          IF DUALPROJ

          IN SWITCHX          ;projector home OK ?
          BIT XHMP,A
          RZ
          ELSE
          IN SWITCH           ;projector home OK ?
          BIT SHMP,A
          RZ

          ENDIF

          LXI H,MADJ          ;Flash 'Adj' message for Hold state
          SHLD FLASHPTR
          CALL OUTMUX3        ;out both LED + SIO
          CALL OUTEOLN

          LHLD ADJSTPCT       ;try adjusting for so many single steps
          SHLD RUNADJCT

ADJPT:    CALL MOTORON        ;prepare to enable motor on

          CALL INITSSTP       ;run for 1 single step

WAITADJ:  LDA MOTROVER        ;single step over ?
          ORA A
          JNZ WAITADJ

          LXI H,MRUN          ;re-buffer Run state
          SHLD MSGBUF3

          IF DUALPROJ

          IN SWITCHX          ;check projector home again ?
          BIT XHMP,A
          RZ                  ;...self-adjustment OK
          ELSE
          IN SWITCH           ;check projector home again ?
          BIT SHMP,A
          RZ                  ;...self-adjustment OK

          ENDIF

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

          IF DUALPROJ

          IN SWITCHX          ;user adjusted projector home ?
          BIT XHMP,A
          JNZ PREGPT
          ELSE
          IN SWITCH           ;user adjusted projector home ?
          BIT SHMP,A
          JNZ PREGPT

          ENDIF

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
          MVI A,PIOMASK       ;switch mask bits
          RES SHMC,A          ;camera
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

          IF DUALPROJ

          LDA SYNCSTAT        ;sync both projectors ?
          ORA A
          JNZ SYNCON

          LDA AERLSTAT        ;aerial only ?
          ORA A
          JNZ AERLON

          ENDIF

          LDA PRJDIRST        ;projector direction forward or reverse ?
          ORA A
          JNZ PRJREVON

; Main Projector on only.

PRJFWDON: IN MOTRCNTL	      ;projector forward
          SETB MNCM,A         ;camera disable
	  SETB MDIR,A         ;motor forward
	  RES  MNPR,A         ;projector enable
	  OUT MOTRCNTL

          IF DUALPORT
          IN MOTRCNTX         ;extra motor control port
          RES  XSTP,A         ;step overide enable
          SETB XDIR,A         ;direction forward
          IF DUALPROJ
          SETB XNAR,A         ;aerial disable
          RES  XNPR,A         ;projector enable
          ELSE
          RES  XNDC,A         ;projector DC motor enable
          RES  XNLP,A         ;projector low-power overide enable
          ENDIF
          OUT MOTRCNTX
          ENDIF

          MVI A,PIOMASK       ;switch mask bits
          RES SHMP,A          ;projector
          STA WHSWITCH
*         MVI A,FALSE         ;sense YES
*         MVI A,TRUE          ;sense NO
	  LDA ADJSTPCT        ;sense if 0 adjustment
	  STA SWITMASK        ;ignore projector sensing switches NOT
	  RET

PRJREVON: IN MOTRCNTL         ;projector reverse
	  SETB MNCM,A         ;camera disable
	  RES  MDIR,A         ;motor reverse
	  RES  MNPR,A         ;projector enable
	  OUT MOTRCNTL

          IF DUALPORT
          IN MOTRCNTX         ;extra motor control port
          RES  XSTP,A         ;step overide enable
          RES  XDIR,A         ;direction reverse
          IF DUALPROJ
          SETB XNAR,A         ;aerial disable
          RES  XNPR,A         ;projector enable
          ELSE
          RES  XNDC,A         ;projector DC motor enable
          RES  XNLP,A         ;projector low-power overide enable
          ENDIF
          OUT MOTRCNTX
          ENDIF

	  MVI A,PIOMASK       ;switch mask bits
	  RES SHMP,A          ;projector
	  STA WHSWITCH
	  LDA ADJSTPCT        ;sense if 0 adjustment
          STA SWITMASK
          RET

; Aerial Projector on only:

          IF DUALPROJ

AERLON:   LDA AERDIRST        ;aerial projector direction forward or reverse ?
          ORA A
          JNZ AERREVON

AERFWDON: IN MOTRCNTL	      ;projector forward
          SETB MNCM,A         ;camera disable
          SETB MNPR,A         ;main projector disable
          OUT MOTRCNTL
          IN MOTRCNTX         ;extra motor control port
          RES  XSTP,A         ;step overide enable
          SETB XNPR,A         ;main projector disable
          SETB XDIR,A         ;direction forward
          RES  XNAR,A         ;aerial enable
          OUT MOTRCNTX
          MVI A,PIOMASK       ;switch mask bits
          NOP                 ;none
          STA WHSWITCH
          MVI A,FALSE
          STA SWITMASK
          RET

AERREVON: IN MOTRCNTL         ;projector reverse
          SETB MNCM,A         ;camera disable
          SETB MNPR,A         ;main projector disable
          OUT MOTRCNTL
          IN MOTRCNTX         ;extra motor control port
          RES  XSTP,A         ;step overide enable
          SETB XNPR,A         ;main projector disable
          RES  XDIR,A         ;direction reverse
          RES  XNAR,A         ;aerial enable
          OUT MOTRCNTX
          MVI A,PIOMASK
          NOP
          STA WHSWITCH
          MVI A,FALSE
          STA SWITMASK
          RET

          ENDIF

; Both projectors on in synchronism:
; Independent direction lines for each projector.

          IF DUALPROJ

SYNCON:   LDA AERDIRST        ;aerial direction forward or reverse ?
          ORA A
          JNZ AEREVSYN

          IN MOTRCNTX
          RES  XSTP,A         ;step overide enable
          SETB XDIR,A         ;aerial forward
          RES  XNPR,A         ;projector enable
          RES  XNAR,A         ;aerial enable
          OUT MOTRCNTX
          JMP PRJDIRSN

AEREVSYN: IN MOTRCNTX
          RES  XSTP,A         ;step overide enable
          RES  XDIR,A         ;aerial reverse
          RES  XNPR,A         ;projector enable
          RES  XNAR,A         ;aerial enable
          OUT MOTRCNTX

PRJDIRSN: LDA PRJDIRST        ;projector direction forward or reverse ?
          ORA A
          JNZ SYNREVON

SYNFWDON: IN MOTRCNTL	      ;projector forward
          SETB MNCM,A         ;camera disable
          SETB MDIR,A         ;motor forward
          RES  MNPR,A         ;projector enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMP,A
          STA WHSWITCH
          MVI A,FALSE
          STA SWITMASK
          RET

SYNREVON: IN MOTRCNTL         ;projector reverse
          SETB MNCM,A         ;camera disable
          RES  MDIR,A         ;motor reverse
          RES  MNPR,A         ;projector enable
          OUT MOTRCNTL
          MVI A,PIOMASK
          RES SHMP,A
          STA WHSWITCH
          MVI A,FALSE
          STA SWITMASK
          RET

          ENDIF

; Output motor control signals off.
; Effective for AC motor enable signals immediately.

MOTOROFF: RET

; Output motor control signals null.
; Effective for DC motor enable signals after final time-out.

MOTORNUL: IN MOTRCNTL	        ;all motors off
          SETB MNCM,A           ;camera disable
	  SETB MNPR,A           ;projector disable
	  OUT MOTRCNTL

          IF DUALPORT
          IN MOTRCNTX           ;all motors off
          IF DUALPROJ
          SETB XNAR,A           ;aerial disable
	  SETB XNPR,A           ;projector disable
          ELSE
          SETB XSTP,A           ;step overide disable (pull-down AND)
          RES  XNDC,A           ;projector DC motor enable (continuous)
          SETB XNLP,A           ;projector low-power (pull-down R)
          ENDIF
	  OUT MOTRCNTX
          ENDIF

          RET

; Output motor control signals to 0 DC.
; Effective for DC motor enable signals by user command.

MOTORDC0: IN MOTRCNTL	        ;all motors off
          SETB MNCM,A           ;camera disable
	  SETB MNPR,A           ;projector disable
	  OUT MOTRCNTL

          IF DUALPORT
          IN MOTRCNTX           ;all motors off
          SETB XNDC,A           ;projector DC motor disable
          SETB XNLP,A           ;projector low-power (pull-down R)
	  OUT MOTRCNTX
          ENDIF

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

INITSSTP: DI
          XRA A
          CMA                 ;motor running status
          STA MOTROVER

          LXI H,STOPINT       ;only 1 interrupt point
          SHLD INTCTCV0

          MVI A,IC000LRC      ;load counter CTC0 with interrupts
          OUT CTC0
          MVI A,1             ;counter byte = 1 single step
          OUT CTC0

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

SEQUOSTP: LHLD REVSHCNT       ;transfer full revolution count
          SHLD STEPCNT
          LDA PROJSTAT        ;projector active ?
          ORA A
          RZ
          LHLD REVLNCNT       ;if so, then re-load with custom step count
          IF DUALPORT AND (NOT DUALPROJ)
          DCX H               ;account for XSTP toggle on dual port
          ENDIF
          SHLD STEPCNT
          RET




; Keypad Interface

	  KEYIOM

; LED Interface

	  LEDIOM

; LCD Interface

	  LCDIOM

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

; Reset PIO

; Reset LED

; Reset CTC

; Reset Memory

	  RESETM

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

DSPEED:     EQU 334           ;default frames per second
* DSPEED:   EQU 120           ;1.20 frames per second for 72 RPM
* DSPEED:   EQU 200           ;2.00 frames per second for 120 RPM
* DSPEED:   EQU 240           ;2.40 frames per second for 2x 72 RPM
* DSPEED:   EQU 334           ;3.33 frames per second for 200 RPM
* DSPEED:   EQU 400           ;4.00 frames per second

DMINSPD:    EQU 100           ;default minimum speed
* DMINSPD:  EQU LOWSPDHF      ;lowest min speed for half-stepping
* DMINSPD:  EQU 100           ;1.00 frames per second min speed

DTORQTME:   EQU 10            ;default torque time-out
* DTORQTME: EQU 5             ;0.05 second torque time-out for battery pack
* DTORQTME: EQU 10            ;0.10 second torque time-out for Rock pegbars
* DTORQTME: EQU 25            ;0.25 second torque time-out for JK printer

DEXPCOMP:   EQU 14            ;default exposure compensation time
* DEXPCOMP: EQU 14            ;exp comp time = 0.14 sec Bolex at 2.00 FPS
* DEXPCOMP: EQU 12            ;exp comp time = 0.12 sec Bolex at 2.40 FPS
* DEXPCOMP: EQU 08            ;exp comp time = 0.08 sec Bolex at 3.34 FPS
* DEXPCOMP: EQU 14            ;exp comp time for Mitchell 16 at 3.34 FPS

DEXPANGL:   EQU 47            ;default shutter-open exposure angle
* DEXPANGL: EQU 47            ;shutter-open exp angle = 170 deg Mitchell
* DEXPANGL: EQU 65            ;shutter-open exp angle = 235 deg Mitchell 16
* DEXPANGL: EQU 28            ;135 degrees * 75% prism for Bolex reflex

DOPNANGL:   EQU 50            ;default shutter-open rotation angle
* DOPNANGL: EQU 50            ;shutter-open rotation angle = 180 deg Mitchell
* DOPNANGL: EQU 35            ;125 degrees for Mitchell JK mount
* DOPNANGL: EQU 31            ;110 degrees for Bolex

DREVLNCN:   EQU 400           ;default revolution step count
* DREVLNCN: EQU 25000         ;revolution step count = 25000 micro-steps
* DREVLNCN: EQU 2000          ;2000 micro-steps
* DREVLNCN: EQU 400           ;400 half-steps
* DREVLNCN: EQU 396           ;400 half-steps shortened for JK home switches

DADJSTP:    EQU 0             ;default single-step adjustment count
* DADJSTP:  EQU 3             ;single-step adjustment count JK printer
* DADJSTP:  EQU 0             ;single-step adjustment count OFF

DRAMPCNT:   EQU 100           ;default ramp count
* DRAMPCNT: EQU 250           ;ramp count for 2000 PPR micro-steppers
* DRAMPCNT: EQU 100           ;0.25 rev for 400 half-stepping 35mm
* DRAMPCNT: EQU 50            ;0.125 rev for 400 half-stepping 16mm
* DRAMPCNT: EQU 0             ;no ramping for constant speed AC motor

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
          SHLD REVSHCNT       ;full revolution shutter count
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

	  LXI H,DADJSTP
	  SHLD ADJSTPCT       ;adjustment steps for projector home
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

; ThingM Test Sequence with Signon message

	  THINGM

*         DB '(C) 1990 Penguin Associates'


; Remote Debugger code patch.

	  IF DEBUGGER

DBUGSIGN: DB 'DEBUGGER'

RSETDBUG: IN SWITCH           ;check trigger port
          BIT STRP,A          ;debug trigger active ?
          JZ RSETNORM         ;no trigger --> no debugger

          LXI H,DBUGSIGN      ;signon for debugger
	  MVI B,8
	  MVI C,20
	  CALL OUTLCDN

	  JMP ROMDBUG         ;goto debugger

*	  RDEBUGM

	  ELSE

RSETDBUG: JMP RSETNORM        ;continue normal program

	  ENDIF





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
REVSHCNT: DS 2           ;full revolution camera shutter step count
OPNSHCNT: DS 2           ;shutter-open step count
CLOSHCNT: DS 2           ;shutter-closed step count
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
PROJCTBF: DS 2           ;main projector counter buffer
AERLCTBF: DS 2           ;aerial projector counter buffer
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
          
