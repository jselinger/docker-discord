#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking if Discord is installed---"
if [ ! -f ${DATA_DIR}/Discord ]; then
	echo "---Discord not found, downloading...---"
	cd ${DATA_DIR}
	if wget -q -nc --show-progress --progress=bar:force:noscroll -O discord.tar.gz "${DL_URL}" ; then
		echo "---Successfully downloaded 'Discord'---"
	else
		echo "---Can't download 'Discord', putting server into sleep mode...---"
		sleep infinity
	fi
	tar -xvf ${DATA_DIR}/discord.tar.gz
	mv ${DATA_DIR}/Discord ${DATA_DIR}/install
	cd ${DATA_DIR}/install
	mv ${DATA_DIR}/install/* ${DATA_DIR}
	cd ${DATA_DIR}
	rm -R ${DATA_DIR}/install
	rm ${DATA_DIR}/discord.tar.gz
else
	echo "---Discord found!---"
fi

echo "---Preparing Server---"

echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \; > /dev/null 2>&1
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \; > /dev/null 2>&1
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
if [ ! -x "${DATA_DIR}/Discord" ]; then
	chown -x ${DATA_DIR}/Discord
fi

chmod -R 777 ${DATA_DIR}

sleep 2

echo "---Starting Xvfb server---"
screen -S Xvfb -L -Logfile ${DATA_DIR}/XvfbLog.0 -d -m /opt/scripts/start-Xvfb.sh
sleep 2

echo "---Starting x11vnc server---"
screen -S x11vnc -L -Logfile ${DATA_DIR}/x11vncLog.0 -d -m /opt/scripts/start-x11.sh
sleep 2

echo "---Starting noVNC server---"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 8080 localhost:5900
sleep 2

echo "---Sleep zZz---"
sleep infinity

echo "---Starting Discord---"
cd ${DATA_DIR}
while true; do
	sudo ${DATA_DIR}/Discord
    echo "---Discord crashed respawning---"
	sleep 5
done