.PHONY: all upload

all: atmega328p

upload: atmega328p.hex
	avrdude -V -c arduino -p atmega328p -P /dev/ttyACM0 -b 115200 -U flash:w:atmega328p.hex

atmega328p.hex: atmega328p
	avr-objcopy -O ihex -R .eeprom atmega328p atmega328p.hex

atmega328p: atmega328p.c protocol.c protocol.h
	avr-gcc -std=c99 -Os -flto -DF_CPU=16000000UL -mmcu=atmega328p -o atmega328p -Wall -Wextra \
		atmega328p.c \
		protocol.c
