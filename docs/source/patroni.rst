.. _dynamic_configuration:

patroni 管理
==============

存在数据
~~~~~~~~~

将现有流复制集群，转为由patroni管理。如果新环境，忽略这一节。 

前期准备
--------

数据库用户

- superuser
- replication
- pg_rewind

.. code-block:: ini

  --- 创建超级用户  
  CREATE USER $PATRONI_SUPERUSER_USERNAME WITH SUPERUSER ENCRYPTED PASSWORD '$PATRONI_SUPERUSER_PASSWORD';
  --- 创建复制用户 
  CREATE USER $PATRONI_REPLICATION_USERNAME WITH REPLICATION ENCRYPTED PASSWORD '$PATRONI_REPLICATION_PASSWORD';
  
  ---- PG_VERSION > 10 , pg version 10 是使用 supperuser 来操作 pg_rewind
  CREATE USER $REWIND_USERNAME ENCRYPTED PASSWORD '$REWIND_PASSWORD';
  GRANT EXECUTE ON function pg_catalog.pg_ls_dir(text, boolean, boolean) TO $REWIND_USERNAME;
  GRANT EXECUTE ON function pg_catalog.pg_stat_file(text, boolean) TO $REWIND_USERNAME;
  GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text) TO $REWIND_USERNAME;
  GRANT EXECUTE ON function pg_catalog.pg_read_binary_file(text, bigint, bigint, boolean) TO $REWIND_USERNAME;

修改 pg_hba.conf 确认以上用户可以远端正常访问。根据原有情况配置 md5 或 scram-sha-256

.. code-block:: ini

  ## patroni 使用超级用户连接数据库
  local   postgres        $PATRONI_SUPERUSER_USERNAME             scram-sha-256
  ## 其他用户 & 应用用户 
  host    all             all             0.0.0.0/0               scram-sha-256
  ## replication 用户
  host    replication     all             0.0.0.0/0               scram-sha-256

关闭数据库开机自启

.. code-block:: ini

  systemctl disable postgreql

试运行

.. code-block:: ini
  playbooks/create_pgha_patroni.yml -e 'server_name=patroni_cluster_a1' -C 

服务配置
~~~~~~~~~~

.. code-block:: ini
  
  [patroni_cluster_a1]
  ## 定义一组postgres集群
  10.10.2.11 application_name=node31 node_id=1 
  10.10.2.12 application_name=node32 node_id=2 
  10.10.2.13 application_name=node33 node_id=3 is_leader=true
  #10.10.2.14 application_name=node32 node_id=4 clone_from='node31'
  [patroni_cluster_a1:vars]
  PG_CLUSTER_NAME = pg_cluster001

  ETCD_HOSTS = '10.10.2.11:2379,10.10.2.12:2379,10.10.2.13:2379'
  ETCD_NAME ="etcd001"
  #ETCD_USERNAME='etcd_user'
  #ETCD_PASSWORD='etcd_password'
  #post requst safe
  REST_API_USERNAME='Myuser'
  REST_API_PASSWORD='Mypassword'

  ##failover 
  TTL > = loop_wait + retry_timeout * 2

  PG_VERSION=10
  PG_BIN=/usr/pgsql-10/bin/
  PG_DATA=/var/lib/pgsql/10/data
  PG_CONFIG=/var/lib/pgsql/10/data
  ##
  # 确保以下用户及密码与上一节中的用户相对应
  #
  #超级用户 default postgres  
  # SUP_USER=postgres 
  SUP_PASSWORD='superpassword'

  #流复制用户
  REP_USER='rep_user'
  REP_PASSWORD='rep_password'

  #PG_VERSION 11 及之后有效
  #REWIND_USER=
  #REWIND_PASSWORD=


DCS 设置
~~~~~~~~

  patroni 依赖 dcs， 这里选用etcd作为dcs。

  如现有环境中没有etcd集群需创建。多套patroni可公用一个etcd集群。
  注意多套patroni集群公用etcd时，使用不同的 `PG_CLUSTER_NAME` 进去区分。

运行命令
~~~~~~~~

.. code-block:: ini

  # 创建集群
  playbooks/create_pgha_patroni.yml -e 'server_name=patroni_cluster_a1'
  # 增加新节点
  playbooks/create_pgha_patroni.yml -e 'server_name=patroni_cluster_a1' -l 10.10.2.14

`server_name` 为 hosts.ini 中的定义的服务名称， 在hosts.ini 中可定义多个patroni集群

集群管理
~~~~~~~~~

