# 初始使用

**中控机**

​        通过中控机来管理控制所有机器。推荐安装 CentOS 7.3 及以上版本 Linux 操作系统（默认包含 Python 2.7）

**目标机**

​        可被中控机访问管理，推荐安装 CentOS 7.3 及以上版本 Linux 操作系统，x86_64 架构 (amd64)

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

配置 `tidb` 用户 sudo 免密码，将 `tidb ALL=(ALL) NOPASSWD: ALL` 添加到文件末尾即可

```
visudo

tea ALL=(ALL) NOPASSWD: ALL
```

生成 SSH key

```
su - tea
ssh-keygen -t rsa
```

下载tealab

```
sudo su - tea
git clone -b $tag https://github.com/xxxx.git
```

安装中控ansible 及依赖

```
cd /home/tea/tealab && \
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
[servers]
172.16.10.1
172.16.10.2
172.16.10.3
172.16.10.4
172.16.10.5
172.16.10.6
```

执行以下命令，按提示输入部署目标机器的 `root` 用户密码

```
ansible-playbook -i hosts.ini create_users.yml -u root -k
```

该步骤将在部署目标机器上创建 `tidb` 用户，并配置 sudo 规则，配置中控机与部署目标机器之间的 SSH 互信。

测试互通效果

```
ansible -i hosts all -m shell -a 'whoami' -u tea

ansible -i hosts.ini all -m shell -a 'whoami' -u tea -b
```

后期安全建议，目标机禁用root登录

```
ansible-playbook -i hosts.ini disable_rootlogin.yml -u tea --private-key /home/tea/.key
```

至此，中控机及目标机环境准备完成。

**调试指南**

建立首次连接访问互信 

```
ansible all -i hosts -m shell -a 'whoami' -u vagrant -b --private-key /home/zhangeamon/.vagrant.d/insecure_private_key
```

查看执行脚本中的hosts

```
sudo ansible-playbook test.yml --list-hosts
```

只检查，不真正执行

```
sudo ansible-playbook test.yml -C
```

真正执行

```
sudo ansible-playbook test.yml
```
