include "src/hardware.inc" ; https://github.com/gbdev/hardware.inc
include "src/constants.asm"
include "src/hram.asm"
include "src/macros.asm"

; Hardware interrupts
section "vblank", rom0[$40]
	jp VBlank
section "hblank", rom0[$48]
	reti
section "timer", rom0[$50]
	jp Timer
section "serial", rom0[$58]
	reti
section "joypad", rom0[$60]
	reti

section "Header", rom0[$100]

; Execution always begins at $100, but the header starts at $104
; so we need to jump quickly to another location.
EntryPoint::
    di
    jp Start
    
    ; The cartridge header is located here, which contains things like
    ; the game title, Nintendo logo, and GBC support flag.
    ; This instruction fills this space with zeros, and the `rgbfix` 
    ; program will overwrite with the correct values later.
    ds $150 - $104

section "Main", rom0[$150]

Start::
    call DisableLCD
    call CopySnakeTilesToVRAM
    call CopySnakeBGPaletteToVRAM
    call ConfigureInitialSnakeValuesAndScore
    call SetInitialDirection
    call UpdateApplePosition
    call ConfigureInterrupts
    call StartTimer
    call EnableLCD
    ei
.gameLoop
    halt
    jr .gameLoop

ConfigureInterrupts::
    ld a, IEF_VBLANK | IEF_TIMER | IEF_SERIAL
    ld [rIE], a
    ret

StartTimer::
    ld a, TACF_START | TACF_4KHZ
    ld [rTAC], a
    ret

include "src/common.asm"
include "src/wram.asm"
include "src/vblank.asm"
include "src/timer.asm"
include "src/snake-gfx.asm"
include "src/snake.asm"
include "src/apple.asm"
include "src/random.asm"
include "src/joypad.asm"
