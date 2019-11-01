section "Snake Gameplay Logic", rom0

ConfigureInitialSnakeValuesAndScore::
    xor a
    ld [wHeadOffset], a  ; reset snake head offset to zero
    ld a, 3 ; snake has initial length of 3
    ld [wSnakeLength], a
    ld a, 3 * $20 + 4 ; initial position of snakes head. three rows down and four from the left.
    ld hl, wSegmentLocations
    ld [hl], 0
    inc hl
    ld [hli], a
    dec a
    ld [hl], 0
    inc hl
    ld [hli], a
    dec a
    ld [hl], 0
    inc hl
    ld [hli], a
    xor a ; set score to zero
    ld [wScore], a
    ld [wScore + 1], a
    ret

AdvanceSnake::
    ld a, [wHeadOffset]
    dec a
    ld [wHeadOffset], a
    inc a
    call LoadLocationAtOffsetIntoBC
    call UpdateBCLocationBasedOnDirection
    call WrapBCIfNecessary
    ld a, [wHeadOffset]
    call LoadLocationBCIntoOffsetA
    call CheckIfSnakeIsBitingApple
    ret

; Load the BG map location of the segment with offset `a` into `bc`
; @param `a` - offset within `wSegmentLocations`
LoadLocationAtOffsetIntoBC::
    ld c, a
    ld b, 0
    call DoubleBC ; each segment is 16-bits, so we need to double the offset
    ld hl, wSegmentLocations
    add hl, bc ; `hl` contains location segment in WRAM
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    ret

; Load the BG map location at `bc` into offset `a`
; @param `bc` - the location to load
; @param `a` - the offset within `wSegmentLocations` to load the location
LoadLocationBCIntoOffsetA::
    ld e, a
    ld d, 0
    call DoubleDE ; each segment is 16-bits, so we need to double the offset
    ld hl, wSegmentLocations
    add hl, de ; `hl` contains location segment in WRAM
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ret

; Advance bc to the next space based on the current direction
; @param `bc` - location to update
UpdateBCLocationBasedOnDirection::
    ld a, [hDirection]
    ld h, b
    ld l, c ; `hl` contains the location to update
    ld de, $20 ; `de` contains the length of one full row of tiles in the bg map
.checkRight
    cp DIRECTION_RIGHT
    jr nz, .checkDown
    inc bc
    ret
.checkDown
    cp DIRECTION_DOWN
    jr nz, .checkLeft
    add hl, de
    ld b, h
    ld c, l
    ret
.checkLeft
    cp DIRECTION_LEFT
    jr nz, .checkUp
    dec bc
    ret
.checkUp
    cp DIRECTION_UP
    jr nz, .finish
    ld a, l
    sub e
    ld l, a
    jr nc, .noCarry
    dec h
.noCarry
    ld b, h
    ld c, l
.finish
    ret

; If `bc` moved off the edge of the visible area, wrap it to the opposite side
WrapBCIfNecessary::
    ld h, b
    ld l, c ; `hl` contains the location
    ld de, 20 ; `de` contains 20, then length of a visible row
    ld a, c
    and $1f ; masks off the current row. What we're left with is a value 0-31
.checkWrapLeft
    cp 31 ; 31 is the rightmost tile in the row, so we've wrapped on the left side
    jr nz, .checkRight
    add hl, de ; add 20 to `hl`
    jr .finish
.checkRight
    cp 20 ; the visible screen is 20 tiles wide, so if `bc` is at 20, it has wrapped on the right side
    jr nz, .checkTop
    ld a, l
    sub 20
    ld l, a
    jr nc, .finish
    dec h
    jr .finish
.checkTop
    ld a, h
    cp $ff
    jr nz, .checkBottom
    ld a, l
    and $e0 ; mask off the column number. What we're left with is only row information
    cp $e0
    jr nz, .checkBottom ; at this point, we've determined `hl` == $ffe0 when you mask off the row info. This means the snake has gone off the top.
    ld a, l
    and $1f ; masks off the current row. What we're left with is a value 0-31
    ld h, $02 ; high byte of last row
    add $20 ; low byte of last row == $20 + the column number (0-31)
    ld l, a
    jr .finish
.checkBottom
    ld a, h
    cp $02
    jr nz, .finish
    ld a, l
    and $e0 ; mask off the column number. What we're left with is only row information
    cp $40
    jr nz, .finish ; at this point, we've determined `hl` == $0240 when you mask off the row info. This means the snake has gone off the bottom.
    ld a, l
    and $1f ; masks off the current row. What we're left with is a value 0-31
    ld h, 0
    ld l, a
    jr .finish
.finish
    ld b, h ; copy `hl` back into `bc`
    ld c, l
    ret

; Check if the current snake head position is the same as the apple position
; @param `bc` - The snake head position
CheckIfSnakeIsBitingApple::
    ld a, [wAppleLocation]
    cp b
    jr nz, .finish
    ld a, [wAppleLocation + 1]
    cp c
    jr nz, .finish
    ; Apple location matches `bc`! move the apple and increment the score
    call UpdateApplePosition
    call IncrementGameScore
    call IncrementSnakeLength
.finish
    ret

; Increments the score by 1
IncrementGameScore::
    ld a, [wScore + 1]
    inc a
    ld [wScore + 1], a
    ret nz
    ; incrememnt high byte if the low byte rolled over and is now zero
    ld a, [wScore]
    inc a
    ld [wScore], a
    ret

IncrementSnakeLength::
    ld a, [wSnakeLength]
    inc a
    ld [wSnakeLength], a
    ret
