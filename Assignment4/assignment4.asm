extern	printf

%include	"mine.inc"

%define	SYS_OPEN	5
%define SYS_CLOSE	6
%define SYS_CREAT	8
%define SYS_READ	3
%define SYS_WRITE	4
%define SYS_EXIT	1
%define STDIN		0
%define STDOUT		1
%define O_RDONLY	0
%define O_WRONLY	1
%define O_RDWR		2

%define BUFLEN	32

%define	ARGC 20
%define ARGV 24

global main

section .data

	errorMsg	db "First line of the input file must be a positive integer", 10, 0
	intMsg		db "Total number of integers: ", 0
	intMsgLen	equ $- intMsg
	decMsg		db "Total number of floats: ", 0
	decMsgLen	equ $- decMsg
	intOutFile	db "proj4_float.out", 0
	fltOutFile	db "proj4_integer.out", 0
	fileTest	db "testfile1.txt", 0
	lineBreak	db "", 10, 0
	lbLen		equ $- lineBreak
	fileName	dd 0
	number		dd 0
	currentVal	dd 0
	cvLen		equ $- currentVal
	filePTR		dd 0
	totalValues	dd 0
	intArray	times 1000 dd 0
	fltArray	times 1000 dd 0
	decMod		dd 0
	signMod		dd 0
	expMod		dd 0
	isDec		dd 0
	isExp		dd 0
	currentLine	dd 0
	decVal		dq 0
	lgFltMsg db "The largest float number is: "
	lgFltMsgLen equ $- lgFltMsg
	smFltMsg db "The smallest float number is: "
	smFltMsgLen equ $- smFltMsg
	sumOfInts dd 0
	sumOfFlts dq 0

section .bss

	fileContents	resb 1024
	numOfInts	resb 1024
	numOfFlts	resb 1024
	intSum		resb 1024
	fltSum		resb 1024
	largestFlt	resb 1024
	smallestFlt	resb 1024

section .text

main:
	;call functions to get the file name, open the file, and read its value
	call	inputFile
	call	openFile
	call	readFile

	;clear the ecx register
	xor	ecx, ecx
	
	;read the first line to get the number of entries in the file (currently held as a comment to prevent segmentation fault)
;	call	readLine1

	;read subsequent lines in the input file (currently held as a comment to prevent segmentation fault)
;	call	readValueLines

	;save the number of integers and number of floats in memory locations and clear edi and esi registers
	mov	[numOfInts], edi
	mov	[numOfFlts], esi
	xor	edi, edi
	xor	esi, esi
	
	;find the largest and smallest floats
;	call	startFindLargest
;	fst	dword [largestFlt]

;	call	startFindSmallest
;	fst	dword [smallestFlt]

	;clear registers
	xor	edi, edi
	xor	esi, esi
	xor	eax, eax
	xor	ebx, ebx

	;find the sum of the integers and the sum of the floats
;	call	addInts
;	fstp	dword [intSum]
;	call	addFlts
;	fstp	dword [fltSum]

	;call functions to print the values and create the output files
	call	closeFile
	call	printValues
	call	createIntFile
	call	createFltFile
	call	exit

inputFile:
	; calls the GetCommandLine macro defined in the previous assignment and pushed the value into the fileName memory location
	push	dword fileName
	call	GetCommandLine
	add	esp, 4
	
	ret

returnLine:
	;funtion exists to allow other functions to jump to a return
	ret

readLine1:
	;parser reads the first line, which should be an integer
	;an error is thrown if a non-numeric character is found
	;it knows it has processed the entire number when it reaches the endline character 0xA
	xor	ebx, ebx
	mov	bl, byte [fileContents+ecx]
	inc	ecx

	cmp	bl, 0xA
	je	returnLine

	cmp	bl, "-"
	je	error

	cmp	bl, "."
	je	error

	cmp	bl, "E"
	je	error	

	sub	bl, '0'
	mov	eax, [totalValues]
	imul	eax, 10
	mov	[totalValues], eax
	add	[totalValues], bl
	mov	eax, 1
	mov	[signMod], eax
	mov	eax, 0
	mov	[decMod], eax
	mov	[expMod], eax
	jmp	readLine1

