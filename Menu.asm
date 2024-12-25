
extrn GAME:FAR
extrn CHAT:FAR

.MODEL SMALL
.STACK 64
.DATA
    ; All displayed lines
    text_main_menu_title db 'WELCOME TO BRICK BREAKER$'
    text_main_menu_select_options db 'PLEASE SELECT OPTIONS$'
    text_main_menu_play_game db 'PRESS ENTER TO PLAY GAME$'
    text_main_menu_chat db 'PRESS C TO CHAT $'
    text_main_menu_exit db 'PRESS esc TO EXIT $'
    
    MAIN_MENU_POS equ 0505h

    key_pressed db 0
.CODE
MENU PROC
    mov ax,@DATA
    mov ds,ax
    xor ax,ax

  

start:

   mov ah, 0              
    mov al, 13              
    int 10h 
   
    call MainMenu_proc
    call GetKey_proc

    cmp key_pressed, 01h  ; Esc key
    je endMenu

    cmp key_pressed, 1Ch  ; Check if Enter key is pressed
    je callGame

    cmp key_pressed, 2Eh  ; Check if 'C' key is pressed
    je callChat

    callGame:
        call GAME
        jmp start

    callChat:
        call CHAT
        jmp start

    endMenu:
      mov      ah, 4Ch
    int      21h
MENU ENDP


MainMenu_proc proc NEAR

    
    ;////////// 
    mov dx,MAIN_MENU_POS
    lea bx,text_main_menu_title
    call DisplayColoredString_proc
    
    inc dh
    inc dh
    ;///////////// 
    call MoveCursor_proc
    push dx
    lea dx,text_main_menu_select_options
    call DisplayString_proc
    pop dx

    inc dh
    inc dh

    call MoveCursor_proc
    push dx
    lea dx,text_main_menu_play_game
    call DisplayString_proc
    pop dx
    
    inc dh
    inc dh

    call MoveCursor_proc
    push dx
    lea dx,text_main_menu_chat
    call DisplayString_proc
    pop dx



     inc dh
    inc dh

    call MoveCursor_proc
    push dx
    lea dx,text_main_menu_exit
    call DisplayString_proc
    pop dx


    ret                  ; Return from the routine (optional)
MainMenu_proc ENDP


ClearScreen_proc proc NEAR
    mov ax,0600h    ; Scroll window up function
    mov bh,07h      
    mov cx,0        
    mov dx,184FH    
    int 10h
    RET
ClearScreen_proc ENDP

DisplayString_proc proc NEAR
    mov ah,9
    int 21h
    RET
DisplayString_proc ENDP

DisplayColoredString_proc proc NEAR
    mov si, bx        
push dx
print_char_colored:
    lodsb             
    cmp al, '$'       
    je done         

    call MoveCursor_proc    
    mov ah, 09h        
    mov bh, 0          
    mov bl, 0Eh        
    mov cx, 1          
    int 10h            
    inc dl           
    jmp print_char_colored

done:
pop dx

    ret
DisplayColoredString_proc ENDP

MoveCursor_proc proc NEAR
    mov bh,0h      ; Page 1
    mov ah,2
    int 10h
    RET
MoveCursor_proc ENDP


 GetKey_proc proc NEAR
loopTillPressed:
    mov ah, 0          ; Function 0: Get keyboard input
    int 16h            ; BIOS interrupt for keyboard input

    cmp ah, 17h        ; Check if 'I' key scan code
    je storeKey
    cmp ah, 1Ch        ; Check if Enter key scan code
    je storeKey
    cmp ah, 2Eh        ; Check if 'C' key scan code
    je storeKey
    cmp ah, 01h        ; Check if Escape key scan code
    je storeKey

    jmp loopTillPressed ; Continue looping if no match

storeKey:
    mov key_pressed, ah ; Store the scan code in key_pressed
    ; Add additional logic here if necessary
    RET
GetKey_proc ENDP

END MENU