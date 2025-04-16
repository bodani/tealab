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

## 软件包准备

## 软件包准备

下载软件包到 , `group_vars/all.yml` 中设置 
```
local_bin: "~/local_bin/packages"
```

例如
```
sudo mkdir -p ~/local_bin/packages/prometheus/
sudo wget https://github.com/prometheus/prometheus/releases/download/v3.2.1/prometheus-3.2.1.linux-amd64.tar.gz
sudo tar zxf prometheus-3.2.1.linux-amd64.tar.gz -C ~/local_bin/packages/prometheus/
sudo mv ~/local_bin/packages/prometheus/prometheus-3.2.1.linux-amd64/{prometheus,promtool} ~/local_bin/packages/prometheus/
sudo rm -rf  ~/local_bin/packages/prometheus/prometheus-3.2.1.linux-amd64

sudo mkdir -p ~/local_bin/packages/alertmanager/
sudo wget https://github.com/prometheus/alertmanager/releases/download/v0.28.1/alertmanager-0.28.1.linux-amd64.tar.gz
sudo tar zxf ~/local_bin/packages/alertmanager/alertmanager-0.28.1.linux-amd64.tar.gz -C ~/local_bin/packages/alertmanager/

sudo mkdir -p ~/local_bin/packages/blackbox_exporter/
sudo wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.26.0/blackbox_exporter-0.26.0.linux-amd64.tar.gz
sudo tar zxf ~/local_bin/packages/blackbox_exporter-0.26.0.linux-amd64.tar.gz -C ~/local_bin/packages/blackbox_exporter/

sudo mkdir -p ~/local_bin/packages/node_exporter/
suoo wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
sudo tar zxf ~/local_bin/packages/node_exporter-1.9.1.linux-amd64.tar.gz -C ~/local_bin/packages/node_exporter

```

## 监控管理

` vim hosts.ini ` 

```
[monitor]
10.10.2.14
```
` vim group_vars/monitor.yml `
```
# prometheus data path
prometheus_data_path: /data/monitor/prometheus
grafana_admin_username: admin
grafana_admin_password: admin
```

创建监控服务

```
playbooks/monitor.yml -i hosts.ini 
```

## 查看监控

http://10.10.2.14:3000 