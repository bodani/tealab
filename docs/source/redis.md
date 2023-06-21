# redis高可用

利用sentinel 实现redis高可用

## 实体机配置建议:

​	开启swap，并设置与内存大小相等

​	为充分利用cpu，可采用单实体机多redis实例方式部署。多redis实例分别使用不同的存储路径及端口号

服务资源列表

为保证sentinel 高可用，至少需要三台独立服务器。

| 软件           | 端口  |
| -------------- | ----- |
| redis          | 6379  |
| sentinel       | 26379 |
| redis_exporter | 9121  |

## 配置服务

`vim hosts.ini`
```
[redis]
## 定义第一组redis主从
10.10.2.11  
10.10.2.12  
10.10.2.13 replica_priority=80
```
`vim  group_vars/redis.yml`
```
############################### redis 配置相关信息 #########################################
redis_port: 6379
dir: /var/lib/redis
redis_password: f447b20a7fcbf53a5d5be013ea0b15af

# 主从复制配置相关
# min-replicas-to-write: 3
# min-replicas-max-lag: 10

#限制redis服务使用的最大内存，超过阈值redis继续提供服务但是会报错。建议单个实例小于10G
maxmemory: 10GB
# 淘汰策略
maxmemory_policy: 'allkeys-lfu' 


# 数据保存策略 生产系统 RDB AOF 混合模式。 默认 开启 aof-use-rdb-preamble yes
# RDB 保存时机
save: '3600 1 300 100 60 10000'
# aof 配置
appendonly: "yes"
appendfilename: "appendonly.aof"
appenddirname: "appendonlydir"
 #everysec always no 
appendfsync: everysec
# 重写 瘦身aof
no_appendfsync_on_rewrite: "no"
auto_aof_rewrite_percentage: 100
auto_aof_rewrite_min_size: 64mb
aof_load_truncated: "yes"
aof_use_rdb_preamble: "yes"
aof_timestamp_enabled: "no"
aof_rewrite_incremental_fsync: "yes"

################################## redis_sentinel 配置相关信息 ###############################
# 连接信息
master_node: 10.10.2.11
sentinel_port: 26379
master_groupname: mymaster001
# the quorum is only used to detect the failure
quorum: 2
replica_priority: 100
down_after_milliseconds: 1000*60
failover_timeout: 1000*180
parallel_syncs: 1

sentinel_dir: /var/lib/redis/
```

## 一步到位

包括redis 主从, sentinel 及监控

```
playbooks/create_redis_sentinel.yml -i hosts.ini
```

## 验证

### 登录redis 查看

```
# 登录主节点redis 服务
$ redis-cli 
127.0.0.1:6379> AUTH f447b20a7fcbf53a5d5be013ea0b15af
OK
127.0.0.1:6379> info replication
# Replication
role:master
connected_slaves:2
slave0:ip=10.10.2.13,port=6379,state=online,offset=1548116,lag=0
slave1:ip=10.10.2.12,port=6379,state=online,offset=1548116,lag=0
```

### 登录sentinel 查看 

```
# 登录sentinel 节点 , 注意查看 flags值
# 查看redis信息
$ redis-cli -p 26379
127.0.0.1:26379> AUTH f447b20a7fcbf53a5d5be013ea0b15af
OK
# 查看master节点
127.0.0.1:26379> sentinel masters
sentinel masters
1)  1) "name"
    2) "mymaster001"
    3) "ip"
    4) "10.10.2.11"
    5) "port"
    6) "6379"
    7) "runid"
    8) "820a82215c08d11bbc0cbabe8061a460cd50c6f6"
    9) "flags"
   10) "master"
# 查看master 对应的slave 节点
127.0.0.1:26379> sentinel slaves mymaster001

# 查看 sentinel 集群信息
127.0.0.1:26379> sentinel sentinels mymaster001
```

## 加redis 节点

可以添加一个从节点到原redis组。也可新定义一组redis。

`vim hosts.ini`
```
[redis]
## 定义第一组redis主从
10.10.2.11 
10.10.2.12 
10.10.2.13 
10.10.2.14 replica_priority=100
```

```
playbooks/create_redis_sentinel.yml -i hosts.ini --tags redis -l 10.10.2.14 
```

## 压测

```
 redis-benchmark --tls  --cacert /etc/redis/certs/ca.crt --cert /etc/redis/certs/redis.crt --key /etc/redis/certs/redis.key  -a f447b20a7fcbf53a5d5be013ea0b15af -h 10.10.2.11 -p 6379 -n 100000 -c 20

```

## 数据迁移

```
./redis-shake.linux -type=sync -conf=redis-shake.conf
```

参考https://help.aliyun.com/document_detail/111066.html

## 不停机在线升级

不同版本可以共存

 https://redis.io/docs/manual/admin/#upgrading-or-restarting-a-redis-instance-without-downtime

 ## 最佳实践参考
 https://zhuanlan.zhihu.com/p/354486475

