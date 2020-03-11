;-----------------------------------------------------------------------------
;   initialization
;-----------------------------------------------------------------------------

; for IntTo32bit: *429496729.6,   for IntTo16bit: 6553.6
SET    1.000,1,0       ;Get rate at 1 ms & scaling O command
; rate msPerStep, DACscale(1 = +-5V), DACoffset
; offset for Drum and Chair because of the DAC0 output bias
VAR    V22,DrumOff=VDAC32(0.0000)
VAR    V23,Chairoff=VDAC32(0.0000)

VAR    V24,DrumAmp=VDAC16(0.05) ;V24: Amplitude of Drum Velocity command
VAR    V25,DrumPh=VAngle(0) ;V25: Phase of Drum Velocity command
VAR    V26,DrumFreq=VHz(1) ;V26: Frequency of Drum Velocity command

VAR    V27,ChrAmp=VDAC16(0.1) ;V27: Amplitude of Chair Velocity command
VAR    V28,ChrPh=VAngle(0) ;V28: Phase of Chair Velocity command
VAR    V29,ChrFreq=VHz(1) ;V29: Fequency of Chair Velocity command

VAR    V31,ChAmpOff=vdac16(0)
VAR    V32,DrAmpOff=vdac16(0)

VAR    V33,PulseWai=1  ;variables for stimulation pulses (opto)
VAR    V34,PulseNum=1
VAR    V35,PulseDur=1
VAR    V36,PulseInt=1
VAR    V37,PulseSta=1

VAR    V38,StepRes2=100 ;variables for steps (drum & chair)
VAR    V39,StepStar=100 ;Not currently used 12/16
VAR    V40,StepLeng=500
VAR    V41,SteLeng1=500
VAR    V42,StepRes1=500
VAR    V43,SAmpC=VDAC32(.01) ;Step amp chair
VAR    V44,SAmpD=VDAC32(.001) ;Step amp drum
VAR    V45,SAmpCn=VDAC32(-.01) ;Step amp chair inverse
VAR    V46,SAmpDn=VDAC32(-.001) ;Step amp drum inverse

VAR    V47,stepLen1=0  ;variables for step DELAYED light pulses
VAR    V48,stepLen2=500
VAR    V49,stepLen3=0

VAR    V50,PulseDuV=33 ;pulse Duration V
VAR    V51,PulseWaV=966 ;pulse wait V
VAR    V52,PulsePer=1000 ;pulse period duration
VAR    V53,PulseHPe=500 ;Half Period duration

VAR    V55,QueTime=250
VAR    V56,DOffOrig=vdac16(0)
VAR    V57,COffOrig=vdac16(0)
VAR    V58,pDelay=500

;-----------------------------------------------------------------------------
; LOOP: our idle loop.
;-----------------------------------------------------------------------------
LOOP:       SZ     7,1        ;set cosine amplitude
            OFFSET 7,0        ;cosine offset command to ghost timing sine wave
            ANGLE  7,0        ;cosine phase
            RATE   7,1        ;set rate and start ghost cosine

LOOP1:      DAC 0,DrumOff     ; >Looping.
            DAC 1,Chairoff
            JUMP   LOOP1

;-----------------------------------------------------------------------------
; INIT: Move CHAIR (DAC1) & DRUM (DAC0) to zero
;-----------------------------------------------------------------------------
INIT:   'I  RATE   0,0             ;stop cosine on drum
            RATE   1,0             ;stop cosine on chair
            DAC    0,DrumOff       ;stop the drum
            DAC    1,Chairoff      ;stop the chair
            DIGOUT [000.0000]      ;stop any pulses EXCEPT TTL5. TTL5 is used for Fiber Photometry
            JUMP   KCHAIR          ;return chair to zero

;-----------------------------------------------------------------------------
; QUIT: Stops all movement on drum and chair
;-----------------------------------------------------------------------------
QUIT:   'O  RATE   0,0             ;stop cosine on drum
            RATE   1,0             ;stop cosine on chair
            DAC    0,DrumOff       ;stop the drum
            DAC    1,Chairoff      ;stop the chair
            DIGOUT [00000000]      ;stop any pulses
            JUMP   LOOP            ;idle loop

