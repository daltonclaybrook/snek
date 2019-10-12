section "Joypad", rom0

SetInitialDirection::
    ld a, DIRECTION_RIGHT
    ld [hDirection], a
    ret

SetDirectionFromJoypad::
    ld a, %100000 ; select direction buttons
    ld [rP1], a
    ld a, [rP1]
    and a, %1111
    ld b, a
.checkUp
    bit 2, b
    jr nz, .checkLeft
    ld a, DIRECTION_UP
    ld [hDirection], a
.checkLeft
    bit 1, b
    jr nz, .checkDown
    ld a, DIRECTION_LEFT
    ld [hDirection], a
.checkDown
    bit 3, b
    jr nz, .checkRight
    ld a, DIRECTION_DOWN
    ld [hDirection], a
.checkRight
    bit 0, b ; right direction
    jr nz, .finish
    ld a, DIRECTION_RIGHT
    ld [hDirection], a
.finish
    ret
