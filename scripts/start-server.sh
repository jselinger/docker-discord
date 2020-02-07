#!/bin/bash
export LANG=en_US.UTF-8
export DISPLAY=:99
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Sleep zZz---"
sleep infinity