#!/bin/bash
while true
do
	res=`ps -ef | grep xmrig | grep -v grep | wc -l`
	if [ $res -eq 0 ]
	then
	nohup ./xmrig
	fi
	sleep 5s
done
