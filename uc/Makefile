.PHONY: all avr

all: avr

avr: main.hex
	avrdude -V -c arduino -p atmega328p -P /dev/ttyACM0 -b 115200 -U flash:w:main.hex

main.hex: main
	avr-objcopy -O ihex -R .eeprom main main.hex

main: main.c
	avr-gcc -std=c99 -O2 -DF_CPU=16000000UL -mmcu=atmega328p -o main main.c -Wall -Wextra
