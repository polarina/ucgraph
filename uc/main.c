#include <avr/interrupt.h>
#include <avr/io.h>
#include <avr/pgmspace.h>
#include <avr/sfr_defs.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <util/delay.h>

#define BAUD 9600
#include <util/setbaud.h>

volatile uint8_t tmp;

ISR (USART_RX_vect)
{
	tmp = UDR0;
}

uint8_t chr = 0x00;

ISR (USART_UDRE_vect)
{
	UDR0 = chr++;

	PORTB ^= 0x20;

	/* disable data register empty interrupt */
	//UCSR0B &= ~_BV (UDRIE0);
}

int main ()
{
	PORTB = 0x01;
	DDRB = 0x20;
	DDRD = 0x02;

	/* set baud rate */
	UBRR0 = UBRR_VALUE;

#if USE_2X
	UCSR0A |= _BV (U2X0);
#else
	UCSR0A &= ~_BV (U2X0);
#endif

	/* serial: enable RX complete and data register empty interrupt,
	           receiver and transmitter */
	UCSR0B = _BV (RXCIE0) | _BV (UDRIE0) | _BV (RXEN0) | _BV (TXEN0);

	/* serial: 8-bit characters */
	UCSR0C = _BV (UCSZ01) | _BV (UCSZ00);

	sei ();

	while (1)
	{
		//_delay_ms (200);

		/* enable data register empty interrupt */
		//UCSR0B |= _BV (UDRIE0);
	}

	return 0;
}
