section "Timer", rom0

; approx 16 ticks per second
TIMER_COUNT EQU 4 ; Count of timer fires until advancing gameplay

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
    call AdvanceSnake

.finish
    pop hl
	pop de
	pop bc
	pop af
	reti
