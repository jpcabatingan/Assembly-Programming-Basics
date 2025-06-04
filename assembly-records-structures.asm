global _start

global display_message
global get_choice
global find_patient
global edit_patient
global print_patients


section .data
	; prompts
	menu db 10, "[1] Add Patient", 10, "[2] Edit Patient", 10, "[3] Print Patients", 10, "[4] Exit", 10, "Enter choice: "
	menuLength equ $-menu

	invalidChoice db 10, "Invalid choice!", 10
	invalidChoiceLength equ $-invalidChoice

	fullPrompt db "Record is already full!", 10
	fullPromptLength equ $-fullPrompt

	addPatID db 10, "Enter Patient ID: "		;Use this prompt for add and edit
	addPatIDLength equ $-addPatID

	addSex db "Enter sex (F - Female, M - Male): "
	addSexLength equ $-addSex

	addStatus db "Enter status (1 - out-patient, 2 - admitted, 3 - discharged): " ;Use this prompt for add and edit
	addStatusLength equ $-addStatus

	addDiagnosis db "Enter diagnosis: "
	addDiagnosisLength equ $-addDiagnosis

	printPatID db 10, "Patient ID: "
	printPatIDLength equ $-printPatID

	printSex db 10, "Sex: "
	printSexLength equ $-printSex

	printStatus db 10, "Status: "
	printStatusLength equ $-printStatus

	printDiagnosis db 10, "Diagnosis: "
	printDiagnosisLength equ $-printDiagnosis

	cannotEdit db "Cannot edit records of a discharged patient.", 10
	cannotEditLength equ $-cannotEdit

	cannotFind db "Patient not found!", 10
	cannotFindPrompt equ $-cannotFind

	newLine db 10
	newLineLength equ $-newLine

	; additional prompts
	emptyPrompt db "Records are empty!", 10
	emptyPromptLength equ $-emptyPrompt

	goodbye db "Goodbye!", 10
	goodbyeLength equ $-goodbye

	; for classifications
	sexFemale db "Female"
	sexFemaleLength equ $ - sexFemale

	sexMale db "Male"
	sexMaleLength equ $ - sexMale

	statusOutpatient db "Out-patient"
	statusOutpatientLength equ $ - statusOutpatient
	
	statusAdmitted db "Admitted"
	statusAdmittedLength equ $ - statusAdmitted

	statusDischarged db "Discharged"
	statusDischargedLength equ $ - statusDischarged

	; array
	arraysize equ 5

	; structure
	patient_record equ 46       ; total size of structure
	patientId equ 0             ; starting address of patientId
	patientIdLength equ 11      ; starting address of patientId
	sex equ 12                  ; starting address of sex
	sexLength equ 13            ; starting address of sexLength
	status equ 14               ; starting address of status
	statusLength equ 15         ; starting addreess of statusLength
	diagnosis equ 16            ; starting address of diagnosis
	diagnosisLength equ 30		; starting address of diagnosisLength

	; string for editing search
	strlen db 0
	
section .bss
	choice resb 2
	string1 resb 11
	patient resb patient_record				; patient structure
	record resb patient_record*arraysize	; array of patient structures
	
section .text
_start:
	; current index / counter for array elements
	mov r10, 0
	mov r12, 0

	; input choice cases
	prompt_loop:
		; display menu
		mov rsi, menu
		mov rdx, menuLength
		call display_message
		call get_choice
		
		cmp byte[choice], '1'
		je choice_add

		cmp byte[choice], '2'
		je choice_edit

		cmp byte[choice], '3'
		je choice_print

		cmp byte[choice], '4'
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

	; add patient
	choice_add:
		cmp r10, arraysize
		je error_records_full

		call add_patient
		inc r10
		 
		jmp prompt_loop

	; edit patient
	choice_edit:
		; check if there are elements to edit
		cmp r10, 0
		je error_records_empty

		; display prompt
		mov rsi, addPatID
		mov rdx, addPatIDLength
		call display_message

		mov byte[string1], 0
		; get input
		mov rax, 0
		mov rdi, 0
		mov rsi, string1
		mov rdx, 11
		syscall
		dec rax
		mov byte[strlen], al

		mov rdi, string1
		movzx rcx, byte [strlen]
		
		mov rax, 0
		; check if patient exists
		call find_patient
		cmp rax, -1
		je error_cannot_find

		mov r11, rax

		; edit patient
		call edit_patient
		cmp rax, -1
		je error_cannot_edit

		jmp prompt_loop
	
	; print patient records
	choice_print:
		; check if there are elements to print
		cmp r10, 0
		je error_records_empty

		call print_patients

		jmp prompt_loop

	; error messages ---------------------------
	; full array
	error_records_full:
		mov rsi, fullPrompt
		mov rdx, fullPromptLength
		call display_message
		jmp prompt_loop
	
	; cannot edit discharged patient
	error_cannot_edit:
		mov rsi, cannotEdit
		mov rdx, cannotEditLength
		call display_message
		jmp prompt_loop

	; patient does not exist
	error_cannot_find:
		mov rsi, cannotFind
		mov rdx, cannotFindPrompt
		call display_message
		jmp prompt_loop
	
	; no elements in array
	error_records_empty:
		mov rsi, emptyPrompt
		mov rdx, emptyPromptLength
		call display_message
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
	
; add new patient
add_patient:
	; get patientId  --------------------------

	; display prompt
	mov rsi, addPatID
	mov rdx, addPatIDLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + patientId]
	mov rdx, 11
	syscall
	
	dec rax
	mov byte[patient + patientIdLength], al

	; get sex  --------------------------

	; display prompt
	mov rsi, addSex
	mov rdx, addSexLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + sex]
	mov rdx, 2
	syscall
	
	dec rax
	mov byte[patient + sexLength], al
	

	; get status  --------------------------

	; display prompt
	mov rsi, addStatus
	mov rdx, addStatusLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + status]
	mov rdx, 2
	syscall
	
	dec rax
	mov byte[patient + statusLength], al
	
	; get diagnosis  --------------------------

	; display prompt
	mov rsi, addDiagnosis
	mov rdx, addDiagnosisLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + diagnosis]
	mov rdx, diagnosisLength
	syscall
	
	dec rax
	mov byte[patient + diagnosisLength], al

	; add to array of patient structures
	mov rax, r10                			
	imul rax, patient_record					
	lea rsi, [patient] 
	lea rdi, [record + rax]	     
	mov rcx, patient_record      			
	cld
	rep movsb                 		

	ret

; find existence of patient
find_patient:
	; counters / iterators
	mov r11, 0
	mov r12, r10

	find_patient_loop:
		; check if array has been exhausted
		cmp r12, 0
		je not_found

		; go to each patient record in array
		mov rax, r11
		imul rax, patient_record
		lea rbx, [record + rax]

		; compare lengths
		mov al, [rbx + patientIdLength]
		cmp al, [strlen]
		jne next_record

		; compare patientId in database with input patientID
		movzx rcx, al
		lea rdi, [rbx + patientId]
		lea rsi, [string1]
		push rdi
		push rsi
		push rcx
		repe cmpsb
		pop rcx
		pop rsi
		pop rdi
		jz found

		; go to next patient
		next_record:
			inc r11
			dec r12
			jmp find_patient_loop

	; patient exists
	found:
		mov rax, r11
		ret

	; patient does not exist
	not_found:
		mov rax, -1
		ret


; edit selected patient
edit_patient:
	; go to specific patient record in array
	mov rax, r11
	imul rax, patient_record
	lea rbx, [record + rax]

	; check first if patient has been discharged
	cmp byte[rbx + status], '3'
	je cannot_edit

	; edit patientID ----------------------------------

	; display prompt
	mov rsi, addPatID
	mov rdx, addPatIDLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + patientId]
	mov rdx, 11
	syscall
	
	dec rax
	mov byte[patient + patientIdLength], al

	; edit sex ---------------------------------------

	; display prompt
	mov rsi, addSex
	mov rdx, addSexLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + sex]
	mov rdx, 2
	syscall
	
	dec rax
	mov byte[patient + sexLength], al

	; edit status ------------------------------------

	; display prompt
	mov rsi, addStatus
	mov rdx, addStatusLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + status]
	mov rdx, 2
	syscall
	
	dec rax
	mov byte[patient + statusLength], al

	; edit diagnosis ---------------------------------

	; display prompt
	mov rsi, addDiagnosis
	mov rdx, addDiagnosisLength
	call display_message

	; get input
	mov rax, 0
	mov rdi, 0
	lea rsi, [patient + diagnosis]
	mov rdx, diagnosisLength
	syscall
	
	dec rax
	mov byte[patient + diagnosisLength], al

	; update patient record
	lea rsi, [patient]
	lea rdi, [rbx]
	mov rcx, patient_record
	cld
	rep movsb

	jmp return

	; discharged patient
	cannot_edit:
		mov rax, -1
		jmp return
	
print_patients:
	; counters / iterators
    mov r11, 0
	mov r12, r10

	print_loop:
		; check if all patient records have been printed already
		cmp r12, 0
		je return

		; go to patient record in array
		mov rax, r11
		imul rax, patient_record
		lea rbx, [record + rax]

		; print patientId
		print_patientID:
			mov rsi, printPatID
			mov rdx, printPatIDLength
			call display_message

			mov rax, 1
			mov rdi, 1
			lea rsi, [rbx + patientId]
			mov dl, byte[rbx + patientIdLength]
			syscall

		; print sex
		print_sex:
			mov rsi, printSex
			mov rdx, printSexLength
			call display_message

			cmp byte[rbx + sex], 'F'
			je sex_female
			cmp byte[rbx + sex], 'M'
			je sex_male

		sex_female:
			mov rsi, sexFemale
			mov rdx, sexFemaleLength
			call display_message
			jmp print_status

		sex_male:
			mov rsi, sexMale
			mov rdx, sexMaleLength
			call display_message
			jmp print_status

		; print status
		print_status:
			mov rsi, printStatus
			mov rdx, printStatusLength
			call display_message

			cmp byte[rbx + status], '1'
			je status_outpatient
			cmp byte[rbx + status], '2'
			je status_admitted
			cmp byte[rbx + status], '3'
			je status_discharged

		status_outpatient:
			mov rsi, statusOutpatient
			mov rdx, statusOutpatientLength
			call display_message
			jmp print_diagnosis

		status_admitted:
			mov rsi, statusAdmitted
			mov rdx, statusAdmittedLength
			call display_message
			jmp print_diagnosis

		status_discharged:
			mov rsi, statusDischarged
			mov rdx, statusDischargedLength
			call display_message
			jmp print_diagnosis

		; print diagnosis
		print_diagnosis:
			mov rsi, printDiagnosis
			mov rdx, printDiagnosisLength
			call display_message

			mov rax, 1
			mov rdi, 1
			lea rsi, [rbx + diagnosis]
			mov dl, byte[rbx + diagnosisLength]
			syscall

		; print new line
		mov rsi, newLine
		mov rdx, newLineLength
		call display_message

		; update counters / iterators
		dec r12
		mov r13, r10
		sub r13, r12 
		mov r11, r13
		
		jmp print_loop

return:
    ret

