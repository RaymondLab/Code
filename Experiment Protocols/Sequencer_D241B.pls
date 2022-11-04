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

                VAR    V54,SumSine=500 ;Sum of Sines

                VAR    V55,QueTime=250
                VAR    V56,DOffOrig=vdac16(0)
                VAR    V57,COffOrig=vdac16(0)
                VAR    V58,pDelay=500

;-----------------------------------------------------------------------------
; LOOP: our idle loop.
;-----------------------------------------------------------------------------
0000 LOOP:      SZ     7,1             ;set cosine amplitude
0001            OFFSET 7,0             ;cosine offset command to ghost timing sine wave
0002            ANGLE  7,0             ;cosine phase
0003            RATE   7,1             ;set rate and start ghost cosine

0004 LOOP1:     DAC    0,DrumOff       ;                   >Looping.
0005            DAC    3,Chairoff
0006            JUMP   LOOP1

;-----------------------------------------------------------------------------
; INIT: Move CHAIR (DAC1) & DRUM (DAC0) to zero
;-----------------------------------------------------------------------------
0007 INIT:  'I  RATE   0,0             ;stop cosine on drum
0008            RATE   3,0             ;stop cosine on chair
0009            DAC    0,DrumOff       ;stop the drum
0010            DAC    3,Chairoff      ;stop the chair
0011            DIGOUT [000.0000]      ;stop any pulses EXCEPT TTL5. TTL5 is used for Fiber Photometry
0012            JUMP   KCHAIR          ;return chair to zero

;-----------------------------------------------------------------------------
; QUIT: Stops all movement on drum and chair
;-----------------------------------------------------------------------------
0013 QUIT:  'O  RATE   0,0             ;stop cosine on drum
0014            RATE   3,0             ;stop cosine on chair
0015            DAC    0,DrumOff       ;stop the drum
0016            DAC    3,Chairoff      ;stop the chair
0017            DIGOUT [00000000]      ;stop any pulses
0018            JUMP   LOOP            ;idle loop

;-----------------------------------------------------------------------------
; KCHAIR: Chair return function
;-----------------------------------------------------------------------------
0019 KCHAIR:    RATE   3,0             ;stop cosine on chair

0020 KCHAIR1:   CHAN   V8,2            ;Get value of chair position
0021            MOVI   V9,0            ;Intialize v9 to 0 (0=false) >Returning chair.
0022            BGT    V8,0,KCHAIR2    ;get absolute value by negating if under 0
0023            NEG    V8,V8           ;it was < 0 so we negate it.
0024            MOVI   V9,1            ;and then remember that it was negative

0025 KCHAIR2:   BLE    V8,vdac16(0.01),KCHAIREX
                                  ;check if we're within our epsilon
0026            BNE    V9,0,KCHAIR3    ;check if position was negative.
0027            DAC    3,0.02          ;vel for positive position
0028            JUMP   KCHAIR1

0029 KCHAIR3:   DAC    3,-0.02         ;vel for negative position
0030            JUMP   KCHAIR1

0031 KCHAIREX:  DAC    3,Chairoff      ;Stop the chair
0032            JUMP   KDRUM           ;Now initialize the drum

;-----------------------------------------------------------------------------
;KDRUM: Drum return function
;-----------------------------------------------------------------------------
0033 KDRUM:     RATE   0,0             ;stop sine on drum

0034 KDRUM1:    CHAN   V8,3            ;Get position of drum position
0035            MOVI   V9,0            ;Initiliaze v9 to 0 (false)
0036            BGT    V8,0,KDRUM2     ;get absolute value of position by negating if under 0
0037            NEG    V8,V8           ;it was < 0 so we negate it.
0038            MOVI   V9,1            ;and then remember that it was negative

0039 KDRUM2:    BLE    V8,vdac16(0.01),KDRUMEX
                                    ;check if we're within our epsilon
                                    ;if so, exit
0040            BNE    V9,0,KDRUM3     ;check if position was negative
0041            DAC    0,-0.02         ;vel for positive pos
0042            JUMP   KDRUM1

