# 数据库的创建时间
select to_timestamp((SELECT system_identifier FROM pg_catalog.pg_control_system()) >> 32);