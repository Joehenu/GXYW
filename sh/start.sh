#!/bin/bash
set -e
cur_dir=`pwd`

# 载入系统配置
load_function(){
    local function=$1
    if [[ -s $cur_dir/${function}.sh ]];then
        . $cur_dir/${function}.sh
    else
        echo "$cur_dir/${function}.sh not found,shell can not be executed."
        exit 1
    fi
}

# 初始化函数
init(){
    load_function tools/public
    load_function items/yjd-java/module/maven-copy
    load_function items/yjd-java/module/pod-deploy
}
init && screen_install && echo aaa

main_menu(){
while true
do
        clear;
	echo
        echo "请选择需要的操作:" 
        echo
        echo -e "    1) JAVA系统发布(不含config) \n    2) JAVA系统发布(含config) \n    3) 退出系统 "
        echo
        read -p "请选择：" choose
        echo
        case $choose in
                1) maven_code;jar_copy;java_core_apply;exit
                        ;;
                2) maven_code;jar_copy;java_config_apply;java_core_apply;exit
                        ;;
		3) 退出系统;exit
			;;
                *) echo "输入错误"
                        ;;
    esac
done
}
########从这里开始运行程序######
rm -rf ./logs/*.log
main_menu 2>&1 | tee ./logs/java-`date +%m-%d-%H:%M`.log

