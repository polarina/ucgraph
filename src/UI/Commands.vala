namespace uCgraph.UI
{
	class Commands : Gtk.Menu
	{
		public Gtk.Application application { get; construct set; }
		public Gtk.Window parent_window { get; construct set; }

		public Commands (Gtk.Application application, Gtk.Window parent)
		{
			Object (
				application: application,
				parent_window: parent
			);
		}

		construct
		{
			Gtk.MenuItem about = new Gtk.MenuItem.with_mnemonic ("_About");
			Gtk.MenuItem quit = new Gtk.MenuItem.with_label ("Quit");

			this.add (about);
			this.add (new Gtk.SeparatorMenuItem ());
			this.add (quit);

			about.activate.connect (() => {
				UI.AboutDialog dialog = new UI.AboutDialog (this.parent_window);
				dialog.present ();
			});

			quit.activate.connect (() => {
				this.application.quit ();
			});
		}
	}
}
