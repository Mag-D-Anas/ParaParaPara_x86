.model small
.stack 100h

.DATA 

; BRICKS POSITION
BrickWidth DW 30
BrickHeight DW 20 


.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; set the video mode
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    ; draw a pixel - 10 column, - 10 row, color: red
    MOV AH, 0CH
    MOV CX, 10    ; column
    MOV DX, 10    ; row
    MOV AL, 48    ; green color
    INT 10H 

    ; wait for a key press
    MOV AH, 00H
    INT 16H

    ; return to text mode
    MOV AH, 00H
    MOV AL, 03H
    INT 10H

    ; terminate the program
    MOV AH, 4CH
    INT 21H

MAIN ENDP

DrawBrick_proc PROC NEAR
   

RET
DrawBrick_proc ENDP

END MAIN


