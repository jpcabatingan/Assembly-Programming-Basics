global _start
global get_strlen
global jejenerate

section .data
    NULL equ 0
    SYS_EXIT equ 60
    ; string db 'aeiou', NULL          ; the word to be converted
    string db 'hello everyone', NULL    
    strlen dq 0

section .bss
    string1 resb 20

section .text

_start:
    mov rdi, string
    mov rsi, strlen
    call get_strlen

    mov rcx, qword[strlen]
    mov rsi, string
    mov rdi, string1    ; stores result
    call jejenerate     ; call jeje generator

exit_here:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

get_strlen:                     ; get length of word
    len_loop:
        mov al, byte[rdi]
        cmp al, NULL
        je return

        inc rdi
        inc byte[rsi]
        jmp len_loop
    
    return:
        ret

jejenerate:
    compare_vowels:
        lodsb

    check_vowel:
        cmp al, "a"         ; check if each character is a vowel
        je vowel_a

        cmp al, "e"
        je vowel_e

        cmp al, "i"
        je vowel_i

        cmp al, "o"
        je vowel_o

        cmp al, "u"
        je vowel_u

        stosb               ; directly copy when not vowel
        jmp move_forward

        vowel_a:                ; convert to equivalent character
            mov al, "@"
            stosb
            jmp move_forward
        vowel_e:
            mov al, "3"
            stosb
            jmp move_forward
        vowel_i:
            mov al, "1"
            stosb
            jmp move_forward
        vowel_o:
            mov al, "0"
            stosb
            jmp move_forward
        vowel_u:
            mov al, "U"
            stosb
            jmp move_forward

    move_forward:
        loop compare_vowels         ; go back to loop
    
    ret                             ; return generated word