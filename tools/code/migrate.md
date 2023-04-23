# 利用逻辑复制进行数据迁移

## 前期准备

- 运行机上具有pg运行环境，可以执行pg_dump 及 pgsql
- 连接源端和目标端数据库的超级用户
- 在目标端创建好数据库database及对应的owner。owner与源数据对应的database相同。
- 在目标端创建extentions需要的依赖

## 迁移步骤

 1. check 检查运行环境
 2. start-mgirate 数据迁移
 3. show-progress 显示迁移进度 watch migrete show-progress
 4. verify        数据校验 (结合实际场景)
 5. 原库停止写入    
 6. sync-sequence 同步最新序列
 7. 业务切换至新库 
 8. finish-migrate 清理订阅和发布

## 迁移命令

```
python pg_migrate.py --s_host=10.10.2.11 --s_user=supper_test --s_database=dbname --s_password=123456 --s_port=5432 --d_host=10.10.2.12 --d_user=supper_dest --d_database=dbname --d_password=123456 --d_port=15432 check

```

--s 源端数据库连接

--d 目标端数据库连接
