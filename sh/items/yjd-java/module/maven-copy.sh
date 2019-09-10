# java编译及oss存储 
java_code=/opt/p-parent
java_code_bak=/opt/p-parent-bak
java_conf=$cur_dir/items/yjd-java/conf/product.properties
oss_jar=/opt/code/jar
jar_name="p-cloud/p-cloud-discovery/target/p-cloud-discovery-0.0.1-SNAPSHOT.jar
        p-dts/service/p-dts-service/target/p-dts-service-0.0.1-SNAPSHOT.jar
        p-msg/broker/p-msg-service/target/p-msg-service-0.0.1-SNAPSHOT.jar
        p-account/p-account-service/target/p-account-service-0.0.1-SNAPSHOT.jar
        p-borrow/p-borrow-service/target/p-borrow-service-0.0.1-SNAPSHOT.jar 
        p-invest/p-invest-service/target/p-invest-service-0.0.1-SNAPSHOT.jar
        p-notification/p-notification-service/target/p-notification-service-0.0.1-SNAPSHOT.jar
        p-depository/p-depository-service/target/p-depository-service-0.0.1-SNAPSHOT.jar
        p-core/p-core-admin/target/p-core-admin-0.0.1-SNAPSHOT.jar
        p-job/target/p-job-0.0.1-SNAPSHOT.jar
	p-other/p-api/target/p-api-0.0.1-SNAPSHOT.jar
        p-config/p-config-service/target/p-config-service-0.0.1-SNAPSHOT.jar"
pull_code(){
        cd $java_code
        git fetch --all
        read -p "请输入Tag编号:" TagId
	echo 
        git checkout -f $TagId || { echo "代码更新失败，退出程序"; exit 1; }
        echo
        echo
        git status
	
}
maven_code(){
        echo "=================开始拉取p-parent代码======================"
        if [ -d $java_code ]; then
                #git clone git@gitee.com:yijiedai-java/p-parent.git $java_code
                pull_code 
        else
                git clone git@gitee.com:yijiedai-java/p-parent.git $java_code
                pull_code 
        fi
        rm -rf $java_code_bak
        cp -r $java_code  $java_code_bak
        sed -i "s:/code/IdeaProjects/p-parent:$java_code_bak:" $java_code_bak/pom.xml
       # sed -i "s:/var/www/repository:/opt/repository:" /opt/apache-maven-3.6.1/conf/settings.xml
        rm -rf  $java_code_bak/config/product.properties
        cp -rf $java_conf  $java_code_bak/config/product.properties
        echo "=================开始进行编译====================="
        cd $java_code_bak
        mvn clean install -Dmaven.test.skip=true -P product  || { echo "编译失败，退出程序"; exit 1; } 
}
jar_copy(){
	echo "=================开始复制编译后jar包至OSS======================"
        cd $java_code_bak
	if [ -d $oss_jar/p-java-common ]; then 
            rm -rf $oss_jar/p-java-common/*
	else
	    mkdir -p $oss_jar/p-java-common
	fi
        for i in $jar_name
        do
                cp ./$jar_name  $oss_jar/p-java-common/
        done
        cd $oss_jar/p-java-common/
        pwd
        ls -l $oss_jar/p-java-common/
        echo
        echo
	echo "================开始备份jar包======================"
        if [ -d $oss_jar/$TagId ]; then
            rm -rf $oss_jar/$TagId/*
	    cp -r $oss_jar/p-java-common/* $oss_jar/$TagId/
        else
	    mkdir -p $oss_jar/$TagId/
            cp -r $oss_jar/p-java-common/* $oss_jar/$TagId/
        fi
        cd $oss_jar/$TagId/
        pwd
        ls -l $oss_jar/$TagId/
}
