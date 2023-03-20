# 前言

## 简介

tealabs 是一款基于[ansible](https://doc.zhangeamon.top/categories/ansible/)开发的自动化运维管理工具、致力于帮助你轻松管理服务及设施。

包括系统环境管理、服务安装、日志收集、主要指标监控、报警规则制定、重要数据备份及恢复、安全加固等。

秉承简单哲学，简单即力量。

## 支持服务

tealabs 适用于Linux系统环境（CentOS、Ubuntu、Debian）,可以为私有云，公有云，虚拟机等。

### 	基础服务

- nginx
- haproxy
- etcd 集群
- minio 集群
- redis 集群
- kafka 集群
- rabbitmq 集群

### 	Postgres 数据库

- 单机
- 原始主从结构
- 基于repmgr 高可用
- 基于patroni 高可用
- pgbouncer 连接池
- wal-g 数据备份恢复
- citus 集群
- debezium 数据迁移

### 应用服务

- docker
- k3s
- hub

### 	日志服务

- filebeat
- logstash
- elasticsearch
- loki

### 	监控服务

- node_exporter
- blackbox_exporter
- *_exporter
- prometheus
- grafana
- zabbix
- sentry

### 其他服务

- gitea
- dns
- 安全加固

## **Why tealab**

Everyone at some point reaches a threshold when manual maintenance of a cluster becomes an arduous chore, and the necessity of some automated  solution becomes more and more apparent. Here will be discussed an  example of such an automated solution.

## **Philosophy**

Simple&Easy is Power: A maintenance process should be easy, obvious, coherent, and uniform. Complex instructions, custom shell scripts, which are never supported, and tribal knowledge should be minimized.

**The world is beautiful because of simplicity**

Have a cup of tea , wait for a moment ，everything is accomplished the way you expect it to be !  


## Stargazers over time

[![Stargazers over time](https://starchart.cc/bodani/tea.svg)](https://starchart.cc/bodani/tea)