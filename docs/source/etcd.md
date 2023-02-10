# etcd集群管理

## 硬件推荐

https://etcd.io/docs/v3.5/op-guide/hardware/

## [环境准备](install-tea.html#id4)

将集群服务器加入tea中管理

## 编辑配置

```
$ vim conf/etcd.conf
# etcd version 3.3
[etcd]
10.10.2.11
10.10.2.12
10.10.2.13

[etcd:vars]
# 自签名证书过期时间, 10年
CERT_EXPIRY=87600h
# 证书在中控机存放位置
CERT_LOCAL_DIR=/etc/ssl/etcd/

# 在ectd服务器中 证书存放位置
ECTD_CERT_DIR=/etc/ssl/certs
# etcd 数据存放位置
ETCD_DATA_DIR=/var/lib/etcd
# etcd wal日志存放位置
ETCD_WAL_DIR=/var/lib/etcd/wal
# 端口号, 后期不可修改， 请注意
ETCD_PEER_PORT = 2380
ETCD_CLIENT_PORT = 2379
```

## 创建集群

```
 ansible-playbook -i hosts.ini -i conf/etcd.conf playbooks/create_etcd.yml
```

## 添加节点 

​	每次只能新加入一个节点

修改etcd集群配置文件

 ```
 $ vim conf/etcd.conf
 # etcd version 3.3
 [etcd]
 10.10.2.11
 10.10.2.12
 10.10.2.13
 10.10.2.14 # 加入新节点
 ```

[将新节点加入管理](/install-tea.html#id5)

执行加入etcd节点命令。 

```
#加入etcd新节点
ansible-playbook -i hosts.ini -i conf/etcd.conf playbooks/add_etcd.yml  -l 10.10.2.14
ansible-playbook -i hosts.ini -i conf/etcd.conf playbooks/reload_etcd.yml
```

备注:  reload_etcd 的主要作用是因为新加入节点后证书需要重新签署，并重新颁发到每个节点。

需要重启每个节点上的etcd服务。

## 删除节点

执行删除etcd节点命令

```
#加入etcd新节点, 注意一定要加 -l 参数.
ansible-playbook -i conf/etcd.conf playbooks/delete_etcd.yml  -l 10.10.2.14
ansible-playbook -i hosts.ini -i conf/etcd.conf playbooks/reload_etcd.yml
```
``` important:: 删除节点为危险动作 
```

**手动删除**  如果节点为宕机状态，请在手动在集群中执行删除动作

```
# 登录到集群的中任一节点中
# 查看现在集群接待单，找出要删除需要剔除的节点ID
$ etcdctl member list
e875c7a56a96ba: name=etcd-10.10.2.12 peerURLs=https://10.10.2.12:2380 clientURLs=https://10.10.2.12:2379 isLeader=false
57a1101668dd9764: name=etcd-10.10.2.13 peerURLs=https://10.10.2.13:2380 clientURLs=https://10.10.2.13:2379 isLeader=false
5924eb0f7f665351: name=etcd-10.10.2.14 peerURLs=https://10.10.2.14:2380 clientURLs=https://10.10.2.14:2379 isLeader=true
7cebb079e53fc9e7: name=etcd-10.10.2.11 peerURLs=https://10.10.2.11:2380 clientURLs=https://10.10.2.11:2379 isLeader=false

# 删除 10.10.2.14 节点。对应的member id 为: 5924eb0f7f665351
$ etcdctl remove 5924eb0f7f665351
```

修改配置etcd集群配置文件

```
$ vim conf/etcd.conf
# etcd version 3.3
[etcd]
10.10.2.11
10.10.2.12
10.10.2.13
#10.10.2.14 #  将改行删除或注释掉
```

## 数据备份

修改配置 

```
$ vim conf/etcd.conf
# 数据备份 , 在etcd集群leader 节点上
ETCD_TMP_BACKUP_DIR = /tmp/backup/etcd/

# 在中控机上数据存储位置,改目录具有执行用户写权限
LOCAL_ETCD_BACKUP_DIR = /tmp/etcd
```

备份etcd集群数据, 实际备份操作只在leader节点上执行。

```
ansible-playbook -i conf/etcd.conf playbooks/backup_etcd.yml
```

执行完毕后，ectd的备份文件将存储在中控机的`LOCAL_ETCD_BACKUP_DIR`目录中

## 数据恢复

数据准备: 将备份文件放在中控集群的`LOCAL_ETCD_BACKUP_DIR`目录中，并命名为`etcd_snapshot.db`  

数据文件可以是前面数据备份产生的备份文件，也可以是其他集群备的备份文件。

恢复snapshot.db 数据到etd集群

```
ansible-playbook -i conf/etcd.conf playbooks/restore_etcd.yml
```

可通过数据备份、数据恢复进行集群数据迁移

## 数据迁移

将原有etcd集群中的数据平滑迁移到新集群中

```
ETCDCTL_API=3 etcdctl make-mirror [options] <destination> [flags] 
```

```
#例如
etcdctl make-mirror --no-dest-prefix=true  新集群:2379  --endpoints=127.0.0.1:2379 --insecure-skip-tls-verify=true
```

## migrate v2 to v3

将 etcd v2 数据 复制到 v3 中,包括 ttl数据

```
ansible-playbook -i conf/etcd.conf playbooks/migrate_etcd_v2_2_v3.yml
```

执行过程中会需要重启etcd服务 

## 集群升级

​	下载新版etcd binary文件到中控机, TODO

```
ansible-playbook -i conf/etcd.conf playbooks/upgrade_etcd.yml
```

## TODO

- 用户管理https://etcd.io/docs/v3.5/op-guide/authentication/rbac/

## 验证

```
# 验证查看证书
cfssl-certinfo -cert=ca.pem
cfssl-certinfo -cert=etcd.pem

# 查看集群健康状况
$ etcdctl --ca-file=/etc/ssl/certs/ca.pem cluster-health
member 5d36a1683ec7182 is healthy: got healthy result from https://10.10.2.13:2389
member 8810f5b7934fb3c5 is healthy: got healthy result from https://10.10.2.11:2389
member a3a6e6e20c472a5a is healthy: got healthy result from https://10.10.2.12:2389
cluster is healthy

# 查看节点信息
$ etcdctl --ca-file=/etc/ssl/certs/ca.pem member list
5d36a1683ec7182: name=etcd-10.10.2.13 peerURLs=https://10.10.2.13:2381 clientURLs=https://10.10.2.13:2389 isLeader=false
8810f5b7934fb3c5: name=etcd-10.10.2.11 peerURLs=https://10.10.2.11:2381 clientURLs=https://10.10.2.11:2389 isLeader=true
a3a6e6e20c472a5a: name=etcd-10.10.2.12 peerURLs=https://10.10.2.12:2381 clientURLs=https://10.10.2.12:2389 isLeader=false
```

