public DrawBricks_proc2
public CheckCollision_proc2


.model small
.stack 100h

.data

; BRICKS INFO
brick_width DW 18    ; width of each brick
brick_height DW 6    ; height of each brick
brick_initial_x DW 161, 181, 201, 221, 241, 261, 281, 301   ; brick columns
brick_initial_y DW 15, 31, 47, 63                   ; brick rowsck
brick_colors DB 3, 5, 9, 10
ROW_COUNT EQU 4       ; number of rows
COLUMN_COUNT EQU 8    ; number of columns

; state_of_bricks_row DB ROW_COUNT DUP(0)      ; 0 - brick is not hit, 1 - brick is hit
; state_of_bricks_col DB COLUMN_COUNT DUP(0)   ; 0 - brick is not hit, 1 - brick is hit
state_of_bricks DB ROW_COUNT * COLUMN_COUNT DUP(0)

extrn BALL_X_REC:word
extrn BALL_Y_REC:word
extrn BALL_SIZE_REC:word
extrn BALL_VELOCITY_X2:word
extrn BALL_VELOCITY_Y2:word
  
.CODE

;---------------------------------------
    ; Function: DrawBricks_proc2
    ; Purpose: Draws the bricks on the screen
    ; Inputs: brick_initial_x, brick_initial_y => to determine the position of the bricks
    ; Outputs: Updates SI, DI to traverse the grid of bricks.
;---------------------------------------

DrawBricks_proc2 PROC FAR
   MOV AX, @DATA
   MOV DS, AX
   PUSH BX
   MOV SI, offset brick_initial_x      ; set the column
   MOV DI, offset brick_initial_y      ; set the row
   MOV BX, 0

   draw_bricks:
    MOV AL, brick_colors[BX]           ; set the color of the brick
    CALL DrawBrick_proc2                ; draw the brick at (SI,DI)
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
DrawBricks_proc2 ENDP

;---------------------------------------
; Function: DrawBrick_proc2
; Purpose: Draws a single brick on the screen.
; Inputs:
;  - SI: Pointer to the initial X position of the brick (column).
;  - DI: Pointer to the initial Y position of the brick (row).
;  - AL: Color of the brick.
; Outputs:
;  - Draws a rectangular block of pixels at the specified position.
;---------------------------------------

DrawBrick_proc2 PROC NEAR
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
DrawBrick_proc2 ENDP

;---------------------------------------
; Function: CheckCollision_proc2
; Purpose: Checks if the ball has collided with any of the bricks.
; Inputs:
;  - CL and CH: Row and column counters for the bricks.
;  - DX and BX: Initial Y and X positions of the bricks.
;  - AX: Ball position and size.
; Outputs:
;  - Updates the state_of_bricks_row and state_of_bricks_col arrays.
; - Calls DestroyBrick_proc2 if a collision is detected.
;---------------------------------------

CheckCollision_proc2 PROC FAR
    PUSH BX
    PUSH AX
    PUSH CX
    PUSH DX

    MOV CL, 0                             ; row count   
    MOV CH, 0                             ; column count 
    MOV SI, offset brick_initial_x        ; set the column
    MOV DI, offset brick_initial_y        ; set the row                      

    row_loop:
        MOV DX, [DI]        ; set the row  

        ; check collision with the brick => y axis
        ; check top edge
            MOV AX, BALL_Y_REC 
            ADD AX, BALL_SIZE_REC           ; calculate the bottom edge of the ball
            CMP AX, DX                  ; compare with the top edge of the brick => if DX = AX bounce up
            JE bounce_up_down
            JNG next_row                ; if the ball is above the brick, skip to the next brick


        ; check bottom edge
            ADD DX, brick_height        ; calculate the bottom edge of the brick
            SUB AX, BALL_SIZE_REC
            CMP AX, DX                  ; compare with the bottom edge of the brick
            JE bounce_up_down           ; if DX = AX bounce down
            JG next_row                 ; if the ball is below the brick, skip to the next brick

        
        column_loop:
            MOV BX, [SI]                ; set the column
            
            ; check collision with the brick => x axis 
            ; check left edge
                MOV AX, BALL_X_REC 
                ADD AX, BALL_SIZE_REC           ; calculate the right edge of the ball
                CMP AX, BX                  ; compare with the left edge of the brick => if BX = AX bounce left
                JE bounce_left_right
                JNG next_column             ; if the ball is to the left of the brick, skip to the next brick

            ; check right edge
                ADD BX, brick_width         ; calculate the right edge of the brick
                SUB AX, BALL_SIZE_REC
                CMP AX, BX                  ; compare with the right edge of the brick
                JE bounce_left_right        ; if BX = AX bounce right
                JG next_column              ; if the ball is to the right of the brick, skip to the next brick

            ; if we reach this point, the ball has collided with the brick
            ; check if the state index of this brick has already collided: continue
            ; else set the state of the brick to 1 and destroy the brick
            bounce_up_down:
                MOV AL, CL
                MOV BL, COLUMN_COUNT
                MUL BL
                ADD AL, CH
                MOV BL, AL           ; index of the brick in the state array
                MOV BH, 0
                CMP state_of_bricks[BX], 1   ; check if the brick is already hit
                JE next_column               ; if hit with a black brick, continue   
                NEG BALL_VELOCITY_Y2
                JMP destroy                  ; destroy the brick 

            bounce_left_right:
                MOV AL, CL
                MOV BL, COLUMN_COUNT
                MUL BL
                ADD AL, CH
                MOV BL, AL    ; index of the brick in the state array
                MOV BH, 0
                CMP state_of_bricks[BX], 1
                JE next_column
                NEG BALL_VELOCITY_X2
                JMP destroy

        ; set the state of the brick to 1 and destroy the brick
         destroy:
            MOV state_of_bricks[BX], 1
            CALL DestroyBrick_proc2
            jmp exit_collision

            next_column:
                INC CH                      ; increment the column
                CMP CH, COLUMN_COUNT        ; compare the column with the last brick
                JGE next_row                 ; if CH = 7, go to the next row
                ADD SI, 2                   ; move to the next column
                JMP column_loop             ; go to the next column

            next_row:
                INC CL                      ; increment the row
                CMP CL, ROW_COUNT           ; compare the row with the last brick
                JGE exit_collision           ; if CL = 3, exit the loop
                MOV CH, 0                   ; reset the column
                ADD DI, 2                   ; move to the next row
                JMP row_loop                ; go to the next row

    exit_collision:
        POP DX
        POP CX
        POP AX
        POP BX
RET
CheckCollision_proc2 ENDP


DestroyBrick_proc2 PROC NEAR
    PUSH AX
    ; set the color of the brick to black
    ; draw the brick at the same position
    MOV AL, 0
    CALL DrawBrick_proc2

    POP AX
RET
DestroyBrick_proc2 ENDP
              





END DrawBricks_proc2


