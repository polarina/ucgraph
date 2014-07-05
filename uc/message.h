#ifndef _UC_MESSAGE_H_
#define _UC_MESSAGE_H_

#include <stdint.h>

enum uc_client_message_type
{
	UC_CLIENT_PING = 0x00
};

enum uc_server_message_type
{
	UC_SERVER_PONG = 0x00
};

struct uc_client_message
{
	uint8_t type;

	union
	{
		uint32_t payload;
	} ping;
};

struct uc_server_message
{
	uint8_t type;

	union
	{
		uint32_t payload;
	} pong;
};

#endif
