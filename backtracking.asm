; basic opponent that check for each possible scenario (depth = 4)

section .bss
    scores RESW 7 ; word to store 7⁴ (wcs)
    actuallyPlaying RESB 4 

section .data
    DEPTH DB 4

section .text

    global ALGO_WIN_SCENARIO
    
    extern CHECK_GRID
    extern statusFlags
    extern rowPos
    extern linePos

    START_ALGO:
        MOV actuallyPlaying, 0
        MOV al, [statusFlags]
        OR al, 0b00000001                    ; indicates that the algorithm is starting
        MOV statusFlags, al

    NEXT_ALGO_TRY:
        MOV [rowPos], [actuallyPlaying]
        MOV BYTE [linePos], 5
        CALL CHECK_GRID
        CALL CHECK_FOR_WIN
        
    ALGO_WIN_SCENARIO:
        ADD esp, 8                           ; remove 2 CALL from the stack

        