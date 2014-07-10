namespace uCgraph
{
	class Application : Gtk.Application
	{
		public Application ()
		{
			Object (
				application_id: "is.system.ucgraph",
				flags:          ApplicationFlags.FLAGS_NONE
			);
		}

		protected override void activate ()
		{
			Gtk.ApplicationWindow window = new Gtk.ApplicationWindow (this);
			Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			Gtk.HeaderBar header_bar = new Gtk.HeaderBar ();
			Gtk.MenuButton menu_button = new Gtk.MenuButton ();
			Gtk.Image image = new Gtk.Image.from_icon_name ("emblem-system-symbolic", Gtk.IconSize.BUTTON);
			Gtk.Paned paned = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
			Gtk.Notebook notebook = new Gtk.Notebook ();
			Gtk.Statusbar statusbar = new Gtk.Statusbar ();
			UI.Commands commands = new UI.Commands (this, window);

			commands.show_all ();

			menu_button.add (image);
			menu_button.set_popup (commands);

			header_bar.title = "Atmega328p";
			header_bar.subtitle = "/dev/ttyACM0";
			header_bar.show_close_button = true;

			header_bar.pack_end (menu_button);

			paned.expand = true;

			paned.add1 (new Gtk.Label ("Ports & Pins"));
			paned.add2 (notebook);

			notebook.append_page (
				new Gtk.Label ("Graphs and Stuff"),
				new Gtk.Label ("Atmega328p"));

			statusbar.add (new Gtk.Label ("Baud rate: 9600"));

			box.add (paned);
			box.add (statusbar);

			window.set_default_size (640, 480);
			window.set_titlebar (header_bar);
			window.add (box);

			window.show_all ();
		}

		protected override void open (File[] files, string hint)
		{
		}
	}
}
