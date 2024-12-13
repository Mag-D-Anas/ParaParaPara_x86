.MODEL SMALL
.STACK 64
.DATA
    ; All displayed lines
    text_main_menu_title db 'WELCOME TO BRICK BREAKER$'
    text_main_menu_select_options db 'PLEASE SELECT OPTIONS$'
    text_main_menu_play_game db 'PRESS ENTER TO PLAY GAME$'
    text_main_menu_instruction db 'PRESS I TO GO INTO INSTRUCTION BOX$'
    text_main_menu_chat db 'PRESS C TO CHAT $'
    
    MAIN_MENU_POS equ 0505h

.CODE
MAIN PROC
    mov ax,@DATA
    mov ds,ax
    xor ax,ax

    mov ah, 0              
    mov al, 13              
    int 10h 

    call MainMenu_proc
    call ClearScreen_proc

    ; terminate the program
    mov AH, 4CH
    int 21H
MAIN ENDP

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
    lea dx,text_main_menu_instruction
    call DisplayString_proc
    pop dx

    inc dh
    inc dh

    call MoveCursor_proc
    push dx
    lea dx,text_main_menu_chat
    call DisplayString_proc
    pop dx

loopTillPressed:
    mov ah,0
    int 16h
    
    cmp ah,17h   ; 'I' key
    je pressed
    cmp ah,1Ch   ; Enter key
    je pressed
    cmp ah,2Eh   ; 'C' key
    je pressed
    
    jmp loopTillPressed

pressed:
    ret
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

END MAIN