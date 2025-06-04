global _start
global get_choice
global get_seconds
global convert_seconds_to_minutes
global convert_seconds_to_hours

global display_message

section .data
    ; prompts
	menu db 10, "************MENU***********", 10
     db "[1] Convert to Minutes", 10
     db "[2] Convert to Hours", 10
     db "[0] Exit", 10
     db "**************************", 10
     db "Choice: "
    menuLength equ $ - menu


    invalidChoice db 10, "Invalid choice!", 10
	invalidChoiceLength equ $-invalidChoice

    goodbye db "Goodbye!", 10
	goodbyeLength equ $-goodbye

    enterSeconds db 10, "Enter time in seconds (5-digits): "
	enterSecondsLength equ $-enterSeconds

section .bss
    choice resb 2
    seconds resb 6
    minutes resb 10
    hours resb 10

section .text
_start:
    ; input choice cases
	prompt_loop:
		; display menu
		mov rsi, menu
		mov rdx, menuLength
		call display_message
		call get_choice
		
		cmp byte[choice], '1'
		je choice_minutes

		cmp byte[choice], '2'
		je choice_hours

		cmp byte[choice], '0'
		mov rsi, goodbye
		mov rdx, goodbyeLength
		call display_message
		je exit_here
	
	; choice not in options
	invalid_choice:
		mov rsi, invalidChoice
		mov rdx, invalidChoiceLength
		call display_message
		jmp prompt_loop

	; operations ----------------------------------
    choice_minutes:
        mov rsi, enterSeconds
        mov rdx, enterSecondsLength
		call display_message
        call get_seconds

        ; convert seconds to minutes
        mov rsi, seconds
        mov rdi, minutes
        call convert_seconds_to_minutes
        jmp prompt_loop

    choice_hours:
        mov rsi, enterSeconds
        mov rdx, enterSecondsLength
		call display_message
        call get_seconds

        ; convert seconds to minutes
        mov rsi, seconds
        mov rdi, hours
        call convert_seconds_to_hours
        jmp prompt_loop

exit_here:
	mov rax, 60
	xor rdi, rdi
	syscall

; display or output strings
display_message:
	mov rax, 1
	mov rdi, 1
	syscall
	ret

; get menu choice
get_choice:
	mov rax, 0
	mov rdi, 0
	lea rsi, [choice]
	mov rdx, 2
	syscall
	ret

; get seconds to convert
get_seconds:
	mov rax, 0
	mov rdi, 0
	lea rsi, [seconds]
	mov rdx, 6
	syscall
	ret

; convert seconds to minutes
convert_seconds_to_minutes:
    mov rsi, seconds
    call ascii_to_int        

    xor rdx, rdx
    mov rbx, 60
    div rbx                  

    mov rdi, minutes         
    call int_to_ascii

    mov rsi, minutes
    mov rdx, 6              
    call display_message
    ret

; convert seconds to hours
convert_seconds_to_hours:
    mov rsi, seconds
    call ascii_to_int     

    xor rdx, rdx
    mov rbx, 3600
    div rbx               

    mov rdi, hours
    call int_to_ascii

    mov rsi, hours
    mov rdx, 6
    call display_message
    ret
   
; convert ascii input to int so we can run arithmetic operations
ascii_to_int:
    xor rax, rax      
    xor rcx, rcx

	next_character:
	    movzx rbx, byte [rsi + rcx]
	    cmp bl, 10         
	    je return
	    cmp bl, '0'
	    jb return
	    cmp bl, '9'
	    ja return
	    sub bl, '0'
	    imul rax, rax, 10
	    add rax, rbx
	    inc rcx
	    jmp next_character
	
	return:
	    ret
    
; convert int back to ascii so we can display results
int_to_ascii:
    mov rcx, 0

	loop_reverse:
	    xor rdx, rdx
	    mov rbx, 10
	    div rbx
	    add dl, '0'
	    push rdx
	    inc rcx
	    test rax, rax
	    jnz loop_reverse
	
	loop_digits:
	    pop rax
	    mov [rdi], al
	    inc rdi
	    loop loop_digits
	    mov byte [rdi], 10    
	    inc rdi
	    mov byte [rdi], 0
	    ret