;-----------------------------------------------------------------------------
; KCHAIR: Chair return function
;-----------------------------------------------------------------------------
KCHAIR:     RATE   1,0             ;stop cosine on chair

KCHAIR1:    CHAN   V8,4            ;Get value of chair position
            MOVI   V9,0            ;Intialize v9 to 0 (0=false) >Returning chair.
            BGT    V8,0,KCHAIR2    ;get absolute value by negating if under 0
            NEG    V8,V8           ;it was < 0 so we negate it.
            MOVI   V9,1            ;and then remember that it was negative

KCHAIR2:    BLE    V8,vdac16(0.01),KCHAIREX
                                  ;check if we're within our epsilon
            BNE    V9,0,KCHAIR3    ;check if position was negative.
            DAC    1,0.02          ;vel for positive position
            JUMP   KCHAIR1

KCHAIR3:    DAC    1,-0.02         ;vel for negative position
            JUMP   KCHAIR1

KCHAIREX:   DAC    1,Chairoff      ;Stop the chair
            JUMP   KDRUM           ;Now initialize the drum

;-----------------------------------------------------------------------------
;KDRUM: Drum return function
;-----------------------------------------------------------------------------
KDRUM:      RATE   0,0             ;stop sine on drum

KDRUM1:     CHAN   V8,3            ;Get position of drum position
            MOVI   V9,0            ;Initiliaze v9 to 0 (false)
            BGT    V8,0,KDRUM2     ;get absolute value of position by negating if under 0
            NEG    V8,V8           ;it was < 0 so we negate it.
            MOVI   V9,1            ;and then remember that it was negative

KDRUM2:     BLE    V8,vdac16(0.01),KDRUMEX
                                    ;check if we're within our epsilon
                                    ;if so, exit
            BNE    V9,0,KDRUM3     ;check if position was negative
            DAC    0,-0.02         ;vel for positive pos
            JUMP   KDRUM1

KDRUM3:     DAC    0,0.02          ;vel for negative position
            JUMP   KDRUM1

KDRUMEX:    DAC    0,DrumOff       ;Exit KDRUM
            JUMP   LOOP            ;Drum stopped

;-----------------------------------------------------------------------------
; STEP COMMAND
;-----------------------------------------------------------------------------
STEP:   'J  DAC    0,SAmpD
            DAC    1,SAmpC
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEP

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "aligned to complete cycle"
;-----------------------------------------------------------------------------
STEPL:  't  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DIGOUT [.......1]           ;Light on
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DIGOUT [.......0]           ;Light off
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DIGOUT [.......1]           ;Light on
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DIGOUT [.......0]           ;Light off
            DELAY  StepRes2
            JUMP   STEPL

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "delayed"
;-----------------------------------------------------------------------------
STEPD:  'd  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPD

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "Aligned to somewhere in the middle of step"
;-----------------------------------------------------------------------------
STEPB:  'b  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPB

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "aligned to end of step"
;-----------------------------------------------------------------------------
STEPE:  'e  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPE

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto | "aligned to complete cycle"
;-----------------------------------------------------------------------------
STEPL2:  'T  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DIGOUT [.....1.1]           ;Light on
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DIGOUT [.....0.0]           ;Light off
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DIGOUT [....1..1]           ;Light on
            DELAY  StepLeng
            DAC    0,DrumOff
            DAC    1,Chairoff
            DIGOUT [....0..0]           ;Light off
            DELAY  StepRes2
            JUMP   STEPL2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto |"delayed"
;-----------------------------------------------------------------------------
STEPD2:  'D  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPD2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto |"Aligned to somewhere in the middle of step"
;-----------------------------------------------------------------------------
STEPB2:  'B  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DELAY  StepLen3
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPB2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto | "aligned to end of step"
;-----------------------------------------------------------------------------
STEPE2:  'E  DAC    0,SAmpD              ;Turn on drum
            DAC    1,SAmpC              ;Turn on chair
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLen1
            DIGOUT [.......1]           ;Light on
            DELAY  StepLen2
            DIGOUT [.......0]           ;Light off
            DAC    0,DrumOff
            DAC    1,Chairoff
            DELAY  StepRes2
            JUMP   STEPE2

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | with NO light cue. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
STEPK2: 'k  DAC    0,SAmpD
            DAC    1,Chairoff
            DELAY  StepLeng
            DAC    0,SAmpDn
            DAC    1,Chairoff
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,Chairoff
            JUMP   STEPK2

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | with Light Queue. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
STEPK:  'K  DAC    0,SAmpD
            DAC    1,Chairoff
            DELAY  StepLeng
            DIGOUT [.......0]
            DAC    0,SAmpDn
            DAC    1,Chairoff
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,Chairoff
            DIGOUT [.......1]
            DELAY  QueTime
            JUMP   STEPK

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | in random directions. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
STEPg:  'g  BRAND STEPg2,.5
            DAC    0,SAmpD
            DAC    1,SAmpC
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,COffOrig
            DELAY  StepRes1
            DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,COffOrig
            DELAY  StepRes2
            JUMP   STEPg

