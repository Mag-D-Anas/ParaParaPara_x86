.model small
.stack 100h

.DATA 

; BRICKS INFO
brick_width DW 30    ; width of each brick
brick_height DW 6    ; height of each brick
brick_initial_x DW 10, 45, 80, 115, 150, 185, 220, 255   ; brick columns
brick_initial_y DW 15, 31, 47, 63                   ; brick rows
ROW_COUNT EQU 4       ; number of rows
COLUMN_COUNT EQU 8    ; number of columns
brick_colors DB 3, 5, 9, 10
  
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; set the video mode
    MOV AH, 00H
    MOV AL, 13H
    INT 10H

    CALL DrawBricks_proc


    ; terminate the program
    MOV AH, 4CH
    INT 21H

MAIN ENDP

;---------------------------------------
    ; Function: DrawBricks_proc
    ; Purpose: Draws the bricks on the screen
    ; Inputs: brick_initial_x, brick_initial_y => to determine the position of the bricks
    ; Outputs: Updates SI, DI to traverse the grid of bricks.
;---------------------------------------

DrawBricks_proc PROC NEAR

   PUSH BX
   MOV SI, offset brick_initial_x      ; set the column
   MOV DI, offset brick_initial_y      ; set the row
   MOV BX, 0

   draw_bricks:
    MOV AL, brick_colors[BX]           ; set the color of the brick
    CALL DrawBrick_proc                ; draw the brick at (SI,DI)
    ADD SI, 2                          ; draw the next brick horizontally
    CMP SI, offset brick_initial_x + (COLUMN_COUNT * 2)     ; compare the column with the last brick
    JB draw_bricks                     ; if SI < offset brick_initial_x + 8, continue the loop
 
    MOV SI, offset brick_initial_x     ; reset the column
   

    ADD DI, 2                          ; draw the next brick vertically
    CMP DI, offset brick_initial_y + (ROW_COUNT * 2)     ; compare the row with the last brick
    INC BX                             ; increment the color index
    JB draw_bricks                     ; if DI < offset brick_initial_y + 3, continue the loop
    POP BX
RET
DrawBricks_proc ENDP

;---------------------------------------
; Function: DrawBrick_proc
; Purpose: Draws a single brick on the screen.
; Inputs:
;  - SI: Pointer to the initial X position of the brick (column).
;  - DI: Pointer to the initial Y position of the brick (row).
;  - AL: Color of the brick.
; Outputs:
;  - Draws a rectangular block of pixels at the specified position.
;---------------------------------------

DrawBrick_proc PROC NEAR
   PUSH CX 
   PUSH DX
   PUSH BX  
   MOV CX, [SI]                       ; set the column
   MOV DX, [DI]                       ; set the row

   draw_brick_horizontal:
   ; draw a pixel - 10 column, - 10 row, color: red
        MOV AH, 0CH
        INT 10H 

        INC CX                        ; increment the column


        ; CX - initial_x > brick_width => exit condition
        MOV BX, CX                    ; use BX as auxillary reg
        SUB BX, [SI]                  ; BX = CX - initial_x
        CMP BX, brick_width           ; compare BX with brick_width 

 
        JNG draw_brick_horizontal     ; if AX < brick_width, continue the loop

        ; reset the column
        MOV CX, [SI]                  ; set the column to complete the rectangle
        INC DX                        ; increment the row

        ; DX - initial_y > brick_height => exit condition
        MOV BX, DX                    ; use BX as auxillary reg
        SUB BX, [DI]                  ; BX = DX - initial_y
        CMP BX, brick_height          ; compare BX with brick_height
    
        JNG draw_brick_horizontal     ; if AX < brick_height, continue the loop

        POP BX
        POP DX
        POP CX
RET
DrawBrick_proc ENDP

END MAIN


