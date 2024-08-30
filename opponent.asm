%include "macros.inc"

section .bss
    fakeGridA RESB 6
    fakeGridB RESB 6
    ; the inital plan was to use these fake grids to simulate hypothetical moves
    ; without loosing the real grids. However, it has been chosen to use them to store
    ; the real grids so other functions can still be called as if it was a "real" move

section .data

section .text

    extern CHECK_GRID
    extern gridA
    extern gridB
    extern actualPlayerGrid
    extern rowPos
    extern linePos

    OPPONENTS_TURN:
        CALL COPY_GRIDS
        ; for each row, call check_grid

    COPY_GRIDS:
        ; copies gridA-B in fakeGridA-B

        MOV esi, gridA
        ; (esi = source)
        MOV edi, fakeGridA
        ; (edi = destination)
        MOV al, 6
        ; iteration counter set to 6 to avoid a CMP
        ; DEC al will raise the zero flag at the end

        CALL COPY_LOOP

        ; same for B
        MOV esi, gridB
        MOV edi, fakeGridB
        MOV al, 6

        CALL COPY_LOOP
        RET

    COPY_LOOP:
        MOV bl, [esi]
        MOV [edi], bl 

        INC esi
        INC edi 
        DEC al

        JNZ COPY_LOOP
        RET

    TRY_MOVES:
        ; loop to try to play every move
        MOV [rowPos], 6
        MOV [linePos], 5
        ; once again doing it by decreasing the iteration to avoid a CMP

    TRY_LOOP:
        CALL CHECK_GRID

        ; DO SOMETHING

        ; prepare for next iteration
        MOV [linePos], 5
        DEC [rowPos]
        ; redo the loop while rowPos >= 0
        JNS TRY_LOOP
    
        RET