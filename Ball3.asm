; AUTHOR: Anas Magdy
; DATE: 5 Dec 2024
; BALL logic procedure, with handling the collisions of the walls

;extrn DrawBricks_proc_single:FAR
public MOVE_BALL_single
public CLEAR_BALL_single
public DRAW_BALL_single
public UPDATE_POSITION_single
public INIT_BALL_single

; extrn to bricks
public BALL_X_single
public BALL_Y_single
public BALL_SIZE_single
public BALL_VELOCITY_X_single
public BALL_VELOCITY_Y_single

; import paddle parameters
extrn paddleX_single:WORD
extrn paddleY_single:WORD
extrn paddleWidth_single:WORD
extrn paddleHeight_single:WORD

.model small
.stack 100h

.data
            WINDOW_WIDTH    DW      320     ; 320 pixels
            WINDOW_HEIGHT   DW      200     ; 200 pixels
            WINDOW_BOUNDS   DW      4       ; pre check the walls
            PREV_MS         DB      0       ; neede for fps movements
            BALL_X_single          DW      160     ; X position of the ball
            BALL_Y_single          DW      100     ; Y position of the ball
            BALL_SIZE_single       DW      7     ; Size of the ball (pixels width and height)
            BALL_VELOCITY_X_single DW      -5      ; velocity of incrementing the ball starting position
            BALL_VELOCITY_Y_single DW      4      ; positive -> go down // negative -> go up

.code

    INIT_BALL_single PROC FAR
            MOV      AX, @DATA
            MOV      DS, AX
            RET
    INIT_BALL_single ENDP

    UPDATE_POSITION_single PROC FAR
        MOV      AX, BALL_VELOCITY_X_single    ; edited X - Vep/+locity
        ADD      BALL_X_single, AX             ; move the initial X - position of the ball 
        MOV      AX, BALL_VELOCITY_Y_single    ; edited Y - Velocity
        ADD      BALL_Y_single, AX             ; move the initial Y - position of the ball
        RET
    UPDATE_POSITION_single ENDP

 

    MOVE_BALL_single PROC FAR    
            ; Left Wall
            MOV      BX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_X_single, BX             ; comparing the curr X - position with the first column of the window
            JB       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity

            ; Right Wall
            MOV      AX, WINDOW_WIDTH       ; AX holds the last column of the window
            SUB      AX, BALL_SIZE_single          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            SUB      AX, WINDOW_BOUNDS      ; one not enough ( I do not know why, but it works XD)
            CMP      BALL_X_single, AX             ; comparing the curr X - position with the last column of the window
            JA       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity
        
            ; Ceil
            MOV      BX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y_single, BX             ; comparing the curr Y - position with the first row of the window
            JB       NEG_VELOCITY_Y         ; isHitted? change the direction of Y - velocity

            ; Floor
            MOV      AX, WINDOW_HEIGHT      ; AX holds the last Row of the window
            SUB      AX, BALL_SIZE_single          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y_single, AX             ; comparing the curr X - position with the last Row of the window
            JA       EXIT                   ; isHitted? You lose

            ; Amr
            ; Paddle
            ; Check if the ball's x is less than the paddle's x + width
            MOV      AX, paddleX_single            ; AX holds the start of the paddle
            MOV      BX, paddleWidth_single 
            ADD      BX, AX                 ; BX holds the end of the paddle
            CMP      BALL_X_single, BX             ; comparing the curr X - position with the end of the paddle
            JB      CMP_PADDLE_START       ; within range? check the start of the paddle
            JE     CHECK_PADDLE_WALLS         ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions
            
            CMP_PADDLE_START: ; we know that x <= paddleX_single + paddleWidth_single
            MOV      BX, BALL_X_single
            ADD      BX, BALL_SIZE_single
            CMP      BX, AX             ; comparing the curr X - position with the start of the paddle
            JA      CMP_PADDLE_Y           ; within range? check the Y - position of the paddle
            JE      CHECK_PADDLE_WALLS         ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions
            
            CMP_PADDLE_Y: ; we know that x <= paddleX_single + paddleWidth_single and x + BallWidth => paddleX_single
            MOV      AX, paddleY_single            ; AX holds the start of the paddle
            SUB      AX, BALL_SIZE_single          ; needed to check AX with the start of the ball and without it the ball go out of bound
            CMP      BALL_Y_single, AX             ; comparing the curr Y - position with the start of the paddle
            JAE       NEG_VELOCITY_Y         ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions

            CHECK_PADDLE_WALLS:
            MOV      AX, paddleY_single            ; AX holds the start of the paddle
            SUB      AX, BALL_SIZE_single          ; needed to check AX with the start of the ball and without it the ball go out of bound
            CMP      BALL_Y_single, AX             ; comparing the curr Y - position with the start of the paddle
            JA       NEG_VELOCITY_X
            JMP      NEXT_CHECK
            
            NEG_VELOCITY_X:
            NEG      BALL_VELOCITY_X_single        ; positive -> go right // negative -> go left
            RET

            NEG_VELOCITY_Y:
            NEG      BALL_VELOCITY_Y_single        ; positive -> go down // negative -> go up
            RET

            NEXT_CHECK:
            RET


        EXIT:
            CALL     CLEAR_BALL_single             ; Clear the loser ball
            MOV      BALL_VELOCITY_X_single, -5    ; Reset X - velocity ( dump value )
            MOV      BALL_VELOCITY_Y_single, 4   ; Reset Y - velocity ( dump value )
            MOV      BALL_X_single, 160            ; Reset X - position ( dump value )
            MOV      BALL_Y_single, 100            ; Reset Y - position ( dump value )
            RET

    MOVE_BALL_single ENDP



    DRAW_BALL_single PROC FAR

            MOV      CX, BALL_X_single            ; X - initial position
            MOV      DX, BALL_Y_single            ; Y - initial position

        DRAW_COLUMN:
            MOV      AH, 0Ch               ; {
            MOV      AL, 0Fh               ;     Drawing pixel (white)
            MOV      BH, 00h               ;      At (x = CX, y = DX) position
            INT      10h                   ; }

            INC      DX                    ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y_single            ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE_single         ;    at the last row
            CMP      DX, AX                ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      DRAW_COLUMN           ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN1:                      ; if we did, then
            INC      CX                    ; increment our current column
            MOV      DX, BALL_Y_single            ; reset our current row
            MOV      AX, BALL_X_single            ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE_single         ;    at the last column
            CMP      CX, AX                ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      DRAW_COLUMN           ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    DRAW_BALL_single ENDP

     CLEAR_BALL_single PROC FAR
            ; Initial positions
            MOV      CX, BALL_X_single           ; X - initial position
            MOV      DX, BALL_Y_single           ; Y - initial position

        CLEAR_COLUMN:
            MOV      AH, 0Ch              ; {
            MOV      AL, 00h              ;     Clearing pixel (black)
            MOV      BH, 00h              ;      At (x = CX, y = DX) position
            INT      10h                  ; }

            INC      DX                   ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y_single           ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE_single        ;    at the last row
            CMP      DX, AX               ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      CLEAR_COLUMN         ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN2:                     ; if we did, then
            INC      CX                   ; increment our current column
            MOV      DX, BALL_Y_single           ; reset our current row
            MOV      AX, BALL_X_single           ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE_single        ;    at the last column
            CMP      CX, AX               ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      CLEAR_COLUMN         ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    CLEAR_BALL_single ENDP
    


end INIT_BALL_single
