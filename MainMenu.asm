
.MODEL SMALL
.STACK 64
.DATA
;All displayed lines 
text_main_menu_title db 'WELCOME TO BRICK BREAKER$'
text_main_menu_select_options db 'PLEASE SELECT OPTIONS$'
text_main_menu_play_game db 'PRESS ENTER TO PLAY GAME$'
text_main_menu_instruction db 'PRESS I TO GO INTO INSTRUCTION BOX$'



MAIN_MENU_POS equ 0515h

.CODE
MAIN PROC
mov ax,@DATA
mov ds,ax
xor ax,ax

call ClearScreen_proc

call MainMenu_proc

call ClearScreen_proc




  ; terminate the program
    mov AH, 4CH
    int 21H

MAIN ENDP

MainMenu_proc proc NEAR
;//////////
mov dx,MAIN_MENU_POS
lea bx,TEXT_MAIN_MENU_TITLE
call DisplayColoredString_proc
inc dh
inc dh
;/////////////
call MoveCursor_proc
push dx
lea dx,TEXT_MAIN_MENU_SELECT_OPTIONS
call DisplayString_proc
pop dx

inc dh
inc dh

call MoveCursor_proc
push dx
lea dx,TEXT_MAIN_MENU_PLAY_GAME
call DisplayString_proc
pop dx

inc dh
inc dh

call MoveCursor_proc
push dx
lea dx,TEXT_MAIN_MENU_INSTRUCTION
call DisplayString_proc
pop dx

loopTillPressed:
mov ah,0
int 16h

cmp ah,17h
je endLoop
cmp ah,1Ch
je endLoop
jmp loopTillPressed

endLoop:

ret
MainMenu_proc ENDP

   
ClearScreen_proc  proc NEAR

  mov ax,0600h
mov bh,07 
mov cx,0 
mov dx,184FH
 int 10h
 RET
ClearScreen_proc ENDP


DisplayString_proc  proc NEAR
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
mov bh,0
mov ah,2
int 10h
RET

MoveCursor_proc ENDP




END MAIN
