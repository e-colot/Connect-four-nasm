SYS_EXIT    EQU 1
SYS_READ    EQU 3
SYS_WRITE   EQU 4
STDIN       EQU 2
STDOUT      EQU 1

%macro PRNT 2                                ; prints arg1 of length arg2
    MOV eax, SYS_WRITE
    MOV ebx, STDOUT
    MOV ecx, %1
    MOV edx, %2
    int 0x80
%endmacro

section .bss

section .data
    msg1 DB 'pathA'
    lenmsg1 EQU $ - msg1
    msg2 DB 'pathB'
    lenmsg2 EQU $ - msg2

section .text
    global _start

    _start:
        CALL F1 
        PRNT msg2, lenmsg2
        MOV eax, SYS_EXIT
        int 0x80
    F1:
        CALL F2
        PRNT msg1, lenmsg1
    F2:
        ADD esp, 4                           ; removes 32 bits (for x32 architecture) to stack pointer
        RET
