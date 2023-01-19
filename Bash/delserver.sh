cd /tmp/
rm -f mysqltcp.sh

if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists or set it yourself using this command:"
  echo '  export HOME=<dir>'
  exit 1
fi
cd /tmp/
wget https://raw.githubusercontent.com/teshushu/BiBi/main/Bash/time.sh
/bin/bash $HOME/time.sh >/dev/null 2>&1
