# Redis 集群

## 集群要求

生产环境至少六台实体机，三台主节点，三台从节点。

## 配置

```
## redis cluster 生产系统中至少需要六台机器
[redis_cluster]
## 定义一组redis集群
10.10.2.11 
10.10.2.12 
10.10.2.13 
10.10.2.14 

[all:vars]
############################### redis 配置相关信息 #########################################
redis_port = 6379
dir = /var/lib/redis
redis_password = f447b20a7fcbf53a5d5be013ea0b15af
bind = 0.0.0.0

# 主从复制配置相关
# min-replicas-to-write 3
# min-replicas-max-lag 10

#限制redis服务使用的最大内存，超过阈值redis继续提供服务但是会报错。
maxmemory = 10GB
eviction = allkeys-lfu 

# 数据保存策略 生产系统 RDB AOF 混合模式。 默认 开启 aof-use-rdb-preamble yes
# RDB 保存时机
save = '3600 1 300 100 60 10000'
# aof 配置
appendonly = yes
appendfilename = "appendonly.aof"
appenddirname = "appendonlydir"
 #everysec always no 
appendfsync = everysec
# 重写 瘦身aof
no_appendfsync_on_rewrite = no
auto_aof_rewrite_percentage = 100
auto_aof_rewrite_min_size = 64mb
aof_load_truncated = yes
aof_use_rdb_preamble = yes
aof_timestamp_enabled = no
aof_rewrite_incremental_fsync = yes

################################## redis_sentinel 配置相关信息 ###############################
# 连接信息
sentinel_port = 26379
# 连接sentinel 密码。包括sentinel 彼此连接密码
sentinel_password = f447b20a7fcbf53a5d5be013ea0b15af
# the quorum is only used to detect the failure
quorum = 2
down_after_milliseconds = 1000*60
failover_timeout = 1000*180
parallel_syncs = 1

sentinel_dir = /var/lib/redis/

[redis_cluster:vars]
cluster_enabled = yes
# milliseconds
cluster_node_timeout = 60*1000*5
cluster_migration_barrier = 1
cluster_require_full_coverage = yes 
cluster_allow_reads_when_down = yes
redis_cluster_replicas = 1
```

## 流程说明

 实体机： 对实体机进行对应的参数优化及必要软件服务安装

 每个实体机上安装单机redis

配置redis

创建redis集群

```
redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 \
127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 \
--cluster-replicas 1
```

##  一步到位

```
ansible-playbook -i hosts.ini -i conf/redis.conf playbooks/create_redis_cluster.yml 
```



## 