.. code-block:: ini

  # 查看集群
  patronictl list 

  # 手动swithover
  patronictl switchover

  # 编辑配置文件
  patronictl edit-config
  patronictl show-config

  # 暂停恢复 failover
  patronictl pause
  patronictl resume


tags 配置说明
~~~~~~~~~~~~~

  # 是否可以被选为主
  nofailover: false
  # GET /replica 是否返回200. 可读。 
  # 用法：新加入节点为true。不接入业务流量，当缓存完毕后（pg_rewarm）在接入业务。
  # 节点需要维护时。
  noloadbalance: false
  # 级联复制
  clonefrom: {{clone_form}} 
  nosync: false


管理集群 `更多参考 <https://doc.zhangeamon.top/postgres/patroni02/>`_

failover 
~~~~~~~~~~~

决定 failover 的时间参数  

- ttl 

  the TTL to acquire the leader lock (in seconds). Think of it as the length of time before initiation of the automatic failover process. Default value: 30

- loop_wait

  the number of seconds the loop will sleep. Default value: 10

- retry_timeout

  timeout for DCS and PostgreSQL operation retries (in seconds). DCS or network issues shorter than this will not cause Patroni to demote the leader. Default value: 10

TTL > = loop_wait + retry_timeout * 2

这个机制是这样的，patroni进程每隔10秒(loop_wait)都会更新Leader key还有TTL，如果Leader节点异常导致patroni进程无法及时更新Leader key，则会重新进行2次尝试（retry_timeout）。如果尝试了仍然无效。这个时候时间超过了TTL（生存时间）。领导者密钥就会过期，然后触发新的选举。

对外提供服务
~~~~~~~~~~~~

应用连接patroni集群、主要是使用patroni restapi 观测pg服务的状态。

.. code-block:: ini

  # return code 200 or not
  
  ##主库
  GET /primary
  GET /read-write
  
  ##从库
  GET /replica
  GET /replica?lag=1024KB
  
  ##所有可读库 包括主库
  GET /read-only 


测试用例
~~~~~~~~~~~~

计划内维护 switchover
---------------------- 
- 主从切换
- 下线一个从库
- 上线一个从库
- 卸载从库负载
- 恢复从库负载
- 暂停故障切换
- 恢复故障切换

服务不可用时间: primary 新主数据库promote时间 1秒以内。 replica 数据库重启时间，与业务访问并发相关。

故障切换 failover
---------------------
- ETCD 故障 

  关闭etcd集群： 服务正常。此时如果有任意一个节点服务故障。主节点将降级为只读。
  重启etcd集群: 集群恢复正常

  删除etcd数据： 在下一个心跳后重新生成。

- reboot 主库
  
  发生主从切换，重启后原主库降级为新主库的从库。

- reboot 从库

  从节点关机时间段对外不提供服务，重启后自动加入集群

- restart 主库patroni

  发生主从切换

- restart 从库Patroni

  集群结构不变

- stop 主库Patroni

  发生主从切换，集群自动删除节点

- stop 从库patroni

  集群结构不变，自动删除节点

- kill -9 主库 postgres  进程

  postgres进程被自动拉起， 集群结构保持不变

- kill -9 从库

  postgres进程被自动拉起

- kill -9 主库patroni

  patroni 自动被从新拉起。与restart 类似

- kill -9 从库patroni

  patroni 自动被从新拉起。 与restart 类似

- 拔掉主库网卡

  时间大于一个心跳周期，主库降级为只读。选举新主库

- 拔掉从库网卡

  节点在集群中被删除

- 插回主库网卡

  以从库的身份自动加入集群。如果离线时间过长，注意新主库wal是否仍然保留

- 插回从库网卡
 
  自动加入集群。如果离线时间过长，注意主库wal是否仍然保留。

发生自动故障切换故障判断时间: 小于等于 ttl (30s) 

注意事项
~~~~~~~~

当存在如下网络结构时。 即存在多个网络分区，并且ETCD节点和PG节点在同一个网络分区中。

.. code-block:: ini

  ----net1---------------net2-------------net3----------
  |   ETCD-1        |    ETCD-2         |    ETCD-3    |
  |   PG-1          |    PG-2           |    PG-3      |
  ------------------------------------------------------

如以下场景：

- 多IDC 
- etcd与pg 服务部署在同一个节点

当主节点网络断开一段时间，集群将会选举新的主节点。原主节点降级为只读模式。

在网络重新恢复后，原主有更新leader风险。请根据具体情况修改配置策略。