readValueLines:
	;parser reads subsequent lines of the file
	;it store information about whether the number is negative, a decimal...
	;...or is a precision float and uses that to process the number later
	mov	bl, byte [fileContents+ecx]
	inc	ecx

	mov	eax, [currentLine]
	cmp	eax, [totalValues]
	je	returnLine

	cmp	bl, 0xA
	je	nextLine

	cmp	bl, "-"
	je	isNegNum

	cmp	bl, "."
	je	isDecNum

	cmp	bl, "E"
	je	isExpNum	

	sub	bl, '0'
	mov	eax, [number]
	imul	eax, 10
	mov	[number], eax
	add	[number], bl
	mov	eax, [decMod]
	imul	eax, 10
	mov	[decMod], eax
	mov	eax, [expMod]
	imul	eax, 10
	mov	[expMod], eax
	jmp	readValueLines

nextLine:
	;this modifies the number based on its sign and decides whether to...
	;process it as an integer or a float
	mov	eax, [number]
	imul	eax, [signMod]
	mov	[number], eax
	mov	eax, [isDec]
	cmp	eax, 0
	je	saveInt
	jmp	saveFlt

isNegNum:
	;this sets up a modifier if a "-" is found by the parser
	mov	eax, -1
	mov	[signMod], eax
	xor	eax, eax
	jmp	readValueLines

isDecNum:
	;this sets up a modifier if a "." is found by the parser
	mov	eax, 1
	mov	[isDec], eax
	mov	[decMod], eax
	xor	eax, eax
	jmp	readValueLines

isExpNum:
	;this sets up a modifier if an "E" is found by the parser
	mov	eax, 1
	mov	[isExp], eax
	mov	[expMod], eax
	xor	eax, eax
	jmp	readValueLines

saveInt:
	;processes the value if it's an integer and moves to the next line of the...
	;input file
	mov	eax, [number]
	mov	[intArray+edi*4], eax
	inc	edi
	call	resetLine
	jmp	readValueLines

saveFlt:
	;processes the value if it's a float and moves to the next line of the...
	;input file. The numeric portion of the number is processed and then it...
	;is divided based on how many decimal places were present and then...
	;multiplied based on the exponent of E
	mov	eax, [number]
	mov	[decVal], eax
	fild	dword [decVal]
	fdiv	dword [decMod]
	fmul	dword [expMod]
	fstp	dword [fltArray+esi*4]
	inc	esi
	call	resetLine
	jmp	readValueLines

resetLine:
	;resets all registers to the start value for processing the next line
	mov	eax, [currentLine]
	inc	eax
	mov	[currentLine],eax
	mov	eax, 1
	mov	[signMod], eax
	mov	eax, 0
	mov	[decMod], eax
	mov	[expMod], eax
	mov	[isDec], eax
	mov	[isExp], eax
	ret

error:
	;prints an error message when the first line is not an integer
	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, errorMsg			;message to write
	mov	edx, BUFLEN			;number of bytes
	int	80h				;call kernel


	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lineBreak			;message to write
	mov	edx, lbLen			;number of bytes
	int	80h				;call kernel

	call	exit

startFindLargest:
	; loads the first array value onto the top of the stack
	fld	dword [fltArray+edi*4]
	jmp	findLargest

findLargest: 
	;loops to check the top stack value with the rest of the array
	inc	edi
	cmp	edi, [numOfFlts]
	je	returnLine
	fcom	dword [fltArray+edi*4]
	jg	replaceLargest
	jmp	findLargest

replaceLargest:
	;if a value is larger than the one on top of the stack, the stack is...
	;...emptied and the larger value is placed on top
	add	esp, 4
	fld	dword [fltArray+edi*4]

	ret

startFindSmallest:
	; loads the first array value onto the top of the stack
	mov	ebx, [fltArray+edi*4]
	jmp	findSmallest

findSmallest:
	;loops to check the top stack value with the rest of the array
	inc	edi
	cmp	edi, [numOfFlts]
	je	returnLine
	fcom	dword [fltArray+edi*4]
	jl	replaceSmallest
	jmp	findSmallest

replaceSmallest:
	;if a value is smaller than the one on top of the stack, the stack is...
	;...emptied and the larger value is placed on top
	add	esp, 4
	fld	dword [fltArray+edi*4]

	ret

