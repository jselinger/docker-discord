FROM ich777/novnc-baseimage

LABEL maintainer="admin@minenet.at"

RUN apt-get update && \
	apt-get -y install --no-install-recommends libnss3 libgtk-3-0 libasound2 && \
	rm -rf /var/lib/apt/lists/* && \
	sed -i '/    document.title =/c\    document.title = "Discord - noVNC";' /usr/share/novnc/app/ui.js

ENV DATA_DIR=/discord
ENV DL_URL="https://discordapp.com/api/download?platform=linux&format=tar.gz"
ENV CUSTOM_RES_W=1024
ENV CUSTOM_RES_H=768
ENV UMASK=000
ENV UID=99
ENV GID=100

RUN mkdir $DATA_DIR	&& \
	useradd -d $DATA_DIR -s /bin/bash --uid $UID --gid $GID discord && \
	chown -R discord $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 770 /opt/scripts/ && \
	chown -R discord /opt/scripts/

USER discord

#Server Start
ENTRYPOINT ["/opt/scripts/start-server.sh"]