namespace uCgraph
{
	class Device : Object
	{
		public string name { get; construct set; }
		public Gee.List<Port> ports { get; construct set; }

		public Device (string name, Gee.List<Port> ports)
		{
			Object (
				name: name,
				ports: ports
			);
		}
	}
}
