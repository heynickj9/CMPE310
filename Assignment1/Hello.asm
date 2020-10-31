;
; Assemble using NASM
;

section .data                                   ; section declaration
msg     db  'Hello, world!',0xA                 ; our string
len     equ $ - msg                             ; length of our string

section     .text                               ; section declaration
global      _start                              ; must be declared for linker (ld)

_start:                                         ; tell linker entry point

    mov     eax,4                               ; system call number (sys_write)
    mov     ebx,1                               ; file descriptor (stdout)
    mov     ecx,msg                             ; message to write
    mov     edx,len                             ; message length
    int     0x80                                ; call kernel
                                                 

                                                ; final exit
    mov     eax,1                               ; system call number (sys_exit)
    xor     ebx,ebx                             ; sys_exit return status
    int     0x80                                ; call kernel
