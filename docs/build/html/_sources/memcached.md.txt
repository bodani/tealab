# memcached 管理

## 配置

```
# 配置memcached 服务
[memcached]
10.10.2.12
10.10.2.13

[memcached:vars]
MEMCACHED_PORT="11211"
MEMCACHED_USER="memcached"
MEMCACHED_MAXCONN="1024"
#MB
MEMCACHED_CACHESIZE="64"
MEMCACHED_OPTIONS=""
```

## 部署

```
ansible-playbook -i hosts.ini -i conf/memcached.conf playbooks/create_memcaced.yml
```

### 只部署服务

```
ansible-playbook -i hosts.ini -i conf/memcached.conf playbooks/create_memcaced.yml --tags install
```

### 只部署监控

```
ansible-playbook -i hosts.ini -i conf/memcached.conf playbooks/create_memcaced.yml --tags monitor
```

