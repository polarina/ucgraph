namespace uCgraph
{
	class Device : Object
	{
		public string name { get; construct set; }
		public Serial serial { get; construct set; }

		public Device (string name, Serial serial)
		{
			Object (
				name: name,
				serial: serial
			);
		}
	}
}
