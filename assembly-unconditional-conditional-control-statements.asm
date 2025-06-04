global _start

section .data
	SYS_EXIT equ 60
	a db 7
    b db 15
    c db 21
	largestInput db 'A'
    largestNum db 0

section .text
_start:
	mov al, byte[a]		; al = a
	cmp al, byte[b]
	jb b_greater         ; a < b or b > a

    cmp al, byte[c]
    jb c_largest        ; a < c or c > a, hence C is largest

    mov byte[largestInput], 'A'    ; largestInput = A
    mov byte[largestNum], al       ; largestNum = value of a

	jmp exit_here

b_greater:  
    mov al, byte[b]                 ; al = b
    cmp al, byte[c]        
    jb c_largest                    ; b < c or c > a, hence C is largest

    mov byte[largestInput], 'B'    ; largestInput = B
    mov byte[largestNum], al        ; largestNum = value of b

    jmp exit_here

c_largest:
    mov al, byte[c]                ; al = c
    mov byte[largestInput], 'C'    ; largestInput = C
    mov byte[largestNum], al        ; largestNum = value of c

    jmp exit_here

exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall