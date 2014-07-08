#define BAUD 9600

#include <avr/interrupt.h>
#include <avr/io.h>
#include <stddef.h>
#include <util/setbaud.h>

#include "protocol.h"

void
uc_protocol_on_ident ()
{
	uc_protocol_do_ident (
		"Atmega328p", 3,
		"Port B",
			NULL,
			NULL,
			"PB5",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PB4",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PB3",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			"PB2",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			"PB1",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			"PB0",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
		"Port C",
			NULL,
			NULL,
			"PC5",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC4",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC3",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC2",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC1",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC0",
				PIN_ANALOG_INPUT | PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
		"Port D",
			"PC7",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC6",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			"PC5",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			"PC4",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC3",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT,
			"PC2",
				PIN_DIGITAL_INPUT | PIN_DIGITAL_OUTPUT | PIN_PWM,
			NULL,
			NULL);
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
