## 将原主从模式升级为repmgrd自动故障转移，前期准备

https://repmgr.org/docs/5.2/quickstart-postgresql-configuration.html

一 每台机器配置 并重启服务
shared_preload_libraries='repmgr';

二 主数据库设置
set password_encryption = 'scram-sha-256';
create user repmgr replication login superuser encrypted password 'xxx';
alter user repmgr set search_path to repmgr,"$user",public;
create database repmgr owner  repmgr;

三 每台机器配置  
sudo su - postgres
vi .pgpass
#hostname:port:database:username:password
#*:5432:repmgr:repmgr:123456 
ip:port:repmgr:repmgr:repmgr
chmod 0600  .pgpass

四 配置pg_hba.conf 需要填写对应行上
host    repmgr          repmgr             0.0.0.0/0            scram-sha-256
host    replication     repmgr             0.0.0.0/0            scram-sha-256

五 配置recovery.conf
recovery.conf 中 的application_name 与node_name 保持一致

## 集群维护

#### 集群状态查看
repmgr_ctl cluster show

#### 手动切换
试运行
repmgr_ctl standby switchover --dry-run

repmgr_ctl standby switchover

repmgr_ctl standby switchover --siblings-follow 

#### 重新加入集群 

数据库或节点意外挂掉后，数据库关闭状态时执行。重新将数据库加入集群中。
试运行
repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v --dry-run

repmgr_ctl node rejoin  -d 'host=10.10.2.11,10.10.2.12,10.10.12.13 dbname=repmgr user=repmgr' --force-rewind -v 

 多hosts连接
 https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING