#ifndef _UC_PROTOCOL_H_
#define _UC_PROTOCOL_H_

#include <stdint.h>

#define PIN_ANALOG_INPUT 0x01
#define PIN_ANALOG_OUTPUT 0x02
#define PIN_DIGITAL_INPUT 0x04
#define PIN_DIGITAL_OUTPUT 0x08
#define PIN_PWM 0x10

void
uc_protocol_init ();

uint8_t
uc_protocol_tx_next ();

void
uc_protocol_step (uint8_t byte);

void
uc_protocol_do_ident (const char *device, uint8_t ports, ...);

void
uc_protocol_do_pong (uint32_t payload);

void
uc_protocol_do_port_digital_state (uint8_t port, uint8_t state);

void
uc_protocol_on_ident ();

void
uc_protocol_on_monitor_port (uint8_t port);

void
uc_protocol_on_neglect_port (uint8_t port);

void
uc_protocol_on_ping (uint32_t payload);

void
uc_protocol_on_set_port_mode (uint8_t port, uint8_t mode);

void
uc_protocol_on_set_port_state (uint8_t port, uint8_t state);

void
uc_protocol_tx_enable ();

void
uc_protocol_tx_disable ();

#endif
