
# repmgr管理

## 配置信息

```
[postgresql]
## 定义一组postgres集群
10.10.2.11 application_name=node11 node_id=1
10.10.2.12 replicaof='10.10.2.11' application_name=node12 node_id=2
10.10.2.13 replicaof='10.10.2.11' application_name=node13 node_id=3
# 10.10.2.14 replicaof='10.10.2.11' application_name=node14 node_id=4

[postgresql:vars]
pg_cluster_name = batman001 
PG_VERSION=10
PG_DATA=/var/lib/pgsql/10/data
#default 复制用户设置 如 repmgr
rep_user=repmgr
rep_password=pwd123456
# 是否使用复制槽
use_slot=true
install_pgbouncer=true
# 主节点保持最小从库的数量。从库的数量小于该值，主库将关闭。
# 主要是为了预防脑裂问题。如主节点断网后，集群选举新主节点。原主节点的从节点数降为零后关闭。
master_min_child_nodes=1
shared_preload_libraries='repmgr';
# 若原postgresql 集群环境已经存在，现在想通过repmgr进行failover管理。需手动准备必要环境配置
prepare_pg_manu=false
# 其他优化参数 
#https://pgtune.leopard.in.ua/
```
## 创建数据库

```
playbooks/create_pgha_repmgr.yml -i conf/pgha_repmgr.conf
```

失效节点重新加入集群
```
repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v --dry-run
repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v
```
## 将原主从模式升级为由repmgrd管理

### 配置项修改
```
prepare_pg_manu=true
```
### 数据库必要项修改

https://repmgr.org/docs/5.2/quickstart-postgresql-configuration.html

一 每台机器配置
```
shared_preload_libraries='repmgr';
```
二 主数据库设置
```
set password_encryption = 'scram-sha-256';
create user repmgr replication login superuser encrypted password 'xxx';
alter user repmgr set search_path to repmgr,"$user",public;
create database repmgr owner  repmgr;
```
三 每台机器配置  
```
sudo su - postgres
vi .pgpass
#hostname:port:database:username:password
#*:5432:repmgr:repmgr:123456 
#*:5432:reolication:repmgr:123456 
ip:port:repmgr:repmgr:repmgr
chmod 0600  .pgpass
```
四 配置pg_hba.conf 需要填写对应行上
```
host    repmgr          repmgr             0.0.0.0/0            scram-sha-256
host    replication     repmgr             0.0.0.0/0            scram-sha-256
```
五 配置recovery.conf
```
recovery.conf 中 的application_name 与node_name 保持一致
```

### 安装repmgr
```
playbooks/create_pgha_repmgr.yml -i conf/pgha_repmgr.conf --tags repmgr
```

## 集群维护
```
su - postgres
```
#### 集群状态查看
```
repmgr_ctl cluster show
```
#### 手动切换
```
repmgr_ctl standby switchover
```
#### 重新加入集群 

数据库或节点意外挂掉后，数据库关闭状态时执行。重新将数据库加入集群中。
```
repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v --dry-run
repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v 
```

## 测试CASE