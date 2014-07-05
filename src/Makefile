.PHONY: all

all:
	valac \
		-g \
		--pkg gio-unix-2.0 \
		--pkg gtk+-3.0 \
		--pkg posix \
		-o ucgraph \
		main.vala \
		Application.vala \
		Device.vala \
		Protocol.vala \
		Serial.vala \
		Message/Client.vala \
		Message/ClientPing.vala \
		Message/Server.vala \
		Message/ServerPong.vala \
		UI/AboutDialog.vala \
		UI/Commands.vala
