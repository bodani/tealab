# 安装tea 

## 基础概念

**中控机**

​       安装 tea的主机节点为中控机，通过中控机来管理控制所有机器。

**目标机**

​        被中控机访问管理的节点

## 环境准备

- 依赖安装ansbile

**以root 用户登录，并执行以下命令** 

安装依赖软件

```
yum -y install epel-release git curl sshpass && \
yum -y install python3-pip
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

## 安装tea

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
username = tea
############## local repo 存放位置##############
local_bin = "~/local_bin/"
```

创建目标机器远程连接用户，需要远程节点超级用户权限。

在配置文件hosts.ini 中设置 `username='yourname'`定义用户名 

执行以下命令

```
ansible-playbook -i hosts.ini playbooks/create_user.yml -u root -k
```

该步骤将在部署目标机器上创建 `tea` 用户，并配置 sudo 规则，配置中控机与部署目标机器之间的 SSH 互信。

测试互通效果

```
ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea

ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea -b 
```

后期安全建议，目标机禁用root登录

```
ansible-playbook -i hosts.ini playbooks/disable_rootlogin.yml -u tea --private-key /home/tea/.key
```

至此，中控机及目标机环境准备完成。

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

创建用户 
```
ansible-playbook -i hosts.ini playbooks/create_user.yml -u root -k -l 10.10.2.14
```

测试可连接性
```
ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea -l 10.10.2.14

ansible -i hosts.ini nodes -m shell -a 'whoami' -u tea -b -l 10.10.2.14
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

## 软件包管理

tealab 目前利用二进制文件或安装包方式安装应用服务。

在安装安装应用前将准备好的软件包放在 hosts.ini 配置文件指定的 `local_bin = "~/local_bin/"`  文件目录下

如果网络环境自信, tags 按需下载软件包

```
# 网络环境自信者一键搞定，下载解压
ansible-playbook -i download.ini playbooks/prepare.yml
# 按需下载
ansible-playbook -i download.ini playbooks/prepare.yml --tags xxx
```

为了解决网络问题也通过如下方式下载软件包

```
#下载软件包
git clone https://gitee.com/zhangeamon/tea-package-download.git
#解压软件包
cd tea-package-download 
sh unzip.sh
# 注意将tea-package-download 与 local_bin = "~/local_bin/" 保持一致
```

可通过软件包来管理软件的版本。到此准备工作全部完成。

**油箱加满，准备出发**！

**未来可能会提供更简洁的安装方式**

- docker 
- go-ansible

``` important:: 配置文件建议
```

hosts.ini 为全局配置，所有需要被管理的节点都配置在[nodes] 段中。

TODO 思考如何支持管理多集群