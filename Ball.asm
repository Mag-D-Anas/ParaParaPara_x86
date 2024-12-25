; AUTHOR: Anas Magdy
; DATE: 5 Dec 2024
; BALL logic procedure, with handling the collisions of the walls

;extrn DrawBricks_proc:FAR
public MOVE_BALL
public CLEAR_BALL
public DRAW_BALL
public UPDATE_POSITION
public INIT_BALL
public ResetBall

; extrn to bricks
public BALL_X
public BALL_Y
public BALL_SIZE
public BALL_VELOCITY_X
public BALL_VELOCITY_Y

public first_player_lives

; import paddle parameters
extrn paddleX:WORD
extrn paddleY:WORD
extrn paddleWidth:WORD
extrn paddleHeight:WORD

.model medium
.stack 100h

.data
            WINDOW_WIDTH    DW      158     ; 320 pixels
            LEFT_WALL      DW       4      ; left wall
            WINDOW_HEIGHT   DW      200     ; 200 pixels
            WINDOW_BOUNDS   DW      0      ; pre check the walls
            CEIL       DW      15      ; top wall
            BALL_X          DW      70     ; X position of the ball
            BALL_Y          DW      100     ; Y position of the ball
            BALL_SIZE       DW      5     ; Size of the ball (pixels width and height)
            BALL_VELOCITY_X DW      -5      ; velocity of incrementing the ball starting position
            BALL_VELOCITY_Y DW      4      ; positive -> go down // negative -> go up

            ; LIVES INFO
            LIVES_LABEL         DB      'LIVES: ', '$'
            first_player_lives  DB      10     ; number of lives for player 1
            LIVES_STRING        DB      '3', '$'
.code

    INIT_BALL PROC FAR
            MOV      AX, @DATA
            MOV      DS, AX

            CALL DISPLAY_LIVES
            RET
    INIT_BALL ENDP

    UPDATE_POSITION PROC FAR
        MOV      AX, BALL_VELOCITY_X    ; edited X - Vep/+locity
        ADD      BALL_X, AX             ; move the initial X - position of the ball 
        MOV      AX, BALL_VELOCITY_Y    ; edited Y - Velocity
        ADD      BALL_Y, AX             ; move the initial Y - position of the ball
        RET
    UPDATE_POSITION ENDP

 

