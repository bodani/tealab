# minio集群管理

## [环境准备](install-tea.html#id4)

将集群服务器加入tea中管理制定服务 

## 编辑配置

```
# 编辑配置文件，制定服务
$ vim minio.conf
# 将minio服务安装到哪些节点
[minio]
10.10.10.1
10.10.10.1
10.10.10.1
10.10.10.1

[minio:vars]
# 数据存储位置
datastore=/data/minio
adminuser=xxxx
adminpassword=xxxx
# 纠删码，允许最大失效磁盘个数。参数范围 [2 - n/2] （n为节点或磁盘个数）
ec=2
# 是否需要监控
use_monitor=true
# 是否进行系统参数调优
use_node_tuning=true
```

## 安装服务

```
# 开始安装服务
$ tea_ctl minio -i minio.conf create
```

## 数据迁移

```
mc mirror -w $srcCluster/Bucket $destCluster
```

```
rclone
```

