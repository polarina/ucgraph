namespace uCgraph.UI
{
	class AboutDialog : Gtk.AboutDialog
	{
		public AboutDialog (Gtk.Window parent)
		{
			Object (
				modal: true,
				transient_for: parent
			);
		}

		construct
		{
			const string[] authors = {
				"Gabríel Arthúr Pétursson <gabriel@system.is>",
				null
			};

			this.authors = authors;

			this.program_name = "µCgraph";
			this.copyright = "Copyright © 2014 Gabríel Arthúr Pétursson";
			this.license_type = Gtk.License.GPL_3_0;
		}
	}
}
