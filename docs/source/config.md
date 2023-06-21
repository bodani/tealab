# 配置说明
tealab 主要依赖配置描述对服务进行管理和排版。

配置文件位置 

`hosts.ini`

`group_vars/*.yml`

## 配置文件示例

` vim hosts.ini `
```
[nodes]
10.10.2.10  hostname=controller idc=first
10.10.2.11  hostname=node1 idc=first
10.10.2.12  hostname=node2 idc=first
10.10.2.13  hostname=node3 idc=first
10.10.2.14  hostname=node4 idc=second

[monitor]
10.10.2.14
```

` vim group_vars/all.yml `
```
[all:vars]
############## local repo 存放位置##############
# local repo 存放位置
local_bin: "~/local_bin/packages"
# 自定义证书在中控机存放位置
CERT_LOCAL_BASE_DIR: /etc/ssl/certs/tealabs/
```

` vim monitor.yml`
```
# prometheus data path
prometheus_data_path: /data/monitor/prometheus
grafana_admin_username: admin
grafana_admin_password: admin

# 监控域名及证书到期时间 
domain_https: 
 - https://www.baidu.com
 - https://doc.zhangeamon.top
 - https://test.zhangeamon.top
```

## 配置文件安全

#### 加密
```
ansible-vault encrypt hosts.ini 
ansible-vault encrypt group_vars/*.yml
```
#### 编辑
```
ansible-vault edit hosts.ini
```
#### 解密
```
ansible-vault decrypt hosts.ini
```
