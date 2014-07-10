namespace uCgraph.UI
{
	class PortsView : Gtk.TreeView
	{
		public PortsView (PortsStore model)
		{
			Object (
				model: model
			);
		}

		construct
		{
			Gtk.CellRendererToggle toggle = new Gtk.CellRendererToggle ();

			toggle.toggled.connect ((sender, path) => {
				Gtk.TreeIter iter;
				Value value;

				PortsStore model = this.model as PortsStore;

				model.get_iter_from_string (out iter, path);
				model.get_value (iter, 2, out value);
				model.set_value (iter, 2, ! (value as bool));
			});

			Gtk.TreeViewColumn enabled = new Gtk.TreeViewColumn.with_attributes (
				"Enabled",
				toggle,
				"active", 2,
				"visible", 0,
				null);

			Gtk.TreeViewColumn name = new Gtk.TreeViewColumn.with_attributes (
				"Pin",
				new Gtk.CellRendererText (),
				"text", 1,
				null);

			name.expand = true;

			this.append_column (enabled);
			this.append_column (name);
		}
	}
}
