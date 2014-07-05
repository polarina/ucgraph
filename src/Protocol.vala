namespace uCgraph
{
	class Protocol : Object
	{
		public IOStream stream { get; construct set; }

		public signal void messare_received (Message.Server message);

		public Protocol (IOStream stream)
		{
			Object (
				stream: stream
			);
		}

		private async void work () throws IOError
		{
			uint8[] buffer = new uint8[4096];

			while (true)
			{
				ssize_t read;

				read = yield this.stream.input_stream.read_async (buffer);

				if (read == 0)
					return;

				GLib.stdout.printf ("%.*s", read, buffer);
				GLib.stdout.flush ();
			}
		}
	}
}
