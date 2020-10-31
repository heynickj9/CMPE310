; File: assignment2.asm
; Anthony Johns
;
; This program implements the Hamming (8,4) ECC.
; Input is limited to 8 characters (minimum and maximum).
;
; Encoding format:
;                 ------------------------------------------------
; bit position    | 8   | 7   | 6   | 5   | 4   | 3   | 2   | 1  |
;                 ------------------------------------------------
; parity order    | p4  | d4  | d3  | d2  | p3  | d1  | p2  | p1 |
;                 ------------------------------------------------     
;
;
;

%define STDIN         0
%define STDOUT        1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN        9
extern	printf


        section .data                                   ; section declaration

msg     db  'Input Data: '                              ; Input prompt
len     equ $ - msg                                     ; length of input prompt


msgI    db  'Invalid Data!',0Ah                         ; Invalid data message
lenI    equ $ - msgI                                    ; length of invalid data message


msgE    db  'Two or more bit errors detected!',0Ah      ; Two or more bit errors detected
lenE    equ $ - msgE                                    ; length of two or more bit errors detected


bitE    db  'Bit error detected at position: '          ; Bit error string
lenBE   equ $ - bitE                                    ; length of bit error string

msgC    db  0Ah, 'Corrected bit sequence: ',            ; Corrected string
lenC    equ $ - msgC                                    ; length of corrected string


msgA    db  'Overall Parity Error Detected',0Ah         ; our string
lenA    equ $ - msgA                                    ; length of our string

bitNE   db  'No Error Detected',0Ah                     ; our string
lenNE   equ $ - bitNE                                   ; length of our string


        section .bss                                    ; section declaration
temp    resb BUFLEN+10                                  ; our string
binD    resb 1                                          ; original binary
pos     resb 2                                          ; bit error position
result  resb 32                                     	; corrected result
p4	resb 4                                        	;reserving space for each bit
p3	resb 4
p2	resb 4
p1	resb 4
d4	resb 4
d3	resb 4
d2	resb 4
d1	resb 4
                          
        section .text                                   ; Code section.
        global main

main:   
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,msg                                 ; message to write
        mov     edx,len                                 ; message length
        int     80h                                     ; call kernel


        mov     eax,SYSCALL_READ                        ; system call number (sys_read)
        mov     ebx,STDIN                               ; file descriptor (stdin)
        mov     ecx,temp                                ; message to write
        mov     edx,BUFLEN+10                           ; message length
        int     80h                                     ; call kernel

        cmp     eax,BUFLEN                              ; check to see if user input exceeded limit                 
        jg      invalid                                 ; if exceeded, print invalid message

initbin:                                                ; sequence that converts user input in ASCII to binary
        mov     edx, temp                               ; initialize EDX with the address of user input
        xor     edi, edi                                ; initialize EDI for index tracking
        mov     ecx, BUFLEN-1                           ; initialize counter ECX to keep track of user input
        mov     ebx, 0                                  ; initialize EBX, which will eventually hold the ...
                                                        ; ... converted binary in its upper byte BH

binchk:                                                 ; loop that converts user input to binary 
        mov     bl, byte[edx+edi]                       ; BL will initially hold each character in the user input     
        inc     edi                                     ; proceed to next character index
        sub     bl, '0'                                 ; determine the decimal equivalent of the character
        cmp     bl, 1                                   ; this comparison additionally checks for invalid characters
        jg      invalid                                 ; if the user input an invalid character print invalid message
        shl     bh, 1                                   ; shift value in BH by one bit position to accomodate the ...
        xor     bh, bl                                  ; ... next converted bit
        loop    binchk                                  ; loop instruction performs a jmp after decrementing ECX by one ...
                                                        ; ... if ECX is 0, no jmp is performed and the next instruction ...
                                                        ; ... is executed

begin:                                                  ; implement your parity checker here
                                                        ; call/jmp to appropriate routine when necessary

	mov	byte[binD], bh				; places the binary string into a memory location
	mov	eax, [binD]				; places the binary string into the accumulator
	mov	ebx, 0000b				; next 4 lines set registers to start value
	mov	ecx, 0000b
	mov	edx, 0000b
	mov	edi, 9	
	mov	byte[p4], 0000b				; next 8 lines set default value at memory location
	mov	byte[p3], 0000b
	mov	byte[p2], 0000b
	mov	byte[p1], 0000b	
	mov	byte[d4], 0000b	
	mov	byte[d3], 0000b	
	mov	byte[d2], 0000b	
	mov	byte[d1], 0000b	

