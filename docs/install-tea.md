# 安装tea 

## 基础概念

**中控机**

​       安装 tea的主机节点为中控机，通过中控机来管理控制所有机器。

**目标机**

​        被中控机访问管理的节点

## 使用实体机安装

- 依赖安装ansbile

**以root 用户登录，并执行以下命令** 

安装依赖软件

```
yum -y install epel-release git curl sshpass && \
yum -y install python2-pip
```

创建 tea 用户

```
useradd -m -d /home/tea tea
```

设置 tea 用户密码

````
passwd tea
````

配置 `tea` 用户 sudo 免密码，将 `tea ALL=(ALL) NOPASSWD: ALL` 添加到文件末尾即可

```
visudo
tea ALL=(ALL) NOPASSWD: ALL
```

生成 SSH key

```
su - tea
ssh-keygen -t rsa
ls ~/.ssh
```

```important:: 一定要保管好ssh key
```



安装tea

```
sudo su - tea
git -b $tag  clone https://github.com/eamonzhang/tealab
cd tealab
sudo pip install -r ./requirements.txt
```

查看ansible版本

```
ansible --version
ansible 2.5.0
```

与其他节点ssh 免密互通

```
cd /home/tea/tealab && \
vi hosts.ini
```

```
[nodes]
10.10.2.11
10.10.2.12
10.10.2.13

[all:vars]
remote_user = root # 目标节点超级用户账号，用于首次连接初始化
username = tea
```

创建目标机器远程连接用户，需要远程节点超级用户权限。

在配置文件hosts.ini 中设置 `username='yourname'`定义用户名 

执行以下命令

```
ansible-playbook -i hosts.ini playbooks/create_user.yml -u root -k
```

```
tea_ctl init create_user
```

该步骤将在部署目标机器上创建 `tea` 用户，并配置 sudo 规则，配置中控机与部署目标机器之间的 SSH 互信。

测试互通效果

```
ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea

ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea -b 
```

```
tea_ctl init check_user_ssh
```



后期安全建议，目标机禁用root登录

```
ansible-playbook -i hosts.ini playbooks/disable_rootlogin.yml -u tea --private-key /home/tea/.key
```

目标机使用私有源

```
$ vi hosts.init 默认使用如下私有源，如需使用自己的私有源请修改
[all:vars]
repo_address = mirror.zhangeamon.top
```

```
ansible-playbook -i hosts.ini playbooks/use_repo.yml -u tea
```

```
tea_ctl init use_repo
```

至此，中控机及目标机环境准备完成。**油箱加满，准备出发**！

**未来可能会提供更简洁的安装方式**

- docker 
- go-ansible

## 简单总结

- hosts.ini 文件中配置所有需要管理的目标机

- 建立中控机与目标机之间免密互通

  ```
  # 创建tea管理用户
  tea_ctl init create_user 
  # 验证新用户可连接性
  tea_ctl init check_user_ssh
  ```

- 在目标机指定私有源地址

  ```
  tea_ctl init use_repo
  ```

## 配置文件建议

 hosts.ini 为全局配置，所有需要被管理的节点都配置在[nodes] 段中。

除repo节点，prometheus节点等在整个IDC中只需要部署一份的基础服务、其他服务建议在创建一个单独的配置文件

如 redis001.conf 。

这样的好处，便于在同一个IDC中管理多个redis服务。

使用的时候只需指定你的配置文件即可

``` 
tea_ctl redis  create -i conf/redis001.conf
```

## 添加目标节点

 加入新节点 `10.10.2.14`

```
$ vim hosts.ini
[nodes]
10.10.2.11
10.10.2.12
10.10.2.13
10.10.2.14  # 新节点地址
```

新节点建立ssh免密互通

```
创建用户
$tea_ctl init create_user -l 10.10.2.14
测试可连接性
$tea_ctl init check_user_ssh -l 10.10.2.14
```

新节点指定私有源地址

```
$tea_ctl init use_repo -l 10.10.2.14
```

## 调试指南

查看执行脚本中的hosts

```
sudo ansible-playbook test.yml --list-hosts
```

只检查，不真正执行

```
sudo ansible-playbook test.yml -C
```

详细的日志

```
sudo ansible-playbook test.yml -vvv
```

真正执行

```
sudo ansible-playbook test.yml
```

## 接下来

tealab 目前利用yum仓库或二进制文件两种方式安装应用服务

你可以使用默认的yum仓库，也可以利用tealab 轻松搭建属于自己的yum仓库服务
