# minio集群管理

## [环境准备](install-tea.html#id4)

将集群服务器加入tea中管理制定服务 

## 软件下载

```
ansible-playbook -i download.ini playbooks/prepare.yml --tags minio

curl ....tar -o ~/local/bin/minio.tar && tar -zxf minio.tar
```

## 编辑配置

```
# 编辑配置文件，制定服务 minio.yml
minio:
  children:
  # 一个池
    pool1:
      hosts:
        10.10.2.11:
        10.10.2.12:
        10.10.2.13: 
        10.10.2.14:

      vars:
        # 服务二进制文件存放位置
        MINIO_SER_BIN_LOCAL: /usr/local/bin/

        # NODE 节点存储数据路径  
        NODE_DIR: 
          - /mnt/minio1
          - /mnt/minio2
        
  # 集群变量
  vars:
      # 账号信息
      MINIO_ROOT_USER: root
      MINIO_ROOT_PASSWORD: f447b20a7fcbf53a5d5be013ea0b15af 

       # minio 服务端口
      MINIO_SER_PORT: 9000 

      # UI 访问端口
      MINIO_CONL_PORT: 9001

      MINIO_MC_ALIAS: myminio
# 考虑集群扩容
      NODE_HOSTS: 
          - 10.10.2.11 minio1
          - 10.10.2.12 minio2
          - 10.10.2.13 minio3
          - 10.10.2.14 minio4
# Minio 存储池 ,通过添加pool 对集群进行扩容        
      MINIO_VOLUMES: 
       - http://minio{1...4}:9000/mnt/minio{1...2}

# sidekick gateway 负载均衡 
      MINIO_LB_SER_PORT: 9009
      SIDEKICK_BACKEND: http://minio{1...4}:9000
```

## 安装服务

```
# 开始安装服务
$ tea_ctl minio create -i conf/minio.yml
```

## 销毁服务

```
$ tea_ctl minio destory -i conf/minio.yml
```

## 集群扩容

​		两种方式： 水平扩容（加机器），垂直扩容（加硬盘）

​		通过配置MINIO_VOLUMES 建立新minio pool。

```
#垂直扩容 ， 每台机器新加入两张硬盘 ,并挂载到 /mnt/minio3 /mnt/minio4
MINIO_VOLUMES: 
       - http://minio{1...4}:9000/mnt/minio{1...2}
       - http://minio{1...4}:9000/mnt/minio{3...4}
# 水平扩容
MINIO_VOLUMES: 
       - http://minio{1...4}:9000/mnt/minio{1...2}
       - http://minio{5...8}:9000/mnt/minio{1...2}
```

扩容查看

```
$ mc admin decommission status  myminio/
┌─────┬─────────────────────────────────────┬─────────────────────────────────┬────────┐
│ ID  │ Pools                               │ Capacity                        │ Status │
│ 1st │ http://minio{1...4}:9000/mnt/minio1 │ 73 MiB (used) / 120 GiB (total) │ Active │
│ 2nd │ http://minio{1...4}:9000/mnt/minio2 │ 73 MiB (used) / 120 GiB (total) │ Active │
└─────┴─────────────────────────────────────┴─────────────────────────────────┴────────┘
```

垂直扩容不需要对系统进行调优，负载均衡，监控等环节。

## 更多 tags

```
ansible-playbook -i hosts.ini -i conf/minio.yml  playbooks/create_minio.yml --tags install , monitor ,sidekick 
```

## 服务检测

```
 mc admin info myminio 
```

## 压力测试

```
# need register
mc support perf object minio --duration 20s --size 128MiB

# S3 benchmarking tool 
./warp mixed --host=minio{1...3}:9000 --access-key=root --secret-key=f447b20a7fcbf53a5d5be013ea0b15af --concurrent=30 --obj.size=500k --get-distrib=5 --stat-distrib=0 --put-distrib=1 --delete-distrib=0  --autoterm

https://zhuanlan.zhihu.com/p/600295425
```

## 数据迁移

- 使用mc ， minio服务之间进行迁移

```
mc mirror -w $srcCluster/Bucket $destCluster
```

- 使用rclone ， S3 服务之间进行迁移

```
rclone 配置
[minio]
type = s3
provider = Minio
env_auth = false
access_key_id = admin
secret_access_key = 12345678
region =
endpoint = http://10.10.2.11:9000
基本命令操作
# 列出所有bucket
$rclone lsd minio:/
# 创建bucket
$rclone mkdir minio:/bucket
# 上传本地文件
$rclone sync /home/files minio:bucket
# 同步两个minio数据
$rclone sync minio-1:bucket-1 minio-2:bucket-2
```

## 集群升级

下载新版本的二进制文件后，执行

```
tea_ctl minio upgrade -i conf/minio.yml
```

