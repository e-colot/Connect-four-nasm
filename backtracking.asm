; basic opponent that check for each possible scenario (depth = 4)

section .bss
    scores RESW 7 ; words to store 7⁴ (wcs)
    actuallyPlaying RESB 1

section .data
    DEPTH DB 4

section .text
    
    extern statusFlags

    START_ALGO:
        MOV actuallyPlaying, 0
        MOV al, [statusFlags]
        OR al, 0b00000001                    ; indicates that the algorithm is starting

    NEXT_ALGO_TRY:

        

