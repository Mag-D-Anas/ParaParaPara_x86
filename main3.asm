public GAME_SINGLE

extrn DrawBricks_proc_single:FAR
extrn CheckCollision_proc_single:FAR

extrn MOVE_BALL_single:FAR
extrn CLEAR_BALL_single:FAR
extrn UPDATE_POSITION_single:FAR
extrn DRAW_BALL_single:FAR
extrn INIT_BALL_single:FAR

; Paddle
extrn CheckInput_single:FAR
extrn ClearPaddle_single:FAR
extrn DrawPaddle_single:FAR
extrn InitPaddle_single:FAR
; Second paddle



.model small
.stack 100h

.data
      PREV_MS         DB      0       ; needed for fps movements
.code
  GAME_SINGLE PROC FAR
      mov AX, @DATA
      mov DS, AX
  
      mov      ah, 00h                ; Set the config to video mode
      mov      al, 13h                ; Chosen video mode
      INT      10h                    ; Execute interrupt

      CALL     InitPaddle_single              ; Initialize the paddle position      ; Initialize the paddle position
      CALL     DrawBricks_proc_single        ; Draw the bricks
      CALL     INIT_BALL_single

      time_loop:
            ; Paddle 1
            CALL     CheckInput_single   ; Check for user input
            CALL     ClearPaddle_single  ; Erase the old paddle
            CALL     DrawPaddle_single   ; Draw the new paddle
            ; Paddle 2
            ;CALL     CheckInput_single2   ; Check for user input
            ;CALL     ClearPaddle_single2  ; Erase the old paddle
            ;CALL     DrawPaddle_single2   ; Draw the new paddle

            MOV      AH, 2Ch                ; Get the system time
            INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
            CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
            JE       time_loop              ; if equal then hold the program 1ms 
            MOV      PREV_MS, DL            ; Update timne
            
            CALL     MOVE_BALL_single              ; check Collisions (for now, the walls only)
            CALL     CLEAR_BALL_single             ; Erase the ball to draw it in new position
            CALL     CheckCollision_proc_single    ; check bricks collision
            CALL     UPDATE_POSITION_single        ; update position of the ball
            CALL     DRAW_BALL_single              ; Draw the ball with moved ( X - Y ) initial position

            JMP      time_loop              ; REPEAT TO INFINITY
    EXITPROG:      
        RET
    GAME_SINGLE ENDP
    END GAME_SINGLE