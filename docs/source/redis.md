# redis高可用

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

## 流程说明

 实体机： 对实体机进行对应的参数优化及必要软件服务安装

 redis主从

1. 安装redis实例
2. 配置redis 服务
3. 建立redis主从关系

redis sentinel

1. 安装redis sentinel
2. 将redis master 注册到每个sentinel 服务中。注册完成后sentinel利用自动发现规则自成集群 

## 配置服务

```
## 主从模式注意事项 master has persistence enabled
[redis]
## 定义第一组redis主从
10.10.2.11 redis_role=master master_groupname=mymaster001 quorum=2
10.10.2.12 replicaof=10.10.2.11 replica_priority=100
10.10.2.13 replicaof=10.10.2.11 replica_priority=80

## 定义第二组redis主从

# 至少三台
[redis_sentinel]
10.10.2.11
10.10.2.12
10.10.2.13

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

################################## redis_sentinel 配置相关信息 ###############################
# 连接信息
sentinel_port = 26379
# 连接sentinel 密码。包括sentinel 彼此连接密码
sentinel_password = f447b20a7fcbf53a5d5be013ea0b15af
# the quorum is only used to detect the failure
quorum = 2
down-after-milliseconds = 1000*60
failover-timeout = 1000*180
parallel-syncs = 1

sentinel_dir = /var/lib/redis/
```

说明: [all:vars] 中的变量为全局默认变量。 也可以在redis实例节点上分别定义。

具有主从关系的redis的实例为一组，使用统一的组名。在master节点上定义。

一组redis实例的存储路径及端口号建议相同，否则在发生切换时发生错误。

## 一步到位

包括redis 主从, sentinel 及监控

```
ansible-playbook -i hosts.ini -i conf/redis.conf playbooks/create_redis.yml 
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

```
## 主从模式注意事项 master has persistence enabled
[redis]
## 定义第一组redis主从
10.10.2.11 redis_role=master master_groupname=mymaster001 quorum=2
10.10.2.12 replicaof=10.10.2.11 replica_priority=100
10.10.2.13 replicaof=10.10.2.11 replica_priority=80
10.10.2.14 replicaof=10.10.2.11 replica_priority=100
```

```
ansible-playbook -i hosts.ini -i conf/redis.conf playbooks/create_redis.yml --tags redis -l 10.10.2.14 
```

## 只监控

如果已存在redis服务，现在的需求只是对原服务添加监控。

```
# 只配置monitor,对原有redis进行监控
ansible-playbook -i hosts.ini -i conf/redis.conf playbooks/create_redis.yml --tags  monitor
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

