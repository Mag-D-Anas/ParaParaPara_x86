; Bricks 1
extrn DrawBricks_proc:FAR
extrn CheckCollision_proc:FAR

; Bricks 2
extrn DrawBricks_proc2:FAR
extrn CheckCollision_proc2:FAR

; Ball 1
extrn MOVE_BALL:FAR
extrn CLEAR_BALL:FAR
extrn UPDATE_POSITION:FAR
extrn DRAW_BALL:FAR
extrn INIT_BALL:FAR

; Ball 2
extrn CLEAR_BALL_REC:FAR
extrn DRAW_BALL_REC:FAR
extrn INIT_BALL_REC:FAR

; Paddle
extrn CheckInput:FAR
extrn ClearPaddle:FAR
extrn DrawPaddle:FAR
extrn InitPaddle:FAR
; ; Second paddle
; extrn CheckInput2:FAR
extrn ClearPaddle2:FAR
extrn DrawPaddle2:FAR
extrn InitPaddle2:FAR

; Communication
extrn COM_INIT:FAR
extrn SendCom:FAR
extrn RecCom:FAR



.model small
.stack 100h

.data
      PREV_MS         DB      0       ; needed for fps movements
      vertical_line_x DW      159
      vertical_line_y DW      0
      vertical_line_height DW 200
      vertical_line_width  DW 1
.code
  MAIN PROC FAR
      mov AX, @DATA
      mov DS, AX
  
      mov      ah, 00h                ; Set the config to video mode
      mov      al, 13h                ; Chosen video mode
      INT      10h                    ; Execute interrupt
      CALL     InitPaddle              ; Initialize the paddle position
      CALL     InitPaddle2             ; Initialize the paddle position
      CALL     DrawBricks_proc        ; Draw the bricks
      CALL     DrawBricks_proc2        ; Draw the bricks
      CALL     INIT_BALL
      CALL     INIT_BALL_REC
      CALL     COM_INIT

      time_loop:
            CALL     DrawVerticalLine_proc
            ; Paddle 1
            CALL     CheckInput   ; Check for user input
            CALL     ClearPaddle2  ; Erase the old paddle
            CALL     ClearPaddle  ; Erase the old paddle
            CALL     DrawPaddle   ; Draw the new paddle
            ; Paddle 2
            ; CALL     CheckInput2   ; Check for user input
              
            CALL     DrawPaddle2   ; Draw the new paddle


            MOV      AH, 2Ch                ; Get the system time
            INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
            CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
            JE       time_loop              ; if equal then hold the program 1ms 
            MOV      PREV_MS, DL            ; Update timne
            
            CALL     SendCom

            CALL     MOVE_BALL              ; check Collisions (for now, the walls only)
            CALL     CLEAR_BALL             ; Erase the ball to draw it in new position
            CALL     CLEAR_BALL_REC
            CALL     CheckCollision_proc    ; check bricks collision
            CALL     RecCom
            CALL     CheckCollision_proc2   ; check bricks collision
            CALL     UPDATE_POSITION        ; update position of the ball
            CALL     DRAW_BALL_REC
            CALL     DRAW_BALL              ; Draw the ball with moved ( X - Y ) initial position


            JMP      time_loop              ; REPEAT TO INFINITY
    EXITPROG:      
            mov      ah, 4Ch
            int      21h
    MAIN ENDP

    DrawVerticalLine_proc PROC
    PUSH DX
    PUSH CX
    PUSH AX
    
    MOV CX, vertical_line_x      ; set the column
    MOV DX, vertical_line_y      ; set the row  

    draw_line_horizontal:
        MOV AH, 0Ch ; set the configuration to writing a pixel
        MOV AL, 03h ; choose white as color
        MOV BH, 00h ; set page number to 0
        INT 10h     ; execute the configuration

        INC CX                ; increment the column
        MOV AX, CX                     ; use AX as auxillary reg
        SUB AX, vertical_line_x        ; AX = CX - vertical_line_x 
        CMP AX, vertical_line_width    ; compare AX with vertical_line_width 
        JNG draw_line_horizontal
        MOV CX, vertical_line_x        ; CX goes back to initial column
        INC DX                         ; increment the row
        MOV AX, DX                     ; use AX as auxillary reg
        SUB AX, vertical_line_y        ; AX = DX - vertical_line_y
        CMP AX, vertical_line_height   ; compare AX with vertical_line_height
        JNG draw_line_horizontal
    POP AX
    POP DX
    POP CX
RET
DrawVerticalLine_proc ENDP

    END MAIN