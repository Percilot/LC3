                .ORIG x3000

Main:           LD R0, Data
                LDR R1, R0, #-2
                ST R1, LineNumber
                LDR R1, R0, #-1
                ST R1, RowNumber
                LD R6, DataStack
                JSR MemIn
                
                AND R1, R1, #0
                AND R2, R2, #0
                
                ADD R6, R6, #1  ;max
                STR R1, R6, #0
                BRnzp LOOP2

LOOP1:          LD R3, StartLine
                ADD R3, R3, #1
                LD R4, LineNumber
                NOT R4, R4
                ADD R4, R4, #2
                ADD R5, R3, R4
                BRp ExitSearch
                ST R3, StartLine
                AND R3, R3, #0
                ST R3, StartRow

LOOP2:          LD R1, StartLine
                LD R2, StartRow
                JSR MaxLength
                LD R0, Return
                LDR R3, R6, #0
                NOT R3, R3
                ADD R4, R0, R3
                BRn Adjust
                STR R0, R6, #0

Adjust:         LD R3, StartRow
                ADD R3, R3, #1
                LD R4, RowNumber
                NOT R4, R4
                ADD R4, R4, #2
                ADD R5, R3, R4
                BRp LOOP1
                ST R3, StartRow
                BRnzp LOOP2

ExitSearch:     LDR R2, R6, #0
                ADD R6, R6, #-1
                
PrintResult:    ADD R3, R2, #0
                AND R1, R1, #0
PrintLoop:      ADD R1, R1, #1
                ADD R3, R3, #-10
                BRzp PrintLoop
                
                ADD R0, R1, #-1
                BRz Print2nd
Print1st:       ADD R0, R1, #15
                ADD R0, R0, #15
                ADD R0, R0, #15
                ADD R0, R0, #2
                OUT

Print2nd:       ADD R0, R3, #13
                ADD R0, R0, #15
                ADD R0, R0, #15
                ADD R0, R0, #15
                OUT
                HALT

MemIn:          AND R0, R0, #0
                AND R5, R5, #0
                LEA R3, HaveAccessed
InLoop:         STR R0, R3, #0
                ADD R5, R5, #1
                ADD R3, R3, #1
                ADD R4, R5, #-15
                ADD R4, R4, #-15
                ADD R4, R4, #-15
                ADD R4, R4, #-5
                BRn InLoop
                RET

MaxLength:      ADD R6, R6, #1
                STR R7, R6, #0
                ADD R6, R6, #1  ;max
                AND R0, R0, #0
                STR R0, R6, #0
                ADD R6, R6, #1  ;s
    
                ADD R6, R6, #1  ;OldLocation

                JSR OffsetFigure
                STR R0, R6, #0
                LEA R3, HaveAccessed
                ADD R3, R3, R0
                LDR R0, R3, #0
                BRp NormalExit

                ADD R2, R2, #1
                JSR LegitimacyTest
                ADD R0, R0, #0
                BRp Next1
                ADD R6, R6, #2
                STR R1, R6, #-1
                STR R2, R6, #0
                JSR MaxLength
                LDR R2, R6, #0
                LDR R1, R6, #-1
                ADD R6, R6, #-2
                LD R0, Return
                LDR R5, R6, #-2
                NOT R5, R5
                ADD R3, R0, R5
                BRn Next1
                STR R0, R6, #-2

Next1:          ADD R2, R2, #-2
                JSR LegitimacyTest
                ADD R0, R0, #0
                BRp Next2
                ADD R6, R6, #2
                STR R1, R6, #-1
                STR R2, R6, #0
                JSR MaxLength
                LDR R2, R6, #0
                LDR R1, R6, #-1
                ADD R6, R6, #-2
                LD R0, Return
                LDR R5, R6, #-2
                NOT R5, R5
                ADD R3, R0, R5
                BRn Next2
                STR R0, R6, #-2

Next2:          ADD R2, R2, #1
                ADD R1, R1, #1
                JSR LegitimacyTest
                ADD R0, R0, #0
                BRp Next3
                ADD R6, R6, #2
                STR R1, R6, #-1
                STR R2, R6, #0
                JSR MaxLength
                LDR R2, R6, #0
                LDR R1, R6, #-1
                ADD R6, R6, #-2
                LD R0, Return
                LDR R5, R6, #-2
                NOT R5, R5
                ADD R3, R0, R5
                BRn Next3
                STR R0, R6, #-2

Next3:          ADD R1, R1, #-2
                JSR LegitimacyTest
                ADD R0, R0, #0
                BRp Exit
                ADD R6, R6, #2
                STR R1, R6, #-1
                STR R2, R6, #0
                JSR MaxLength
                LDR R2, R6, #0
                LDR R1, R6, #-1
                ADD R6, R6, #-2
                LD R0, Return
                LDR R5, R6, #-2
                NOT R5, R5
                ADD R3, R0, R5
                BRn Exit
                STR R0, R6, #-2


Exit:           LDR R0, R6, #-2
                ADD R0, R0, #1
                LEA R5, HaveAccessed
                LDR R4, R6, #0
                ADD R5, R5, R4
                STR R0, R5, #0
                
NormalExit:     ST R0, Return
                LDR R7, R6, #-3
                ADD R6, R6, #-4
                RET

LegitimacyTest: ADD R6, R6, #1
                STR R7, R6, #0
                
                AND R0, R0, #0
                LD R3, LineNumber
                NOT R3, R3
                ADD R3, R3, #2
                ADD R3, R3, R1
                BRp Illegal
                LD R4, RowNumber
                NOT R4, R4
                ADD R4, R4, #2
                ADD R4, R4, R2
                BRp Illegal
                ADD R1, R1, #0
                BRn Illegal
                ADD R2, R2, #0
                BRn Illegal
                
                LD R5, Data
                LDR R3, R6, #-1
                ADD R4, R5, R3
                LDR R3, R4, #0
                ADD R6, R6, #1
                STR R3, R6, #0
                
                JSR OffsetFigure
                ADD R4, R5, R0
                LDR R4, R4, #0
                LDR R3, R6, #0
                ADD R6, R6, #-1
                
                NOT R4, R4
                ADD R4, R4, #1
                ADD R3, R3, R4
                BRnz Illegal
                AND R0, R0, #0
                LDR R7, R6, #0
                ADD R6, R6, #-1
                RET

Illegal:        LDR R7, R6, #0
                ADD R6, R6, #-1
                AND R0, R0, #0
                ADD R0, R0, #1
                RET

OffsetFigure:   AND R0, R0, #0
                LD R4, RowNumber
                ADD R3, R1, #0
                ADD R6, R6, #1
                STR R7, R6, #0
                JSR MUL
                ADD R0, R0, R2
                LDR R7, R6, #0
                ADD R6, R6, #-1
                RET

MUL:            AND R0, R0, #0
                ADD R3, R3, #0
                BRz MULExit
                MULLoop:
                ADD R0, R0, R4
                ADD R3, R3, #-1
                BRp MULLoop
                MULExit:
                RET

StartLine       .FILL #0
StartRow        .FILL #0
Return          .FILL #0
LineNumber      .BLKW #1
RowNumber       .BLKW #1
Data            .FILL x4002
DataStack       .FILL x5000
HaveAccessed    .BLKW #50
                .END

                .ORIG x5000
StackSpace      .BLKW #1000
                .END