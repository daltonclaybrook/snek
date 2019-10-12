; Define a 2-byte RGB color
;
; /1 = R, /2 = G, /3 = B
; Each color component is 5 bits (0-31)
; `RGB 31, 31, 31` == white
RGB: MACRO
     dw (\3 << 10 | \2 << 5 | \1)
ENDM
