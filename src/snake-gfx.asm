section "Snake GFX", rom0

CopySnakeTilesToVRAM::
    ld hl, _VRAM
    ld de, SnakeTiles ; pointer to next tile
    ld bc, SnakeTilesEnd - SnakeTiles ; counter of tiles remaining
.copyNextByte
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .copyNextByte
    ret

CopySnakeBGPaletteToVRAM::
    ld a, %10000000 ; 7th bit is set to tell palette register to auto-increment.
    ld [rBCPS], a
    ld de, rBCPD
    ld hl, SnakePalette
    ld c, SnakePaletteEnd - SnakePalette ; count of color bytes to copy
.copyNextByte
    ld a, [hli]
    ld [de], a ; do not increment de because it is auto-incremented
    dec c
    jr nz, .copyNextByte
    ret

section "Snake Data", rom0

SnakeTiles::
    incbin "bin/snake.2bpp"
SnakeTilesEnd::

SnakePalette::
    incbin "bin/snake.pal"
SnakePaletteEnd::
