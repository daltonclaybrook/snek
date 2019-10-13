section "WRAM Bank 0", wram0

; An offset within `wSegmentLocations` representing the location of the head of the snake. 
wHeadOffset::
    ds 1

; The current length of the snake.
; Incremented when the snake eats an apple. Reset when the snake eats itself.
; Because this is only an 8-
wSnakeLength::
    ds 1

; The buffer where snake segment locations are stored.
; There are 360 visible tiles inside the scrolling area (20x18)
; Segments are stored as 16-bit numbers, so 360 * 2 is reserved.
wSegmentLocations::
    ds 360 * 2

; The current location of the apple as an offset in the BG Map
wAppleLocation::
    ds 2

; Used to zero out the tile where the apple last was
wLastAppleLocation::
    ds 2
