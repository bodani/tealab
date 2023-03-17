alias pgb_admin='psql -U tea_mon  -p 6432 -h 127.0.01  -d pgbouncer'
alias pgb_stats='psql -U tea_mon  -p 6432 -h 127.0.01  -d pgbouncer'
alias pgb_sync_users='python /etc/pgbouncer/mkauth.py /etc/pgbouncer/userlist.txt  "host=localhost user=postgres"'