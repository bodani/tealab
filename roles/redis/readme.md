## redis 配置

bind 0.0.0.0
daemonize yes
logfile "/var/log/reids.log"
dbfilename dump.rdb
dir /data/redis/
requirepass 
# 时间：秒 数量：条
save 5 1000

appendonly yes
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
appendfsync everysec # always no 
# AOF 重写期间是否会仍然记录
no-appendfsync-on-rewrite no


RDB 

优点
1 紧凑的压缩二进制文件
2 fork 子进程性能最大化
3 启动效率高

缺点
1 生成快照的时机，间隔周期
2 fork 进程的性能开销

## 常用命令 

DBSIZE

SAVE 阻塞
BGSAVE  非阻塞

SHUTDOWN -> save 

bgrewriteaof

## 容灾备灾

定期备份 rdb 文件

##  部署建议

硬盘 SSD 

主节点 AOF 禁用。 从节点备份



