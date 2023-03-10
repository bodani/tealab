# 监控服务

## 监控介绍

作为整个IDC监控的服务端。

由界面显示服务 grafana 、数据存储服务 prometheus 、报警服务 altermanager 组成。

数据采集端包括节点信息采集 node_exporter 、网络信息采集 blackbox_exporter组成。

服务启动后主要包括：对监控服务自身节点的节点信息、网络信息、域名检测。

服务资源列表

| 软件              | 端口 |
| ----------------- | ---- |
| prometheus        | 9090 |
| grafana           | 3000 |
| altermanager      | 9093 |
| node_exporter     | 9100 |
| blackbox_exporter | 9115 |

## 监控管理

配置文件管理, 在hosts.ini 中

```
[monitor]
10.10.2.14

[monitor:vars]
# prometheus data path
prometheus_data_path = /data/monitor/prometheus
grafana_admin_username = admin
grafana_admin_password = admin

# 监控域名及证书到期时间
domain_https=['https://www.baidu.com','https://doc.zhangeamon.top','https://tea.zhangeamon.top']

```

创建监控服务

```
playbooks/monitor.yml -i hosts.ini 
```

## 查看监控

http://10.10.2.14:3000 