PUBLIC Chat
.MODEL small
.STACK 100h
.data
VALUE DB ?
Xpos_s DB 0
Ypos_s DB 0
Xpos_r DB 0
Ypos_r DB 0Dh
color_s equ 07h
color_r equ 05h
.code

ResetUpperScreen MACRO
    mov ax,060Dh
    mov bh,color_s
    mov cx,0       
    mov dh, 12
    mov dl, 79
    int 10h 
ENDM ResetUpperScreen

ResetLowerScreen MACRO
    mov ax,060Ch
    mov bh,color_r
    mov ch,13
    mov cl, 0       
    mov dh,24
    mov dl, 79
    int 10h 
    
ENDM ResetLowerScreen


ScrollUpperScreen MACRO  
mov ah,6
mov al , 1
mov bh,07h
mov ch,0       
mov cl,0       
mov dh,12    
mov dl,79
int 10h 
  
ENDM ScrollUpperScreen 


ScrollLowerScreen MACRO
mov ah,6
mov al , 1
mov bh,05h
mov ch,13     
mov cl,0        
mov dh,24    
mov dl,79 
int 10h 
ENDM ScrollLowerScreen 

SaveCursorS MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov Xpos_s, DL
    mov Ypos_s, DH
ENDM SaveCursorS

SaveCursorR MACRO
    mov ah, 3h
    mov bh, 0h
    int 10h
    mov Xpos_r, DL
    mov Ypos_r, DH
ENDM SaveCursorR

SetCursor MACRO x, y
    mov ah, 2
    mov bh, 0
    mov dl, x
    mov dh, y
    int 10h
ENDM SetCursor

Chat proc
    mov ax, @data
    mov ds, ax

   
      ResetUpperScreen
      ResetLowerScreen
      SetCursor 0, 0

    ; initinalize COM
    ;Set Divisor Latch Access Bit
    mov dx,3fbh 			; Line Control Register
    mov al,10000000b		;Set Divisor Latch Access Bit
    out dx,al				;Out it
    ;Set LSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f8h			
    mov al,0ch			
    out dx,al

    ;Set MSB byte of the Baud Rate Divisor Latch register.
    mov dx,3f9h
    mov al,00h
    out dx,al

    ;Set port configuration
    mov dx,3fbh
    mov al,00011011b
    out dx,al


    call checkInput

    
checkInput proc

    START:

    ;Check that Transmitter Holding Register is Empty
        mov ah,01h     ; check if key is pressed
        Int 16h
        jz dummy2        ; if no key is pressed go check for uart again

    send:
        mov ah,0h     ;read the char to see if it is esc
        Int 16h

        mov VALUE, AL
        cmp al, 0Dh
        jz ENTERKEY
        jnz CONT

    dummy2:jmp recieve

    ENTERKEY:
        cmp Ypos_s, 11
        jnz INCREMENT ; no overflow
        
        OverFlow:
            ScrollUpperScreen
            jmp PRINT

        INCREMENT:
        inc Ypos_s
        MOV Xpos_s, 0 ; reset x position

        CONT:
        SetCursor Xpos_s, Ypos_s
        cmp Xpos_s, 79 ; check if x position is at the end of the screen
        jnz PRINT ; if not print the char

        CHECKY: ; check if y position is at the end of the screen
        cmp Ypos_s, 11
        jnz PRINT
        ScrollUpperScreen
        mov Xpos_s, 0
        mov Ypos_s, 11
        SetCursor Xpos_s, Ypos_s ; reset the cursor to the start of the screen

    PRINT:
        mov ah, 2
        mov dl, VALUE
        int 21h


    SENDSTATUS:
        mov dx , 3FDH		; Line Status Register
    AGAIN:  
        In al , dx 			;Read Line Status
        AND al , 00100000b ; 0 -> busy, recieve, 1 - > free
        JZ recieve


        ;If empty put the VALUE in Transmit data register
        mov dx , 3F8H		; Transmit data register
        mov al, VALUE
        out dx , al 

    ESCAPEKEY:
        cmp al, 1Bh
        JZ dummy
        SaveCursorS
        jmp START

    dummy: jmp exit
    dummy3: jmp send

    recieve:
    mov ah, 1
    int 16h
    jnz dummy3

        ;Check that Data Ready from UART
    READSTATUS:
        mov dx , 3FDH		; Line Status Register
        in al , dx 
        AND al , 1
        JZ recieve     ; if there is not char in uart go check for key pressed

    READ:
        mov dx , 03F8H
        in al , dx 
        mov VALUE , al
        cmp VALUE, 1Bh
        jz dummy

        cmp VALUE, 0Dh
        jnz contR

        newlineR:
        cmp ypos_r, 24 ; end of recieve screen
        jnz YR

        ScrollLowerScreen

        jmp PRINTR

        YR: ; not end of recieve screen, increase y, reset x and print
        inc Ypos_r
        mov Xpos_r, 0

        contR:
        SetCursor Xpos_r, Ypos_r
        cmp Xpos_r, 79 ; end of screen x
        jnz PRINTR

        CHECKYR: ; is end of screen x
        cmp Ypos_r, 24 ; check if end of y
        jnz PRINTR ; if not, print
        ScrollLowerScreen ; scroll because end of screen y
        mov Xpos_r, 0 ; reset x to start
        mov Ypos_r, 24 ; put y in last line again
        SetCursor Xpos_r, ypos_r

        PRINTR:
        mov ah, 2
        mov dl, VALUE
        int 21h

        SaveCursorR

        jmp START
   
checkInput endp


exit:
ret
Chat endp
end Chat

