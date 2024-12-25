; AUTHOR: Anas Magdy
; DATE: 5 Dec 2024
; BALL logic procedure, with handling the collisions of the walls

;extrn DrawBricks_proc:FAR
public CLEAR_BALL_REC
public DRAW_BALL_REC
public INIT_BALL_REC
public MOVE_BALL2
public UPDATE_POSITION2

public second_player_lives

; extrn to bricks
public BALL_X_REC
public BALL_Y_REC
public BALL_SIZE_REC
public BALL_VELOCITY_X2
public BALL_VELOCITY_Y2

; import paddle parameters
extrn paddleX2:WORD
extrn paddleY2:WORD
extrn paddleWidth2:WORD
extrn paddleHeight2:WORD

.model small
.stack 100h

.data
            WINDOW_WIDTH    DW      319     ; 320 pixels
            LEFT_WALL       DW      165      ; left wall
            WINDOW_HEIGHT   DW      200     ; 200 pixels
            WINDOW_BOUNDS   DW      0       ; pre check the walls
            BALL_X_REC          DW      231     ; X position of the ball
            BALL_Y_REC          DW      100     ; Y position of the ball
            BALL_SIZE_REC       DW      5     ; Size of the ball (pixels width and height)
            BALL_VELOCITY_X2 DW      -5      ; velocity of incrementing the ball starting position
            BALL_VELOCITY_Y2 DW      4      ; positive -> go down // negative -> go up
            CEIL            DW      15     ; top wall

            ; LIVES INFO
            LIVES_LABEL         DB      'LIVES: ', '$'
            second_player_lives  DB      20      ; number of lives for player 1
            LIVES_STRING        DB      '3', '$'


.code

    INIT_BALL_REC PROC FAR
            MOV      AX, @DATA
            MOV      DS, AX

            CALL DISPLAY_LIVES
            RET
    INIT_BALL_REC ENDP

    UPDATE_POSITION2 PROC FAR
        MOV      AX, BALL_VELOCITY_X2    ; edited X - Vep/+locity
        ADD      BALL_X_REC, AX             ; move the initial X - position of the ball 
        MOV      AX, BALL_VELOCITY_Y2    ; edited Y - Velocity
        ADD      BALL_Y_REC, AX             ; move the initial Y - position of the ball
        RET
    UPDATE_POSITION2 ENDP

 
