namespace uCgraph.Message
{
	class ServerPong : Server
	{
		public uint32 payload;

		public ServerPong (uint32 payload)
		{
			this.payload = payload;
		}

		public ServerPong.deserialize (DataInputStream stream)
			throws IOError
		{
			this.payload = stream.read_uint32 ();
		}

		public override void serialize (DataOutputStream stream)
			throws IOError
		{
			stream.put_byte (0x00);
			stream.put_uint32 (this.payload);
		}
	}
}
