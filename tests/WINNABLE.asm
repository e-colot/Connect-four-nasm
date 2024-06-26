SYS_EXIT    EQU 1
SYS_READ    EQU 3
SYS_WRITE   EQU 4
STDIN       EQU 2
STDOUT      EQU 1

; ---------------------------- MACROS --------------------------------

%macro PRNT 2               ; prints arg1 of length arg2
    MOV eax, SYS_WRITE
    MOV ebx, STDOUT
    MOV ecx, %1
    MOV edx, %2
    int 0x80
%endmacro

%macro INPUT 0
    MOV eax, SYS_READ
    MOV ebx, STDIN
    MOV ecx, tmp
    MOV edx, 2
    int 0x80
    MOV al, [tmp]
    CMP al, 'q'
    JE END_GAME
    SUB al, '1'
    JS INVALID_MOVE         ; if last operation changed the sign (input < '1' in ASCII)
    CMP al, 6
    JG INVALID_MOVE         ; if input > '7' in ASCII
    MOV [tmp], al
%endmacro

%macro ATURN 0
    MOV esi, gridA
    MOV [actualPlayerGrid], esi
    PRNT inputmsg, leninputmsg
    INPUT
    MOV al, [tmp]
    MOV [rowPos], al               ; rowPos used to store the row
    MOV BYTE [linePos], 5          ; linePos used to store the line at which we are trying to add a pawn
    JMP CHECK_GRID
%endmacro

%macro BTURN 0
    MOV esi, gridB
    MOV [actualPlayerGrid], esi
    PRNT inputmsg, leninputmsg
    INPUT
    MOV al, [tmp]
    MOV [rowPos], al               ; rowPos used to store the row
    MOV BYTE [linePos], 5          ; linePos used to store the line at which we are trying to add a pawn
    JMP CHECK_GRID
%endmacro

%macro NBR_COMMON_BITS 2        ; output in dl
    MOV al, [%1]
    MOV bl, %2
    AND al, bl
    MOV dl, 0
    MOV cl, 0
    CALL COUNT_1
%endmacro

%macro CHECK_FOR_WIN 0
    CALL H_WIN
    CALL V_WIN
    CALL SLANT1_WIN
    CALL SLANT2_WIN
%endmacro

; ----------------------------- CODE ---------------------------------

section .text
    global _start               ; to use gcc

    RETURN:
        RET

    COUNT_1:                    ; with the total in dl, the count in cl and the byte in al
        MOV bl, al              ; using bl to not remove the byte from al
        SHR bl, cl
        AND bl, 0x1
        ADD dl, bl
        INC cl
        CMP cl, 7
        JNE COUNT_1
        RET

    FOR_EACH_LINE:
        MOV BYTE dl, [esi]
        SHR dl, cl
        AND dl, 0x1
        ADD al, dl
        SHL al, 1
        INC esi
        INC bl
        CMP bl, 6
        JNE FOR_EACH_LINE
        RET

    H_WIN:                      ; checks for - win
        AND ebx, 0x0
        MOV bl, [linePos]
        MOV esi, [actualPlayerGrid]
        ADD esi, ebx
        MOV al, [esi]
        MOV [tmp1], al
        JMP END_CHECK

    V_WIN:                      ; checks for | win
        MOV al, 0x1
        MOV BYTE cl, 6
        SUB cl, [rowPos]
        MOV esi, [actualPlayerGrid]
        MOV bl, 0               ; used as a counter for the number of lines
        CALL FOR_EACH_LINE
        MOV [tmp1], al
        JMP END_CHECK

    SLANT1_WIN:                 ; checks for / win
        MOV bl, [linePos]
        MOV bh, [rowPos]
        MOV BYTE cl, 5               ; 5 and not 6 bcs cl is increased at FOR_SLANT1 before any operation
        SUB cl, bl
        SUB cl, bh              ; cl is the shift (minus 1)
        MOV esi, [actualPlayerGrid]
        DEC esi
        MOV BYTE ah, -1              ; iteration counter
        AND dl, 0x0             ; result registers initalization
        CALL FOR_SLANT1
        MOV [tmp1], dl
        JMP END_CHECK

    FOR_SLANT1:
        INC esi
        INC ah
        INC cl
        CMP cl, 0
        JL FOR_SLANT1
        MOV BYTE al, [esi]
        SHR al, cl
        AND al, 1
        ADD dl, al
        SHL dl, 1
        CMP cl, 6
        JE RETURN
        CMP ah, 5
        JE RETURN
        JMP FOR_SLANT1

    SLANT2_WIN:                 ; checks for \ win
        MOV bl, [linePos]
        MOV bh, [rowPos]
        MOV BYTE cl, 7          
        ADD cl, bl
        SUB cl, bh              ; cl is the shift (plus 1)
        MOV esi, [actualPlayerGrid]
        DEC esi
        MOV BYTE ah, -1              ; iteration counter
        AND dl, 0x0             ; result registers initalization
        CALL FOR_SLANT2
        MOV [tmp1], dl
        JMP END_CHECK

    FOR_SLANT2:
        INC esi
        INC ah
        DEC cl
        CMP cl, 7
        JG FOR_SLANT2
        MOV BYTE al, [esi]
        SHR al, cl
        AND al, 1
        ADD dl, al
        SHL dl, 1
        CMP cl, 0
        JE RETURN
        CMP ah, 5
        JE RETURN
        JMP FOR_SLANT2

    END_CHECK:
        NBR_COMMON_BITS tmp1, 0b1111000
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS tmp1, 0b0111100
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS tmp1, 0b0011110
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS tmp1, 0b0001111
        CMP dl, 4
        JE WIN
        RET

    WIN:
        PRNT msg, lenmsg
        JMP END_GAME

