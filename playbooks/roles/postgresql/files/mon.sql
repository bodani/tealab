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

  SELECT COUNT(*) AS "__c
ount" FROM "pda_message" INNER JOIN "message_message" ON ("pda_message"."message_ptr_id" = "message_message"."message_id") WHERE ("pda_message"."is_read" = false AND "message_messag
e"."user_id" = 'f672b090d80711eca54e0242ac120002' AND NOT ("message_message"."body" @> '{"status": 2}' AND "message_message"."code" = 2002701))