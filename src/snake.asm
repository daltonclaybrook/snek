section "Snake Gameplay Logic", rom0

ConfigureInitialSnakeValues::
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
.checkBottom
.finish
    ld b, h ; copy `hl` back into `bc`
    ld c, l
    ret