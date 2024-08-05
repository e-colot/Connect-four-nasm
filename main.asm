%include "macros.inc"

section .bss
    actualPlayerGrid RESD 1

section .data
    gridA TIMES 6 DB 0b00000000
    gridB TIMES 6 DB 0b00000000
    startmsg DB 'start of the game', 0xA, 0xD
    lenstartmsg EQU $ - startmsg
    statusFlags DB 0                         ; will be used to store some true/false status
    ;0b0000000X is true if the algorithm is making virtual moves

section .text

    global _start                            ; to use gcc
    global END_GAME
    global actualPlayerGrid
    global gridA
    global gridB
    global statusFlags

    extern SHOW_GRID
    extern LAUNCH_A_TURN

    _start:
        PRNT startmsg, lenstartmsg
        CALL SHOW_GRID
        JMP LAUNCH_A_TURN

    END_GAME:       
        MOV eax, SYS_EXIT
        int 0x80
