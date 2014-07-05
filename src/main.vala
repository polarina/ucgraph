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
		stdout.printf ("%.*s", data.length, data);
		stdout.flush ();
	});

	protocol.begin ();

	return app.run (args);
}
