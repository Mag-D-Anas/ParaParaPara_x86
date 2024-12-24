PUBLIC GAME

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
extrn MOVE_BALL2:FAR
extrn UPDATE_POSITION2:FAR

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
extrn CheckInput2:FAR

extrn ClearPaddle2:FAR
extrn DrawPaddle2:FAR
extrn InitPaddle2:FAR

; Communication
extrn COM_INIT:FAR
; extrn SendCom:FAR
; extrn RecCom:FAR
extrn SendStartFlag:FAR
extrn WaitForRec:FAR

; Lives
extrn first_player_lives:byte

.model small
.stack 100h

.data
      PREV_MS         DB      0       ; needed for fps movements
      vertical_line_x DW      159
      vertical_line_y DW      0
      vertical_line_height DW 200
      vertical_line_width  DW 1
      otherReady DB 0

      game_over       DB      0     ; 0 - game is running, 1 - game is over
      game_over_text  DB      'GAME OVER', '$'	; Game over menu title
      winner_text     DB      'Player 0 won', '$'
      winner_index    DB       0	 ; the index of the winner => 1 for player 1, 2 for player 2

.code
  GAME PROC FAR
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

      CALL SendStartFlag
      CALL WaitForRec


      MOV game_over, 0


      time_loop:
            ; check if the game is over before repeating the loop
            CALL     checkWin_proc
            CMP      game_over, 1
            JE       show_game_over

            CALL     DrawVerticalLine_proc
            ; Paddle 1
            CALL     CheckInput   ; Check for user input
            CALL     CheckInput2   ; Check for user input

            CALL     ClearPaddle  ; Erase the old paddle
            CALL     ClearPaddle2  ; Erase the old paddle
            CALL     DrawPaddle   ; Draw the new paddle
            ; Paddle 2              
            CALL     DrawPaddle2   ; Draw the new paddle


            MOV      AH, 2Ch                ; Get the system time
            INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
            CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
            JE       time_loop              ; if equal then hold the program 1ms 
            MOV      PREV_MS, DL            ; Update timne
            
            ; mov dx , 3FDH		; Line Status Register
            ; in al , dx 
            ; AND al , 1
            ; JNZ rec_first
            ;CALL SendStartFlag
            ; CALL     SendCom
            ; CALL     RecCom
            ;rec_first:

            CALL     MOVE_BALL              ; check Collisions (for now, the walls only)
            CALL     MOVE_BALL2              ; check Collisions (for now, the walls only)

            CALL     CLEAR_BALL             ; Erase the ball to draw it in new position
            CALL     CLEAR_BALL_REC
            CALL     CheckCollision_proc    ; check bricks collision
            CALL     CheckCollision_proc2   ; check bricks collision
            CALL     UPDATE_POSITION        ; update position of the ball
            CALL     UPDATE_POSITION2        ; update position of the ball

            CALL     DRAW_BALL              ; Draw the ball with moved ( X - Y ) initial position
            CALL     DRAW_BALL_REC


            JMP      time_loop              ; REPEAT TO INFINITY

      show_game_over:
            CALL DrawGameOver_proc
            JMP  time_loop

    EXITPROG:      
            mov      ah, 4Ch
            int      21h
    GAME ENDP


; check win and loss
; compare 2 lives => if 0 => loss and display loss screen 
; if win => display win screen
; win when a destroy all the bricks => when score equals 80
checkWin_proc PROC
    ; TODO: game over logic
    CMP first_player_lives, 0
    JE set_game_over
    JMP exit
    set_game_over :
     MOV game_over, 1
     MOV winner_index, 1  ; for now
     CALL DrawGameOver_proc
    exit:
 RET
checkWin_proc ENDP

DrawGameOver_proc PROC NEAR
      CALL ClearScreen_proc
   
      ; SHOW GAME OVER TITLE
      MOV AH, 02H
      MOV BH, 00H
      MOV DH, 04H
      MOV DL, 04H
      INT 10H

      MOV AH, 09H
      LEA DX, game_over_text
      INT 21H

      ; shows the winner
      MOV AH, 02H
      MOV BH, 00H
      MOV DH, 06H
      MOV DL, 04H
      INT 10H

      CALL UpdateWinnerText_proc

      MOV AH, 09H
      LEA DX, winner_text
      INT 21H

      ; wait for a key press
      MOV AH, 00H
      INT 16H

DrawGameOver_proc ENDP

UpdateWinnerText_proc proc NEAR
      MOV AL, winner_index            ; get the winner index
      ADD AL, 30H
      MOV [winner_text + 7], AL   ; update the text with the winner index;
RET
UpdateWinnerText_proc ENDP

ClearScreen_proc proc NEAR
      MOV AH, 00h
      MOV AL, 13h
      INT 10h

      MOV AH, 0BH
      MOV BH, 00h
      MOV BL, 00H
      INT 10H
    RET
ClearScreen_proc ENDP


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

END GAME