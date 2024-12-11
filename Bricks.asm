public DrawBricks_proc
; extrn BALL_X:DW
; extrn BALL_Y:DW
; extrn BALL_SIZE:DW

.model small
.stack 100h

.DATA 

; BRICKS INFO
brick_width DW 30    ; width of each brick
brick_height DW 6    ; height of each brick
brick_initial_x DW 10, 45, 80, 115, 150, 185, 220, 255   ; brick columns
brick_initial_y DW 15, 31, 47, 63                   ; brick rowsck
brick_colors DB 3, 5, 9, 10
ROW_COUNT EQU 4       ; number of rows
COLUMN_COUNT EQU 8    ; number of columns

state_of_bricks_row DB ROW_COUNT DUP(0)      ; 0 - brick is not hit, 1 - brick is hit
state_of_bricks_col DB COLUMN_COUNT DUP(0)   ; 0 - brick is not hit, 1 - brick is hit
  
.CODE

;---------------------------------------
    ; Function: DrawBricks_proc
    ; Purpose: Draws the bricks on the screen
    ; Inputs: brick_initial_x, brick_initial_y => to determine the position of the bricks
    ; Outputs: Updates SI, DI to traverse the grid of bricks.
;---------------------------------------

DrawBricks_proc PROC FAR
   MOV AX, @DATA
   MOV DS, AX
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

;---------------------------------------
; Function: CheckCollision_proc
; Purpose: Checks if the ball has collided with any of the bricks.
; Inputs:
;  - CL and CH: Row and column counters for the bricks.
;  - DX and BX: Initial Y and X positions of the bricks.
;  - AX: Ball position and size.
; Outputs:
;  - Updates the state_of_bricks_row and state_of_bricks_col arrays.
; - Calls DestroyBrick_proc if a collision is detected.
;---------------------------------------

CheckCollision PROC FAR
    PUSH BX
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CL, 0                             ; row count   
    MOV CH, 0                           ; column count                       

    row_loop:
        MOV DX, brick_initial_y[CL]        ; set the row  

        ; check collision with the brick => y axis
        ; check top edge
            MOV AX, BALL_Y 
            ADD AX, BALL_SIZE           ; calculate the bottom edge of the ball
            CMP AX, DX                  ; compare with the top edge of the brick => if DX = AX bounce up
            JNG next_row                ; if the ball is above the brick, skip to the next brick

        ; check bottom edge
            ADD DX, brick_height        ; calculate the bottom edge of the brick
            SUB AX, BALL_SIZE           ; calculate the top edge of the ball
            CMP AX, DX                  ; compare with the bottom edge of the brick
            JG next_row                 ; if the ball is below the brick, skip to the next brick

        column_loop:
            MOV BX, brick_initial_x[CH]    ; set the column
            
            ; check collision with the brick => x axis 
            ; check left edge
                MOV AX, BALL_X 
                ADD AX, BALL_SIZE           ; calculate the right edge of the ball
                CMP AX, BX                  ; compare with the left edge of the brick => if BX = AX bounce left
                JNG next_column              ; if the ball is to the left of the brick, skip to the next brick

            ; check right edge
                ADDBX, brick_width          ; calculate the right edge of the brick
                SUB AX, BALL_SIZE           ; calculate the left edge of the ball
                CMP AX, BX                  ; compare with the right edge of the brick
                JG next_column               ; if the ball is to the right of the brick, skip to the next brick

            ; if we reach this point, the ball has collided with the brick
            ; set the state of the brick to 1
            MOV state_of_bricks_row[CL], 1
            MOV state_of_bricks_col[CH], 1
            ; CALL DestroyBrick_proc


            next_column:
                INC CH                      ; increment the column
                CMP CH, COLUMN_COUNT        ; compare the column with the last brick
                JE next_row                 ; if CH = 7, go to the next row

            next_row:
                INC CL                      ; increment the row
                CMP CL, ROW_COUNT           ; compare the row with the last brick
                JE exit_collision           ; if CL = 3, exit the loop
                MOV CH, 0                   ; reset the column
                JMP row_loop                ; go to the next row
    exit_collision:
        POP DX
        POP CX
        POP AX
        POP BX


              



   

            

                









    



    POP BX
RET
CheckCollision ENDP

END DrawBricks_proc


