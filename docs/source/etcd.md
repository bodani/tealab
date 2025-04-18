# etcd集群管理

## 硬件推荐

https://etcd.io/docs/v3.5/op-guide/hardware/

## [环境准备](install-tea.html#id4)

将集群服务器加入tea中管理

## 流程介绍

- 配置验证
- 生成证书
- 防火墙端口配置
- 创建用户
- 集群安装包预备
- 配置集群
- 启动集群
- 验证集群

## 软件包准备

下载软件包到 , `group_vars/all.yml` 中设置 
```
local_bin: "~/local_bin/packages"
```
例如
```
sudo mkdir -p ~/local_bin/packages/etcd/
sudo wget https://github.com/etcd-io/etcd/releases/download/v3.5.21/etcd-v3.5.21-linux-amd64.tar.gz
sudo tar -zxf etcd-v3.5.21-linux-amd64.tar.gz -C ~/local_bin/packages/etcd/
sudo mv ~/local_bin/packages/etcd/etcd-v3.5.21-linux-amd64/etcd* ~/local_bin/packages/etcd/
sudo rm -rf ~/local_bin/packages/etcd/etcd-v3.5.21-linux-amd64/
```
最终结果
```
~/local_bin/packages$ tree etcd/
etcd/
├── etcd
├── etcdctl
├── etcdutl
```

## 编辑配置
` vim hosts.ini `

```
# etcd version 3.3 -3.5
[etcd]
10.10.2.11 
10.10.2.12
10.10.2.13
# 10.10.2.14

#监控系统 prometheus grafana 如需要监控配置
[monitor]
10.10.2.14
```

` vim  group_vars/etcd.yml `
```
# 服务名 etcd
ETCD_NAME: etcd001
# 在ectd服务器中 证书存放位置
ECTD_CERT_DIR: /etc/etcd/certs
# etcd 数据存放位置
ETCD_DATA_DIR: /var/lib/etcd
# etcd wal日志存放位置
ETCD_WAL_DIR: /var/lib/etcd/wal
# 端口号, 设定完成后期不可修改， 请注意
ETCD_PEER_PORT: 2380
ETCD_CLIENT_PORT: 2379
# 通用域名
CERT_DNS: etcd01.zhangeamon.top
#是否同时安装监控
NEED_MONITOR: no
########### 数据备份#####################
# 在中控机上数据存储位置,该目录具有执行用户写权限
ETCD_LOCAL_BACKUP_DIR: /tmp/etcd/
```

## 创建集群

```
playbooks/create_etcd.yml -i hosts.ini 
```

## 查看集群

```
etcdctl endpoint status --cluster -w table
+------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
|        ENDPOINT        |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| https://10.10.2.11:2379 | 502f3098caa4c961 |   3.5.7 |  954 kB |     false |      false |        15 |      20350 |              20350 |        |
| https://10.10.2.12:2379 | 85000e0cddb968c6 |   3.5.7 |  954 kB |      true |      false |        15 |      20350 |              20350 |        |
| https://10.10.2.13:2379 | e48b26f32e7578f8 |   3.5.7 |  954 kB |     false |      false |        15 |      20350 |              20350 |        |
+------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

```

## 添加节点 

**每次只能新加入一个节点**

[将新节点加入管理](/install-tea.html#id4)

修改etcd集群配置文件

`  vim hosts.ini `

```
 # etcd version 3.3-3.5
 [etcd]
 10.10.2.11
 10.10.2.12
 10.10.2.13
 10.10.2.14 # 加入新节点
 ```

执行加入etcd节点命令。 

```
#加入etcd新节点
playbooks/add_etcd.yml -i hosts.ini -l 10.10.2.14
```

## 删除节点

``` important:: 删除节点为危险动作 
```

**手动删除**  如果节点为宕机状态，请在手动在集群中执行删除动作

```
# 登录到集群的中任一节点中
# 查看现在集群接待单，找出要删除需要剔除的节点ID
$ etcdctl member list -w table
+------------------+---------+-----------------+-------------------------+-------------------------+------------+
|        ID        | STATUS  |      NAME       |       PEER ADDRS        |      CLIENT ADDRS       | IS LEARNER |
+------------------+---------+-----------------+-------------------------+-------------------------+------------+
|  de875c7a56a96ba | started | etcd-10.10.2.12 | https://10.10.2.12:2380 | https://10.10.2.12:2379 |      false |
| 57a1101668dd9764 | started | etcd-10.10.2.13 | https://10.10.2.13:2380 | https://10.10.2.13:2379 |      false |
| 5f0749d4389084c1 | started | etcd-10.10.2.14 | https://10.10.2.14:2380 | https://10.10.2.14:2379 |      false |
| 7cebb079e53fc9e7 | started | etcd-10.10.2.11 | https://10.10.2.11:2380 | https://10.10.2.11:2379 |      false |
+------------------+---------+-----------------+-------------------------+-------------------------+------------+


# 删除 10.10.2.11 节点。对应的member id 为: 7cebb079e53fc9e7
$ etcdctl member remove 7cebb079e53fc9e7

```
**一个好的习惯。将节点从集群中剔除后将数据存放目录清除，由变量ETCD_DATA_DIR定义**

修改配置etcd集群配置文件

`vim host.ini`

```
# etcd version 3.3-3.5
[etcd]
10.10.2.11
10.10.2.12
10.10.2.13
#10.10.2.14 #  将改行删除或注释掉
```

## ETCD数据管理基础操作

#### 切换 leader

```
etcdctl  move-leader  57a1101668dd9764
```
#### 数据备份

```
etcdctl snapshot save etcd_data_backup.db

etcdctl snapshot status  etcd_data_backup.db -w table
```
可定期备份并存储在S3中

#### 数据恢复

``` important:: 恢复数据前清空原有集群数据 
```

数据准备: 将备份文件放在中控节点，并配置 `LOCAL_ETCD_BACKUP_DATA`  

数据文件可以是前面数据备份产生的备份文件，也可以是其他集群备的备份文件。

恢复备份数据etcd集群 中

```
playbooks/restore_etcd.yml -i hosts.ini
```

可通过数据备份、数据恢复进行集群数据迁移

#### 数据迁移

将原有etcd集群中的数据平滑迁移到新集群中

```
ETCDCTL_API=3 etcdctl make-mirror [options] <destination> [flags] 
```

```
#例如
etcdctl make-mirror --no-dest-prefix=true  新集群:2379  --endpoints=https:://xxxx:2379 --insecure-skip-tls-verify=true
```

#### 压力测试

将 etcd v2 数据 复制到 v3 中,包括 ttl数据

```
etcdctl check perf --load l
```

#### 集群升级

​下载新版etcd binary文件到中控机, TODO

```
playbooks/upgrade_etcd.yml -i conf/etcd.conf 
```

## TODO

- 用户管理https://etcd.io/docs/v3.5/op-guide/authentication/rbac/


