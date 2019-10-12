section "VBlank", rom0

HEAD_TILE_RIGHT EQU $4
HEAD_TILE_UP EQU $6

VBlank::
    push af
	push bc
	push de
	push hl

	call SetDirectionFromJoypad
    call DrawSnake

    pop hl
	pop de
	pop bc
	pop af
	reti

DrawSnake::
	ld a, [wHeadOffset]
	ld b, a ; load head offset into `b`
	ld a, [wSnakeLength]
	ld c, a ; load snake length int `c`
	inc c ; increment the snake length counter by 1 because we will draw a blank tile at the last location behind the snake.

.drawNextSegment
	ld hl, wSegmentLocations
	ld e, b
	ld d, 0 ; `de` contains 8-bit offset of current segment
	sla e
	jr nc, .noCarry
	inc d
.noCarry ; `de` contains the offset doubled because each segment location is 16 bits
	add hl, de ; `hl` contains memory location of current segment
	ld a, [hli]
	ld d, a
	ld a, [hl]
	ld e, a ; `de` contains the bg map index of the current segment
	ld hl, _SCRN0
	add hl, de ; `hl` contains address in bg map to draw segment
	ld a, HEAD_TILE_RIGHT
	ld [hl], a
	inc b
	dec c
	jr nz, .drawNextSegment
	ld [hl], 0 ; erase the last tile drawn
	ret
