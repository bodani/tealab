# 快速开始

## 安装nginx

## 准备阶段

配置 指定需要安装nginx的目标机 

```
$ vim hosts.ini
[nodes]
10.10.2.14
```

建立访问互通

```
ansible-playbook -i hosts.ini create_user.yml -u root -k
```

测试互通效果

```
ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea
ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea -b
```

设置repo

```
ansible-playbook -i hosts.ini use_repo.yml -u tea
```

## 开始安装

配置nginx服务管理文件

```
$ vi conf/nginx.conf
# 目标机器ip
[nginx]
10.10.2.14
```

安装nginx服务

```
ansible-playbook -i conf/nginx.conf create_nginx.yml 
```

执行以上命令后将完成nginx的安装





