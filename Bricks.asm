.model small
.stack 100h

.DATA 

; BRICKS POSITION
brick_width DW 40
brick_height DW 6
brick_initial_x DW 30, 80, 130, 180, 230, 280, 330, 380
brick_initial_y DW 10, 30, 50
  



.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; set the video mode
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    ; draw a pixel - 10 column, - 10 row, color: green
    ; MOV AH, 0CH
    ; MOV CX, 10    ; column
    ; MOV DX, 10    ; row
    ; MOV AL, 48    ; green color
    ; INT 10H 
    MOV SI, offset brick_initial_x
    MOV DI, offset brick_initial_y
    CALL DrawBrick_proc


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
   MOV CX, SI                      ; set the column
   MOV DX, DI                       ; set the row

   draw_brick_horizontal:
   ; draw a pixel - 10 column, - 10 row, color: red
        MOV AH, 0CH
        MOV AL, 48    ; green color
        INT 10H 

        INC CX        ; increment the column

        ; CX - initial_x > brick_width => exit condition
        MOV AX, CX                   ; use AX as auxillary reg
        SUB AX, SI                   ; AX = CX - initial_x
        CMP AX, brick_width          ; compare AX with brick_width 
        JNG draw_brick_horizontal    ; if AX < brick_width, continue the loop

        ; reset the column
        MOV CX, SI    ; set the column to complete the rectangle
        INC DX        ; increment the row

        ; DX - initial_y > brick_height => exit condition
        MOV AX, DX                    ; use AX as auxillary reg
        SUB AX, DI                    ; AX = DX - initial_y
        CMP AX, brick_height          ; compare AX with brick_height
        JNG draw_brick_horizontal     ; if AX < brick_height, continue the loop
RET
DrawBrick_proc ENDP

END MAIN


