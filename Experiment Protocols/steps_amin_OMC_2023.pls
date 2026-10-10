;-----------------------------------------------------------------------------
; Initial Parameters
;-----------------------------------------------------------------------------
            ; Set rate to 1 ms/step, 1 scaling, and 0 offset            
            SET    1.000,1,0

            ; Flags (1=running, 0=stopped)
            VAR    V1,Counter      ;Sample step counter
            VAR    V2,DrumFlg      ;Drum flag
            VAR    V3,ChairFlg     ;Chair flag
            VAR    V4,BlockFlg=0   ;General block flag
            VAR    V5,Gap1Dur=478  ;(Gap1Dur*rate/5)-2
            VAR    V6,FlashDur=39  ;(FlashDur*rate/5)-1
            VAR    V7,Gap3Dur=479  ;(Gap3Dur*rate/5)-1

            ; Drum parameters
            VAR    V8,DrumOff=0
            VAR    V9,DrumAmp=0
            VAR    V10,DrumNeg=0
            VAR    V11,DrumFrq=0
            VAR    V12,DrumPha=0

            ; Chair parameters
            VAR    V13,ChairOff=0
            VAR    V14,ChairAmp=0
            VAR    V15,ChairNeg=0
            VAR    V16,ChairFrq=0
            VAR    V17,ChairPha=0

            VAR    V18,LightPer
            VAR    V19,StepDel=100
            VAR    V20,StepDurP=100
            VAR    V21,StepDurN=100
            VAR    V22,StepOff=50

; Sequencer Constants
Slope       =      0.007


;-----------------------------------------------------------------------------
; LOOP: Sequencer loop when all signals are OFF
;-----------------------------------------------------------------------------
LOOP:   '0  CALL   SETOFF          ;Repeatedly sets offset of drum and chair >IDLING
            JUMP   LOOP


;-----------------------------------------------------------------------------
; TTL1OFF: Turns off TTL channel 1 (digital output bit 8)
;-----------------------------------------------------------------------------
TTL1OFF: 'l DIGOUT [.......0]      ;Turn TTL 1 off
            RETURN 


;-----------------------------------------------------------------------------
; TTL1ON: Turns on TTL channel 1 (digital output bit 8)
;-----------------------------------------------------------------------------
TTL1ON: 'L  DIGOUT [.......1]      ;Turn TTL 1 on
            RETURN 


;-----------------------------------------------------------------------------
; SETOFF: Sets DAC offsets for drift correction
;-----------------------------------------------------------------------------
SETOFF:     DAC    0,DrumOff       ;Sets voltage offset of drum
            DAC    1,ChairOff      ;Sets voltage offset of chair
            RETURN 


;-----------------------------------------------------------------------------
; DSTEPPOS: Sets drum positive step amplitude
;-----------------------------------------------------------------------------
DSTEPPOS:   DAC    0,DrumAmp       ;Sets voltage offset of drum
            DAC    1,ChairOff      ;Sets voltage offset of chair
            RETURN 


;-----------------------------------------------------------------------------
; DSTEPNEG: Sets drum negative step amplitude
;-----------------------------------------------------------------------------
DSTEPNEG:   DAC    0,DrumNeg       ;Sets voltage offset of drum
            DAC    1,ChairOff      ;Sets voltage offset of chair
            RETURN 


;-----------------------------------------------------------------------------
; CSTEPPOS: Sets chair positive step amplitude
;-----------------------------------------------------------------------------
CSTEPPOS:   DAC    0,DrumOff       ;Sets voltage offset of drum
            DAC    1,ChairAmp      ;Sets voltage offset of chair
            RETURN 


;-----------------------------------------------------------------------------
; CSTEPNEG: Sets chair negative step amplitude
;-----------------------------------------------------------------------------
CSTEPNEG:   DAC    0,DrumOff       ;Sets voltage offset of drum
            DAC    1,ChairNeg      ;Sets voltage offset of chair
            RETURN 


;-----------------------------------------------------------------------------
; RESET: Resets sequencer to initial state
;-----------------------------------------------------------------------------
RESET:  'R  CALL   TTL1OFF         ;Reset to initial state
            RAMP   1,ChairOff,Slope
            RAMP   0,DrumOff,Slope
RESET1:     WAITC  1,RESET1
RESET2:     WAITC  0,RESET2
            RETURN 


;-----------------------------------------------------------------------------
; DSTEP: Outputs single period of a drum velocity step
;-----------------------------------------------------------------------------
DSTEP:  'D  MOV    Counter,StepDel
DWAIT1:     CALL   SETOFF
            DBNZ   Counter,DWAIT1
            MOV    Counter,StepDurP
            RAMP   0,DrumAmp,Slope
DRAMP1:     WAITC  0,DRAMP1
DWAIT2:     CALL   DSTEPPOS
            DBNZ   Counter,DWAIT2
            MOV    Counter,StepOff
            RAMP   0,DrumOff,Slope
DRAMP2:     WAITC  0,DRAMP2
DWAIT3:     CALL   SETOFF
            DBNZ   Counter,DWAIT3
            MOV    Counter,StepDurN
            RAMP   0,DrumNeg,Slope
