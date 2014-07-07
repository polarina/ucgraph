int main (string[] args)
{
	uCgraph.Application app = new uCgraph.Application ();
	uCgraph.Serial serial;

	try
	{
		serial = new uCgraph.Serial ("/dev/ttyACM0");
	}
	catch (IOError e)
	{
		return 1;
	}

	uCgraph.Protocol protocol = new uCgraph.Protocol (serial);

	protocol.on_ident.connect ((object, device) => {
		stdout.printf ("ident (%s)\n", device);
	});

	protocol.on_pong.connect ((object, payload) => {
		stdout.printf ("pong (%u)\n", payload);
	});

	protocol.begin ();

	int i = 0;

	Timeout.add (2000, () => {
		if (i == 0)
		{
			protocol.do_ident ();
		}

		protocol.do_ping (i++);

		return true;
	});

	return app.run (args);
}
