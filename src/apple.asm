section "Apple Logic", rom0

UpdateApplePosition::
    call RandomWord ; `bc` contains a random number
    ld a, c
    and $1f ; masks off the current row. What we're left with is a value 0-31
    cp 20 ; if this sets the carry flag, the value is between 0-19 (the visible range)
    jr c, .normalizeRow
    add 12 ; move to the next line
    and $1f ; masks off any row change that might have just occurred.
    ld d, a
    ld a, c
    and $e0 ; mask of column info. `a` now contains only row info
    or d
    ld c, a ; `c` is now guarenteed to have a column of 0-19 (the visible range)
.normalizeRow
    ld hl, $233 ; $233 is the bottom right tile in the BG map. Anything higher has overflowed.
    call CompareHLToBC ; if `bc` is larger, the carry flag will be set
    jr nc, .finish
    ld de, $240 ; The count of tiles in the visible 18 rows (18 x 32)
    ld a, c
    sub e
    ld c, a
    jr nc, .noCarry
    dec b
.noCarry
    ld a, b
    sub d
    ld b, a
    jr .normalizeRow ; keep subtracting until `bc` is in the range
.finish
    ; load `wAppleLocation` with updated location
    ld a, b
    ld [wAppleLocation], a
    ld a, c
    ld [wAppleLocation + 1], a
    ret

; Compare `hl` to `bc` and set the carry flag if `bc` is larger
CompareHLToBC::
    ld a, l
    cp c
    jr nc, .noCarry
    ld a, h
    cp 1
    ret c ; return if subtracting 1 from h carried, meaning `bc` is larger    
.decrementH
    dec h
.noCarry
    ld a, h
    cp b
    ret