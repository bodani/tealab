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