#define BAUD 9600

#include <avr/interrupt.h>
#include <avr/io.h>
#include <util/setbaud.h>

#include "protocol.h"

void
uc_protocol_on_ident ()
{
	uc_protocol_do_ident ("Atmega328p");
}

void
uc_protocol_on_ping (uint32_t payload)
{
	uc_protocol_do_pong (payload);
}

void
uc_protocol_tx_enable ()
{
	/* enable data register empty interrupt */
	UCSR0B |= _BV (UDRIE0);
}

void
uc_protocol_tx_disable ()
{
	/* disable data register empty interrupt */
	UCSR0B &= ~_BV (UDRIE0);
}

int
main ()
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

	/* serial: enable RX complete, receiver and transmitter */
	UCSR0B = _BV (RXCIE0) | _BV (RXEN0) | _BV (TXEN0);

	/* serial: 8-bit characters */
	UCSR0C = _BV (UCSZ01) | _BV (UCSZ00);

	sei ();

	while (1)
		;

	return 0;
}

ISR (USART_RX_vect)
{
	uc_protocol_step (UDR0);
}

ISR (USART_UDRE_vect)
{
	UDR0 = uc_protocol_tx_next ();
}
