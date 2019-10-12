section "Common", rom0

DisableLCD::
    ld b, SCREEN_HEIGHT ; Game Boy screen is 144 pixels tall. Any value over this and we're in V-Blank period.
.loop
    ld a, [rLY] ; read y coordinate register
    cp b
    jr c, .loop ; if no carry occurs, we're in the vblank period
    ld a, [rLCDC]
    res LCD_ON_BIT, a ; turn off LCD
    ld [rLCDC], a
    ret

EnableLCD::
    ld a, [rLCDC]
    set LCD_ON_BIT, a ; turn on LCD
    ld [rLCDC], a
    ret