*       MINPRGU4
*
*       OPT Z01,LLE=96
*		
*
*       THIS PROGRAM WILL CHECK, PROGRAM AND VERIFY
*       THE MC68701 OR THE MC68701U4 EPROM. IT ALSO
*       DETERMINES WHETHER A MC68701 OR A MC68701U4 IS
*       BEING PROGRAMMED.
*
*
*       E Q U A T E S
P1DDR   EQU $00         PORT 1 DATA DIR. REGISTER
P1DR    EQU $02         PORT 1 DATA REGISTER
TCSR    EQU $08         TIMER CONTROL/STAT REGISTER
TIMER   EQU $09         COUNTER REGISTER
OUTCMP  EQU $0B         OUTPUT COMPARE REGISTER  
EPMCNT  EQU $14         RAM/EROM CONTROL REGISTER
TCR2    EQU $18         TIMER/CONTROL REG. 2
*
*       L O C A L   V A R I A B L E S
*
        ORG $80
IMBEG   RMB 2           START OF MEMORY BLOCK
IMEND   RMB 2           LAST BYTE OF MEMORY BLOCK
PNTR    RMB 2           FIRST BYTE OF EPROM TO BE PROGRAMMED
WAIT    RMB 2           COUNTER VALUE
*
        ORG     $B850
START   LDS     #$FF    INITIALIZE STACK  
        LDAA    #$17    INIT. PORT 1
        STAA    P1DDR   DDR
        STAA    P1DR    DATA REGISTER (ALL LEDs OFF / NO Vpp APPLIED)
*
*
*               DETEMINE WETHER MC68701 OR MC68701U4 
*               IS BEING PROGRAMMED
*
        LDAA    TCR2    TCR2 = $03 ON RESET 
        CMPA    #%00000011 IF 701U4, THIS VALUE
        BEQ     P4K     GO TO 701U4 MEMORY SETUP
        LDAA    #$FE    SECOND CHECK
        STAA    TCR2    WRITE A ZERO TO TCR2-0 (CLOCK)
        LDAA    TCR2    NOW READ IT BACK
        ANDA    #$01    MASK CLOCK BIT
        BEQ     P4K     MC68701U4 IF "Z" = 1
*
*       INITIALIZE EPROM MEMORY SIZE TO MC68701 (2K)
*
        LDD     #$7800  START OF EPROM
        STD     IMBEG
        LDD     #$F800  START OF MC68701 EPROM
        STD     PNTR
        BRA     BLKROM
*
*       INITIALIZE EPROM MEMORY SIZE TO MC68701U4 (4K)
*
P4K     LDD     #$7000  START OF EPROM
        STD     IMBEG
        LDD     #$F000  START OF 7801 EPROM
        STD     PNTR
*
*       B L A N K  C H E C K 
*
BLKROM  LDX     PNTR    CHECK IF EPROM ERASED
        LDAB    #$00    GET READY FOR CMPR 
ERASE   LDAA    0,X     LOAD EPROM CONTENTS
        CBA             COMPARE TO ZERO
        BNE     ERROR1  BRANCH IF NOT ZERO 
        CPX     #$FFFF  CHECK IF DONE
        BEQ     NEXT    IF SO BRANCH
        INX             GO AGAIN
        BRA     ERASE 
* *
NEXT    LDAA    #$16    TURN ON ERASED LIGHT
        STAA    P1DR
* *
*       D E L A Y  L O O P
*
        STX     WAIT
        LDX     #$0046  GET READY FOR 70 TIMES THROUGH LOOP
STALL1  DEX
        LDD     #$C350  INIT. 50MS LOOP
        ADDD    TIMER   BUMP CURRENT VALUE
        CLR     TCSR    CLEAR OCF
        STD     OUTCMP  SET OUTPUT COMPARE
        LDAA    #$40    NOW WAIT FOR OCE
STALL2  BITA    TCSR
        BEQ     STALL2  NOT YET
        CPX     #$0000  70 TIMES YET?
        BNE     STALL1  NOPE
        BRA     PGINT
* *
ERROR1  LDAA    #$02    LIGHT ERROR AND ERASE LEDs
        STAA    P1DR
        BRA     SELF
* *
PGINT   LDX     #$7FFF  INIT. IMEND
        STX     IMEND
        LDX     #$C350  INIT. WAIT (4.0MHZ) 
        STX     WAIT
*
*       P R O G R A M M I N G  L O O P 
*
EPROM   LDAA    #$07    TURN OFF LEDs AND APPLY Vpp
        STAA    P1DR
        LDX     PNTR    SAVE CALLING ARGUMENT
        PSHX            RESTORE WHEN DONE
        LDX     IMBEG   USE STACK
EPR002  PSHX            SAVE POINTER ON STACK
        LDAA    #$FE    REMOVE Vpp, SET LATCH
        STAA    EPMCNT  PPC=1, PLC=0
        LDAA    0,X     MOVE DATA MEMORY-TO-LATCH
        LDX     PNTR    GET WHERE TO PUT IT
        STAA    0,X     STASH AND LATCH
        INX             NEXT ADDR
        STX     PNTR    ALL SET FOR NEXT
        LDAA    #$FC    ENABLE EPROM POWER (Vpp)
        STAA    EPMCNT  PPC=0, PLC=0
*
*       NOW WAIT 50MS TIMEOUT USING COMPARE
*
        LDD     WAIT    GET CYCLE COUNTER
        ADDD    TIMER   BUMP CURRENT VALUE
        CLR     TCSR    CLEAR OCF
        STD     OUTCMP  SET OUTPUT COMPARE
        LDAA    #$40    NOW WAIT FOR OCF
EPR004  BITA    TCSR
        BEQ     EPR004  NOT YET
        PULX            SET UP FOR NEXT ONE
        INX             NEXT
        CPX     IMEND   MAYBE DONE
        BLS     EPR002  NOT YET
        LDAA    #$17    REMOVE Vpp AT PGINT
        STAA    P1DR
        LDAA    #$FF    REMOVE Vpp, INHIBIT LATCH
        STAA    EPMCNT  EPROM CAN NOW BE READ
        PULX            RESTORE PNTR
        STX     PNTR
*
*       V E R I F Y  N E W  C O D E
*
        LDX     IMBEG   SETUP POINTER
VERF2   PSHX            SAVE POINTER ON STACK
        LDAA    0,X     GET DESIRED DATA
        LDX     PNTR    GET EPROM ADDR 
        LDAB    0,X     GET DATA TO BE CHECKED
        CBA             CHECK IF SAME
        BNE     ERROR2  BRANCH IF ERROR (LIGHT RED)
        INX             NEXT ADDR
        STX     PNTR    ALL SET FOR NEXT
        PULX            SETUP FOR NEXT ONE
        INX             NEXT
        CPX     #$8000  MAYBE DONE
        BNE     VERF2   NOT YET
* *
        LDAA    #$15
        STAA    P1DR    LIGHT VERIY LEDs
* *
SELF    BRA     SELF    WAIT FOREVER
* *
ERROR2  LDAA    #$13    LIGHT ERROR LED
        STAA    P1DR
        BRA SELF
* *     
*       R E S T A R T  A N D  I N T R.  V E C.
*
        ORG     $BFF0
        FDB     SELF
        FDB     SELF
        FDB     SELF
        FDB     SELF
        FDB     SELF
        FDB     SELF
        FDB     SELF
        FDB     START
        END