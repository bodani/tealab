.. _dynamic_configuration:

操作系统初始管理
================

系统初始设置要求

Ubuntu 2022.04(Minimized)  
------------------------

更新系统(建议)
~~~~~~~~

.. code-block:: ini

   sudo apt-get update -y 

   sudo apt-get dist-upgrade -y 

用户(必须)
~~~~~~
需要一个拥有sudo 权限用户，且切换root时无需密码

.. code-block:: ini 

  echo "yourname ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/yourname

软件安装(无需,由tealab 管理)
~~~~~~~~

.. code-block:: ini

   sudo apt-get install vim -y
   sudo apt-get install ufw -y 

防火墙基本管理(无需，由tealab 管理)
~~~~~~~~~~~~

防火墙采用默认拒绝所有访问，逐步开放策略

.. code-block:: ini
    
   sudo ufw enable  # 启用
   sudo ufw status  # 查看

   sudo ufw allow ssh  # 允许ssh 访问
   sudo ufw allow 53   # 允许 53 dns 
   sudo ufw default deny # 默认拒绝所有
   sudo ufw default allow outgoing
   sudo ufw default deny incoming
   
   # ufw 配置 
   # 开机自启
   vim /etc/ufw/ufw.conf
    enabled=yes 
   # 关闭ipv6
   vim /etc/default/ufw
     IPV6=disable 

   # 规则语法 示例
   sudo ufw allow <port>/<protocol>
   sudo ufw deny <port>/<protocol>
   sudo ufw allow from <IP address>
   sudo ufw deny from <IP address>
   # 根据实际情况开放访问
   sudo ufw allow proto tcp from 10.10.10.0/24 to any port 6789 