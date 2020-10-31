	;; NASM program to read from cmd line arg, open file, read first line, and print first line to screen
	;;	Uses fopen, fscanf, and printf
	;; For help using the stack to write subroutines, consult Lab 5 lecture notes

	;; nasm -f elf cfunctions.asm
	;; gcc -m32 cfunctions.o
	;; a.out input.txt
	
	
%include "mine.inc"
	
extern printf
extern fopen
extern fscanf

%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4

	
global main

section .data
		
read_char:	db 'r', 0
format:		dd "%d",10,0
filename:	dd 0
file_pointer:	dd 0
number:		dd 0
string:	        db "The integer is %d",10,0

; EVERYTHING ABOVE THIS LINE COMES FROM THE PROVIDED CFUNCTIONS.ASM FILE
; ***************************************************************************************

; ***************************************************************************************


error:		db "Invalid file name", 10, 0
array:  	times 1000 dd 0
sortedArray:	times 1000 dd 0
sumString	db "The sum of the array is %d", 10, 0
sortString	db "The sorted array is as follows:", 10, 0	
arrayVal	db "%d", 10, 0
totalInts	dd 0
	


; EVERYTHING IN THIS SECTION COMES FROM THE PROVIDED CFUNCTIONS.ASM FILE
; *******************************************************************************************************

;********************************************************************************************************


section .text

main:

	;; Get the filename, pointer to input filename is returned, will equal 0 for an invalid filname
	push	dword filename	; Push address of the pointer to the filename
	call	GetCommandLine	; Return address pushed to stack, Go to line 72, GetCommandLine
	add	esp, 4		; Resets stack value (equivalent to 'pop' inst)

	;; Open the file using fopen
	;; Equivalent to eax = fopen("input.txt", "r") if programmed in C
	push    dword read_char	; "r" to open a file for reading
	push    dword [filename] ; filename from cmd line arg
	call    fopen
	add     esp, 8 


; END OF SECTION FROM CFUNCTIONS.ASM FILE
; **********************************************************************************************************

; **********************************************************************************************************


	;; Error check fstream returned from fopen
	cmp	eax, 0				; provided in cfunctions.asm file
	je	error1				; altered from cfunctions.asm file to output the error message
	mov	[file_pointer], eax		; provided in cfunctions.asm file
  	jmp	next1				; jump to the section that scans the user file

error1:
	push	error				; puts the error message on the stack
	call	printf				; prints the error message
	jmp	Exit				; exits the program

next1:
						;; Read a value from the file using fscanf
	push	dword number			; Address of 'number'
	push    dword format			; %d to read an integer
	push    dword [file_pointer] 		; fstream from fopen
	call    fscanf				; calls the fscanf function
	add     esp, 12				; moves the stack pointer 3 poitions

	mov	edi, [number]			; move the first number value (line 1) into the edi register
	mov	[totalInts], edi		; move the first number value from edi to its own memory location
	mov	esi, 0				; set esi to zero
	jmp	looping				; jump to the loop that reads each value in the input file	
  
looping: 
						;; Read a value from the file using fscanf
	push	dword number			; Address of 'number'
	push    dword format			; %d to read an integer
	push    dword [file_pointer] 		; fstream from fopen
	call    fscanf				; scan next number from file 
	add     esp, 12				; move stack pointer 3 positions
   
   	mov	ebx, [number]			; move the current line of the input file into ebx 
   	mov	[array+esi*4], ebx		; move ebx into an array at index location esi
 
 	inc	esi				; increment esi
  	cmp	esi, [totalInts]		; compare esi to the number of integers to be put in the array
  	je	clear				; jump out of the loop to the next section
 	jmp	looping

clear:
	xor	esi, esi			; clear the esi register
	mov	ebx, 0				; set the ebx register to zero
	jmp	addUp				; jump to section that adds up the array values

addUp:
	mov	ecx, [array+esi*4]		; move the value of the array at the esi index location into ecx
	add	ebx, ecx			; add ecx to ebx
	inc	esi				; increment esi
	cmp	esi, [totalInts]		; check to see if esi equals the total number of values in the array
	je	printSum			; if all of the values have been added together, jump to print the sum
	jmp	addUp				; if there are still values to add, restart the loop

