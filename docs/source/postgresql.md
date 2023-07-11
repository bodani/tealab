# Postgresql 主从

## 配置信息

```
[postgresql]
## 定义一组postgres集群
10.10.2.11 application_name=node11
10.10.2.12 replicaof='10.10.2.11' application_name=node12
10.10.2.13 replicaof='10.10.2.11' application_name=node13
# 10.10.2.14 replicaof='10.10.2.11' application_name=node14

[postgresql:vars]
pg_cluster_name = batman001 
PG_VERSION=10
PG_DATA=/var/lib/pgsql/10/data
#default 流复制用户设置
rep_user=repuser
rep_password=123456
# 是否使用复制槽
use_slot=true
#是否需要安装pgbouncer
install_pgbouncer=true
# 其他优化参数 
#https://pgtune.leopard.in.ua/
```
## 创建数据库

```
playbooks/create_postgresql.yml -i conf/postgresql.conf
```