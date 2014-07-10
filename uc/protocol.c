#include <stdarg.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "protocol.h"

#define WRITE(x) do { \
		buf[end++] = (x); \
		end %= sizeof (buf); \
	} while (0)

#define WRITE_STRING(x) do { \
		const char *str = (x); \
		for (size_t i = 0; str[i] != 0; ++i) { \
			WRITE (str[i]); \
		} \
		WRITE (0x00); \
	} while (0)

enum uc_protocol_type
{
	PROTOCOL_TYPE_IDENT = 0x01,
	PROTOCOL_TYPE_MONITOR_PORT = 0x02,
	PROTOCOL_TYPE_NEGLECT_PORT = 0x03,
	PROTOCOL_TYPE_PING = 0x00,

	PROTOCOL_TYPE_NONE = 0xff,
};

static uint8_t buf[256];
static uint8_t begin;
static uint8_t end;

static enum uc_protocol_type type = PROTOCOL_TYPE_NONE;

static union
{
	struct
	{
		uint32_t payload;
		uint8_t pos;
	} ping;
} state;

static bool
uc_protocol_step_ping (uint8_t byte)
{
	state.ping.payload <<= 8;
	state.ping.payload |= byte;
	++state.ping.pos;

	if (state.ping.pos == 4)
	{
		uc_protocol_on_ping (state.ping.payload);

		state.ping.pos = 0;

		return true;
	}

	return false;
}

void
uc_protocol_step (uint8_t byte)
{
	bool done = false;

	switch (type)
	{
		case PROTOCOL_TYPE_NONE:
			switch (byte)
			{
				case PROTOCOL_TYPE_IDENT:
					uc_protocol_on_ident ();
					break;
				default:
					type = byte;
					break;
			}
			break;
		case PROTOCOL_TYPE_MONITOR_PORT:
			uc_protocol_on_monitor_port (byte);
			done = true;
			break;
		case PROTOCOL_TYPE_NEGLECT_PORT:
			uc_protocol_on_neglect_port (byte);
			done = true;
			break;
		case PROTOCOL_TYPE_PING:
			done = uc_protocol_step_ping (byte);
			break;
		default:
			type = PROTOCOL_TYPE_NONE;
			break;
	}

	if (done)
	{
		type = PROTOCOL_TYPE_NONE;
	}
}

uint8_t
uc_protocol_tx_next ()
{
	uint8_t byte = buf[begin++];

	begin %= sizeof (buf);

	if (begin == end)
	{
		uc_protocol_tx_disable ();
	}

	return byte;
}

void
uc_protocol_do_ident (const char *device, uint8_t ports, ...)
{
	WRITE (0x01);
	WRITE_STRING (device);
	WRITE (ports);

	va_list ap;
	va_start (ap, ports);

	for (uint8_t i = 0; i < ports; ++i)
	{
		WRITE_STRING (va_arg (ap, const char *));

		for (uint8_t j = 0; j < 8; ++j)
		{
			const char *pin_name = va_arg (ap, const char *);

			if (pin_name)
			{
				WRITE_STRING (pin_name);
				WRITE (va_arg (ap, int));
			}
			else
			{
				WRITE (0x00);
			}
		}
	}

	va_end (ap);
}

void
uc_protocol_do_pong (uint32_t payload)
{
	WRITE (0x00);
	WRITE (payload >> 24);
	WRITE (payload >> 16);
	WRITE (payload >> 8);
	WRITE (payload);

	uc_protocol_tx_enable ();
}

void
uc_protocol_do_port_digital_state (uint8_t port, uint8_t state)
{
	WRITE (0x02);
	WRITE (port);
	WRITE (state);

	uc_protocol_tx_enable ();
}