CLEAR_BALL PROC FAR
            ; Initial positions
            MOV      CX, BALL_X           ; X - initial position
            MOV      DX, BALL_Y           ; Y - initial position

        CLEAR_COLUMN:
            MOV      AH, 0Ch              ; {
            MOV      AL, 00h              ;     Clearing pixel (black)
            MOV      BH, 00h              ;      At (x = CX, y = DX) position
            INT      10h                  ; }

            INC      DX                   ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y           ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE        ;    at the last row
            CMP      DX, AX               ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      CLEAR_COLUMN         ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN2:                     ; if we did, then
            INC      CX                   ; increment our current column
            MOV      DX, BALL_Y           ; reset our current row
            MOV      AX, BALL_X           ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE        ;    at the last column
            CMP      CX, AX               ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      CLEAR_COLUMN         ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    CLEAR_BALL ENDP




    MOVE_BALL PROC FAR    
            ; Left Wall
            MOV      BX,LEFT_WALL     ; pre checking the ball collision with safety space
            CMP      BALL_X, BX             ; comparing the curr X - position with the first column of the window
            JB       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity

            ; Right Wall
            MOV      AX, WINDOW_WIDTH       ; AX holds the last column of the window
            SUB      AX, BALL_SIZE          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            SUB      AX, WINDOW_BOUNDS      ; one not enough ( I do not know why, but it works XD)
            CMP      BALL_X, AX             ; comparing the curr X - position with the last column of the window
            JA       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity
        
            ; Ceil
            MOV      BX, CEIL      ; pre checking the ball collision with safety space
            CMP      BALL_Y, BX             ; comparing the curr Y - position with the first row of the window
            JB       NEG_VELOCITY_Y         ; isHitted? change the direction of Y - velocity

            ; Floor
            MOV      AX, WINDOW_HEIGHT      ; AX holds the last Row of the window
            SUB      AX, BALL_SIZE          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y, AX             ; comparing the curr X - position with the last Row of the window
            JA       EXIT                   ; isHitted? You lose

            ; Amr
            ; Paddle
            ; Check if the ball's x is less than the paddle's x + width
            MOV      AX, paddleX            ; AX holds the start of the paddle
            MOV      BX, paddleWidth 
            ADD      BX, AX                 ; BX holds the end of the paddle
            CMP      BALL_X, BX             ; comparing the curr X - position with the end of the paddle
            JB      CMP_PADDLE_START       ; within range? check the start of the paddle
             ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions

            CMP_PADDLE_START: ; we know that x <= paddleX + paddleWidth
            MOV      BX, BALL_X
            ADD      BX, BALL_SIZE
            CMP      BX, AX             ; comparing the curr X - position with the start of the paddle
            JA      CMP_PADDLE_Y           ; within range? check the Y - position of the paddle
             ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions

            CMP_PADDLE_Y: ; we know that x <= paddleX + paddleWidth and x + BallWidth => paddleX
            MOV      AX, paddleY            ; AX holds the start of the paddle
            SUB      AX, BALL_SIZE          ; needed to check AX with the start of the ball and without it the ball go out of bound
            CMP      BALL_Y, AX             ; comparing the curr Y - position with the start of the paddle
            JAE       NEG_VELOCITY_Y         ; bounce back
            JMP NEXT_CHECK              ; continue checking other collisions

            

            NEG_VELOCITY_X:
            NEG      BALL_VELOCITY_X        ; positive -> go right // negative -> go left
            RET

            NEG_VELOCITY_Y:
            NEG      BALL_VELOCITY_Y        ; positive -> go down // negative -> go up
            RET

            NEXT_CHECK:
            RET



          EXIT:
            DEC      first_player_lives
            CALL     DISPLAY_LIVES          ; Display the remaining lives 
            CMP      first_player_lives, 0
            JNE      RESET_BALL             ; If the player still has lives, then reset the ball

        RESET_BALL:
            CALL     CLEAR_BALL             ; Clear the loser ball
            MOV      BALL_VELOCITY_X, -5    ; Reset X - velocity ( dump value )
            MOV      BALL_VELOCITY_Y, 4   ; Reset Y - velocity ( dump value )
            MOV      BALL_X, 70            ; Reset X - position ( dump value )
            MOV      BALL_Y, 100            ; Reset Y - position ( dump value )
            RET

    MOVE_BALL ENDP



    DRAW_BALL PROC FAR

            MOV      CX, BALL_X            ; X - initial position
            MOV      DX, BALL_Y            ; Y - initial position

        DRAW_COLUMN:
            MOV      AH, 0Ch               ; {
            MOV      AL, 0Fh               ;     Drawing pixel (white)
            MOV      BH, 00h               ;      At (x = CX, y = DX) position
            INT      10h                   ; }

            INC      DX                    ; Counter for each row pixel (start of Y-index of the row till its size)     
            MOV      AX, BALL_Y            ; Calculating Y-index of the pixel
            ADD      AX, BALL_SIZE         ;    at the last row
            CMP      DX, AX                ; Compare the curr row ( DX ) with the last row ( AX )
            JNA      DRAW_COLUMN           ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN1:                      ; if we did, then
            INC      CX                    ; increment our current column
            MOV      DX, BALL_Y            ; reset our current row
            MOV      AX, BALL_X            ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE         ;    at the last column
            CMP      CX, AX                ; Compare the curr column ( CX ) with the last column ( AX )
            JNA      DRAW_COLUMN           ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    DRAW_BALL ENDP

     
    DISPLAY_LIVES PROC NEAR
        PUSH AX
        PUSH BX
        PUSH DX
        PUSH DI
        ; print the "LIVES" label
        MOV AH, 02H               ; Set cursor position
        MOV BH, 00H               ; Page number
        MOV DH, 00H               ; Row
        MOV DL, 02                ; Column
        INT 10H

        MOV AH, 09H
        LEA DX, LIVES_LABEL
        INT 21H
   
        MOV AL, first_player_lives
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
    

ResetBall proc
    mov BALL_X, 70
    mov BALL_Y, 100
    mov BALL_VELOCITY_X, -5
    mov BALL_VELOCITY_Y, 4
    mov first_player_lives, 10
    ret
ResetBall endp
end INIT_BALL