0043 KDRUM3:    DAC    0,0.02          ;vel for negative position
0044            JUMP   KDRUM1

0045 KDRUMEX:   DAC    0,DrumOff       ;Exit KDRUM
0046            JUMP   LOOP            ;Drum stopped

;-----------------------------------------------------------------------------
; STEP COMMAND
;-----------------------------------------------------------------------------
0047 STEP:  'J  DAC    0,SAmpD
0048            DAC    3,SAmpC
0049            DELAY  StepLeng
0050            DAC    0,DrumOff
0051            DAC    3,Chairoff
0052            DELAY  StepRes1
0053            DAC    0,SAmpDn
0054            DAC    3,SAmpCn
0055            DELAY  StepLeng
0056            DAC    0,DrumOff
0057            DAC    3,Chairoff
0058            DELAY  StepRes2
0059            JUMP   STEP

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "aligned to complete cycle"
;-----------------------------------------------------------------------------
0060 STEPL: 't  DAC    0,SAmpD         ;Turn on drum
0061            DAC    3,SAmpC         ;Turn on chair
0062            DIGOUT [.......1]      ;Light on
0063            DELAY  StepLeng
0064            DAC    0,DrumOff
0065            DAC    3,Chairoff
0066            DIGOUT [.......0]      ;Light off
0067            DELAY  StepRes1
0068            DAC    0,SAmpDn
0069            DAC    3,SAmpCn
0070            DIGOUT [.......1]      ;Light on
0071            DELAY  StepLeng
0072            DAC    0,DrumOff
0073            DAC    3,Chairoff
0074            DIGOUT [.......0]      ;Light off
0075            DELAY  StepRes2
0076            JUMP   STEPL

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "delayed"
;-----------------------------------------------------------------------------
0077 STEPD: 'd  DAC    0,SAmpD         ;Turn on drum
0078            DAC    3,SAmpC         ;Turn on chair
0079            DELAY  stepLen1
0080            DIGOUT [.......1]      ;Light on
0081            DELAY  stepLen2
0082            DIGOUT [.......0]      ;Light off
0083            DELAY  stepLen3
0084            DAC    0,DrumOff
0085            DAC    3,Chairoff
0086            DELAY  StepRes1
0087            DAC    0,SAmpDn
0088            DAC    3,SAmpCn
0089            DELAY  stepLen1
0090            DIGOUT [.......1]      ;Light on
0091            DELAY  stepLen2
0092            DIGOUT [.......0]      ;Light off
0093            DELAY  stepLen3
0094            DAC    0,DrumOff
0095            DAC    3,Chairoff
0096            DELAY  StepRes2
0097            JUMP   STEPD

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "Aligned to somewhere in the middle of step"
;-----------------------------------------------------------------------------
0098 STEPB: 'b  DAC    0,SAmpD         ;Turn on drum
0099            DAC    3,SAmpC         ;Turn on chair
0100            DIGOUT [.......1]      ;Light on
0101            DELAY  stepLen2
0102            DIGOUT [.......0]      ;Light off
0103            DELAY  stepLen3
0104            DAC    0,DrumOff
0105            DAC    3,Chairoff
0106            DELAY  StepRes1
0107            DAC    0,SAmpDn
0108            DAC    3,SAmpCn
0109            DIGOUT [.......1]      ;Light on
0110            DELAY  stepLen2
0111            DIGOUT [.......0]      ;Light off
0112            DELAY  stepLen3
0113            DAC    0,DrumOff
0114            DAC    3,Chairoff
0115            DELAY  StepRes2
0116            JUMP   STEPB

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | "aligned to end of step"
;-----------------------------------------------------------------------------
0117 STEPE: 'e  DAC    0,SAmpD         ;Turn on drum
0118            DAC    3,SAmpC         ;Turn on chair
0119            DELAY  stepLen1
0120            DIGOUT [.......1]      ;Light on
0121            DELAY  stepLen2
0122            DIGOUT [.......0]      ;Light off
0123            DAC    0,DrumOff
0124            DAC    3,Chairoff
0125            DELAY  StepRes1
0126            DAC    0,SAmpDn
0127            DAC    3,SAmpCn
0128            DELAY  stepLen1
0129            DIGOUT [.......1]      ;Light on
0130            DELAY  stepLen2
0131            DIGOUT [.......0]      ;Light off
0132            DAC    0,DrumOff
0133            DAC    3,Chairoff
0134            DELAY  StepRes2
0135            JUMP   STEPE

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto | "aligned to complete cycle"
;-----------------------------------------------------------------------------
0136 STEPL2: 'T DAC    0,SAmpD         ;Turn on drum
0137            DAC    3,SAmpC         ;Turn on chair
0138            DIGOUT [.....1.1]      ;Light on
0139            DELAY  StepLeng
0140            DAC    0,DrumOff
0141            DAC    3,Chairoff
0142            DIGOUT [.....0.0]      ;Light off
0143            DELAY  StepRes1
0144            DAC    0,SAmpDn
0145            DAC    3,SAmpCn
0146            DIGOUT [....1..1]      ;Light on
0147            DELAY  StepLeng
0148            DAC    0,DrumOff
0149            DAC    3,Chairoff
0150            DIGOUT [....0..0]      ;Light off
0151            DELAY  StepRes2
0152            JUMP   STEPL2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto |"delayed"
;-----------------------------------------------------------------------------
0153 STEPD2: 'D DAC    0,SAmpD         ;Turn on drum
0154            DAC    3,SAmpC         ;Turn on chair
0155            DELAY  stepLen1
0156            DIGOUT [.......1]      ;Light on
0157            DELAY  stepLen2
0158            DIGOUT [.......0]      ;Light off
0159            DELAY  stepLen3
0160            DAC    0,DrumOff
0161            DAC    3,Chairoff
0162            DELAY  StepRes1
0163            DAC    0,SAmpDn
0164            DAC    3,SAmpCn
0165            DELAY  stepLen1
0166            DIGOUT [.......1]      ;Light on
0167            DELAY  stepLen2
0168            DIGOUT [.......0]      ;Light off
0169            DELAY  stepLen3
0170            DAC    0,DrumOff
0171            DAC    3,Chairoff
0172            DELAY  StepRes2
0173            JUMP   STEPD2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto |"Aligned to somewhere in the middle of step"
;-----------------------------------------------------------------------------
0174 STEPB2: 'B DAC    0,SAmpD         ;Turn on drum
0175            DAC    3,SAmpC         ;Turn on chair
0176            DIGOUT [.......1]      ;Light on
0177            DELAY  stepLen2
0178            DIGOUT [.......0]      ;Light off
0179            DELAY  stepLen3
0180            DAC    0,DrumOff
0181            DAC    3,Chairoff
0182            DELAY  StepRes1
0183            DAC    0,SAmpDn
0184            DAC    3,SAmpCn
0185            DIGOUT [.......1]      ;Light on
0186            DELAY  stepLen2
0187            DIGOUT [.......0]      ;Light off
0188            DELAY  stepLen3
0189            DAC    0,DrumOff
0190            DAC    3,Chairoff
0191            DELAY  StepRes2
0192            JUMP   STEPB2

