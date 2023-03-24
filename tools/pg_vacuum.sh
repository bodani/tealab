定时任务日志管理
vi /etc/rsyslog.d/50-default.conf # 编辑文件，打开注释
#cron.*                          /var/log/cron.log

sudo systemctl restart rsyslog



# 每天凌晨一点执行
0 1 * * * postgres vacuumdb  -a -h localhost -e -j 4  >> /tmp/pg.2 2>&1

# cron vacuum pg database at business low peak
0 1 * * * postgres /var/lib/postgrsql/vacuum.sh  >> /tmp/pg.2 2>&1
#!/bin/bash
DBPORT=5432
DBHOST=127.0.0.1
DBDATABASE=xxx
DBPATH=/usr/pgsql-10/bin
$DBPATH/psql -U postgres -p $PGPORT -h $DBHOST <<EOF
checkpoint;
set vacuum_cost_delay = 2; 
set vacuum_cost_limit = 2000;
set maintenance_work_mem='10GB'; 
vacuum analyze verbose;
\q
EOF