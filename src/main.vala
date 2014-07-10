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
		stderr.printf ("IOError: %s\n", e.message);
		return 1;
	}

	uCgraph.Protocol protocol = new uCgraph.Protocol (serial);

	protocol.on_ident.connect ((object, device) => {
		stdout.printf ("ident (device: %s)\n", device.name);
		app.with_device (device);
	});

	protocol.on_pong.connect ((object, payload) => {
		stdout.printf ("pong (%u)\n", payload);
	});

	protocol.on_port_digital_state.connect ((object, port, state) => {
		// stdout.printf ("port-digital-state (%u, %u)\n", port, state);
	});

	protocol.begin ();

	int i = 0;

	Timeout.add (2000, () => {
		if (i == 0)
		{
			protocol.do_ident ();
			protocol.do_monitor_port (1);
		}

		protocol.do_ping (i++);

		return true;
	});

	return app.run (args);
}