printSum:
	push	dword ebx			; push the ebx sum onto the stack 
	push	dword sumString			; push the output message onto the stack
	call	printf				; print the stack
	add	esp, 8				; move the stack pointer up 2 positions

	push	dword sortString		; move the output message for the sorted stack
	call	printf				; print the stack
	add	esp, 4				; move the stack pointer up one position

	xor	edi, edi			; reset edi register
 	xor  	esi, esi			; reset esi register
  	xor  	ecx, ecx			; reset ecx register
	jmp	sortStart			; jump to the start of sorting algorithm

sortStart:
  	xor  	esi, esi			; reset the esi register
  	mov  	eax, -999999			; set the start value of eax to an absurdly low number
  	xchg  	eax, [array+edi*4]		; switch the value of eax and the first value of the array
  	inc  	edi				; increment edi
  	cmp  	edi, [totalInts]		; compare the edi value to the total number of integers in the loaded file
  	je  	finalInsert			; if edi and the number of integers are equal, insert the final value into the...
						; ...last array position
  	jmp  	sorting				; jump to the sorting algorithm
  
sorting:
  	cmp  	eax, [array+esi*4]		; compare the next value in the array with the value in eax
  	jl 	exchange			; if eax value is lower than the array value, jump to an exchange algorithm
  	jmp  	nextSort			; if eax value is greater than or equal to the array value, jump to increment

exchange:
  	xchg  	eax, [array+esi*4]		; place the lower value back into the array and move the larger value to eax
  	jmp  	nextSort			; jump to the increment commands

nextSort:
  	inc  	esi				; increment esi
  	cmp  	esi, [totalInts]		; compare esi to the total number of values in the array
  	je  	addToArray			; if all values have been compared, jump to add the value to a new array
  	jmp  	sorting				; if there are more values to compare, jump to the sorter for the next value

addToArray:
  	mov  	[sortedArray+ecx*4], eax	; move the largest value from the array into the sorted array
  	inc  	ecx				; increment ecx
  	jmp  	sortStart			; jump to start the sorter over again 

finalInsert:
  	mov  	[sortedArray+ecx*4], eax	; move the final array value into the last index position of the sorted array
  	jmp 	printSorted			; jump to the sorted array printer
  
printSorted:
  	push    dword [sortedArray+esi*4]	; push the array value onto the stack
  	push  	dword arrayVal			; push the empty print variable onto the stack
	call    printf				; print the stack
	add     esp, 8				; move the stack pointer up 2 positions
 
 	inc	esi				; increment the esi value
  	cmp	esi, [totalInts]		; compare the esi value to the total number of values in the array
  	je	Exit				; if all values have been printed, exit the program
 	jmp	printSorted			; if there are more values to be printed, restart the print loop



 
; ALL CODE AFTER THIS POINT CAME FROM THE PROVIDED CFUNCTIONS.ASM FILE
; *******************************************************************************************************

; *******************************************************************************************************







Exit:	
	mov     EAX, SYSCALL_EXIT       
        mov     EBX, 0                
        int     080h                    
	ret		


GetCommandLine:

	;; Macros to move esp into ebp and push regs to be saved
         Enter 0
         Push_Regs ebx, ecx, edx

	;; Initially sets [filename] to 0, remains 0 if there's an error
         mov ebx, [ebp + 8]
         mov [ebx], dword 0

	;; Get argc (# of arguments)
         mov ecx, [ebp + 16]

	;; Checks the value of argc, should be 2 (a.out and input.txt), includes the if statement macro
         cmp ecx, 2
         if ne
            jmp gcl_done
         endif

	;; Get argv[0] ("a.out"/"cfunctions" or the executable, this is not used in the project)
	;; Consult slide 6 of Stack Basics... lecture
	 mov ecx, [ebp + 20]   	;  ptr to args ptr
	 mov ebx, [ecx]		;  argv[0]

	;; Get argv[1] ("input.txt")
         mov ecx, [ebp + 20]	; ptr to args ptr
         mov ebx, [ecx + 4]	; argv[1]

	;; Set the filename pointer arg on the stack to the address of the filename
         mov edx, [ebp + 8]
         mov [edx], ebx

gcl_done:
	;; Macros to return
         Pop_Regs ebx, ecx, edx
         Leave

	;; Return
         ret
