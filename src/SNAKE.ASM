; DIR    : MOVEMENT DIR UP => 00H, RIGHT => 01H, DOWN => 02H, LEFT => 03H, IDLE => 04H
; KEYS   : UP 48H, LEFT 4BH, RIGHT 4DH, DOWN 50H

         .MODEL TINY

         .CODE
         ORG   100H
BEGIN:   JMP   MAIN
         
SNAKE    DW    30 DUP (0000H)
HEAD     DW    ?
TAIL     DW    ?
LEN      DW    ?
DIR      DB    ?
FOOD     DW    ?

CURSOR   DW    0000H
COLOR    DB    00H

MAIN     PROC  NEAR

         MOV   AX, 3H                  ; SET VIDEO MODE
         INT   10H                     ; CLEAR SCREEN

         MOV   CX, 2607H               ; HIDE CURSOR
         MOV   AH, 01H
         INT   10H

         MOV   HEAD, 0000H
         MOV   TAIL, 0000H
         MOV   LEN,  1H
         MOV   DIR,  01H

         MOV   FOOD, 0506H

         MOV   BX, HEAD
         MOV   SNAKE[BX], 0505H

GAME:    CALL  DRAW
         CALL  INPUT
         CALL  CLEAR
         CALL  UPDATE
         CALL  EATFOOD
         CALL  SLEEP
         
         JMP   GAME

MAIN     ENDP

SETCRSR  PROC
         PUSH  BX
         PUSH  DX

         MOV   DX, CURSOR              ; CURSOR POS
         MOV   BH, 00H                 ; PAGE NUMBER
         MOV   AH, 02H                 ; REQUEST SET CURSOR
         INT   10H                     ; BIOS CALL

         POP   DX
         POP   BX
         RET
SETCRSR  ENDP

PRNTCHR  PROC
         PUSH  BX
         PUSH  CX

         MOV   AL, ' '                 ; CHAR TO WRITE
         MOV   BH, 00H                 ; PAGE NUMBER
         MOV   BL, COLOR               ; PRINT COLOR
         MOV   CX, 1H                  ; NUMBER OF TIMES TO PRINT
         MOV   AH, 09H                 ; REQUEST TO PRINT CHAR
         INT   10H

         POP   CX
         POP   BX
         RET
PRNTCHR  ENDP
         

DRAW     PROC

         MOV   BX, TAIL
         MOV   CX, LEN

DLOOP:   MOV   AX, SNAKE[BX]           ; ROW, COL
         MOV   CURSOR, AX              ; CURSOR POS
         CALL  SETCRSR                 ; SET CURSOR
         MOV   COLOR, 10101010B        ; SNAKE COLOR
         CALL  PRNTCHR                 ; PRINT CHAR TO CURSOR POS

         SUB   BX, 2H
         DEC   CX
         JNZ   DLOOP

         MOV   AX, FOOD
         MOV   CURSOR, AX
         CALL  SETCRSR
         MOV   COLOR, 11001100B        ; FOODCOLOR
         CALL  PRNTCHR

         RET

DRAW     ENDP

CLEAR    PROC

         MOV   BX, TAIL
         MOV   AX, SNAKE[BX]
         MOV   CURSOR, AX
         CALL  SETCRSR

         MOV   COLOR, 00H              ; BLANK COLOR
         CALL  PRNTCHR

CLEAR    ENDP


INPUT    PROC

         MOV   AH, 01H                 ; CHECK IF A KEY IS PRESSED
         INT   16H
         JZ    ENDIN                   ; ZERO MEANS NOT PRESSED

         MOV   AH, 00H                 ; GET THE KEY
         INT   16H

         CMP   AH, 48H                 ; CHECK UP ARROW
         JE    DIRU
         CMP   AH, 4DH                 ; CHECK RIGHT ARROW
         JE    DIRR
         CMP   AH, 50H                 ; CHECK DOWN ARROW
         JE    DIRD
         CMP   AH, 4BH                 ; CHECK LEFT ARROW
         JE    DIRL

         CMP   AH, 01H                 ; ESC TO EXIT
         CALL  EXIT

ENDIN:   RET

DIRU:    MOV   DIR, 00H
         RET
DIRR:    MOV   DIR, 01H
         RET
DIRD:    MOV   DIR, 02H
         RET
DIRL:    MOV   DIR, 03H
         RET

INPUT    ENDP

UPDATE   PROC

         MOV   BX, TAIL
         MOV   CX, LEN

         DEC   CX
         JZ    ULOOPE

ULOOP:   MOV   AX, SNAKE[BX - 2]
         MOV   SNAKE[BX], AX
         SUB   BX, 2H
         DEC   CX
         JNZ   ULOOP

ULOOPE:  MOV   BX, HEAD
         CMP   DIR, 00H
         JE    MOVEUP
         CMP   DIR, 01H
         JE    MOVERI
         CMP   DIR, 02H
         JE    MOVEDO
         CMP   DIR, 03H
         JE    MOVELE

         RET

MOVEUP:  SUB   SNAKE[BX], 0100H
         RET
MOVERI:  ADD   SNAKE[BX], 0001H
         RET
MOVEDO:  ADD   SNAKE[BX], 0100H
         RET
MOVELE:  SUB   SNAKE[BX], 0001H
         RET

UPDATE   ENDP

EATFOOD  PROC
         
         MOV   BX, HEAD
         MOV   BX, SNAKE[BX]
         MOV   AX, FOOD
         CMP   AX, BX
         JE    EAT
         RET

EAT:     ADD   TAIL, 2H
         MOV   BX, TAIL
         MOV   AX, FOOD
         MOV   SNAKE[BX], AX
         ADD   LEN, 1H
         CALL  RFOODPOS
         RET

EATFOOD  ENDP

RFOODPOS PROC
         MOV   AH, 00H                 ; GET SYSTEM TIME TO DX
         INT   1AH

         MOV   AX, DX
         XOR   DX, DX
         MOV   CX, 14H                 ; FROM 0 TO 20
         DIV   CX                      ; NOW DX CONTAINS NUMBER

         MOV   BL, DL

         MOV   AH, 00H                 ; GET SYSTEM TIME TO DX
         INT   1AH

         MOV   AX, DX
         XOR   DX, DX
         MOV   CX, 14H                 ; FROM 0 TO 30
         DIV   CX                      ; NOW DX CONTAINS NUMBER

         MOV   BH, DL

         MOV   FOOD, BX
         RET
RFOODPOS ENDP

SLEEP    PROC
         MOV     CX, 0002H             ; CX : HIGH WORD 
         MOV     DX, 49F0H             ; DX : LOW WORD
         MOV     AH, 86H               ; DELAY
         INT     15H

         RET
SLEEP    ENDP


EXIT     PROC
         MOV   AX, 3H
         INT   10H                     ; CLEAR SCREEN

         MOV   AH, 4CH 
         INT   21H
EXIT     ENDP

         END   BEGIN