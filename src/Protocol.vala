namespace uCgraph
{
	class Protocol : Object
	{
		private Cancellable cancellable;

		public IOStream stream { get; construct set; }

		public signal void message_received (uint8[] message);

		public Protocol (IOStream stream)
		{
			Object (
				stream: stream
			);
		}

		public void begin ()
		{
			this.cancellable = new Cancellable ();

			this.work.begin ();
		}

		public void end ()
		{
			this.cancellable.cancel ();
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
