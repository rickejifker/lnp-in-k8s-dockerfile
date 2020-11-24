
#!/bin/bash
URL=git@172.16.60.49:root/myapp1.git
Starttime=`date +"%Y-%m-%d_%H-%M-%S"`
Method=$1
Branch=$2
t1=`date +"%Y-%m-%d %H:%M:%S"`

     #代码克隆至jenkins后端
clone_code(){
    cd /root/.jenkins/workspace/mytest && git clone -b $Branch ${URL}&& echo "Clone Finished"
}

 #代码打包压缩并远程推送至k8s-master-1的nginx镜像制作目录
Pack_scp(){
    cd /root/.jenkins/workspace/mytest/ && tar cvzf myapp.tar.gz * && echo Package Finished
    scp myapp.tar.gz root@172.16.60.44:/data/Dockerfile/myapp/ && ssh root@172.16.60.44 'cd /data/Dockerfile/myapp/ && tar xvf myapp.tar.gz && chmod 777 -R ./* && rm -f myapp.tar.gz'
}

build_image(){
    ssh root@172.16.60.44 "cd /data/Dockerfile/myapp/ && chmod +x build.sh && ./build.sh ${Starttime} && echo 'build_image and push_harbor success!'"
}

    #对k8s集群中的nginx的pod应用进行升级
app_update(){

    ssh root@172.16.60.44 "sed -ri 's@image: .*@image: 172.13.28.57/myapp/myapp:${Starttime}@g'  /data/Dockerfile/myapp/myapp.yml"
    ssh root@172.16.60.44 "kubectl set image deployment/myapp-deployment myapp-container=172.13.28.57/myapp/myapp:${Starttime} -n default --record=true"
                t2=`date +"%Y-%m-%d %H:%M:%S"`
    start_T=`date --date="${t1}" +%s`
    end_T=`date --date="${t2}" +%s`
    total_time=$((end_T-start_T))
    echo "deploy success,it has been spent ${total_time} seconds"
}

    #k8s集群中的pod应用进行回滚
app_rollback(){
    ssh root@172.16.60.44 'kubectl rollout undo deployment/myapp-deployment  -n default'
}

    #进行k8s集群自动部署的主函数
main(){
    case $Method in
    deploy)
        clone_code
        Pack_scp
        build_image
        app_update
    ;;
    rollback)
        app_rollback
    ;;
    esac
}

#执行主函数命令
main $1 $2
