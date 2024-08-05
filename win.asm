; Charged of verifying if a player has won

%include "macros.inc"

%macro NBR_COMMON_BITS 2                     ; output in dl
    MOV al, [%1]
    MOV bl, %2
    AND al, bl
    MOV dl, 0
    MOV cl, 0
    CALL COUNT_1
%endmacro

section .bss
    lineBuffer RESB 1

section .data
    endmsg DB 'End of the game', 0xA, 0xD, 0xA, 0xD
    lenendmsg EQU $ - endmsg

section .text

    global CHECK_FOR_WIN

    extern END_GAME
    extern gridA
    extern gridB
    extern actualPlayerGrid
    extern linePos
    extern rowPos

    CHECK_FOR_WIN:
        CALL H_WIN
        CALL V_WIN
        CALL SLANT1_WIN
        CALL SLANT2_WIN
        RET

    RETURN:
        RET

    COUNT_1:                                 ; with the total in dl, the count in cl and the byte in al
        MOV bl, al                           ; using bl to not remove the byte from al
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

    H_WIN:                                   ; checks for - win
        AND ebx, 0x0
        MOV bl, [linePos]
        MOV esi, [actualPlayerGrid]
        ADD esi, ebx
        MOV al, [esi]
        MOV [lineBuffer], al
        JMP END_CHECK

    V_WIN:                                   ; checks for | win
        MOV al, 0x1
        MOV BYTE cl, 6
        MOV ch, [rowPos]
        SUB cl, ch
        MOV esi, [actualPlayerGrid]
        MOV bl, 0                            ; used as a counter for the number of lines
        CALL FOR_EACH_LINE
        MOV [lineBuffer], al
        JMP END_CHECK

    SLANT1_WIN:                              ; checks for / win
        MOV bl, [linePos]
        MOV bh, [rowPos]
        MOV BYTE cl, 5                       ; 5 and not 6 bcs cl is increased at FOR_SLANT1 before any operation
        SUB cl, bl
        SUB cl, bh                           ; cl is the shift (minus 1)
        MOV esi, [actualPlayerGrid]
        DEC esi
        MOV BYTE ah, -1                      ; iteration counter
        AND dl, 0x0                          ; result registers initalization
        CALL FOR_SLANT1
        MOV [lineBuffer], dl
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

    SLANT2_WIN:                              ; checks for \ win
        MOV bl, [linePos]
        MOV bh, [rowPos]
        MOV BYTE cl, 7          
        ADD cl, bl
        SUB cl, bh                           ; cl is the shift (plus 1)
        MOV esi, [actualPlayerGrid]
        DEC esi
        MOV BYTE ah, -1                      ; iteration counter
        AND dl, 0x0                          ; result registers initalization
        CALL FOR_SLANT2
        MOV [lineBuffer], dl
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
        NBR_COMMON_BITS lineBuffer, 0b1111000
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS lineBuffer, 0b0111100
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS lineBuffer, 0b0011110
        CMP dl, 4
        JE WIN
        NBR_COMMON_BITS lineBuffer, 0b0001111
        CMP dl, 4
        JE WIN
        RET

    WIN:
        PRNT endmsg, lenendmsg
        JMP END_GAME

