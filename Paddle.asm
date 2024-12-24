; AUTHOR: Amr Samy
; DATE: 5 Dec 2024
; Paddle logic

public CheckInput
public ClearPaddle
public DrawPaddle
public InitPaddle
; export paddle position and size
public paddleX
public prevPaddleX
public paddleY
public paddleWidth
public paddleHeight

.MODEL SMALL
.STACK 100h

.DATA
paddleX DW 70       ; Initial X position of the paddle
paddleY DW 180       ; Y position of the paddle
prevPaddleX DW ?   ; Previous X position of the paddle
paddleWidth DW 30    ; Width of the paddle
paddleHeight DW 5   ; Height of the paddle


screenHeight EQU 200  ; Screen height in pixels
leftWall EQU 0        ; Left wall position
rightWall EQU 158     ; Right wall position


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
;     CALL InitPaddle   ; Initialize the paddle position



; MainLoop:
;     ;CALL ClearScreen  ; Clear the screen
;     CALL CheckInput   ; Check for user input
;     CALL ClearPaddle  ; Erase the old paddle
;     CALL DrawPaddle   ; Draw the new paddle
;     ; MOV     CX, 0H
;     ; MOV     DX, 0C350H
;     ; MOV     AH, 86H
;     ; INT     15H
;     JMP MainLoop      ; Repeat the loop


; MAIN ENDP

InitPaddle PROC FAR
    MOV AX, @DATA
    MOV DS, AX
    mov ax, screenHeight
    mov bx, paddleHeight
    sub ax, bx
    mov paddleY, ax
    mov ax, paddleX
    mov prevPaddleX, ax
    RET
InitPaddle ENDP
; Subroutine to check keyboard input
CheckInput PROC FAR
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
        ;send LEFT 'l'
        push ax
        push dx
        waitLeft:
        mov dx , 3FDH		; Line Status Register
        In al , dx 			;Read Line Status
        AND al , 00100000b
        JZ waitLeft
        
        mov dx , 3F8H		; Transmit data register
        mov al, 'l'
        out dx , al
        pop dx
        pop ax
        ;///////////////////////////

    mov ax, paddleX
    mov prevPaddleX, ax ; Save the previous X position
    mov ax, paddleSpeed
    SUB paddleX, ax     ; Move left by (speed) pixel

    ; Check if it hits the left wall
    MOV AX, paddleX
    CMP AX, leftWall
    JGE NoKey
    MOV paddleX, leftWall
    RET

MoveRight:

      ;send right 'r'
        push ax
        push dx
        waitRight:
        mov dx , 3FDH		; Line Status Register
        In al , dx 			;Read Line Status
        AND al , 00100000b
        JZ waitRight
        
        mov dx , 3F8H		; Transmit data register
        mov al, 'r'
        out dx , al
        pop dx
        pop ax
        ;///////////////////////////    


    mov ax, paddleX
    mov prevPaddleX, ax ; Save the previous X position
    mov ax, paddleSpeed
    ADD paddleX, ax     ; Move right by (speed) pixel

    ; Check if it hits the right wall
    MOV AX, paddleX
    ADD AX, paddleWidth
    CMP AX, rightWall
    JL NoKey
    mov bx, rightWall
    sub bx, paddleWidth
    MOV paddleX, bx
    RET
CheckInput ENDP

ClearPaddle PROC FAR
    mov ax, prevPaddleX
    cmp ax, paddleX
    je NoClear ; no move, no clear
    jb ClearLeft ; move right, clear left side
    ClearRight: ; move left, clear right side
        mov cx, prevPaddleX
        add cx, paddleWidth ; previous end of the paddle
        sub cx, paddleSpeed ; start of clearing (right after end of the paddle - distance moved)
        mov bx, cx ; X start
        mov si, paddleSpeed
        add si, cx ; clear until the end of the paddle (end of clear)
        jmp StartClearing
    ClearLeft: ; move right, clear left side
        mov cx, prevPaddleX
        mov bx, cx ; X start
        mov si, paddleSpeed
        add si, prevPaddleX ; previous start of the paddle + speed (end of clear)
    StartClearing:
        mov dx, paddleY
        mov di, paddleHeight
        add di, paddleY
        mov al, paddleBgColor
        call DrawRectangle
    NoClear:
    mov ax, paddleX
    mov prevPaddleX, ax ; Update the previous X position
    RET
ClearPaddle ENDP

; Subroutine to draw the paddle
DrawPaddle PROC FAR
    MOV BX, paddleX ; start X POS
    MOV CX, paddleX ; column
    MOV DX, paddleY ; row

    MOV SI, paddleWidth
    MOV DI, paddleHeight
    ADD SI, paddleX ; END X POS
    ADD DI, paddleY ; END Y POS

    MOV AL, paddleColor      ; Paddle color
    CALL DrawRectangle
    RET
DrawPaddle ENDP

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

END InitPaddle
