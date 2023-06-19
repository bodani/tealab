from redis.sentinel import Sentinel

conf = {
    'sentinel': [('10.10.2.11', 26379), ('10.10.2.12', 26379), ('10.10.2.13', 26379)],   # Sentinel地址列表
    'master_group_name': 'mymaster001',  # master name
    'min_other_sentinels': 0,
    'sentinel_kwargs': {
        'ssl': True,
        'ssl_ca_certs': "./redis_ssl/ca.crt",
        'ssl_keyfile': "./redis_ssl/redis.key",
        'ssl_certfile': "./redis_ssl/redis.crt",
        'ssl_cert_reqs': "required",
    },
    'connection_conf': {
        'password': 'f447b20a7fcbf53a5d5be013ea0b15af',   # redis auth
        'socket_timeout': 0.5,
        'retry_on_timeout': True,
        'socket_keepalive': True,
        'max_connections': 20,
        'encoding': 'utf8',
        'decode_responses': True,
        'client_name': 'sentinel_client',  # 客户端连接名称
        'ssl': True,
        'ssl_ca_certs': "./redis_ssl/ca.crt",
        'ssl_keyfile': "./redis_ssl/redis.key",
        'ssl_certfile': "./redis_ssl/redis.crt",
        'ssl_cert_reqs': "required",
    }
}

sentinel = Sentinel(sentinels=conf['sentinel'],min_other_sentinels=conf['min_other_sentinels'],sentinel_kwargs=conf['sentinel_kwargs'], **conf['connection_conf'])
redis_cli_master = sentinel.master_for(conf['master_group_name'], db=0)

redis_cli_master.set("k1","v1")
redis_cli_slave = sentinel.slave_for(conf['master_group_name'], db=0)
v = redis_cli_slave.get("k1")
print(v)