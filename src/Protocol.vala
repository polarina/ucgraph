namespace uCgraph
{
	private enum Type
	{
		IDENT = 0x01,
		PONG = 0x00,
		PORT_DIGITAL_STATE = 0x02,

		NONE = 0xff,
	}

	class Protocol : Object
	{
		public IOStream stream { get; construct set; }

		public signal void on_ident (Device device);
		public signal void on_pong (uint32 payload);
		public signal void on_port_digital_state (uint8 port, uint8 state);

		public Protocol (IOStream stream)
		{
			Object (
				stream: stream
			);
		}

		construct
		{
			this.cancellable = new Cancellable ();
			this.input = new Deserialization (
				this.stream.input_stream,
				this.cancellable);

			this.send_buffer = new Queue<Bytes> ();
		}

		public void begin ()
		{
			this.recv_work.begin ();
			this.sending = true;
			this.send_work.begin ((obj, res) => {
				this.sending = false;
			});
		}

		public void end ()
		{
			this.cancellable.cancel ();
		}

		public void do_ident ()
		{
			this.send_buffer.push_tail (new Bytes ({
				0x01
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		public void do_monitor_port (uint8 port)
		{
			this.send_buffer.push_tail (new Bytes ({
				0x02,
				port
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		public void do_neglect_port (uint8 port)
		{
			this.send_buffer.push_tail (new Bytes ({
				0x03,
				port
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		public void do_ping (uint32 payload)
		{
			this.send_buffer.push_tail (new Bytes ({
				0x00,
				(uint8) (payload >> 24),
				(uint8) (payload >> 16),
				(uint8) (payload >> 8),
				(uint8) payload
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		public void do_set_port_mode (uint8 port, uint8 mode)
		{
			this.send_buffer.push_tail (new Bytes ({
				0x04,
				port,
				mode
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		public void do_set_port_state (uint8 port, uint8 state)
		{
			this.send_buffer.push_tail (new Bytes ({
				0x05,
				port,
				state
			}));

			if ( ! this.sending)
			{
				this.sending = true;
				this.send_work.begin ((obj, res) => {
					this.sending = false;
				});
			}
		}

		private async void step ()
			throws IOError
		{
			uint8 type = yield this.input.read_uint8 ();

			switch (type)
			{
				case Type.IDENT:
					string device = yield this.input.read_string ();
					Gee.List<Port> ports = new Gee.ArrayList<Port> ();
					uint8 num_ports = yield this.input.read_uint8 ();

					for (size_t i = 0; i < num_ports; ++i)
					{
						string port_name = yield this.input.read_string ();
						Gee.List<Pin> pins = new Gee.ArrayList<Pin> ();

						for (int pin = 7; pin >= 0; --pin)
						{
							string pin_name = yield this.input.read_string ();

							if (pin_name != "")
							{
								uint8 capabilities = yield this.input.read_uint8 ();

								pins.add (new Pin (pin_name, (uint8) i, (uint8) pin, capabilities));
							}
						}

						ports.add (new Port (port_name, pins));
					}

					this.on_ident (new Device (device, ports));
					break;
				case Type.PONG:
					uint32 payload = yield this.input.read_uint32 ();
					this.on_pong (payload);
					break;
				case Type.PORT_DIGITAL_STATE:
					uint8 port = yield this.input.read_uint8 ();
					uint8 state = yield this.input.read_uint8 ();
					this.on_port_digital_state (port, state);
					break;
				default:
					assert_not_reached ();
			}
		}

		private async void recv_work ()
			throws IOError
		{
			while (true)
			{
				yield this.step ();
			}
		}

		private async void send_work ()
			throws IOError
		{
			Bytes data;

			while ((data = this.send_buffer.pop_head ()) != null)
			{
				ssize_t sent = yield this.stream.output_stream.write_async (
					data.get_data (),
					Priority.DEFAULT,
					this.cancellable);

				assert (data.length == sent);
			}
		}

		private Cancellable cancellable;
		private Deserialization input;
		private Queue<Bytes> send_buffer;
		private bool sending;
	}
}
