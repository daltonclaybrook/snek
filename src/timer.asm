section "Timer", rom0

; approx 16 ticks per second
TIMER_COUNT EQU 10 ; Count of timer fires until advancing gameplay

Timer::
    push af
	push bc
	push de
	push hl

    ld a, [hTimerCounter]
    inc a
    ld [hTimerCounter], a
    cp a, TIMER_COUNT
    jr c, .finish
    xor a
    ld [hTimerCounter], a
    call GameTick

.finish
    pop hl
	pop de
	pop bc
	pop af
	reti

GameTick::
    ld a, [wHeadOffset]
    dec a
    ld [wHeadOffset], a
    inc a
    call LoadLocationAtOffsetIntoBC
    ld a, [wHeadOffset]
    inc bc
    call LoadLocationBCIntoOffset
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
LoadLocationBCIntoOffset::
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
