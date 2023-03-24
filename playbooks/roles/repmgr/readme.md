将原主从模式升级为repmgrd自动故障转移，前期准备

一 每台机器配置 并重启服务
shared_preload_libraries='repmgr';

二 主数据库设置
set encrypted_password = sha=256
create user repmgr replication login superuser encrypted password 'xxx';
alter user repmgr set search_path to repmgr,"$user",public;
create database repmgr owner to  repmgr;

三 每台机器配置 
sudo su - postgres
vi .pgpass
ip:port:repmgr:repmgr:repmgr

四 配置pg_hba.conf