;-----------------------------------------------------------------------------
; STEP COMMAND | with light | with opto | "aligned to end of step"
;-----------------------------------------------------------------------------
0193 STEPE2: 'E DAC    0,SAmpD         ;Turn on drum
0194            DAC    3,SAmpC         ;Turn on chair
0195            DELAY  stepLen1
0196            DIGOUT [.......1]      ;Light on
0197            DELAY  stepLen2
0198            DIGOUT [.......0]      ;Light off
0199            DAC    0,DrumOff
0200            DAC    3,Chairoff
0201            DELAY  StepRes1
0202            DAC    0,SAmpDn
0203            DAC    3,SAmpCn
0204            DELAY  stepLen1
0205            DIGOUT [.......1]      ;Light on
0206            DELAY  stepLen2
0207            DIGOUT [.......0]      ;Light off
0208            DAC    0,DrumOff
0209            DAC    3,Chairoff
0210            DELAY  StepRes2
0211            JUMP   STEPE2

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | with NO light cue. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
0212 STEPK2: 'k DAC    0,SAmpD
0213            DAC    3,Chairoff
0214            DELAY  StepLeng
0215            DAC    0,SAmpDn
0216            DAC    3,Chairoff
0217            DELAY  StepLeng
0218            DAC    0,DOffOrig
0219            DAC    3,Chairoff
0220            JUMP   STEPK2

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | with Light Queue. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
0221 STEPK: 'K  DAC    0,SAmpD
0222            DAC    3,Chairoff
0223            DELAY  StepLeng
0224            DIGOUT [.......0]
0225            DAC    0,SAmpDn
0226            DAC    3,Chairoff
0227            DELAY  StepLeng
0228            DAC    0,DOffOrig
0229            DAC    3,Chairoff
0230            DIGOUT [.......1]
0231            DELAY  QueTime
0232            JUMP   STEPK

;-----------------------------------------------------------------------------
; STEP COMMAND | SPECIAL | in random directions. For Experiment for Alex F. -- Maxwell 11/19
;-----------------------------------------------------------------------------
0233 STEPg: 'g  BRAND  STEPg2,.5
0234            DAC    0,SAmpD
0235            DAC    3,SAmpC
0236            DELAY  StepLeng
0237            DAC    0,DOffOrig
0238            DAC    3,COffOrig
0239            DELAY  StepRes1
0240            DAC    0,SAmpDn
0241            DAC    3,SAmpCn
0242            DELAY  StepLeng
0243            DAC    0,DOffOrig
0244            DAC    3,COffOrig
0245            DELAY  StepRes2
0246            JUMP   STEPg

0247 STEPg2: 'G DAC    0,SAmpDn
0248            DAC    3,SAmpCn
0249            DELAY  StepLeng
0250            DAC    0,DOffOrig
0251            DAC    3,COffOrig
0252            DELAY  StepRes1
0253            DAC    0,SAmpD
0254            DAC    3,SAmpC
0255            DELAY  StepLeng
0256            DAC    0,DOffOrig
0257            DAC    3,COffOrig
0258            DELAY  StepRes2
0259            JUMP   STEPg

;-----------------------------------------------------------------------------
; SINE COMMAND
;-----------------------------------------------------------------------------
0260 SINEON: 'S SZ     0,DrumAmp       ;set cosine amplitude
0261            OFFSET 0,DrumOff       ;cosine offset
0262            ANGLE  0,DrumPh        ;cosine phase

0263            SZ     3,ChrAmp        ;set cosine amplitude
0264            OFFSET 3,Chairoff      ;cosine offset
0265            ANGLE  3,ChrPh         ;cosine phase

0266            RATE   0,DrumFreq      ;set rate and start cosine
0267            RATE   3,ChrFreq       ;set rate and start cosine

0268 OFFST1:    WAITC  3,OFFST1        ;                   >Sine running.
0269            OFFSET 0,DrumOff       ;                   >Sine running.
0270            OFFSET 3,Chairoff      ;                   >Sine running.
0271            JUMP   OFFST1          ;set loop to continue sine function >Sine running.

0272 SINEOFF: 's RATE  0,0             ;stop cosine on drum
0273            RATE   3,0             ;stop cosine on chair
0274            DAC    0,DrumOff       ;stop the drum
0275            DAC    3,Chairoff      ;stop the chair
0276            JUMP   KCHAIR          ;return chair to zero

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with light on only ipsi or contra head movement. For Experiment for Hyun Geun. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
0277 SINE1: 'M  SZ     0,DrumAmp       ;set cosine amplitude
0278            OFFSET 0,DrumOff       ;cosine centre
0279            ANGLE  0,DrumPh        ;cosine phase
0280            RATE   0,DrumFreq      ;set rate and start cosine off

0281            SZ     3,ChrAmp        ;set cosine amplitude
0282            OFFSET 3,Chairoff      ;cosine offset command to chair b/c DAC1 has bias of -0.8 mV
0283            ANGLE  3,ChrPh         ;cosine phase
0284            RATE   3,ChrFreq       ;set rate and start cosine off

0285 SINE2:     DIGOUT [.......1]
0286            DELAY  498
0287            DIGOUT [.......0]
0288            DELAY  495
0289            OFFSET 0,DrumOff
0290            OFFSET 3,Chairoff
0291            JUMP   SINE2

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with stim on alternating sides each cycle. For experiment for Amin. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
0292 SINE3: 'N  SZ     0,DrumAmp       ;set cosine amplitude
0293            OFFSET 0,DrumOff       ;cosine centre
0294            ANGLE  0,DrumPh        ;cosine phase
0295            RATE   0,DrumFreq      ;set rate and start cosine off

0296            SZ     3,ChrAmp        ;set cosine amplitude
0297            OFFSET 3,Chairoff      ;cosine offset command to chair b/c DAC1 has bias of -0.8 mV
0298            ANGLE  3,ChrPh         ;cosine phase
0299            RATE   3,ChrFreq       ;set rate and start cosine off

0300 SINE4:     DIGOUT [....1...]
0301            DELAY  498
0302            DIGOUT [....0...]
0303            DELAY  498
0304            DIGOUT [.....1..]
0305            DELAY  498
0306            DIGOUT [.....0..]
0307            DELAY  495
0308            OFFSET 0,DrumOff
0309            OFFSET 3,Chairoff
0310            JUMP   SINE4

;-----------------------------------------------------------------------------
; SINE COMMAND | SPECIAL | with light on only ipsi or contra head movement. For Experiment for Amin. -- Maxwell Jan 2020
;-----------------------------------------------------------------------------
0311 SINE5: 'U  SZ     0,DrumAmp       ;set cosine amplitude
0312            SZ     3,ChrAmp        ;set cosine amplitude
0313            OFFSET 0,DrumOff       ;cosine offset
0314            OFFSET 3,Chairoff      ;cosine offset
0315            ANGLE  0,DrumPh        ;cosine phase
0316            ANGLE  3,ChrPh         ;cosine phase

0317            RATE   3,ChrFreq       ;set rate and start cosine
0318            RATE   0,DrumFreq      ;set rate and start cosine

0319 SINE6:     DIGOUT [.......1]
0320            DELAY  483
0321            DIGOUT [....11..]
0322            DELAY  13
0323            DIGOUT [....00.0]
0324            DELAY  495
0325            OFFSET 0,DrumOff
0326            OFFSET 3,Chairoff
0327            JUMP   SINE6

;-----------------------------------------------------------------------------

0328 SETOFF: 'A OFFSET 0,DrumOff
0329            OFFSET 3,Chairoff
0330            JUMP   LOOP

;-----------------------------------------------------------------------------
; LIGHT COMMANDS (ON, OFF)
;-----------------------------------------------------------------------------
0331 LIGHTON: 'L DIGOUT [.......1]
0332            JUMP   OFFST1          ;LOOP

0333 LIGHTOFF: 'l DIGOUT [.......0]
0334            JUMP   OFFST1          ;LOOP

;-----------------------------------------------------------------------------
; LASER COMMANDS (ON, OFF)
;-----------------------------------------------------------------------------
0335 LASERON: 'Z DIGOUT [....11..]
0336            JUMP   OFFST1          ;LOOP

0337 LASEROFF: 'z DIGOUT [....00..]
0338            JUMP   OFFST1          ;LOOP

;-----------------------------------------------------------------------------
; SINE COMMAND | with opto |
;-----------------------------------------------------------------------------
0339 SPULSE0: 'P SZ    0,DrumAmp       ;set cosine amplitude
0340            OFFSET 0,DrumOff       ;cosine offset
0341            ANGLE  0,DrumPh        ;cosine phase

0342            SZ     3,ChrAmp        ;set cosine amplitude
0343            OFFSET 3,Chairoff      ;cosine offset
0344            ANGLE  3,ChrPh         ;cosine phase

