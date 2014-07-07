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

			this.recv_buffer = new uint8[4096];
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

		private void step (uint8 byte)
		{
			bool done = false;

			switch (this.type)
			{
				case Type.NONE:
					switch (byte)
					{
						case Type.IDENT:
							this.string_dummy = "";
							this.type = Type.IDENT;
							break;
						case Type.PONG:
							this.dummy = 0;
							this.type = Type.PONG;
							break;
						default:
							assert_not_reached ();
					}
					break;
				case Type.IDENT:
					done = this.step_ident (byte);
					break;
				case Type.PONG:
					done = this.step_pong (byte);
					break;
			}

			if (done)
			{
				this.type = Type.NONE;
				this.processed = 0;
			}
		}

		private bool step_ident (uint8 byte)
		{
			char chr = (char) byte;

			if (chr == 0x00)
			{
				this.on_ident (this.string_dummy);

				return true;
			}
			else
			{
				this.string_dummy = @"$(this.string_dummy)$chr";
			}

			return false;
		}

		private bool step_pong (uint8 byte)
		{
			this.dummy <<= 8;
			this.dummy |= byte;

			if (++this.processed >= sizeof (uint32))
			{
				this.on_pong (this.dummy);

				return true;
			}

			return false;
		}

		private async void recv_work ()
			throws IOError
		{
			while (true)
			{
				ssize_t read = yield this.stream.input_stream.read_async (
					this.recv_buffer,
					Priority.DEFAULT,
					this.cancellable);

				if (read == 0)
					return;

				foreach (uint8 byte in this.recv_buffer[0:read])
				{
					this.step (byte);
				}
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
		private uint8[] recv_buffer;
		private Queue<Bytes> send_buffer;
		private bool sending;

		private Type type = Type.NONE;
		private size_t processed;

		private uint32 dummy;
		private string string_dummy;
	}
}
