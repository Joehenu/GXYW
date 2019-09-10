pod_yaml=$cur_dir/items/yjd-java/conf/java-deployment-a.yaml
pod_config_yaml=$cur_dir/items/yjd-java/conf/java-config-a.yaml
pod="p-account-service
p-api
p-borrow-service
p-core-admin
p-depository-service
p-dts-service
p-invest-service
p-msg-service
p-notification-service"


# 记录当前POD名
pod_na(){
    local name=$1
    echo -ne \\r> $name
    for po in $pod
    do
        pod_name=`kubectl get po | grep $po |awk -F " " '{print $1}'`
        echo -ne "$pod_name\n" >> $name
    done
}

# 判断POD重新部署
pod_judge(){
    diff pod-name-old pod-name-new > /dev/null
    if [ $? == 0 ];then
        echo "应用名变化，已经重新部署"
    else
        echo "应用名未变化，部署失败"
    fi
	rm -rf pod-name-old pod-name-new
}

# 应用发布
java_core_apply(){
    tag_old=`cat $cur_dir/items/yjd-java/conf/java-tag.conf |awk  '{print $1}'`
    sed -i "s:$tag_old:$TagId:g" $cur_dir/items/yjd-java/conf/java-deployment-a.yaml
    echo "$TagId" > $cur_dir/items/yjd-java/conf/java-tag.conf
    echo "$TagId|`date +%m-%d-%H:%M`" >> $cur_dir/items/yjd-java/conf/java-version
    pod_na  pod-name-old
    kubectl -f apply $pod_yaml || { echo "应用发布失败，退出程序"; exit 1; }
    sleep 60
    pod_na  pod-name-new
    pod_judge 
    kubectl get pod 
}
java_config_apply(){
    tag_old_config=`cat $cur_dir/items/yjd-java/conf/java-tag-config.conf |awk  '{print $1}'`
    sed -i "s:$tag_old_config:$TagId:g" $cur_dir/items/yjd-java/conf/java-config-a.yaml
    echo "$TagId" > $cur_dir/items/yjd-java/conf/java-tag-config.conf
    kubectl -f apply $pod_config_yaml || { echo "应用发布失败，退出程序"; exit 1; }
    sleep 100
    kubectl get pod |grep p-config
}
