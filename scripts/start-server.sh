#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Preparing Server---"
echo "---Checking for old logfiles---"
find $DATA_DIR -name "XvfbLog.*" -exec rm -f {} \; > /dev/null 2>&1
find $DATA_DIR -name "x11vncLog.*" -exec rm -f {} \; > /dev/null 2>&1
echo "---Checking for old lock files---"
find /tmp -name ".X99*" -exec rm -f {} \; > /dev/null 2>&1

chmod -R 777 ${DATA_DIR}

sleep 5

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