CLEAR_BALL_REC PROC FAR
            ; Initial positions
            MOV      CX, BALL_X_REC           ; X - initial position
            MOV      DX, BALL_Y_REC           ; Y - initial position

        CLEAR_COLUMN_REC:
            MOV      AH, 0Ch              ; {
            MOV      AL, 00h              ;     Clearing pixel (black)
            MOV      BH, 00h              ;      At (x = CX, y = DX) position
            INT      10h                  ; }

            INC      DX                   ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y_REC           ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE_REC        ;    at the last row
            CMP      DX, AX               ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      CLEAR_COLUMN_REC         ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN2_REC:                     ; if we did, then
            INC      CX                   ; increment our current column
            MOV      DX, BALL_Y_REC           ; reset our current row
            MOV      AX, BALL_X_REC           ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE_REC        ;    at the last column
            CMP      CX, AX               ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      CLEAR_COLUMN_REC         ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    CLEAR_BALL_REC ENDP


    MOVE_BALL2 PROC FAR    
            ; Left Wall
            MOV      BX, LEFT_WALL      ; pre checking the ball collision with safety space
            CMP      BALL_X_REC, BX             ; comparing the curr X - position with the first column of the window
            JB       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity

            ; Right Wall
            MOV      AX, WINDOW_WIDTH       ; AX holds the last column of the window
            SUB      AX, BALL_SIZE_REC          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            SUB      AX, WINDOW_BOUNDS      ; one not enough ( I do not know why, but it works XD)
            CMP      BALL_X_REC, AX             ; comparing the curr X - position with the last column of the window
            JA       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity
        
            ; Ceil
            MOV      BX, CEIL      ; pre checking the ball collision with safety space
            CMP      BALL_Y_REC, BX             ; comparing the curr Y - position with the first row of the window
            JB       NEG_VELOCITY_Y         ; isHitted? change the direction of Y - velocity

            ; Floor
            MOV      AX, WINDOW_HEIGHT      ; AX holds the last Row of the window
            SUB      AX, BALL_SIZE_REC          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y_REC, AX             ; comparing the curr X - position with the last Row of the window
            JA       EXIT                   ; isHitted? You lose

            ; Amr
            ; Paddle
            ; Check if the ball's x is less than the paddle's x + width
            MOV      AX, paddleX2            ; AX holds the start of the paddle
            MOV      BX, paddleWidth2 
            ADD      BX, AX                 ; BX holds the end of the paddle
            CMP      BALL_X_REC, BX             ; comparing the curr X - position with the end of the paddle
            JB      CMP_PADDLE_START       ; within range? check the start of the paddle
             ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions
            
            CMP_PADDLE_START: ; we know that x <= paddleX2 + paddleWidth
            MOV      BX, BALL_X_REC
            ADD      BX, BALL_SIZE_REC
            CMP      BX, AX             ; comparing the curr X - position with the start of the paddle
            JA      CMP_PADDLE_Y           ; within range? check the Y - position of the paddle
          
            JMP NEXT_CHECK              ; continue checking other collisions
            
            CMP_PADDLE_Y: ; we know that x <= paddleX2 + paddleWidth and x + BallWidth => paddleX2
            MOV      AX, paddleY2            ; AX holds the start of the paddle
            SUB      AX, BALL_SIZE_REC          ; needed to check AX with the start of the ball and without it the ball go out of bound
            CMP      BALL_Y_REC, AX             ; comparing the curr Y - position with the start of the paddle
            JAE       NEG_VELOCITY_Y         ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions

           
            
            NEG_VELOCITY_X:
            NEG      BALL_VELOCITY_X2        ; positive -> go right // negative -> go left
            RET

            NEG_VELOCITY_Y:
            NEG      BALL_VELOCITY_Y2        ; positive -> go down // negative -> go up
            RET

            NEXT_CHECK:
            RET


       
        EXIT:
            DEC second_player_lives
            CALL DISPLAY_LIVES           ; Display the remaining lives
            CMP second_player_lives, 0
            JNE RESET_BALL               ; if the player still has lives, reset the ball

        RESET_BALL:

            CALL     CLEAR_BALL_REC             ; Clear the loser ball
            MOV      BALL_VELOCITY_X2, -5    ; Reset X - velocity ( dump value )
            MOV      BALL_VELOCITY_Y2, 4   ; Reset Y - velocity ( dump value )
            MOV      BALL_X_REC, 231            ; Reset X - position ( dump value )
            MOV      BALL_Y_REC, 100            ; Reset Y - position ( dump value )
            RET

    MOVE_BALL2 ENDP



    DRAW_BALL_REC PROC FAR
    
            ; MOV      AX, BALL_X_REC
            ; MOV      BALL_X_REC, AX
            ;MOV      AX, BALL_Y_REC
            ;MOV      BALL_Y_REC, AX

            MOV      CX, BALL_X_REC            ; X - initial position
            ;ADD      CX, SHIFT_REC
            ;MOV      BALL_X_REC, CX
            MOV      DX, BALL_Y_REC            ; Y - initial position

        DRAW_COLUMN_REC:
            MOV      AH, 0Ch               ; {
            MOV      AL, 0Fh               ;     Drawing pixel (white)
            MOV      BH, 00h               ;      At (x = CX, y = DX) position
            INT      10h                   ; }

            INC      DX                    ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y_REC            ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE_REC         ;    at the last row
            CMP      DX, AX                ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      DRAW_COLUMN_REC           ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN1_REC:                      ; if we did, then
            INC      CX                    ; increment our current column
            MOV      DX, BALL_Y_REC            ; reset our current row
            MOV      AX, BALL_X_REC            ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE_REC         ;    at the last column
            CMP      CX, AX                ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      DRAW_COLUMN_REC           ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    DRAW_BALL_REC ENDP

     DISPLAY_LIVES PROC NEAR
        PUSH AX
        PUSH BX
        PUSH DX
        PUSH DI
        ; print the "LIVES" label
        MOV AH, 02H               ; Set cursor position
        MOV BH, 00H               ; Page number
        MOV DH, 00H               ; Row
        MOV DL, 60                ; Column
        INT 10H

        MOV AH, 09H
        LEA DX, LIVES_LABEL
        INT 21H

        MOV AL, second_player_lives
        ADD AL, 30H
        MOV [LIVES_STRING], AL

        MOV AH, 09H 
        LEA DX, LIVES_STRING
        INT 21H

        POP DI
        POP DX
        POP BX
        POP AX
        RET 
    DISPLAY_LIVES ENDP                                        

    


end INIT_BALL_REC
