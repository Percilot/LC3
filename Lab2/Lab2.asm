.ORIG x3000
;Print prompt statement
LD R6, STACK
LEA R0, PrintOut
PUTS

;Read in data and echo through loop
LEA R1, InputData
InputLoop:  
GETC
OUT
STR R0, R1, #0
ADD R1, R1, #1
ADD R2, R0, #-10
BRnp InputLoop
BRz ExitInputLoop

ExitInputLoop:
ADD R1, R1, #-1
STR R2, R1, #0

;traverse the linked list from NODE0 and search for maching
LEA R1, InputData
LD R0, NODE0
BRz ProgramExit
LDR R0, R0, #0
BRz ProgramExit

SearchingLoop:
;push R0
ADD R6, R6, #-1
STR R0, R6, #0

;compare First Name and InputData
ADD R0, R0, #2
JSR Strcmp
;R5=(Fisrt Name==InputData)?1:0;
ADD R5, R5, #0
BRp YesAndPrint
;compare First Name and InputData
ADD R0, R0, #1
JSR Strcmp
;R5=(Last Name==InputData)?1:0;
ADD R5, R5, #0
BRp YesAndPrint
BRnz NoAndContinue


YesAndPrint:
;pop R0(but R6 hasn't been changed)
LDR R0, R6, #0
;print First Name
ADD R0, R0, #2
LDR R0, R0, #0
PUTS
;print a blank
LD R0, BLANK
OUT
;print Last Name
LDR R0, R6, #0
ADD R0, R0, #3
LDR R0, R0, #0
PUTS
;print a blank
LD R0, BLANK
OUT
;print room number
LDR R0, R6, #0
ADD R0, R0, #1
LDR R0, R0, #0
PUTS
;printf("\n");
LD R0, ENTER
OUT
;add one to the counter
LD R0, NUMBER
ADD R0, R0, #1
ST R0, NUMBER
;move to next node and change R6
ADD R6, R6, #1
LDR R0, R6, #-1
BRz ProgramExit
LDR R0, R0, #0
BRz ProgramExit
BRnp SearchingLoop

NoAndContinue:
;pop R0
ADD R6, R6, #1
LDR R0, R6, #-1
BRz ProgramExit
;move to next node
LDR R0, R0, #0
BRz ProgramExit
BRnp SearchingLoop

ProgramExit:
LD R0, NUMBER
BRnp Exit

;print Not Found
LEA R0, NotFound
PUTS

Exit:
HALT


Strcmp:
;initialize R5
AND R5, R5, #0
ADD R5, R5, #1
;push R0
ADD R6, R6, #-1
STR R0, R6, #0
;push R1
ADD R6, R6, #-1
STR R1, R6, #0
;push R3
ADD R6, R6, #-1
STR R3, R6, #0
;push R4
ADD R6, R6, #-1
STR R4, R6, #0

LDR R0, R0, #0
BRz ProgramExit
CmpLoop:
;compare every character
LDR R3, R0, #0
LDR R4, R1, #0
ADD R3, R3, #0
BRz Ending
ADD R4, R4, #0
BRz Ending
ADD R0, R0, #1
ADD R1, R1, #1
NOT R4, R4
ADD R4, R4, #1
ADD R3, R3, R4
BRz CmpLoop

Ending:
ADD R3, R3, R4
BRnp NotEqual
BRz ReturnMain


NotEqual:
AND R5, R5, #0
BRnzp ReturnMain

ReturnMain:
;pop R4
LDR R4, R6, #0
ADD R6, R6, #1
;pop R3
LDR R3, R6, #0
ADD R6, R6, #1
;pop R1
LDR R1, R6, #0
ADD R6, R6, #1
;pop R0
LDR R0, R6, #0
ADD R6, R6, #1
RET

PrintOut:
.STRINGZ "Enter a name: "

NotFound:
.STRINGZ "Not found"

InputData:   
.BLKW 16

NODE0:
.FILL x4000

STACK: 
.FILL xFE00

NUMBER:
.FILL x0

BLANK: 
.STRINGZ " "

ENTER:
.STRINGZ "\n"

.END