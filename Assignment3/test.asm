extern fopen
extern fgets
extern fclose
extern printf
extern exit

global main

segment .data

	readmode: db "r",0
	filename: db "testfile.txt",0 ; filename to open
	error1: db "Cannot open file",10,0
	format_1: db "%d",0



segment .bss
	buflen: equ 256 ; buffer length
	buffer: resd buflen ; input buffer



segment .text

main:
	pusha

	; OPENING FILE FOR READING
	push readmode ; 1- push pointer to openmode   
	push filename ; 2- push pointer to filename
	call fopen ; fopen retuns a filehandle in eax
	add esp, 8 ; or 0 if it cannot open the file
	cmp eax, 0
	jnz .L1   
	push error1 ; report an error and exit
	call printf
	add esp, 4
	jmp .L4

; READING FROM FILE   
.L1:
	mov ebx, eax ; save filepointer of opened file in ebx

	; Get first line and pass to ecx
	push ebx
	push dword buflen
	push buffer
	call fgets
	add esp, 12
	cmp eax, 0
	je .L3
	
	;convert string -> numeric
	push buffer
	call parseInt
	mov ecx, eax

.L2:
;debug
	push ecx
	push format_1
	call printf
	add esp, 8
	push ebx ; 1- push filehandle for fgets
	push dword buflen ; 2- push max number of read chars
	push buffer ; 3- push pointer to text buffer
	call fgets ; get a line of text
	add esp, 12 ; clean up the stack
	cmp eax, 0 ; eax=0 in case of error or EOF
	je .L3
	push buffer ; output the read string
	call printf
	add esp, 4 ; clean up the stack
	dec ecx
	cmp ecx, 0
	jg .L2

;CLOSING FILE
.L3:
	push ebx ; push filehandle
	call fclose ; close file
	add esp, 4 ; clean up stack

.L4:
	popa
	call exit

parseInt:   
	push ebp
	mov ebp, esp
	push ebx
	push esi
	mov esi, [ebp+8] ; esi points to the string

	xor eax, eax ; clear the accumulator

.I1:
	cmp byte [esi], 0 ; end of string?
	je .I2
	mov ebx, 10
	mul ebx ; eax *= 10
	xor ebx, ebx
	mov bl, [esi] ; bl = character
	sub bl, 48 ; ASCII conversion
	add eax, ebx
	inc esi
	jmp .I1



.I2:
	pop esi
	pop ebx
	pop ebp
	ret 4
