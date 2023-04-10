.. _dynamic_configuration:

patroni 管理
==============

存在数据
~~~~~~~~~

将现有流复制集群，转为由patroni管理。如果新环境，忽略这一节。 

前期准备
------

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

修改 pg_hba.conf 确认以上用户可以远端正常访问。


服务配置
~~~~~~~

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
~~~~~~~~~~

应用连接patroni集群、主要是使用patroni restapi 观测pg服务的状态。

.. code-block:: ini
  # return code 200 or not
  GET /primary
  GET /replica
