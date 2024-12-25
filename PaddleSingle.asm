; AUTHOR: Amr Samy
; DATE: 5 Dec 2024
; Paddle logic

public CheckInput_single
public ClearPaddle_single
public DrawPaddle_single
public InitPaddle_single
; export paddle position and size
public paddleX_single
public paddleY_single
public paddleWidth_single
public paddleHeight_single

.MODEL SMALL
.STACK 100h

.DATA
paddleX_single DW 70       ; Initial X position of the paddle
paddleY_single DW 180       ; Y position of the paddle
prevpaddleX_single DW ?   ; Previous X position of the paddle
paddleWidth_single DW 40    ; Width of the paddle
paddleHeight_single DW 7   ; Height of the paddle


screenHeight EQU 200  ; Screen height in pixels
leftWall EQU 0        ; Left wall position
rightWall EQU 360     ; Right wall position


paddleSpeed DW 5    ; Speed of the paddle (pixels/move)
paddleColor DB 15          ; Paddle color (white in mode 13h)
paddleBgColor DB 0         ; Background color (black in mode 13h)

.CODE
; MAIN PROC FAR
;     MOV AX, @DATA
;     MOV DS, AX

;     ; Set graphics mode 13h (320x200, 256 colors)
;     MOV AX, 0013h
;     INT 10h
;     CALL InitPaddle_single   ; Initialize the paddle position



; MainLoop:
;     ;CALL ClearScreen  ; Clear the screen
;     CALL CheckInput_single   ; Check for user input
;     CALL ClearPaddle_single  ; Erase the old paddle
;     CALL DrawPaddle_single   ; Draw the new paddle
;     ; MOV     CX, 0H
;     ; MOV     DX, 0C350H
;     ; MOV     AH, 86H
;     ; INT     15H
;     JMP MainLoop      ; Repeat the loop


; MAIN ENDP

InitPaddle_single PROC FAR
    MOV AX, @DATA
    MOV DS, AX
    mov ax, screenHeight
    mov bx, paddleHeight_single
    sub ax, bx
    mov paddleY_single, ax
    mov ax, paddleX_single
    mov prevpaddleX_single, ax
    RET
InitPaddle_single ENDP
; Subroutine to check keyboard input
CheckInput_single PROC FAR
    ; Check for key press
    MOV AH, 01h
    INT 16h
    JZ NoKey           ; No key pressed

    ; Get the key
    MOV AH, 00h
    INT 16h
    CMP AH, 4Bh        ; Left arrow key
    JE MoveLeft
    CMP AH, 4Dh        ; Right arrow key
    JE MoveRight
NoKey:
    RET

MoveLeft:
    mov ax, paddleX_single
    mov prevpaddleX_single, ax ; Save the previous X position
    mov ax, paddleSpeed
    SUB paddleX_single, ax     ; Move left by (speed) pixel

    ; Check if it hits the left wall
    MOV AX, paddleX_single
    CMP AX, leftWall
    JGE NoKey
    MOV paddleX_single, leftWall
    RET

MoveRight:
    mov ax, paddleX_single
    mov prevpaddleX_single, ax ; Save the previous X position
    mov ax, paddleSpeed
    ADD paddleX_single, ax     ; Move right by (speed) pixel

    ; Check if it hits the right wall
    MOV AX, paddleX_single
    ADD AX, paddleWidth_single
    CMP AX, rightWall
    JL NoKey
    mov bx, rightWall
    sub bx, paddleWidth_single
    MOV paddleX_single, bx
    RET
CheckInput_single ENDP

ClearPaddle_single PROC FAR
    mov ax, prevpaddleX_single
    cmp ax, paddleX_single
    je NoClear ; no move, no clear
    jb ClearLeft ; move right, clear left side
    ClearRight: ; move left, clear right side
        mov cx, prevpaddleX_single
        add cx, paddleWidth_single ; previous end of the paddle
        sub cx, paddleSpeed ; start of clearing (right after end of the paddle - distance moved)
        mov bx, cx ; X start
        mov si, paddleSpeed
        add si, cx ; clear until the end of the paddle (end of clear)
        jmp StartClearing
    ClearLeft: ; move right, clear left side
        mov cx, prevpaddleX_single
        mov bx, cx ; X start
        mov si, paddleSpeed
        add si, prevpaddleX_single ; previous start of the paddle + speed (end of clear)
    StartClearing:
        mov dx, paddleY_single
        mov di, paddleHeight_single
        add di, paddleY_single
        mov al, paddleBgColor
        call DrawRectangle
    NoClear:
    mov ax, paddleX_single
    mov prevpaddleX_single, ax ; Update the previous X position
    RET
ClearPaddle_single ENDP

; Subroutine to draw the paddle
DrawPaddle_single PROC FAR
    MOV BX, paddleX_single ; start X POS
    MOV CX, paddleX_single ; column
    MOV DX, paddleY_single ; row

    MOV SI, paddleWidth_single
    MOV DI, paddleHeight_single
    ADD SI, paddleX_single ; END X POS
    ADD DI, paddleY_single ; END Y POS

    MOV AL, paddleColor      ; Paddle color
    CALL DrawRectangle
    RET
DrawPaddle_single ENDP

; Subroutine to draw a rectangle
DrawRectangle PROC
    MOV AH, 0Ch       ; Write pixel function

DrawRow:
    MOV CX, BX;
DrawPixel:
    INT 10h            ; Draw pixel at (CX, DX) with color AL
    INC CX             ; Move to the next pixel in the row
    CMP CX, SI         ; Check if we reached the end of the row
    JL DrawPixel       ; If not, continue drawing pixels
    INC DX             ; Move to the next row
    CMP DX, DI         ; Check if we reached the end of the rectangle
    JL DrawRow         ; If not, continue drawing rows
    RET
DrawRectangle ENDP

END InitPaddle_single
