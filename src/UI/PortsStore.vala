namespace uCgraph.UI
{
	class PortsStore : Gtk.TreeStore
	{
		public Device device { get; construct set; }

		public PortsStore (Device device)
		{
			Object (
				device: device
			);
		}

		construct
		{
			GLib.Type[] types = {
				typeof (bool),
				typeof (string),
				typeof (bool),
				typeof (Pin)
			};

			this.set_column_types (types);

			foreach (Port port in device.ports)
			{
				Gtk.TreeIter iter;

				this.insert_with_values (out iter, null, -1,
					0, false,
					1, port.name,
					-1);

				foreach (Pin pin in port.pins)
				{
					this.insert_with_values (null, iter, -1,
						0, true,
						1, pin.name,
						2, false,
						3, pin,
						-1);
				}
			}
		}
	}
}