0345            MOV    V7,PulseDur,-2  ;minor adjustments are to account for delays in sequencer
0346            MOV    V6,PulseInt,-3  ;minor adjustments are to account for delays in sequencer
0347            MOV    V5,PulseWai,-4  ;minor adjustments are to account for delays in sequencer
0348            MOV    V4,PulseWai,-5  ;minor adjustments are to account for delays in sequencer
0349            MOV    V10,PulseNum    ;You cannot modify variables like 'PulseNum', use V10 instead

0350            RATE   0,DrumFreq      ;set rate and start DRUM cosine
0351            RATE   3,ChrFreq       ;set rate and start CHAIR cosine

0352 SPULSE2:   DIGOUT [.....1..]
0353            DELAY  V7
0354            DIGOUT [.....0..]
0355            DELAY  V6
0356            DBNZ   V10,SPULSE2
0357            DELAY  V5
0358            MOV    V10,PulseNum
0359            OFFSET 0,DrumOff
0360            OFFSET 3,Chairoff

0361 SPULSE3:   DIGOUT [....1...]
0362            DELAY  V7
0363            DIGOUT [....0...]
0364            DELAY  V6
0365            DBNZ   V10,SPULSE3
0366            DELAY  V4
0367            MOV    V10,PulseNum
0368            OFFSET 0,DrumOff
0369            OFFSET 3,Chairoff
0370            JUMP   SPULSE2

;-----------------------------------------------------------------------------
;uses commands for pulse stimulation - immediate switching between sides
;-----------------------------------------------------------------------------
0371 IPULSE0: 'Q SZ    0,DrumAmp       ;set cosine amplitude
0372            OFFSET 0,DrumOff       ;cosine centre
0373            ANGLE  0,DrumPh        ;cosine phase

0374            SZ     3,ChrAmp        ;set cosine amplitude
0375            OFFSET 3,Chairoff      ;cosine offset command to chair V
0376            ANGLE  3,ChrPh         ;cosine phase

0377            MOV    V7,PulseDur,-2  ;minor adjustments are to account for delays in sequencer
0378            MOV    V6,PulseDur,-5  ;minor adjustments are to account for delays in sequencer

0379            RATE   0,DrumFreq      ;set rate and start DRUM cosine
0380            RATE   3,ChrFreq       ;set rate and start CHAIR cosine

0381 IW1:       DIGOUT [....01..]      ;Invert two channels
0382            DELAY  V7              ;DELAY takes up 1 ms itself
0383            DIGOUT [....10..]
0384            DELAY  V6              ;DELAY takes up 1 ms itself
0385            OFFSET 0,DrumOff
0386            OFFSET 3,Chairoff
0387            JUMP   IW1

;----------------------------------------------------
0388 KSPULSE: 'p DIGOUT [....00..]     ;set digital outputs low
0389            JUMP   LOOP
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
;uses commands for single channel LED single 33 ms pulse stimulation (event output 1 for video)
;-----------------------------------------------------------------------------
0390 SPULSE4: 'V SZ    0,DrumAmp       ;set cosine amplitude
0391            OFFSET 0,DrumOff       ;cosine centre
0392            ANGLE  0,DrumPh        ;cosine phase
0393            RATE   0,DrumFreq      ;set rate and start cosine off

0394            SZ     3,ChrAmp        ;set cosine amplitude
0395            OFFSET 3,Chairoff      ;cosine offset command to chair
0396            ANGLE  3,ChrPh         ;cosine phase
0397            RATE   3,ChrFreq       ;set rate and start cosine off

0398 SPULSE5:   DIGOUT [......1.]
0399            DELAY  PulseDuV
0400            DIGOUT [......0.]
0401            DELAY  PulseWaV
0402            OFFSET 0,DrumOff
0403            OFFSET 3,Chairoff
0404            JUMP   SPULSE5
;----------------------------------------------------
0405 KPULSE2: 'v DIGOUT [......0.]     ;set digital outputs low
0406            JUMP   INIT

;-----------------------------------------------------------------------------
; TTL5 Control for Fiber Photometry
;-----------------------------------------------------------------------------
0407 FPULSE1: 'H DIGOUT [...1....]
0408            JUMP   LOOP

0409 FPULSE2: 'h DIGOUT [...0....]
0410            JUMP   LOOP