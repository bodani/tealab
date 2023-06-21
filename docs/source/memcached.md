# memcached 管理

## 配置

` vim hosts.ini `
```
# 配置memcached 服务
[memcached]
10.10.2.13
10.10.2.11
10.10.2.12
```

` vim group_vars/memcached.yml `
```
MEMCACHED_PORT: 11211
MEMCACHED_USER: "memcached"
MEMCACHED_MAXCONN: 1024
#MB
MEMCACHED_CACHESIZE: 64
MEMCACHED_OPTIONS: ""
```

## 部署

```
ansible-playbook/create_memcached.yml -i hosts.ini 
```

### 只部署服务

```
ansible-playbook/create_memcached.ym -i hosts.ini --tags install
```

### 只部署监控

```
ansible-playbook/create_memcaced.yml -i hosts.ini  --tags monitor
```

