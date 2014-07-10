using Gee;

namespace uCgraph.UI
{
	class PinControls : Object
	{
		private TreeMap<Pin, Gtk.Widget> pin_widgets;
		private TreeMap<Pin, Gtk.Label> pin_states;

		public Device device { get; construct set; }
		public Gtk.Box pins_box { get; construct set; }

		public signal void pin_mode_changed (Pin pin, bool mode);
		public signal void pin_output_changed (Pin pin, bool output);

		public PinControls (Device device, Gtk.Box pins_box)
		{
			Object (
				device: device,
				pins_box: pins_box
			);
		}

		construct
		{
			this.pin_widgets = new TreeMap<Pin, Gtk.Widget> ();
			this.pin_states = new TreeMap<Pin, Gtk.Label> ();

			foreach (Port port in device.ports)
			{
				foreach (Pin pin in port.pins)
				{
					Gtk.Box controls = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);
					Gtk.Label label = new Gtk.Label (@"<span size=\"x-large\">$(pin.name)</span>");
					Gtk.ComboBoxText state = new Gtk.ComboBoxText ();

					Gtk.Label in_label = new Gtk.Label (@"<span size=\"x-large\">LOW</span>");
					Gtk.ComboBoxText out_combo = new Gtk.ComboBoxText ();

					state.append ("0", "Digital Input");
					state.append ("1", "Digital Output");
					state.active_id = "0";

					label.use_markup = true;

					in_label.use_markup = true;

					out_combo.append ("0", "LOW");
					out_combo.append ("1", "HIGH");
					out_combo.active_id = "0";

					controls.add (label);
					controls.add (state);
					controls.add (in_label);
					controls.add (out_combo);

					this.pins_box.add (controls);

					state.changed.connect ((sender) => {
						switch (state.active_id)
						{
							case "0":
								in_label.show ();
								out_combo.hide ();
								pin_mode_changed (pin, false);
								break;
							case "1":
								in_label.hide ();
								out_combo.show ();
								pin_mode_changed (pin, true);
								break;
							default:
								assert_not_reached ();
						}
					});

					out_combo.changed.connect ((sender) => {
						switch (out_combo.active_id)
						{
							case "0":
								pin_output_changed (pin, false);
								break;
							case "1":
								pin_output_changed (pin, true);
								break;
							default:
								assert_not_reached ();
						}
					});

					label.show ();
					state.show ();
					in_label.show ();

					this.pin_widgets.set (pin, controls);
					this.pin_states.set (pin, in_label);
				}
			}
		}

		public void set_visibility (Pin pin, bool visible)
		{
			this.pin_widgets.get (pin).visible = visible;
		}

		public void set_pin_state (Pin pin, bool state)
		{
			this.pin_states.get (pin).label = @"<span size=\"x-large\">$(state ? "HIGH" : "LOW")</span>";
		}
	}
}
