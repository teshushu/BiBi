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

if [ `/bin/ls -lt /$HOME/myssqlsys.log | head -1 | /bin/awk '{print $5}'` -gt $((18*18*10)) ]
then
    echo > /$HOME/myssqlsys.log
fi
 
ls *.log | xargs -I x -n 1 sh -c "echo > x”
