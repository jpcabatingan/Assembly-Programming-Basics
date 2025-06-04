global _start

section .data
    SYS_EXIT equ 60
    age db 25
    days dd 365
    hours dq 8760


section .text
_start:

    ; days = days * age     dd * db
    ; storing days*age in days
    mov eax, 0
    mov al, byte [age]              ; store age in al register
    mul dword[days]                 ; result in ax
    mov word [days], ax
    mov word [days + 2], dx         ; store in upper quarter

    ; hours = hours * age
    ; storing hours*age in hours
    mov rax, 0
    mov al, byte [age]              ; store age in al register
    mul qword [hours]               ; result in edx:eax
    mov dword [hours], eax
    mov dword [hours + 4], edx      ; store in upper half


    exit_here:
        mov rax, SYS_EXIT
        xor rdi, rdi
        syscall