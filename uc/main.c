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

#include "s11n.h"

struct uc_s11n s11n;
struct uc_des11n des11n;

struct uc_client_message client_msg;
struct uc_server_message server_msg;

ISR (USART_RX_vect)
{
	bool complete = uc_des11n_step (&des11n, UDR0);

	if (complete)
	{
		switch (client_msg.type)
		{
			case UC_CLIENT_PING:
				server_msg.type = UC_SERVER_PONG;
				server_msg.pong.payload = client_msg.ping.payload;

				/* enable data register empty interrupt */
				UCSR0B |= _BV (UDRIE0);
				break;
		}

		des11n = uc_des11n_init (&client_msg);
	}
}

ISR (USART_UDRE_vect)
{
	uint8_t byte;
	bool complete = uc_s11n_step (&s11n, &byte);
	UDR0 = byte;

	if (complete)
	{
		s11n = uc_s11n_init (&server_msg);

		/* disable data register empty interrupt */
		UCSR0B &= ~_BV (UDRIE0);
	}
}

int main ()
{
	des11n = uc_des11n_init (&client_msg);
	s11n = uc_s11n_init (&server_msg);

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
		;

	return 0;
}
