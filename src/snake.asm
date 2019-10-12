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