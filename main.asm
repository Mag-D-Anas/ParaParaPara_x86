extrn DrawBricks_proc:FAR
extrn MOVE_BALL:FAR
extrn CLEAR_BALL:FAR
extrn UPDATE_POSITION:FAR
extrn DRAW_BALL:FAR
extrn INIT_BALL:FAR
; Paddle
extrn CheckInput:FAR
extrn ClearPaddle:FAR
extrn DrawPaddle:FAR
extrn InitPaddle:FAR

.model small
.stack 100h

.data
      PREV_MS         DB      0       ; neede for fps movements
.code
  MAIN PROC FAR
      mov AX, @DATA
      mov DS, AX
  
      mov      ah, 00h                ; Set the config to video mode
      mov      al, 13h                ; Chosen video mode
      INT      10h                    ; Execute interrupt

      CALL     InitPaddle              ; Initialize the paddle position
      CALL     DrawBricks_proc        ; Draw the bricks
      CALL     INIT_BALL

      time_loop:
            CALL     CheckInput   ; Check for user input
            CALL     ClearPaddle  ; Erase the old paddle
            CALL     DrawPaddle   ; Draw the new paddle
            MOV      AH, 2Ch                ; Get the system time
            INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
            CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
            JE       time_loop              ; if equal then hold the program 1ms 
            MOV      PREV_MS, DL            ; Update timne
            
            CALL     MOVE_BALL              ; check Collisions (for now, the walls only)
            CALL     CLEAR_BALL             ; Erase the ball to draw it in new position
            CALL     UPDATE_POSITION        ; update position of the ball
            CALL     DRAW_BALL              ; Draw the ball with moved ( X - Y ) initial position

            JMP      time_loop              ; REPEAT TO INFINITY
    EXITPROG:      
            mov      ah, 4Ch
            int      21h
    MAIN ENDP
    END MAIN