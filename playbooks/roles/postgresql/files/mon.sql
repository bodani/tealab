# 数据库的创建时间
select to_timestamp((SELECT system_identifier FROM pg_catalog.pg_control_system()) >> 32);


DO
$do$
BEGIN
IF EXISTS (
    SELECT FROM pg_catalog.pg_user
    WHERE  usename = 'rep_user') THEN
ELSE
    set password_encryption TO "scram-sha-256";
    create user  rep_user   with encrypted password '{{ rep_password | mandatory }}' REPLICATION CONNECTION LIMIT 10;
END IF;
END
$do$;

select client_addr as addr, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(),replay_lsn)) as replay_lag, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(),flush_lsn))s flush_lag from pg_stat_replication;