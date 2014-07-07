#ifndef _UC_PROTOCOL_H_
#define _UC_PROTOCOL_H_

#include <stdint.h>

void
uc_protocol_init ();

uint8_t
uc_protocol_tx_next ();

void
uc_protocol_step (uint8_t byte);

void
uc_protocol_do_pong (uint32_t payload);

void
uc_protocol_on_ping (uint32_t payload);

void
uc_protocol_tx_enable ();

void
uc_protocol_tx_disable ();

#endif
