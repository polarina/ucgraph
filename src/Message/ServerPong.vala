namespace uCgraph.Message
{
	class ServerPong : Server
	{
		public uint32 payload;

		public ServerPong (DataInputStream stream)
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
