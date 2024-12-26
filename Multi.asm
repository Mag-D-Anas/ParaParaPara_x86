; extrn BALL_X:word
; extrn BALL_Y:word
; extrn paddleX:word
; extrn prevPaddleX:word

; extrn BALL_X_REC:word
; extrn BALL_Y_REC:word
; extrn paddleX2:word
; extrn prevPaddleX2:word

public COM_INIT
; public SendCom
; public RecCom

public SendStartFlag
public WaitForRec

.model medium
.STACK 100h
.code


COM_INIT proc
    ; Initialize COM
    ; Set Divisor Latch Access Bit
    mov dx, 3fbh            ; Line Control Register
    mov al, 10000000b        ; Set Divisor Latch Access Bit (DLAB = 1)
    out dx, al               ; Output to LCR to enable DLAB

    ; Set LSB byte of the Baud Rate Divisor Latch register
    mov dx, 3f8h             ; Base address for serial port (COM1)
    mov al, 0ch              ; LSB of baud rate divisor (12)
    out dx, al               ; Output to Divisor LSB register

    ; Set MSB byte of the Baud Rate Divisor Latch register
    mov dx, 3f9h             ; Address for Divisor MSB register
    mov al, 00h              ; MSB of baud rate divisor (0)
    out dx, al               ; Output to Divisor MSB register

    ; Set port configuration (8 data bits, 2 stop bits, no parity)
    mov dx, 3fbh             ; Line Control Register (LCR) address
    mov al, 00011111b        ; Set 8 data bits, 2 stop bits, no parity
    out dx, al               ; Output to LCR to set configuration



    ret
COM_INIT endp


SendStartFlag proc
        waitToSendStart:
        mov dx , 3FDH		; Line Status Register
        In al , dx 			;Read Line Status
        AND al , 00100000b
        JZ waitToSendStart
        
        mov dx , 3F8H		; Transmit data register
        mov al, 'b'
        out dx , al
        
        RET
SendStartFlag endp

; SendCom proc
;     ; Send marker (0xFF) to indicate start of transmission
; sendInd:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitTHR_Empty1:
; ;     in al, dx              ; Read Line Status
; ;     and al, 00100000b      ; Check if THR Empty (bit 5)
; ;     jz waitTHR_Empty1      ; Wait until THR is empty
; ;     mov dx, 3F8H           ; Transmit Data Register
; ;     mov al, 0FFh           ; Marker byte
; ;     out dx, al

;     ; Send BALL_X
; ; sendBallX:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitTHR_Empty2:
; ;     in al, dx              ; Read Line Status
; ;     and al, 00100000b      ; Check if THR Empty (bit 5)
; ;     jz waitTHR_Empty2      ; Wait until THR is empty
; ;     mov dx, 3F8H           ; Transmit Data Register
; ;     mov al, byte ptr BALL_X
; ;     out dx, al

; ;     ; Send BALL_Y
; ; sendBallY:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitTHR_Empty3:
; ;     in al, dx              ; Read Line Status
; ;     and al, 00100000b      ; Check if THR Empty (bit 5)
; ;     jz waitTHR_Empty3      ; Wait until THR is empty
; ;     mov dx, 3F8H           ; Transmit Data Register
; ;     mov al, byte ptr BALL_Y
; ;     out dx, al

;     ; Send paddleX
; ;      sendPaddleX:
;     mov dx, 3FDH           ; Line Status Register
; ; waitTHR_Empty4:
;     in al, dx              ; Read Line Status
;     and al, 00100000b      ; Check if THR Empty (bit 5)
;     jz skip1      ; Wait until THR is empty
;     mov dx, 3F8H           ; Transmit Data Register
;     mov al, byte ptr paddleX
;     out dx, al
; skip1:
;     ret
; SendCom endp



WaitForRec proc
        rewait:
                mov dx , 3FDH		; Line Status Register
                In al , dx 			;Read Line Status
                AND al , 1
        JZ rewait

        mov dx, 03F8H
        in al, dx
        CMP al, 'b'
        JNZ rewait

        RET

WaitForRec endp

; RecCom proc
;     ; Wait until data is ready, then read marker
; readInd:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitData_Ready1:
; ;     in al, dx              ; Read Line Status
; ;     and al, 1              ; Check if data is ready (bit 0)
; ;     jz waitData_Ready1     ; If not ready, wait
; ;     mov dx, 3F8H           ; Receive Buffer Register
; ;     in al, dx              ; Read data
; ;     cmp al, 0FFh           ; Check for marker (start of data)
; ;     jnz readInd            ; If not marker, wait again

;     ; Read BALL_X
; ; readBallX:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitData_Ready2:
; ;     in al, dx              ; Read Line Status
; ;     and al, 1              ; Check if data is ready (bit 0)
; ;     jz waitData_Ready2     ; If not ready, wait
; ;     mov dx, 3F8H           ; Receive Buffer Register
; ;     in al, dx              ; Read data
; ;     mov byte ptr BALL_X_REC, al
; ;     add BALL_X_REC, 161    ; Adjust value (if needed)

; ;     ; Read BALL_Y
; ; readBallY:
; ;     mov dx, 3FDH           ; Line Status Register
; ; waitData_Ready3:
; ;     in al, dx              ; Read Line Status
; ;     and al, 1              ; Check if data is ready (bit 0)
; ;     jz waitData_Ready3     ; If not ready, wait
; ;     mov dx, 3F8H           ; Receive Buffer Register
; ;     in al, dx              ; Read data
; ;     mov byte ptr BALL_Y_REC, al
; ;     add BALL_Y_REC, 161    ; Adjust value (if needed)

;     ; Read paddleX
;     mov dx, 3FDH           ; Line Status Register


;     in al, dx              ; Read Line Status
;     and al, 1              ; Check if data is ready (bit 0)
;     jz skip     ; If not ready, wait
;     mov dx, 3F8H           ; Receive Buffer Register
;     in al, dx              ; Read data
;     mov ah, 0
;     mov paddleX2, ax
;     add paddleX2, 161      ; Adjust value (if needed)

;         skip:
;     ret
; RecCom endp

; ; exit:
; ;     mov ah, 4ch
; ;     int 21h 

end COM_INIT