STEPg2:  'G DAC    0,SAmpDn
            DAC    1,SAmpCn
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,COffOrig
            DELAY  StepRes1
            DAC    0,SAmpD
            DAC    1,SAmpC
            DELAY  StepLeng
            DAC    0,DOffOrig
            DAC    1,COffOrig
            DELAY  StepRes2
            JUMP   STEPg

;-----------------------------------------------------------------------------
; SINE COMMAND
;-----------------------------------------------------------------------------
SINEON: 'S  SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine offset
            ANGLE  0,DrumPh        ;cosine phase

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset
            ANGLE  1,ChrPh         ;cosine phase

            RATE   0,DrumFreq      ;set rate and start cosine
            RATE   1,ChrFreq       ;set rate and start cosine

OFFST1:     WAITC  1,OFFST1         ; >Sine running.
            OFFSET 0,DrumOff        ; >Sine running.
            OFFSET 1,Chairoff       ; >Sine running.
            JUMP   OFFST1           ;set loop to continue sine function >Sine running.

SINEOFF: 's RATE   0,0             ;stop cosine on drum
            RATE   1,0             ;stop cosine on chair
            DAC    0,DrumOff       ;stop the drum
            DAC    1,Chairoff      ;stop the chair
            JUMP   KCHAIR          ;return chair to zero

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with light on only ipsi or contra head movement. For Experiment for Hyun Geun. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
SINE1: 'M   SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine centre
            ANGLE  0,DrumPh        ;cosine phase
            RATE   0,DrumFreq      ;set rate and start cosine off

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset command to chair b/c DAC1 has bias of -0.8 mV
            ANGLE  1,ChrPh         ;cosine phase
            RATE   1,ChrFreq       ;set rate and start cosine off

SINE2:      DIGOUT [.......1]
            DELAY  498
            DIGOUT [.......0]
            DELAY  495
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   SINE2

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with stim on alternating sides each cycle. For experiment for Amin. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
SINE3: 'N   SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine centre
            ANGLE  0,DrumPh        ;cosine phase
            RATE   0,DrumFreq      ;set rate and start cosine off

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset command to chair b/c DAC1 has bias of -0.8 mV
            ANGLE  1,ChrPh         ;cosine phase
            RATE   1,ChrFreq       ;set rate and start cosine off

SINE4:      DIGOUT [....1...]
            DELAY  498
            DIGOUT [....0...]
            DELAY  498
            DIGOUT [.....1..]
            DELAY  498
            DIGOUT [.....0..]
            DELAY  495
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   SINE4

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with light on only ipsi or contra head movement. For Experiment for Amin. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
SINE5: 'U   SZ     0,DrumAmp       ;set cosine amplitude
            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine offset
            OFFSET 1,Chairoff      ;cosine offset
            ANGLE  0,DrumPh        ;cosine phase
            ANGLE  1,ChrPh         ;cosine phase

            RATE   1,ChrFreq       ;set rate and start cosine
            RATE   0,DrumFreq      ;set rate and start cosine

SINE6:      DIGOUT [.......1]
            DELAY  483
            DIGOUT [....11..]
            DELAY  13
            DIGOUT [....00.0]
            DELAY  495
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   SINE6

;-----------------------------------------------------------------------------

SETOFF: 'A  OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   LOOP

;-----------------------------------------------------------------------------
; LIGHT COMMANDS (ON, OFF)
;-----------------------------------------------------------------------------
LIGHTON: 'L DIGOUT [.......1]
            JUMP   OFFST1    ;LOOP

