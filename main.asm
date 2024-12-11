extrn DrawBricks_proc:FAR
extrn MOVE_BALL:FAR
extrn CLEAR_BALL:FAR
extrn UPDATE_POSITION:FAR
extrn DRAW_BALL:FAR
extrn CheckCollision_proc:FAR

.model small
.stack 100h

.data
      PREV_MS         DB      0       ; needed for fps movements


.code
  MAIN PROC FAR
      mov AX, @DATA
      mov DS, AX
  
      mov      ah, 00h                ; Set the config to video mode
      mov      al, 13h                ; Chosen video mode
      INT      10h                    ; Execute interrupt

      CALL    DrawBricks_proc        ; Draw the bricks

      time_loop:
            MOV      AH, 2Ch                ; Get the system time
            INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
            CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
            JE       time_loop              ; if equal then hold the program 1ms 
            MOV      PREV_MS, DL            ; Update timne

            
            CALL     MOVE_BALL              ; check Collisions (for now, the walls only)
            CALL     CLEAR_BALL             ; Erase the ball to draw it in new position
            CALL     CheckCollision_proc    ; check bricks collision
            CALL     UPDATE_POSITION        ; update position of the ball
            CALL     DRAW_BALL              ; Draw the ball with moved ( X - Y ) initial position

            JMP      time_loop              ; REPEAT TO INFINITY
    EXITPROG:      
            mov      ah, 4Ch
            int      21h
    MAIN ENDP
    END MAIN