.model small
.stack 100h

.DATA 

; BRICKS POSITION
brick_width DW 40    ; width of each brick
brick_height DW 6    ; height of each brick
brick_initial_x DW 10, 60, 110, 160, 210, 260   ; brick columns
brick_initial_y DW 20, 46, 72    ; brick rows
  



.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; set the video mode
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    CALL DrawBricks_proc


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

DrawBricks_proc PROC NEAR
   MOV SI, offset brick_initial_x    ; set the column
   MOV DI, offset brick_initial_y    ; set the row

   draw_bricks:
    CALL DrawBrick_proc                ; draw the brick at (SI,DI)
    ADD SI, 2                          ; draw the next brick horizontally
    CMP SI, offset brick_initial_x + 12 ; compare the column with the last brick
    JB draw_bricks                    ; if SI < offset brick_initial_x + 8, continue the loop

    MOV SI, offset brick_initial_x     ; reset the column

    ADD DI, 2                          ; draw the next brick vertically
    CMP DI, offset brick_initial_y + 6 ; compare the row with the last brick
    JB draw_bricks                    ; if DI < offset brick_initial_y + 3, continue the loop

RET
DrawBricks_proc ENDP


DrawBrick_proc PROC NEAR
   PUSH CX 
   PUSH DX
   PUSH AX  
   MOV CX, [SI]                       ; set the column
   MOV DX, [DI]                       ; set the row

   draw_brick_horizontal:
   ; draw a pixel - 10 column, - 10 row, color: red
        MOV AH, 0CH
        MOV AL, 48    ; green color
        INT 10H 

        INC CX        ; increment the column

        ; CX - initial_x > brick_width => exit condition
        MOV AX, CX                   ; use AX as auxillary reg
        SUB AX, [SI]                   ; AX = CX - initial_x
        CMP AX, brick_width          ; compare AX with brick_width 
        JNG draw_brick_horizontal    ; if AX < brick_width, continue the loop

        ; reset the column
        MOV CX, [SI]                    ; set the column to complete the rectangle
        INC DX                        ; increment the row

        ; DX - initial_y > brick_height => exit condition
        MOV AX, DX                    ; use AX as auxillary reg
        SUB AX, [DI]                    ; AX = DX - initial_y
        CMP AX, brick_height          ; compare AX with brick_height
        JNG draw_brick_horizontal     ; if AX < brick_height, continue the loop

        POP AX
        POP DX
        POP CX
RET
DrawBrick_proc ENDP

END MAIN


