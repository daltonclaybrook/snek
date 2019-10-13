section "Random", rom0

; Returns a random number in `a`.
Random::
    push bc
    call _Random
    ld a, [hRandomAdd]
    pop bc
    ret

; Returns a random word in `bc`
RandomWord::
	call _Random
	ld a, [hRandomAdd]
	ld b, a
	ld a, [hRandomSub]
	ld c, a
	ret

; Generate a random 16-bit value.
_Random::
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
