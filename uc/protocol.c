#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "protocol.h"

#define WRITE(x) do { \
		buf[end++] = (x); \
		end %= sizeof (buf); \
	} while (0)

enum uc_protocol_type
{
	PROTOCOL_TYPE_IDENT = 0x01,
	PROTOCOL_TYPE_PING = 0x00,

	PROTOCOL_TYPE_NONE = 0xff,
};

static uint8_t buf[64];
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
uc_protocol_do_ident (const char *device)
{
	WRITE (0x01);

	for (size_t i = 0; device[i] != 0; ++i)
	{
		WRITE (device[i]);
	}

	WRITE (0x00);
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
