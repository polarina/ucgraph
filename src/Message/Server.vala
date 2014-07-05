namespace uCgraph.Message
{
	abstract class Server : Object
	{
		public static Server deserialize (DataInputStream stream)
			throws IOError
		{
			uint8 type = stream.read_byte ();

			switch (type)
			{
				case 0x00:
					return new ServerPong.deserialize (stream);
				default:
					assert_not_reached ();
			}
		}

		public abstract void serialize (DataOutputStream stream)
			throws IOError;
	}
}
