#ifndef _UC_S11N_H_
#define _UC_S11N_H_

#include "message.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

struct uc_s11n
{
	struct uc_server_message *msg;
	size_t pos;
};

struct uc_des11n
{
	struct uc_client_message *msg;
	size_t pos;
};

struct uc_s11n
uc_s11n_init (struct uc_server_message *msg);

bool
uc_s11n_step (struct uc_s11n *self, uint8_t *byte);

struct uc_des11n
uc_des11n_init (struct uc_client_message *msg);

bool
uc_des11n_step (struct uc_des11n *self, uint8_t byte);

#endif
