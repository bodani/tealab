## 开发计划列表 功能类

提供了一键安装部署、监控告警、备份恢复、性能优化等方面的数据库全生命周期智能运维管理能力

#### 基础环境初始化
- tea安装 
- 依赖软件包加载到本地 支持离线安装，工具与资源包（二进制程序 配置文件 镜像 yaml文件等）分离
- node 纳入tea管理

#### 监控管理

- 服务端 prometheus
- 服务端 grafana 
- 服务端 altermanager
- node 加入 exporter
- load dashboards
- load rules

#### 日志管理
- 服务端 loki
- 服务端 grafana 与监控公用
- node 端 加入 promtail
- 日志rules

#### node 管理
- 必备工具软件及服务安装
- 内核参数修改
- 接入监控
- 接入日志


## 优化类
tea 的安装方式思考
1 tea 是基于ansible开发，需要安装ansible，有依赖python。安装不友好，对控制机环境侵入性高 。

初步优化方式，将所有环境打包为docker images 。一键使用

终态， 一个二进制文件工具，加配置文件