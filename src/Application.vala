namespace uCgraph
{
	class Application : Gtk.Application
	{
		private Gtk.ApplicationWindow window;
		private Protocol protocol;

		public Application ()
		{
			Object (
				application_id: "is.system.ucgraph",
				flags:          ApplicationFlags.FLAGS_NONE
			);
		}

		private void with_device (Device device)
		{
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			Gtk.HeaderBar header_bar = new Gtk.HeaderBar ();
			Gtk.MenuButton menu_button = new Gtk.MenuButton ();
			Gtk.Image image = new Gtk.Image.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.BUTTON);
			Gtk.Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
			Gtk.ScrolledWindow scrolled_window = new Gtk.ScrolledWindow (null, null);
			UI.PortsView ports = new UI.PortsView (new UI.PortsStore (device));
			Gtk.Notebook notebook = new Gtk.Notebook ();
			Gtk.Statusbar statusbar = new Gtk.Statusbar ();
			UI.Commands commands = new UI.Commands (this, window);

			commands.show_all ();

			menu_button.add (image);
			menu_button.set_popup (commands);

			header_bar.title = device.name;
			header_bar.subtitle = "/dev/ttyACM0";
			header_bar.show_close_button = true;

			header_bar.pack_end (menu_button);

			scrolled_window.hscrollbar_policy = Gtk.PolicyType.NEVER;
			scrolled_window.add (ports);

			paned.expand = true;

			paned.add1 (scrolled_window);
			paned.add2 (notebook);

			notebook.append_page (
				new Gtk.Label ("Graphs and Stuff"),
				new Gtk.Label (device.name));

			statusbar.add (new Gtk.Label ("Baud rate: 38400"));

			box.add (paned);
			box.add (statusbar);

			this.window.set_default_size (640, 480);
			this.window.set_titlebar (header_bar);
			this.window.add (box);

			this.window.show_all ();
		}

		protected override void activate ()
		{
			this.window = new Gtk.ApplicationWindow (this);

			uCgraph.Serial serial;

			try
			{
				serial = new uCgraph.Serial ("/dev/ttyACM0");
			}
			catch (IOError e)
			{
				stderr.printf ("IOError: %s\n", e.message);
				this.quit ();
				return;
			}

			this.protocol = new uCgraph.Protocol (serial);

			this.protocol.on_ident.connect ((object, device) => {
				stdout.printf ("ident (device: %s)\n", device.name);
				this.with_device (device);
			});

			this.protocol.on_pong.connect ((object, payload) => {
				stdout.printf ("pong (%u)\n", payload);
			});

			this.protocol.on_port_digital_state.connect ((object, port, state) => {
				// stdout.printf ("port-digital-state (%u, %u)\n", port, state);
			});

			this.protocol.begin ();

			int i = 0;

			Timeout.add (2000, () => {
				if (i == 0)
				{
					this.protocol.do_ident ();
					this.protocol.do_monitor_port (1);
				}

				this.protocol.do_ping (i++);

				return true;
			});
		}

		protected override void open (File[] files, string hint)
		{
		}
	}
}