DRAMP3:     WAITC  0,DRAMP3
DWAIT4:     CALL   DSTEPNEG
            DBNZ   Counter,DWAIT4
            RAMP   0,DrumOff,Slope
DRAMP4:     WAITC  0,DRAMP4
            RETURN 


;-----------------------------------------------------------------------------
; CSTEP: Outputs positive and negative chair velocity step
;-----------------------------------------------------------------------------
CSTEP:  'C  MOV    Counter,StepDel ;Single chair step velocity period
CWAIT1:     CALL   SETOFF
            DBNZ   Counter,CWAIT1
            MOV    Counter,StepDurP
            RAMP   1,ChairAmp,Slope
CRAMP1:     WAITC  1,CRAMP1
CWAIT2:     CALL   CSTEPPOS
            DBNZ   Counter,CWAIT2
            MOV    Counter,StepOff
            RAMP   1,ChairOff,Slope
CRAMP2:     WAITC  1,CRAMP2
CWAIT3:     CALL   SETOFF
            DBNZ   Counter,CWAIT3
            MOV    Counter,StepDurN
            RAMP   1,ChairNeg,Slope
CRAMP3:     WAITC  1,CRAMP3
CWAIT4:     CALL   CSTEPNEG
            DBNZ   Counter,CWAIT4
            RAMP   1,ChairOff,Slope
CRAMP4:     WAITC  1,CRAMP4
            RETURN 


;-----------------------------------------------------------------------------
; GAP: No stimuli for DeltaT seconds and a short TTL light pulse halfway
;-----------------------------------------------------------------------------
GAP:    'G  MOVI   BlockFlg,1      ;Start Gap block    >GAP BLOCK
            CALL   RESET           ;                   >"
            MOV    Counter,Gap1Dur ;                   >"
GAP1:       CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAP1    ;                   >"
            CALL   TTL1ON          ;                   >"
            MOV    Counter,FlashDur ;                  >"
GAP2:       CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAP2    ;                   >"
            CALL   TTL1OFF         ;                   >"
            MOV    Counter,Gap3Dur ;                   >"
GAP3:       CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAP3    ;                   >"
            MOVI   BlockFlg,0      ;Set block as inactive >"
            JUMP   LOOP


;-----------------------------------------------------------------------------
; GAPNF: No stimuli for DeltaT seconds and no short TTL light pulse halfway
;-----------------------------------------------------------------------------
GAPNF:  'K  MOVI   BlockFlg,1      ;Start Gap block    >GAP BLOCK
            CALL   RESET           ;                   >"
            MOV    Counter,Gap1Dur ;                   >"
GAPNF1:     CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAPNF1  ;                   >"
            CALL   TTL1OFF         ;                   >"
            MOV    Counter,FlashDur ;                  >"
GAPNF2:     CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAPNF2  ;                   >"
            CALL   TTL1OFF         ;                   >"
            MOV    Counter,Gap3Dur ;                   >"
GAPNF3:     CALL   SETOFF          ;                   >"
            DBNZ   Counter,GAPNF3  ;                   >"
            MOVI   BlockFlg,0      ;Set block as inactive >"
            JUMP   LOOP


;-----------------------------------------------------------------------------
; TEST: Outputs 3 TTL (channel 1) light pulses with some period
;-----------------------------------------------------------------------------
PPTEST: 'P  MOVI   BlockFlg,1      ;Test block         >TEST BLOCK
            CALL   TTL1OFF         ;                   >"
            DIGPS  0,S,LightPer    ;Set square wave with period of T >"
            DIGPS  0,C,3           ;Run for N periods  >"
            DIGPC  0,G             ;Start TTL train    >"
PPTEST1:    CALL   SETOFF          ;                   >"
            DIGPBR 0,S,PPTEST1     ;Loop until pulses are finished >"
            MOVI   BlockFlg,0      ;Set block as inactive >"
            JUMP   LOOP


;-----------------------------------------------------------------------------
; TRAIN: Outputs 2 TTL (channel 1) light pulses with some period
;-----------------------------------------------------------------------------
TRAIN:  'T  MOVI   BlockFlg,1      ;Oculomotor conditioning block >OMC BLOCK
            CALL   TTL1OFF         ;                   >"
            DIGPS  0,S,LightPer    ;Set square wave with period of T >"
            DIGPS  0,C,3           ;Run for N periods  >"
            DIGPC  0,G             ;Start TTL train    >"
TTL1:       CALL   SETOFF          ;                   >"
            DIGPBR 0,C,TTL1        ;                   >"
            CALL   DSTEP           ;                   >"
TTL2:       CALL   SETOFF          ;                   >"
            DIGPBR 0,C,TTL2        ;                   >"
            CALL   DSTEP           ;                   >"
TTL3:       CALL   SETOFF          ;                   >"
            DIGPBR 0,C,TTL3        ;                   >"
            CALL   DSTEP           ;                   >"
TTL4:       CALL   SETOFF          ;                   >"
            DIGPBR 0,S,TTL4        ;                   >"
            MOVI   BlockFlg,0      ;Set block as inactive >"
            JUMP   LOOP