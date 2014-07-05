namespace uCgraph
{
	class Protocol : Object
	{
		private Cancellable cancellable;
		private DataOutputStream data_output_stream;

		public IOStream stream { get; construct set; }

		public signal void message_received (uint8[] message);

		public Protocol (IOStream stream)
		{
			Object (
				stream: stream
			);
		}

		construct
		{
			this.cancellable = new Cancellable ();
			this.data_output_stream = new DataOutputStream (
				this.stream.output_stream);

			this.data_output_stream.byte_order =
				DataStreamByteOrder.LITTLE_ENDIAN;
			this.data_output_stream.set_close_base_stream (false);
		}

		public void begin ()
		{
			this.work.begin ();
		}

		public void end ()
		{
			this.cancellable.cancel ();
		}

		public void send (Message.Client message)
			throws IOError
		{
			message.serialize (this.data_output_stream);
		}

		private async void work ()
			throws IOError
		{
			uint8[] buffer = new uint8[4096];

			while (true)
			{
				ssize_t read;

				read = yield this.stream.input_stream.read_async (
					buffer,
					Priority.DEFAULT,
					this.cancellable);

				if (read == 0)
					return;

				this.message_received (buffer[0:read]);
			}
		}
	}
}
