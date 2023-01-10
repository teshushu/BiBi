#! /bin/bash
ps -ef | grep "phpup" | grep -v grep
if [ $? -ne 0 ]
then
cd /tmp/ && nohup ./phpup
else
echo "running"
fi