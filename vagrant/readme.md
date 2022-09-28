### 镜像管理
添加镜像
```
vagrant box add centos/7
```

查看镜像
```
vagrant box list
centos/7 (virtualbox, 2004.01)
```

### 配置管理
初始化默认Vagrantfile
```
vagrant init
```

配置Vagrantfile定义虚拟机 , 启动虚拟机
```
vagrant up
```

查看状态
```
vagrant status
Current machine states:

node0                     running (virtualbox)
node1                     running (virtualbox)
node2                     running (virtualbox)
node3                     running (virtualbox)
```

登录虚拟机
```
vagrant ssh node0
ssh root@nodexxx  # root 默认密码 vagrant
```

关闭
```
vagrant halt
```

停止并销毁
```
vagrant destroy 
```

重新加载,重启
```
vagrant reload
```


### 添加磁盘容量

```
1. vim Vagrant
config.disksize.size = '100GB'
2. 安装插件
vagrant plugin install vagrant-disksize
3. 分区
 echo "n





w
" | fdisk /dev/sda

4. 重启生效
     reboot
5. 格式化
 mkfs.xfs -f /dev/sda2

6. 挂载磁盘
mount /dev/sda2 /mnt


```