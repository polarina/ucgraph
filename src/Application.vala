namespace uCgraph
{
	class Application : Gtk.Application
	{
		private Gtk.ApplicationWindow window;

		public Application ()
		{
			Object (
				application_id: "is.system.ucgraph",
				flags:          ApplicationFlags.FLAGS_NONE
			);
		}

		public void with_device (Device device)
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
		}

		protected override void open (File[] files, string hint)
		{
		}
	}
}
