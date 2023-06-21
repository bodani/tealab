# 安装tealabs

## 基础概念

**中控机**

​       安装 tea的主机节点为中控机，通过中控机来管理控制所有机器。

**目标机**

​        被中控机访问管理的节点

## 一键安装
在中控机运行
```
curl -fsSL https://gitee.com/zhangeamon/tealab/raw/main/bin/install.sh | sh -
```
- 将在`\home\tea\.ssh`目录中生成ssh key
- 请切换到tea用户进行使用 `sudo su - tea && cd tealab`
- 配置文件位置 `\etc\tea\tea.conf` 

```important:: 一定要保管好ssh key

```

## 管理节点
与其他主机节点建立ssh 免密互通
```
$ vi tea.conf
[nodes]
10.10.2.11
10.10.2.12
10.10.2.13
```

创建目标机器远程连接用户，需要远程节点超级用户权限。

执行以下命令

```
# 默认在node节点上创建的用户名为 tea
./create_user.yml -i hosts.ini  -u root -k
```

该步骤将在部署目标机器上创建 `tea` 用户，并配置 sudo 规则，配置中控机与部署目标机器之间的 SSH 互信。

测试互通效果

```
ansible -i hosts.ini nodes -m shell -a 'whoami'  -b 
```

后期安全建议，目标机禁用root登录

```
playbooks/disable_rootlogin.yml
```

至此，中控机及目标机环境准备完成。

## 添加目标节点

 加入新节点 `10.10.2.14`

```
$ vim tea.conf
[nodes]
10.10.2.11
10.10.2.12
10.10.2.13
10.10.2.14  # 新节点地址
```

新节点建立ssh免密互通 

创建用户 
```
./create_user.yml  -u root -k -l 10.10.2.14
```

测试可连接性
```
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

在安装安装应用前将准备好的软件包放在 tea.conf 配置文件指定的 `local_bin = "~/local_bin/"`  文件目录下

```
./packages.yml
```

可通过软件包来管理软件的版本。到此准备工作全部完成。

**油箱加满，准备出发**！

**未来可能会提供更简洁的安装方式**

- docker 
- go-ansible