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

	protocol.message_received.connect ((object, data) => {
		stdout.printf ("% 4d: ", data.length);

		foreach (uint8 chr in data)
		{
			stdout.printf ("%02x ", chr);
		}

		stdout.printf ("\n");
		stdout.flush ();
	});

	protocol.begin ();

	Timeout.add (1000, () => {
		stdout.printf ("\n");
		protocol.send (new uCgraph.Message.ClientPing (0x323a));

		return true;
	});

	return app.run (args);
}
