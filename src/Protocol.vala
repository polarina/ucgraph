namespace uCgraph
{
	private enum Type
	{
		IDENT = 0x01,
		PONG = 0x00,
		NONE = 0xff,
	}

	class Protocol : Object
	{
		public IOStream stream { get; construct set; }

		public signal void on_ident (string device);
		public signal void on_pong (uint32 payload);

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

		public void do_ping (uint32 payload)
			throws IOError
		{
			this.send_buffer.push_tail (new Bytes ({
				0x00,
				(uint8) payload >> 24,
				(uint8) payload >> 16,
				(uint8) payload >> 8,
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

		private async void step ()
			throws IOError
		{
			uint8 type = yield this.input.read_uint8 ();

			switch (type)
			{
				case Type.IDENT:
					string device = yield this.input.read_string ();
					this.on_ident (device);
					break;
				case Type.PONG:
					uint32 payload = yield this.input.read_uint32 ();
					this.on_pong (payload);
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
