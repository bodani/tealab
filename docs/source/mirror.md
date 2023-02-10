# 搭建yum源

## 作用

- 统一软件来源及版本管理

  

``` important:: 私有源服务为非必须，建议安装服务
```

## 系统要求

- 网络，可以访问公网完成软件包的下载，目标节点可以直接或间接(通过网关)访问

- 默认使用80端口
- 适当的磁盘空间 用于存储软件包

## 配置介绍

```
$ vim hosts.ini
############## repo ####################
repo_address = mirror.zhangeamon.top
#repo_ip=192.168.6.15
#repo_port=80
```



```
$ vim tealab/roles/repo/defaults/main.yml
# 私有源存储位置设置
repo_path: /data/yum.repo
# 通过url 下载rpm
repo_url_packages:
# 定义您私有源的软件库
repo_packages:
```

在这里添加三方源，例如将如下prometheus.repo文件放在 tealab/roles/repo/files目录下

```
$ cat  tealab/roles/repo/files/prometheus.repo
[prometheus]
baseurl = https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch 
gpgcheck = 0
name = Prometheus and exporters 
```

## 创建私源

 执行以下命令，开始创建私有源服务。由于下载大量软件首次执行需要一些时间

```
sudo ansible-playbook create_repo.yml -i hosts.ini 
```

## 更新源

```
$ vim  tealab/roles/repo/defaults/main.yml
repo_packages:
在此处添加需要的软件
```

然后再次执行

```
sudo ansible-playbook create_repo.yml -i hosts.ini
```

## 手动更新

登录到私有源服务器, 下载软件包

```
yum install --downloadonly --downloaddir={{数据存储位置}}/repo/base/Packages/ new_need_add
```

下载依赖软件包

```
$ cd {{数据存储位置}}/repo/base/Packages/
repotrack new_need_add_***.rpm
```

更新repo xml

```
createrepo  {{数据存储位置}}/repo/base/Packages/
```



