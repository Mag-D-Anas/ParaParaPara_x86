; AUTHOR: Amr Samy
; DATE: 5 Dec 2024
; Paddle logic

public CheckInput2
public ClearPaddle2
public DrawPaddle2
public InitPaddle2
; export paddle position and size
public paddleX2
public paddleY2
public paddleWidth2
public paddleHeight2

.MODEL SMALL
.STACK 100h

.DATA
paddleX2 DW 230       ; Initial X position of the paddle
paddleY2 DW 180       ; Y position of the paddle
prevPaddleX2 DW ?   ; Previous X position of the paddle
paddleWidth2 DW 40    ; Width of the paddle
paddleHeight2 DW 10   ; Height of the paddle


screenHeight2 EQU 200  ; Screen height in pixels
leftWall2 EQU 160        ; Left wall position
rightWall2 EQU 320     ; Right wall position


paddleSpeed2 DW 5    ; Speed of the paddle (pixels/move)
paddleColor2 DB 15          ; Paddle color (white in mode 13h)
paddleBgColor2 DB 0         ; Background color (black in mode 13h)

.CODE
; MAIN PROC FAR
;     MOV AX, @DATA
;     MOV DS, AX

;     ; Set graphics mode 13h (320x200, 256 colors)
;     MOV AX, 0013h
;     INT 10h
;     CALL InitPaddle2   ; Initialize the paddle position



; MainLoop:
;     ;CALL ClearScreen  ; Clear the screen
;     CALL CheckInput2   ; Check for user input
;     CALL ClearPaddle2  ; Erase the old paddle
;     CALL DrawPaddle2   ; Draw the new paddle
;     ; MOV     CX, 0H
;     ; MOV     DX, 0C350H
;     ; MOV     AH, 86H
;     ; INT     15H
;     JMP MainLoop      ; Repeat the loop


; MAIN ENDP

InitPaddle2 PROC FAR
    MOV AX, @DATA
    MOV DS, AX
    mov ax, screenHeight2
    mov bx, paddleHeight2
    sub ax, bx
    mov paddleY2, ax
    mov ax, paddleX2
    mov prevPaddleX2, ax
    RET
InitPaddle2 ENDP
; Subroutine to check keyboard input
CheckInput2 PROC FAR
    ; Check for key press
    MOV AH, 01h
    INT 16h
    JZ NoKey2           ; No key pressed

    ; Get the key
    MOV AH, 00h
    INT 16h
    CMP AH, 4Bh        ; Left arrow key
    JE MoveLeft2
    CMP AH, 4Dh        ; Right arrow key
    JE MoveRight2
NoKey2:
    RET

MoveLeft2:
    mov ax, paddleX2
    mov prevPaddleX2, ax ; Save the previous X position
    mov ax, paddleSpeed2
    SUB paddleX2, ax     ; Move left by (speed) pixel

    ; Check if it hits the left wall
    MOV AX, paddleX2
    CMP AX, leftWall2
    JGE NoKey2
    MOV paddleX2, leftWall2
    RET

MoveRight2:
    mov ax, paddleX2
    mov prevPaddleX2, ax ; Save the previous X position
    mov ax, paddleSpeed2
    ADD paddleX2, ax     ; Move right by (speed) pixel

    ; Check if it hits the right wall
    MOV AX, paddleX2
    ADD AX, paddleWidth2
    CMP AX, rightWall2
    JL NoKey2
    mov bx, rightWall2
    sub bx, paddleWidth2
    MOV paddleX2, bx
    RET
CheckInput2 ENDP

ClearPaddle2 PROC FAR
    mov ax, prevPaddleX2
    cmp ax, paddleX2
    je NoClear ; no move, no clear
    jb ClearLeft ; move right, clear left side
    ClearRight: ; move left, clear right side
        mov cx, prevPaddleX2
        add cx, paddleWidth2 ; previous end of the paddle
        sub cx, paddleSpeed2 ; start of clearing (right after end of the paddle - distance moved)
        mov bx, cx ; X start
        mov si, paddleSpeed2
        add si, cx ; clear until the end of the paddle (end of clear)
        jmp StartClearing
    ClearLeft: ; move right, clear left side
        mov cx, prevPaddleX2
        mov bx, cx ; X start
        mov si, paddleSpeed2
        add si, prevPaddleX2 ; previous start of the paddle + speed (end of clear)
    StartClearing:
        mov dx, paddleY2
        mov di, paddleHeight2
        add di, paddleY2
        mov al, paddleBgColor2
        call DrawRectangle
    NoClear:
    mov ax, paddleX2
    mov prevPaddleX2, ax ; Update the previous X position
    RET
ClearPaddle2 ENDP

; Subroutine to draw the paddle
DrawPaddle2 PROC FAR
    MOV BX, paddleX2 ; start X POS
    MOV CX, paddleX2 ; column
    MOV DX, paddleY2 ; row

    MOV SI, paddleWidth2
    MOV DI, paddleHeight2
    ADD SI, paddleX2 ; END X POS
    ADD DI, paddleY2 ; END Y POS

    MOV AL, paddleColor2      ; Paddle color
    CALL DrawRectangle
    RET
DrawPaddle2 ENDP

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

END InitPaddle2