; --------------------------- PLAYING --------------------------------

    CHECK_GRID:
        MOV bl, [rowPos]
        MOV cl, 6
        SUB cl, bl
        MOV bx, 0x0101
        SHL bx, cl            ; mask
        MOV esi, gridA
        AND edx, 0
        MOV dl, [linePos]
        ADD esi, edx
        MOV BYTE ah, [esi]
        MOV esi, gridB
        ADD esi, edx
        MOV BYTE al, [esi]
        AND ax, bx
        CMP ax, 0
        JE ADD_TO_GRID
        MOV al, [linePos]
        DEC al
        MOV [linePos], al
        CMP al, 0xFF            ; if underflow (so if linePos == -1)
        JNZ CHECK_GRID
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
        CALL SHOW_GRID
        CHECK_FOR_WIN
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

; ---------------------- SHOWING THE GRID ----------------------------

    SHOW_GRID:
        MOV BYTE [lineIndex], 0
        JMP SHOW_LINE

    TOLINE:
        PRNT toLine, 1
        RET

    SPACE:
        PRNT spaces, 2
        JMP NEXT_CHARACTER

    APAWN:
        PRNT aPawn, 1
        JMP SPACE

    BPAWN:
        PRNT bPawn, 1
        JMP SPACE

    NOPAWN:
        PRNT noPawn, 1
        JMP SPACE

    SHOW_CARACTER:
        MOV cl, [caracterIndex]
        SUB cl, 1                   ; substract 1 bcs ebx has a 1 in pre-last pos
        MOV bx, 0x0101
        SHL bx, cl                  ; mask
        MOV ah, [lineA]
        MOV al, [lineB]
        AND ax, bx
        CMP ax, 0
        JE NOPAWN
        CMP ax, 0x0100
        JGE APAWN
        JMP BPAWN

    NEXT_CHARACTER:
        MOV cl, [caracterIndex]
        DEC cl
        MOV BYTE [caracterIndex], cl
        CMP cl, 0
        JNZ SHOW_CARACTER
        JMP NEXT_LINE

    SHOW_LINE:
        MOVZX ecx, BYTE [lineIndex]        ; lineIndex on 1 byte so we have to extend zeros to "cover" the last data
        MOV esi, gridA
        ADD esi, ecx
        MOV BYTE bl, [esi]
        MOV BYTE [lineA], bl
        MOV esi, gridB
        ADD esi, ecx
        MOV BYTE bl, [esi]
        MOV BYTE [lineB], bl
        MOV BYTE [caracterIndex], 7
        JMP SHOW_CARACTER

    NEXT_LINE:
        CALL TOLINE
        MOV cl, [lineIndex]
        INC cl
        MOV [lineIndex], cl
        CMP cl, 6
        JNZ SHOW_LINE
        RET
        
; ------------------------- START & END ------------------------------

    END_GAME:                    ; end the program
        MOV eax, SYS_EXIT
        int 0x80

    _start:
        PRNT msg, lenmsg
        CALL SHOW_GRID
        ATURN
        JMP END_GAME
        
; -------------------------- VARIABLES -------------------------------

section .data
    gridA DB 0b00000000, 0b00000000, 0b00000000, 0b00000100, 0b00000110, 0b00000111
    gridB DB 0b00000000, 0b00000000, 0b00000000, 0b00001000, 0b00001000, 0b00001000
    aPawn DB 'O'                ; length of 1
    bPawn DB 'X'                ; length of 1
    noPawn DB '*'               ; length of 1
    spaces DB '  '              ; length of 2
    toLine DB 0x0A              ; length of 1
    msg DB 'start of the game', 0xA, 0xD
    lenmsg EQU $ - msg
    inputmsg DB 'Choose where to place your pawn', 0xA, 0xD
    leninputmsg EQU $ - inputmsg
    invalidmsg DB 'Invalid input', 0xA, 0xD
    leninvalidmsg EQU $ - invalidmsg

section .bss
    lineA RESB 1
    lineB RESB 1
    caracterIndex RESB 1
    lineIndex RESB 1
    tmp1 RESB 1
    tmp RESB 2
    actualPlayerGrid RESD 1
    linePos RESB 1
    rowPos RESB 1