bit0:							; defines variable p1 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit1					; if the carry is a 0, move to the next bit 
        mov     byte[p1], 0001b				; if the carry is a 1, define the variable as binary value 0001
        jmp	bit1

bit1:							; defines variable p2 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit2					; if the carry is a 0, move to the next bit 
        mov     byte[p2], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit2

bit2:							; defines variable d1 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit3					; if the carry is a 0, move to the next bit 
        mov     byte[d1], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit3
        
bit3:							; defines variable p3 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit4					; if the carry is a 0, move to the next bit 
        mov     byte[p3], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit4

bit4:							; defines variable d2 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit5					; if the carry is a 0, move to the next bit 
        mov     byte[d2], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit5
        
bit5:							; defines variable d3 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit6					; if the carry is a 0, move to the next bit 
        mov     byte[d3], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit6

bit6:							; defines variable d4 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     bit7					; if the carry is a 0, move to the next bit 
        mov     byte[d4], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	bit7
        
bit7:							; defines variable p4 with a binary string based on its value
        shr	eax, 1					; move the lowest bit to the carry flag
        jnc     p4check					; if the carry is a 0, move to the next bit 
        mov     byte[p4], 0001b				; if the carry is a 1, define the variable as binary value 0001
	jmp	p4check

p4check:						; checks if bit P4 has the correct parity value
	mov	eax, [p4]				; move the value of p4 into the accumulator
	xor	eax, [d4]				; the next 7 lines use xor commands to determine if there are ...
	xor	eax, [d3]				; ... an even or odd number of bit in positions 0-6 and if the ...
	xor	eax, [d2]				; ... p4 value is correct. The combined output value should ...
	xor	eax, [p3]				; ... should be odd, which would register as 0001b
 	xor	eax, [d1]
	xor	eax, [p2]
	xor	eax, [p1]
	cmp	eax, 0001b				; compare calculated value with expected value of 0001b
	je	p3check					; if output value equals expected value, move on
	or	ebx, 1000b				; if output value is not correct, add to error code log
	jmp	p3check					; jump to the next segment

p3check:						; check whether the p3 value  is correct
        mov     eax, [p3]				; move p3 to the accumulator
        xor     eax, [d4]				; next three lines use xor commands to find the parity of bits ...
        xor     eax, [d3]				; ... d2, d3, and d4. Output total of all values should be odd.
        xor     eax, [d2]
	cmp	eax, 0001b				; compare calculated value with expected value of 0001b
  	je	p2check					; move to next section if output is correct
        or	ebx, 0100b				; add to the error code log if incorrect
	jmp	p2check					; jump to the next segment

p2check:						; check if the p2 value is correct
        mov     eax, [p2]				; move p2 into the accumulator
        xor     eax, [d4]				; next three lines use xor commands to find the parity of bits ...
        xor     eax, [d3]				; ... d1, d3, and d4. Output total of all values should be odd.
        xor     eax, [d1]
	cmp	eax, 0001b				; compare calculated value with expected value of 0001b 		
  	je	p1check					; move to next section if output is correct
        or	ebx, 0010b				; add to the error code log if incorrect
	jmp	p1check					; jump to the next segment

p1check:						; check if the p1 value is correct
        mov     eax, [p1]				; move p1 into the accumulator
        xor     eax, [d4]				; next three lines use xor commands to find the parity of bits ...
        xor     eax, [d2]				; ... d1, d2, and d4. Output total of all values should be odd.
        xor     eax, [d1]
	cmp	eax, 0001b				; compare calculated value with expected value of 0001b 
	je	errors					; move to next section if output is correct
        or	ebx, 0001b				; add to the error code log if incorrect
	jmp	errors					; jump to the next segment

errors:
	cmp	ebx, 0000b				; determine if the current values are valid
	je	binToHex				; if valid, check to see what if anything was altered
	mov	ebx, 0000b				; reset the start value of ebx
	dec	edi					; decrement the counter
	jmp	whatNext				; jump to the next segment

binToHex:                  				;add the hex value of each bit to the result string
	mov	eax, [p4]            			; move the memory location calue into the accumulator
	add	eax, '0'              			; convert to ASCII
	mov	[result + 1], eax     			; place the value into a specific position in the string
	mov	eax, [d4]                		; the rest of this segment repeats the process for ...
	add	eax, '0'                		; ... each character in the string
	mov	[result + 2], eax
	mov	eax, [d3]
	add	eax, '0'
	mov	[result + 3], eax
	mov	eax, [d2]
	add	eax, '0'
	mov	[result + 4], eax
	mov	eax, [p3]
	add	eax, '0'
	mov	[result + 5], eax
	mov	eax, [d1]
	add	eax, '0'
	mov	[result + 6], eax
	mov	eax, [p2]
	add	eax, '0'
	mov	[result + 7], eax
	mov	eax, [p1]
	add	eax, '0'
	mov	[result + 8], eax

