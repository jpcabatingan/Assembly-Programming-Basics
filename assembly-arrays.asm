global _start
global find_largest
global new_largest
global not_negative
global found_largest

section .data
	SYS_EXIT equ 60
	; num_arr dw -7, -2, -3, -4, -5
    num_arr dw 0, -2, -4, -4, -5
    ; num_arr dw -1, -2, 3, 4, -5
	
section .bss
    all_negative resb 1                 ; reserved for all_negative
	largest resw 1                      ; reserved for lagest value

section .text
_start:
    mov rdi, 0                           ; iteration counter
    mov rsi, num_arr

    mov byte[all_negative], 1           ; initialize all_negative to true until contradicted 
    mov word[largest], -1               ; initialize largest value to -1

    mov rcx, all_negative               ; pass as parameter                         
    mov rdx, largest                     ; pass as parameter      
    
    ; mov rcx, 1                          ; initialize all_negative to true until contradicted 
    ; mov rdx, -1                         ; initialize largest value to -1

    call find_largest                   ; get final largest value
    
exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

find_largest:
    mov ax, word[rsi + rdi * 2]         ; store current index value in ax

    loop_largest:
        call not_negative               ; check if it contradicts all negative
        call new_largest                ; check if it is the new largest value

        inc rdi                         ; increment loop counter
        cmp rdi, 5
        jl loop_largest                 ; continue loop

    call found_largest
    ret

new_largest:
    mov ax, word[rsi + rdi * 2]         ; store current index value
    cmp ax, word[rdx]                   ; compare current index value to current highest
    jg new_largest_true                 ; current index value is higher

    ret

    new_largest_true:
        mov word[rdx], ax               ; update current largest
        ret

not_negative:
    mov ax, word[rsi + rdi * 2]             ; store current index value
    cmp ax, 0                               ; check if value is positive
    jge positive                             ; value is positive

    ret

    positive:
        mov byte[rcx], 0                          ; found a case where values are not all negative
        ret

found_largest:
    cmp byte[rcx], 1              ; all_negative == 1 ?
    je all_neg              ; all values are negative

    ret
    
    all_neg:
        mov word[rdx], -1         ; all values are negative, so highest value is set to -1
        ret