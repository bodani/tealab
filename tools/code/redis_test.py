import redis


pool = redis.ConnectionPool(host='10.10.2.11', port=6379, max_connections=40, decode_responses=True)  # 连接池大小设置为40
user_connection = redis.Redis(host='10.10.2.11', port=6379, password='f447b20a7fcbf53a5d5be013ea0b15af', 
decode_responses=True,
ssl=True,
ssl_ca_certs="./redis_ssl/ca.crt",
ssl_keyfile="./redis_ssl/redis.key",
ssl_certfile="./redis_ssl/redis.crt",
ssl_cert_reqs="required",
)
user_connection.ping()


user_connection.set("k1","v5")

v=user_connection.get("k1")
print(v)



