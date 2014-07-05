namespace uCgraph.Message
{
	class ClientPing : Client
	{
		public uint32 payload;

		public ClientPing (DataInputStream stream)
			throws IOError
		{
			this.payload = stream.read_uint32 ();
		}

		public override void serialize (DataOutputStream stream)
			throws IOError
		{
			stream.put_uint32 (this.payload);
		}
	}
}