addInts:
	;adds all integers using float point instructions
	cmp	edi, [numOfInts]
	jg	returnLine
	fadd	dword [intArray+edi*4]
	inc	edi
	jmp	addInts

addFlts:
	;adds all floats using float point instructions
	cmp	esi, [numOfFlts]
	jg	returnLine
	fadd	dword [fltArray+esi*4]
	inc	esi
	jmp	addFlts

openFile:
	;open the file for reading
	mov	eax, SYS_OPEN			;system call to open the file
	mov	ebx, [fileName]			;specify the filename
	mov	ecx, O_RDONLY			;for read only access
	mov	edx, 0700o			;read, write and execute permissions for user
	int	80h				;call kernel
	mov	[filePTR], eax			;store file handle/pointer for reading

	ret

readFile:
	;read from file
	mov	eax, SYS_READ			;system call number (sys_read)
	mov	ebx, [filePTR]			;file descriptor 
	mov	ecx, fileContents		;message to read
	mov	edx, BUFLEN			;number of bytes
	int	80h				;call kernel

	ret

closeFile: 
	;close the file
	mov	eax, SYS_CLOSE			;system call to close the file
	mov	ebx, [filePTR]			;specify file handle/pointer for reading
	int	80h				;call kernel

	ret

createIntFile:
	;create the file
	mov	eax, SYS_CREAT			;system call to create a file
	mov	ebx, intOutFile			;specify the filename
	mov	ecx, 0700o			;read, write and execute permissions for user 
	int	80h				;call kernel

	mov	[filePTR], eax			;file handle/pointer to file
	call	writeIntFile
	call	closeIntFile

	ret

writeIntFile:
	;write message into the file
	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, [filePTR]			;file descriptor 
	mov	ecx, [intArray+esi*4]		;message to write
	mov	edx, BUFLEN			;number of bytes
	int	80h				;call kernel

;	inc	esi
;	cmp	esi, [numOfInts]
;	jl	writeIntFile			;call kernel

	ret

closeIntFile:
	;close the file
	mov	eax, SYS_CLOSE			;system call to close the file
	mov	ebx, [filePTR]			;specify file handle/pointer for writing
	int	80h				;call kernel

	ret

createFltFile:
	;create the file
	mov	eax, SYS_CREAT			;system call to create a file
	mov	ebx, fltOutFile			;specify the filename
	mov	ecx, 0700o			;read, write and execute permissions for user 
	int	80h				;call kernel
	mov	[filePTR], eax			;file handle/pointer to file
	call	writeFltFile
	call	closeFltFile

	ret

writeFltFile:
	;write message into the file
	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, [filePTR]			;file descriptor 
	mov	ecx, [fltArray+esi*4]		;message to write
	mov	edx, BUFLEN			;number of bytes
	int	80h				;call kernel

;	inc	esi
;	cmp	esi, [numOfFlts]
;	jl	writeFltFile

	ret

closeFltFile:
	;close the file
	mov	eax, SYS_CLOSE			;system call to close the file
	mov	ebx, [filePTR]			;specify file handle/pointer for writing
	int	80h				;call kernel

	ret

printValues:
	;prints all desired information
	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, intMsg			;message to write
	mov	edx, intMsgLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, numOfInts			;message to write
	mov	edx, 32				;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lineBreak			;message to write
	mov	edx, lbLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, decMsg			;message to write
	mov	edx, decMsgLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, numOfFlts			;message to write
	mov	edx, 32				;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lineBreak			;message to write
	mov	edx, lbLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, smFltMsg			;message to write
	mov	edx, smFltMsgLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, smallestFlt			;message to write
	mov	edx, 32				;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lineBreak			;message to write
	mov	edx, lbLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lgFltMsg			;message to write
	mov	edx, lgFltMsgLen			;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, largestFlt			;message to write
	mov	edx, 32				;number of bytes
	int	80h				;call kernel

	mov	eax, SYS_WRITE			;system call number (sys_write)
	mov	ebx, STDOUT			;standard output 
	mov	ecx, lineBreak			;message to write
	mov	edx, lbLen			;number of bytes
	int	80h				;call kernel

	ret

exit:
	mov	eax, SYS_EXIT
	mov	ebx, 0
	int	80h

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
	mov ecx, [ebp + 20]	;ptr to args ptr
	mov ebx, [ecx]		;argv[0]

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