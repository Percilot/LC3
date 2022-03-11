.ORIG x0200

LD R6, OS_SP
LD R0, USER_PSR
ADD R6, R6, #-1
STR R0, R6, #0
LD R0, USER_PC
ADD R6, R6, #-1
STR R0, R6, #0

;Allow the keyboard interrupt
LD R0, KSBRIn
LD R1, KSBR1
STR R0, R1, #0

;Initialize keyboard interrupt function address
LD R0, KeyboardIntFun
LD R1, KeyboardInt
STR R0, R1, #0

;Initialize the regs
AND R0, R0, #0
AND R1, R1, #0

RTI

OS_SP 
.FILL x3000

USER_PSR 
.FILL x8002

USER_PC 
.FILL x3000

KSBR1 
.FILL xFE00

KSBRIn
.FILL x4000

KeyboardInt
.FILL x0180

KeyboardIntFun
.FILL x0800

.END


.ORIG x0800

;Protect the regs
ADD R6, R6, #-1
STR R1, R6, #0
ADD R6, R6, #-1
STR R2, R6, #0
ADD R6, R6, #-1
STR R3, R6, #0

;Store the input
LDI R3, KSDR2
ST R3, InputData

LD R1, InputData
AND R3, R3, #0

;Is Enter?
ADD R2, R1, #-10
BRz CounterSub

;Is Number?
ADD R2, R1, #-16
ADD R2, R2, #-16
ADD R2, R2, #-16
BRzp BiggerThanZero
BRn OtherInput

BiggerThanZero:
ADD R2, R1, #-16
ADD R2, R2, #-16
ADD R2, R2, #-16
ADD R2, R2 ,#-9
BRnz IsNumber
BRp OtherInput

;Is Number, update counter
IsNumber:
STI R1, Counter2
BRnzp ExitInt

;Is Enter, update counter
CounterSub:
LDI R2, Counter2
ADD R2, R2, #-16
ADD R2, R2, #-16
ADD R2, R2, #-16
BRz ExitInt
LDI R2, Counter2
ADD R2, R2, #-1
STI R2, Counter2
BRnzp ExitInt

;Is other input
OtherInput:

;Print an Enter
PrintEnter1:
LDI R2, DSR2
BRzp PrintEnter1
AND R1, R1, #0
ADD R1, R1, #10
STI R1, DDR2

;Print out input 40 times
LD R1, InputData

;Print out input 40 times
PrintLoop2:
LDI R2, DSR2
BRzp PrintLoop2
STI R1, DDR2

;Creat some delay
DELAY2: 
ST R4, DELAY2_R4
LD R4, DELAY2_COUNT

DELAY2_LOOP: 
ADD R4, R4, #-1
BRnp DELAY2_LOOP

LD R4, DELAY2_R4

ADD R3, R3, #1
ADD R2, R3, #-15
ADD R2, R2, #-15
ADD R2, R2, #-10
BRn PrintLoop2

PrintEnter2:
LDI R2, DSR2
BRzp PrintEnter2
AND R1, R1, #0
ADD R1, R1, #10
STI R1, DDR2

ExitInt:
;Load regs
LDR R3, R6, #0
ADD R6, R6, #1
LDR R2, R6, #0
ADD R6, R6, #1
LDR R1, R6, #0
ADD R6, R6, #1

RTI


DELAY2_COUNT 
.FILL #1024

DELAY2_R4 
.BLKW #1

InputData
.BLKW #1

Counter2
.FILL x3020

KSBR2
.FILL xFE00

KSDR2
.FILL xFE02

DSR2
.FILL xFE04

DDR2
.FILL xFE06

.END

.ORIG x3000

;Initialize counter
AND R0, R0, #0
ADD R0, R0, #15
ADD R0, R0, #15
ADD R0, R0, #15
ADD R0, R0, #10
STI R0, Counter3

;Initialize regs
AND R2, R2, #0
AND R3, R3, #0

;Endless loop
PrintLoop3:
LDI R0, Counter3
OUT
JSR DELAY1
ADD R3, R3, #1
ADD R4, R3, #-15
ADD R4, R4, #-15
ADD R4, R4, #-10
BRzp ClearR3
BRn Printloop3

ClearR3:
AND R0, R0, #0
ADD R0, R0, #10
OUT
LDI R0, Counter3
AND R3, R3, #0
BRnzp PrintLoop3


;Creat some delay
DELAY1: 
ST R4, DELAY1_R4
LD R4, DELAY1_COUNT

DELAY1_LOOP: 
ADD R4, R4, #-1
BRnp DELAY1_LOOP

LD R4, DELAY1_R4
RET

DELAY1_COUNT 
.FILL #1024

DELAY1_R4 
.BLKW #1

Counter3
.FILL x3020

.BLKW #1
.END