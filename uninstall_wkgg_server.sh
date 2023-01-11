#!/bin/bash

VERSION=1.0

# printing greetings

echo "Wkgg mining uninstall script v$VERSION."
echo "(please report issues to admin@admin.com email with full output of this script with extra \"-x\" \"bash\" option)"
echo

if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

if [ ! -d $HOME ]; then
  echo "ERROR: Please make sure HOME directory $HOME exists"
  exit 1
fi

echo "[*] Removing mssqlup server"
if sudo -n true 2>/dev/null; then
  sudo systemctl stop mssqlup_miner.service
  sudo systemctl disable mssqlup_miner.service
  rm -f /etc/systemd/system/mssqlup_miner.service
  sudo systemctl daemon-reload
  sudo systemctl reset-failed
fi

sed -i '/myssqltcp/d' $HOME/.profile
killall -9 mssqlsys

echo "[*] Removing $HOME/myssqltcp directory"
rm -rf $HOME/myssqltcp

echo "[*] Uninstall complete"

