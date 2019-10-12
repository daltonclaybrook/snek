section "Random", rom0

Random::
; Returns a random number in `a`.
    push bc
    call _Random
    ld a, [hRandomAdd]
    pop bc
    ret

_Random::
; Generate a random 16-bit value.
	ld a, [rDIV]
	ld b, a
	ld a, [hRandomAdd]
	adc b
	ld [hRandomAdd], a
	ld a, [rDIV]
	ld b, a
	ld a, [hRandomSub]
	sbc b
	ld [hRandomSub], a
	ret
