; AUTHOR: Anas Magdy
; DATE: 5 Dec 2024
; BALL logic procedure, with handling the collisions of the walls

extrn DrawBricks_proc:FAR
; extrn CheckCollision_proc:FAR

public MOVE_BALL
public CLEAR_BALL
public DRAW_BALL
public UPDATE_POSITION

; public BALL_X
; public BALL_Y
; public BALL_SIZE

.model small
.stack 100h

.data
            WINDOW_WIDTH    DW      140h    ; 320 pixels
            WINDOW_HEIGHT   DW      0C8h    ; 200 pixels
            WINDOW_BOUNDS   DW      4       ; pre check the walls
            PREV_MS         DB      0       ; neede for fps movements
            BALL_X          DW      0Ah     ; X position of the ball
            BALL_Y          DW      0Ah     ; Y position of the ball
            BALL_SIZE       DW      0Ah     ; Size of the ball (pixels width and height)
            BALL_VELOCITY_X DW      -5      ; velocity of incrementing the ball starting position
            BALL_VELOCITY_Y DW      -2      ; positive -> go down // negative -> go up

.code
    ; MAIN PROC FAR

    ;         mov      AX, @DATA
    ;         mov      DS, AX

    ;         mov      ah, 00h                ; Set the config to video mode
    ;         mov      al, 13h                ; Chosen video mode
    ;         INT      10h                    ; Execute interrupt

    ;       CALL    DrawBricks_proc        ; Draw the bricks

    ;     BALL_LOOP:
    ;         MOV      AH, 2Ch                ; Get the system time
    ;         INT      21h                    ; CH = hours, CL = minutes, DH = seconds, DL = 1/100 seconds
    ;         CMP      PREV_MS, DL            ; Compare the curr ms with the previous one
    ;         JE       BALL_LOOP              ; if equal then hold the program 1ms 
    ;         MOV      PREV_MS, DL            ; Update timne

    ;         CALL     MOVE_BALL              ; check Collisions (for now, the walls only)
    ;         CALL     CLEAR_BALL             ; Erase the ball to draw it in new position

    ;         MOV      AX, BALL_VELOCITY_X    ; edited X - Vep/+locity
    ;         ADD      BALL_X, AX             ; move the initial X - position of the ball 
    ;         MOV      AX, BALL_VELOCITY_Y    ; edited Y - Velocity
    ;         ADD      BALL_Y, AX             ; move the initial Y - position of the ball
    ;         CALL     DRAW_BALL              ; Draw the ball with moved ( X - Y ) initial position
    ;         JMP      BALL_LOOP              ; REPEAT TO INFINITY

    ;     EXITPROG:      
    ;         mov      ah, 4Ch
    ;         int      21h
    ; MAIN ENDP

    UPDATE_POSITION PROC FAR
        MOV      AX, BALL_VELOCITY_X    ; edited X - Vep/+locity
        ADD      BALL_X, AX             ; move the initial X - position of the ball 
        MOV      AX, BALL_VELOCITY_Y    ; edited Y - Velocity
        ADD      BALL_Y, AX             ; move the initial Y - position of the ball
    UPDATE_POSITION ENDP

    MOVE_BALL PROC FAR
            MOV      AX, @DATA
            MOV      DS, AX
            ; Left Wall
            MOV      BX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_X, BX             ; comparing the curr X - position with the first column of the window
            JL       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity

            ; Right Wall
            MOV      AX, WINDOW_WIDTH       ; AX holds the last column of the window
            SUB      AX, BALL_SIZE          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            SUB      AX, WINDOW_BOUNDS      ; one not enough ( I do not know why, but it works XD)
            CMP      BALL_X, AX             ; comparing the curr X - position with the last column of the window
            JG       NEG_VELOCITY_X         ; isHitted? change the direction of X - velocity
        
            ; Ceil
            MOV      BX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y, BX             ; comparing the curr Y - position with the first row of the window
            JL       NEG_VELOCITY_Y         ; isHitted? change the direction of Y - velocity

            ; Floor
            MOV      AX, WINDOW_HEIGHT      ; AX holds the last Row of the window
            SUB      AX, BALL_SIZE          ; needed to check AX with the start of the ball and without it the ball go out of bound
            SUB      AX, WINDOW_BOUNDS      ; pre checking the ball collision with safety space
            CMP      BALL_Y, AX             ; comparing the curr X - position with the last Row of the window
            JG       EXIT                   ; isHitted? You lose

            RET

        EXIT:
            CALL     CLEAR_BALL             ; Clear the loser ball
            MOV      BALL_VELOCITY_X, 05h   ; Reset X - velocity ( dump value )
            MOV      BALL_VELOCITY_Y, 02h   ; Reset Y - velocity ( dump value )
            MOV      BALL_X, 1Fh            ; Reset X - position ( dump value )
            MOV      BALL_Y, 1Fh            ; Reset Y - position ( dump value )
            RET

        NEG_VELOCITY_X:
            NEG      BALL_VELOCITY_X        ; positive -> go down // negative -> go up
            RET

        NEG_VELOCITY_Y:
            NEG      BALL_VELOCITY_Y        ; positive -> go down // negative -> go up
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
            JNG      DRAW_COLUMN           ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN1:                      ; if we did, then
            INC      CX                    ; increment our current column
            MOV      DX, BALL_Y            ; reset our current row
            MOV      AX, BALL_X            ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE         ;    at the last column
            CMP      CX, AX                ; Compare the curr column ( CX ) with the last column ( AX )
            JNG      DRAW_COLUMN           ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    DRAW_BALL ENDP
    
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
            JNG      CLEAR_COLUMN         ; We didn't reach the last row ( AX ) ? => Repeat

        SHIFTCOLUMN2:                     ; if we did, then
            INC      CX                   ; increment our current column
            MOV      DX, BALL_Y           ; reset our current row
            MOV      AX, BALL_X           ; Calculating X-index of the pixel
            ADD      AX, BALL_SIZE        ;    at the last column
            CMP      CX, AX               ; Compare the curr column ( CX ) with the last column ( AX )
            JNG      CLEAR_COLUMN         ; We didn't reach the last column ( AX ) ? => Keep drawing

            RET

    CLEAR_BALL ENDP

end MOVE_BALL
