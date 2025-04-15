# 证书管理 

## 自签名证书

配置文件 group_vars/all.yml
```
# 自定义证书在中控机存放位置
CERT_LOCAL_BASE_DIR: /etc/ssl/certs/tealabs/
```

将在中控机（执行tea）的 CERT_LOCAL_BASE_DIR 目录下生成自签名证书。

包括

- ca 证书 根证书
- san证书 节点ip绑定及通用域名证书
- 客户端证书 本机
- 通用证书 不与ip绑定