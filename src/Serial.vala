using Posix;

namespace uCgraph
{
	class Serial : IOStream
	{
		private int fd;
		private UnixInputStream input;
		private UnixOutputStream output;

		public string port { get; construct set; }

		public override InputStream input_stream
		{
			get { return this.input; }
		}

		public override OutputStream output_stream
		{
			get { return this.output; }
		}

		public Serial (string port) throws IOError
			requires (port != "")
		{
			Object (
				port: port
			);

			this.fd = open (this.port, O_RDWR | O_NOCTTY);

			if (this.fd < 0)
				throw new IOError.FAILED ("open");

			int status = fcntl (this.fd, F_SETFL, O_NONBLOCK);

			if (status == -1)
				throw new IOError.FAILED ("fcntl");

			termios options;

			status = tcgetattr (this.fd, out options);

			if (status != 0)
				throw new IOError.FAILED ("tcgetattr");

			options.c_cflag &= ~(CSTOPB | PARENB);
			options.c_cflag |= CLOCAL | CREAD | CS8;
			options.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);
			options.c_iflag &= ~(IXON | IXOFF | IXANY);
			options.c_oflag &= ~OPOST;

			status = cfsetispeed (ref options, B9600);

			if (status != 0)
				throw new IOError.FAILED ("cfsetispeed");

			status = cfsetospeed (ref options, B9600);

			if (status != 0)
				throw new IOError.FAILED ("cfsetospeed");

			/* TODO: tcsetattr succeeds when _any_ of the changes are applied,
			   we'd like to check that everything succeeded */
			status = tcsetattr (this.fd, TCSANOW, options);

			if (status != 0)
				throw new IOError.FAILED ("tcsetattr");

			this.input = new UnixInputStream (this.fd, false);
			this.output = new UnixOutputStream (this.fd, false);
		}

		~Serial ()
		{
			Posix.close (this.fd);
		}
	}
}
