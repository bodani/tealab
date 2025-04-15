# 节点管理

## 节点管理介绍

- Update all packages to the latest version
- nlimit 限制调整
- 设置hostname
- ntp 网络时钟
- sysctl 内核参数
- 安装常用工具
- ufw apparmor 防火墙管理

## 服务器管理

配置文件管理, 在hosts.ini 中。

```
[nodes]
 10.10.2.11  hostname=node1 idc=first
 10.10.2.12  hostname=node2 idc=first
 10.10.2.13  hostname=node3 idc=first
 10.10.2.14  hostname=node4 idc=second
```

创建节点管理,包括初始配置优化，常用软件安装，节点进行监控。

```
playbooks/node.yml -i hosts.ini 
```

## 结果查看

http://10.10.2.10:3000