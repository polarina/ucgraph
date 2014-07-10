namespace uCgraph
{
	class Pin : Object
	{
		public string name { get; construct set; }
		public uint8 position { get; construct set; }
		public uint8 capabilities { get; construct set; }

		public Pin (string name, uint8 position, uint8 capabilities)
		{
			Object (
				name: name,
				position: position,
				capabilities: capabilities
			);
		}
	}
}
