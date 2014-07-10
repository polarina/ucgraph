namespace uCgraph
{
	class Port : Object
	{
		public string name { get; construct set; }
		public Gee.List<Pin> pins { get; construct set; }

		public Port (string name, Gee.List<Pin> pins)
		{
			Object (
				name: name,
				pins: pins
			);
		}
	}
}
