global _start

section .data
	SYS_EXIT equ 60
    lpCnt dq 5
	num db 7

    isPrime db 1
    counter db 2

section .text
_start:
    mov rcx, qword[lpCnt]
	mov rax, 1

check_prime:
    mov cl, byte[num]           ; cl = num
    cmp byte[counter], cl          
    je is_prime                 ; counter = num, divisible by itself (and 1) only --> is prime

    mov ax, 0                   ; ax = 0
    mov al, byte[num]           ; bl = 7           
    div byte[counter]           ; num / counter
    cmp ah, 0
    je is_not_prime             ; no remainder, divisible by another number --> is not prime

    inc byte[counter]           ; increment counter
    jmp check_prime             ; loop back

is_prime:
    mov byte[isPrime], 1        ; isPrime is true
    jmp exit_here

is_not_prime:
    mov byte[isPrime], 0        ; isPrime is false
    jmp exit_here

exit_here:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall