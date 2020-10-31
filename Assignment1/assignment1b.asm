;
; Anthony Johns lab 1b
;

section .data

	msg db 'What is your name?', 0xA	; our first string
	len equ $ - msg				; length of our first string
	msg2 db 'Hello, '			; our second string
	len2 equ $ -msg2			; length of out second string

section .bss
	username: resb 40			; user input variable

section .text					; section declaration
	global _start				; must be declared for linker (ld)

_start:                                         ; tell linker entry point

	mov eax, 4                              ; system call number (sys_write)
	mov ebx, 1                              ; file descriptor (stdout)
	mov ecx, msg                            ; Print message ("What is your name")
	mov edx, len                            ; length of message
	int 0x80                                ; call kernel
        
	mov eax, 3				; sysCall, sys.read                                        
 	mov ebx, 0				; source: stdIn()
	mov ecx, username			; user input stored in user name
	mov edx, 40				; length: must be less that 40 chars
	int 0x80				; call kernel

	mov eax, 4				; system call number (sys_write)
	mov ebx, 1				; file descriptor (stdout)
	mov ecx, msg2				; print message ("Hello, ")
	mov edx, len2				; length of message
	int 0x80				; call Kernel

	mov eax, 4				; system call number (sys_write)       
	mov ebx, 1				; file descriptor (stdout)
	mov ecx, username			; Print the user name
	mov edx, 40				; user name max length
	int 0x80        			; call kernel

                                		; final exit
	mov eax,1                               ; system call number (sys_exit)
	xor ebx,ebx                             ; sys_exit return status
	int 0x80                                ; call kernel
