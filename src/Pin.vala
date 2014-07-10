namespace uCgraph
{
	class Pin : Object
	{
		public string name { get; construct set; }
		public uint8 port { get; construct set; }
		public uint8 position { get; construct set; }
		public uint8 capabilities { get; construct set; }
		public bool mode { get; set; }
		public bool output { get; set; }

		public Pin (string name, uint8 port, uint8 position, uint8 capabilities)
		{
			Object (
				name: name,
				port: port,
				position: position,
				capabilities: capabilities,
				mode: false,
				output: false
			);
		}
	}
}
