# 搭建私有源

## 配置介绍

vim tealab/roles/repo/defaults/main.yml

```
# 私有源存储位置设置
repo_path: /data/yum.repo

#访问端口
repo_port: 80

# URL
repo_address: mirrors.zhangeamon.top

# 通过url 下载rpm
repo_url_packages:

# 定义您私有源的软件库
repo_packages:
```

cd  tealab/roles/repo/files

在这里添加三方源，例如将如下prometheus.repo文件放在 /tealab/roles/repo/files目录下

```
[prometheus]
baseurl = https://packagecloud.io/prometheus-rpm/release/el/$releasever/$basearch 
gpgcheck = 0
name = Prometheus and exporters 
```

## 创建私源

 执行以下命令，开始创建私有源服务。由于下载大量软件首次执行需要一些时间

```
sudo ansible-playbook create_repo.yml -i hosts 
```

## 更新源

vi  tealab/roles/repo/defaults/main.yml

```
repo_packages:
在此处添加需要的软件
```

然后再次执行

```
sudo ansible-playbook create_repo.yml -i hosts 
```

## 手动更新

登录到私有源服务器, 下载软件包

```
yum install --downloadonly --downloaddir={{数据存储位置}}/repo/base/Packages/ xxx.rpm
```

下载依赖软件包

```
cd {{数据存储位置}}/repo/base/Packages/
repotrack
```

更新repo xml

```
createrepo  {{数据存储位置}}/repo/base/Packages/
```