LIGHTOFF: 'l DIGOUT [.......0]
            JUMP   OFFST1    ;LOOP

;-----------------------------------------------------------------------------
; LASER COMMANDS (ON, OFF)
;-----------------------------------------------------------------------------
LASERON: 'Z DIGOUT [....11..]
            JUMP   OFFST1    ;LOOP

LASEROFF: 'z DIGOUT [....00..]
            JUMP   OFFST1    ;LOOP

;-----------------------------------------------------------------------------
; SINE COMMAND | with opto |
;-----------------------------------------------------------------------------
SPULSE0: 'P SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine offset
            ANGLE  0,DrumPh        ;cosine phase

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset
            ANGLE  1,ChrPh         ;cosine phase

            MOV    V7,PulseDur,-2  ; minor adjustments are to account for delays in sequencer
            MOV    V6,PulseInt,-3  ; minor adjustments are to account for delays in sequencer
            MOV    V5,PulseWai,-4  ; minor adjustments are to account for delays in sequencer
            MOV    V4,PulseWai,-5  ; minor adjustments are to account for delays in sequencer
            MOV    V10,PulseNum    ; You cannot modify variables like 'PulseNum', use V10 instead

            RATE   0,DrumFreq      ;set rate and start DRUM cosine
            RATE   1,ChrFreq       ;set rate and start CHAIR cosine

SPULSE2:    DIGOUT [.....1..]
            DELAY  V7
            DIGOUT [.....0..]
            DELAY  V6
            DBNZ   V10,SPULSE2
            DELAY  V5
            MOV    V10,PulseNum
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff

SPULSE3:    DIGOUT [....1...]
            DELAY  V7
            DIGOUT [....0...]
            DELAY  V6
            DBNZ   V10,SPULSE3
            DELAY  V4
            MOV    V10,PulseNum
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   SPULSE2

;-----------------------------------------------------------------------------
;uses commands for pulse stimulation - immediate switching between sides
;-----------------------------------------------------------------------------
IPULSE0: 'Q SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine centre
            ANGLE  0,DrumPh        ;cosine phase

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset command to chair V
            ANGLE  1,ChrPh         ;cosine phase

            MOV    V7,PulseDur,-2  ; minor adjustments are to account for delays in sequencer
            MOV    V6,PulseDur,-5  ; minor adjustments are to account for delays in sequencer

            RATE   0,DrumFreq      ;set rate and start DRUM cosine
            RATE   1,ChrFreq       ;set rate and start CHAIR cosine

IW1:        DIGOUT [....01..]      ;Invert two channels
            DELAY  V7               ;DELAY takes up 1 ms itself
            DIGOUT [....10..]
            DELAY  V6               ;DELAY takes up 1 ms itself
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   IW1

;----------------------------------------------------
KSPULSE: 'p DIGOUT [....00..]      ;set digital outputs low
            JUMP   LOOP
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;uses commands for single channel LED single 33 ms pulse stimulation (event output 1 for video)
;-----------------------------------------------------------------------------
SPULSE4: 'V SZ     0,DrumAmp       ;set cosine amplitude
            OFFSET 0,DrumOff       ;cosine centre
            ANGLE  0,DrumPh        ;cosine phase
            RATE   0,DrumFreq      ;set rate and start cosine off

            SZ     1,ChrAmp        ;set cosine amplitude
            OFFSET 1,Chairoff      ;cosine offset command to chair
            ANGLE  1,ChrPh         ;cosine phase
            RATE   1,ChrFreq       ;set rate and start cosine off

SPULSE5:    DIGOUT [......1.]
            DELAY  PulseDuV
            DIGOUT [......0.]
            DELAY  PulseWaV
            OFFSET 0,DrumOff
            OFFSET 1,Chairoff
            JUMP   SPULSE5
;----------------------------------------------------
KPULSE2: 'v DIGOUT [......0.]      ;set digital outputs low
            JUMP   INIT

;-----------------------------------------------------------------------------
; TTL5 Control for Fiber Photometry
;-----------------------------------------------------------------------------
FPULSE1: 'H DIGOUT  [...1....]
            JUMP   LOOP

FPULSE2: 'h DIGOUT  [...0....]
            JUMP   LOOP
