; AUTHOR: Anas Magdy
; DATE: 5 Dec 2024
; BALL logic procedure, with handling the collisions of the walls

;extrn DrawBricks_proc:FAR
public CLEAR_BALL_REC
public DRAW_BALL_REC
public INIT_BALL_REC

; extrn to bricks
public BALL_X_REC
public BALL_Y_REC
public BALL_SIZE_REC

extrn BALL_X:WORD
extrn BALL_Y:WORD
.model small
.stack 100h

.data
            SHIFT_REC           DW      161
            BALL_X_REC          DW      231     ; X position of the ball
            BALL_Y_REC          DW      100     ; Y position of the ball
            BALL_SIZE_REC       DW      4     ; Size of the ball (pixels width and height)

.code

    INIT_BALL_REC PROC FAR
            MOV      AX, @DATA
            MOV      DS, AX
            RET
    INIT_BALL_REC ENDP


    DRAW_BALL_REC PROC FAR
    
            ; MOV      AX, BALL_X
            ; MOV      BALL_X_REC, AX
            ;MOV      AX, BALL_Y
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
    


end INIT_BALL_REC
