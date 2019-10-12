#!/bin/bash

rgbasm -v -o build/main.o main.asm
rgblink -d -n build/snake.sym -o build/snake.gbc build/main.o
rgbfix -cjsv -k 01 -l 0x33 -m 0x1b -p 0 -r 03 build/snake.gbc
