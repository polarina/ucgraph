#include "s11n.h"

struct uc_s11n
uc_s11n_init (struct uc_server_message *msg)
{
	return (struct uc_s11n) {
		.msg = msg,
		.pos = 0
	};
}

bool
uc_s11n_step (struct uc_s11n *self, uint8_t *byte)
{
	uint8_t *buf = (uint8_t *) self->msg;

	*byte = buf[self->pos++];

	switch (buf[0])
	{
		case UC_SERVER_PONG:
			return self->pos > sizeof (self->msg->pong);
		default:
			return true;
	}
}

struct uc_des11n
uc_des11n_init (struct uc_client_message *msg)
{
	return (struct uc_des11n) {
		.msg = msg,
		.pos = 0
	};
}

bool
uc_des11n_step (struct uc_des11n *self, uint8_t byte)
{
	uint8_t *buf = (uint8_t *) self->msg;

	buf[self->pos++] = byte;

	switch (buf[0])
	{
		case UC_CLIENT_PING:
			return self->pos > sizeof (self->msg->ping);
		default:
			return true;
	}
}
