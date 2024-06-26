%include "macros.inc"

section .bss
    actualPlayerGrid RESD 1

section .data
    gridA TIMES 6 DB 0b00000000
    gridB TIMES 6 DB 0b00000000
    startmsg DB 'start of the game', 0xA, 0xD
    lenstartmsg EQU $ - startmsg

section .text

    global _start                            ; to use gcc
    global END_GAME
    global actualPlayerGrid
    global gridA
    global gridB

    extern SHOW_GRID
    extern LAUNCH_A_TURN

    _start:
        PRNT startmsg, lenstartmsg
        CALL SHOW_GRID
        JMP LAUNCH_A_TURN

    END_GAME:       
        MOV eax, SYS_EXIT
        int 0x80
