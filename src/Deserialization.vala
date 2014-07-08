namespace uCgraph
{
	class Deserialization : Object
	{
		public Cancellable cancellable { get; construct set; }
		public InputStream stream { get; construct set; }

		public Deserialization (InputStream stream, Cancellable? cancellable)
		{
			Object (
				cancellable: cancellable,
				stream: stream
			);
		}

		public async uint8[] read_bytes (size_t num)
			throws IOError
		{
			uint8[] bytes = new uint8[num];
			size_t read = 0;

			while (true)
			{
				read += yield stream.read_async (
					bytes[read:bytes.length],
					Priority.DEFAULT,
					this.cancellable);

				if (read == num)
					return bytes;
			}
		}

		public async string read_string ()
			throws IOError
		{
			string str = "";
			uint8 bytes[1];

			while (true)
			{
				ssize_t read = yield stream.read_async (
					bytes,
					Priority.DEFAULT,
					this.cancellable);

				if (read != bytes.length)
					throw new IOError.FAILED ("partial read");

				if (bytes[0] == 0x00)
					return str;

				str = @"$str$((char) bytes[0])";
			}
		}

		public async uint8 read_uint8 ()
			throws IOError
		{
			uint8[] bytes = yield this.read_bytes (1);

			return bytes[0];
		}

		public async uint16 read_uint16 ()
			throws IOError
		{
			uint8[] bytes = yield this.read_bytes (2);

			return bytes[0] << 8 | bytes[1];
		}

		public async uint32 read_uint32 ()
			throws IOError
		{
			uint8[] bytes = yield this.read_bytes (4);

			return bytes[0] << 24 | bytes[1] << 16 | bytes[2] << 8 | bytes[3];
		}
	}
}