isGood:
	cmp	edi, 9					; check to see if counter has incremented from start
	je	valid					; jump if user value was valid
	cmp	edi, 8        				; check for overall parity error
	je	allParPrint  				; jump to outpu for overall parity error
	dec	edi					; decrement the counter so it equals bit position
	add	edi, '0'          			; changes edi value to ASCII
	mov	[pos], edi				; move edi value to pos memory location
	jmp	printRes				; jump to the next segment

whatNext:             					; this is a pretty roundabout loop. It checks which bits...
	cmp	edi, 8            			; ... have been altered to try to find a correct output ...
	je	bit7swap          			; ... and then moves to the next
	cmp	edi, 7
	je	bit6swap
	cmp	edi, 6
	je	bit5swap
	cmp	edi, 5
	je	bit4swap
	cmp	edi, 4
	je	bit3swap
	cmp	edi, 3
	je	bit2swap
	cmp	edi, 2
	je	bit1swap
	cmp	edi, 1
	je	bit0swap
	jmp	invdet

bit7swap:						; check if changing bit 7 gives a valid value
	mov	edx, [p4]				; mov memory value to register			
	xor	edx, 0001b				; invert lowest bit
	mov	[p4], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit6swap:						; check if changing bit 6 gives a valid value
	mov	edx, [p4]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[p4], edx

	mov	edx, [d4]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[d4], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit5swap:						; check if changing bit 5 gives a valid value
	mov	edx, [d4]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[d4], edx

	mov	edx, [d3]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[d3], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit4swap:						; check if changing bit 4 gives a valid value
	mov	edx, [d3]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[d3], edx

	mov	edx, [d2]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[d2], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit3swap:						; check if changing bit 3 gives a valid value
	mov	edx, [d2]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[d2], edx

	mov	edx, [p3]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[p3], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit2swap:						; check if changing bit 2 gives a valid value
	mov	edx, [p3]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[p3], edx

	mov	edx, [d1]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[d1], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit1swap:						; check if changing bit 1 gives a valid value
	mov	edx, [d1]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[d1], edx

	mov	edx, [p2]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[p2], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

bit0swap:						; check if changing bit 0 gives a valid value
	mov	edx, [p2]				; next three lines undo the previous segment
	xor	edx, 0001b
	mov	[p2], edx

	mov	edx, [p1]				; mov memory value to register		
	xor	edx, 0001b				; invert lowest bit
	mov	[p1], edx				; mov register value to memory

	jmp	p4check					; restart parity check with new value

;bit error detected
printRes:
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,bitE                                ; message to write
        mov     edx,lenBE                               ; message length
        int     80h                                     ; call kernel


        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,pos                                 ; message to write
        mov     edx,2                                   ; message length
        int     80h                                     ; call kernel

        jmp     corrected                               ; print the corrected bit sequence

;overall parity error
allParPrint:
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,msgA                                ; message to write
        mov     edx,lenA                                ; message length
        int     80h                                     ; call kernel

corrected:
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,msgC                                ; message to write
        mov     edx,lenC                                ; message length
        int     80h                                     ; call kernel

        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,result                              ; message to write
        mov     edx,BUFLEN                              ; message length
        int     80h                                     ; call kernel

        jmp     exit

valid:  
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,bitNE                               ; message to write
        mov     edx,lenNE                               ; message length
        int     80h                                     ; call kernel
        jmp     exit

invdet:
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,msgE                                ; message to write
        mov     edx,lenE                                ; message length
        int     80h                                     ; call kernel
        jmp     exit

invalid:
        mov     eax,SYSCALL_WRITE                       ; system call number (sys_write)
        mov     ebx,STDOUT                              ; file descriptor (stdout)
        mov     ecx,msgI                                ; message to write
        mov     edx,lenI                                ; message length
        int     80h                                     ; call kernel

exit:                                                   ; final exit
        mov     eax,SYSCALL_EXIT                        ; system call number (sys_exit)
        xor     ebx,ebx                                 ; sys_exit return status
        int     0x80                                    ; call kernel


