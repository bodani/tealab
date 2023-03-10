# 服务器管理

## 服务器管理介绍

服务器管理主要包括两部分

- 对初始安装的服务器进行初始配置优化，常用软件安装
- 对节点服务器监控

服务资源列表

| 软件              | 端口 |
| ----------------- | ---- |
| node_exporter     | 9100 |
| blackbox_exporter | 9115 |

## 依赖环境

- 参考安装tea ，将服务器加入tea进行管理
- 参考monitor服务，安装monitor

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