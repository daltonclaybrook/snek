section "Timer", rom0

; approx 16 ticks per second
TIMER_COUNT EQU 16 ; Count of timer fires until advancing gameplay

Timer::
    push af
	push bc
	push de
	push hl

ldh
    ld a, [hTimerCounter]
    dec a
    ld [hTimerCounter], a
    jr nz, .finish
    ld a, TIMER_COUNT
    ld [hTimerCounter], a
    call Tick

.finish
    pop hl
	pop de
	pop bc
	pop af
	reti

Tick::
    ld a, [wHeadOffset]
    call LoadLocationAtOffsetIntoBC
    ret

; Load the BG map location of the segment with offset `a` into `bc`
; @param `a` - offset within `wSegmentLocations`
LoadLocationAtOffsetIntoBC::
    ld a, [wHeadOffset]
    ld c, a
    ld b, 0
    call DoubleBC ; each segment is 16-bits, so we need to double the offset
    ld hl, wSegmentLocations
    add hl, bc ; `hl` contains location of new snake head location in WRAM
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    ret

; multiple `bc` by 2
DoubleBC::
    sla c
    ret nc
    inc b
    ret
