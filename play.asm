; Charged of adding pawns

%include "macros.inc"

%macro INPUT 0
    MOV eax, SYS_READ
    MOV ebx, STDIN
    MOV ecx, inputBuffer
    MOV edx, 2
    int 0x80
    MOV al, [inputBuffer]
    CMP al, 'q'
    JE END_GAME
    SUB al, '1'
    JS INVALID_MOVE                          ; if last operation changed the sign (input < '1' in ASCII)
    CMP al, 6
    JG INVALID_MOVE                          ; if input > '7' in ASCII
    MOV [inputBuffer], al
%endmacro

%macro ATURN 0
    MOV esi, gridA
    MOV [actualPlayerGrid], esi
    PRNT inputmsg, leninputmsg
    INPUT
    MOV al, [inputBuffer]
    MOV [rowPos], al                         ; rowPos used to store the row
    MOV BYTE [linePos], 5                    ; linePos used to store the line at which we are trying to add a pawn
    JMP CHECK_GRID
%endmacro

%macro BTURN 0
    MOV esi, gridB
    MOV [actualPlayerGrid], esi
    PRNT inputmsg, leninputmsg
    INPUT
    MOV al, [inputBuffer]
    MOV [rowPos], al                         ; rowPos used to store the row
    MOV BYTE [linePos], 5                    ; linePos used to store the line at which we are trying to add a pawn
    JMP CHECK_GRID
%endmacro

section .bss
    linePos RESB 1
    rowPos RESB 1
    inputBuffer RESB 2

section .data
    inputmsg DB 'Choose where to place your pawn', 0xA, 0xD
    leninputmsg EQU $ - inputmsg
    invalidmsg DB 'Invalid input', 0xA, 0xD
    leninvalidmsg EQU $ - invalidmsg

section .text

    global LAUNCH_A_TURN
    global linePos
    global rowPos
    global CHECK_GRID

    extern CHECK_FOR_WIN
    extern SHOW_GRID
    extern END_GAME
    extern RETURN
    extern gridA
    extern gridB
    extern actualPlayerGrid
    extern statusFlags

    CHECK_GRID:
        MOV bl, [rowPos]
        MOV cl, 6
        SUB cl, bl
        MOV bx, 0x0101
        SHL bx, cl                           ; mask
        MOV esi, gridA
        AND edx, 0
        MOV dl, [linePos]
        ADD esi, edx
        MOV BYTE ah, [esi]
        MOV esi, gridB
        ADD esi, edx
        MOV BYTE al, [esi]
        AND ax, bx
        JE ADD_TO_GRID
        MOV al, [linePos]
        DEC al
        MOV [linePos], al
        JNS CHECK_GRID                       ; if linePos < 0
        JMP INVALID_MOVE

    ADD_TO_GRID:
        MOV esi, [actualPlayerGrid]
        AND edx, 0x0
        MOV dl, [linePos]
        ADD esi, edx
        MOV BYTE al, [esi]
        MOV BYTE bl, 1
        MOV BYTE cl, 6
        SUB cl, [rowPos]
        SHL bl, cl
        OR al, bl
        MOV BYTE [esi], al
        JMP NEXT_ROUND

    NEXT_ROUND:
        MOV al, [statusFlags]
        TEST al, 0b00000001                  ; if it's an algorithm virtual move
        JNZ RETURN
        CALL SHOW_GRID
        CALL CHECK_FOR_WIN
        MOV esi, [actualPlayerGrid]
        CMP esi, gridA
        JE LAUNCH_B_TURN
        JMP LAUNCH_A_TURN

    INVALID_MOVE:
        PRNT invalidmsg, leninvalidmsg
        MOV esi, [actualPlayerGrid]
        CMP esi, gridA
        JE LAUNCH_A_TURN
        JMP LAUNCH_B_TURN

    LAUNCH_A_TURN:
        ATURN

    LAUNCH_B_TURN:
        BTURN

