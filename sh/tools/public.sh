# 检测命令是否存在
command_is_exist(){
    local command=$1
    IFS_SAVE="$IFS"
    IFS=":"
    local code
    for path in $PATH;do
        binPath="$path/$command"
        if [[ -f $binPath ]];then
                IFS="$IFS_SAVE"
            return 0
        fi
    done
    IFS="$IFS_SAVE"
    return 1
}

# 判断命令是否正确执行
command_is_succeed(){
    local comman=$1
    if [ $? -ne 0 ]; then
        echo "$$1 执行成功"
    else
        echo "$$1 执行failed，请注意"
    fi
}

# 安装screen
screen_install(){
    local noscreen=false
    PARMS="$@"
    # 如果不在screen中
    if [[ "$TERM" != "screen" ]];then
    # 检测screen命令是否存在
        if command_is_exist screen;then
            #screen -S yaobinjie ./start.sh 
            screen -S online-`date +%Y-%m-%d-%H:%M:%S`  ./start.sh #$PARMS
        else
		yum  -y install 
		apt-get -y install screen
		apk add screen
        fi
    exit
    fi
}
