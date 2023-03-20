# cron vacuum pg database at business low peak
set vacuum_cost_delay = 2; set vacuum_cost_limit = 2000; set maintenance_work_mem='10GB'; vacuum analyze verbose;
vacuumdb  -a -h localhost -e -j 4

# 每天凌晨一点执行
0 1 * * *  psql -U postgres -d xxxx -h 127.0.0.1 -p 5432 -c "set vacuum_cost_delay = 2; set vacuum_cost_limit = 2000; set maintenance_work_mem='10GB'; vacuum analyze;"  >> /tmp/pg.2 2>&1