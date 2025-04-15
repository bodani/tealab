## prometheus 地址
mx-db-mon.conf
http://mon-db-t1.mxcdp.com

配置报警规则
https://help.aliyun.com/zh/grafana/user-guide/configure-grafana-native-alarm


https://www.feishu.cn/flow/api/trigger-webhook/66f1e8fc523fecd5e8886c9b12c14c16


#!/usr/bin/env bash
alerts_message='[
  {
    "labels": {
       "alertname": "磁盘已满",
       "dev": "sda1",
       "instance": "实例1",
       "msgtype": "testing"
     },
     "annotations": {
        "info": "程序员小王提示您：这个磁盘sda1已经满了，快处理！",
        "summary": "请检查实例示例1"
      }
  },
  {
    "labels": {
       "alertname": "磁盘已满",
       "dev": "sda2",
       "instance": "实例1",
       "msgtype": "testing"
     },
     "annotations": {
        "info": "程序员小王提示您：这个磁盘sda2已经满了，快处理！",
        "summary": "请检查实例示例1",
        "runbook": "以下链接http://test-url应该是可点击的"
      }
  }
]'