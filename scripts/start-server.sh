#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99

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
echo "---Checking if config file is present---"
if [ ! -f ${DATA_DIR}/.config/discord/settings.json ]; then
	echo "---Config file not present, creating...---"
	if [ ! -d ${DATA_DIR}/.config/ ]; then
    	mkdir ${DATA_DIR}/.config/
	fi
	if [ ! -d ${DATA_DIR}/.config/discord ]; then
    	mkdir ${DATA_DIR}/.config/discord
	fi
	touch "${DATA_DIR}/.config/discord/settings.json"
	echo '{
  "IS_MAXIMIZED": false,
  "IS_MINIMIZED": false,
  "WINDOW_BOUNDS": {
    "x": 0,
    "y": 0,
    "width": 1024,
    "height": 720
  }
}' >> "${DATA_DIR}/.config/discord/settings.json"
else
	echo "---Config file found!---"
fi
echo "---Resolution check---"
if [ -z "${CUSTOM_RES_W} ]; then
	CUSTOM_RES_W=1000
fi
if [ -z "${CUSTOM_RES_H} ]; then
	CUSTOM_RES_H=768
fi

if [ "${CUSTOM_RES_W}" -le 999 ]; then
	echo "---Width to low must be a minimal of 1000 pixels, correcting to 1000...---"
    CUSTOM_RES_W=1000
fi
if [ "${CUSTOM_RES_H}" -le 767 ]; then
	echo "---Height to low must be a minimal of 768 pixels, correcting to 768...---"
    CUSTOM_RES_H=768
fi
sed -i '/"width": /c\    "width": '${CUSTOM_RES_W}',' "${DATA_DIR}/.config/discord/settings.json"
sed -i '/ "height": /c\    "height": '${CUSTOM_RES_H}'' "${DATA_DIR}/.config/discord/settings.json"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \; > /dev/null 2>&1
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \; > /dev/null 2>&1
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1
if [ ! -x "${DATA_DIR}/Discord" ]; then
	chown -x ${DATA_DIR}/Discord
fi
chmod -R ${DATA_PERM} ${DATA_DIR}
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

echo "---Starting Discord---"
cd ${DATA_DIR}
${DATA_DIR}/Discord