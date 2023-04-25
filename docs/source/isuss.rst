问题列表
~~~~~~~~~~

运行环境

- patroni  3.0.2

- etcd 3.5.7

三个节点，每个节点同时部署 patroni etcd pg

.. code-block:: ini

  + Cluster: pg_cluster_test ----+---------+----+-----------+-------------+
    | Member | Host      | Role    | State   | TL | Lag in MB | Tags        |
    +--------+-----------+---------+---------+----+-----------+-------------+
    | node31 | 10.1.8.31 | Leader  | running  | 25 |         0 | |
    | node32 | 10.1.8.32 | Replica | running  | 25 |           | |
    | node33 | 10.1.8.33 | Replica | running  | 25 |         0 | |
    +--------+-----------+---------+---------+----+-----------+-------------+

问题描述

  node31为leader节点。 将node31网线拔掉， node31 降级为只读节点。node32,node33 重新选主，并继续提供服务。
  运行一段时间后，将node31 网线重新插回。此时出现问题。 node31 直接成为leader。集群状态混乱。


将node31的网线拔掉。node31降级为只读

日志记录

.. code-block:: ini

  2023-04-12 16:11:30 +0800 ERROR: Failed to get list of machines from https://10.1.8.31:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.31', port=2379): Max retries exceeded with url: /v3/cluster
  /member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c99c3c8>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:30 +0800 ERROR: Failed to get list of machines from https://10.1.8.33:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.33', port=2379): Max retries exceeded with url: /v3/cluster
  /member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c99c780>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:30 +0800 ERROR: Failed to get list of machines from https://10.1.8.32:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.32', port=2379): Max retries exceeded with url: /v3/cluster
  /member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c14da90>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:30 +0800 ERROR: KVCache.run EtcdException('Could not get the list of servers, maybe you provided the wrong host(s) to connect to?',)
  2023-04-12 16:11:30 +0800 ERROR: Failed to execute ['/etc/patroni/callbacks/callbacks.sh', on_stop, 'master', 'pg_cluster_test']
  Traceback (most recent call last):
    File "/usr/lib/python3.6/site-packages/patroni/postgresql/cancellable.py", line 30, in _start_process
      self._process = psutil.Popen(cmd, *args, **kwargs)
    File "/usr/lib64/python3.6/site-packages/psutil/__init__.py", line 1429, in __init__
      self.__subproc = subprocess.Popen(*args, **kwargs)
    File "/usr/lib64/python3.6/subprocess.py", line 729, in __init__
      restore_signals, start_new_session)
    File "/usr/lib64/python3.6/subprocess.py", line 1364, in _execute_child
      raise child_exception_type(errno_num, err_msg, err_filename)
  PermissionError: [Errno 13] Permission denied: '/etc/patroni/callbacks/callbacks.sh'
  2023-04-12 16:11:30 +0800 ERROR: Failed to execute ['/etc/patroni/callbacks/callbacks.sh', on_stop, 'replica', 'pg_cluster_test']
  Traceback (most recent call last):
    File "/usr/lib/python3.6/site-packages/patroni/postgresql/cancellable.py", line 30, in _start_process
      self._process = psutil.Popen(cmd, *args, **kwargs)
    File "/usr/lib64/python3.6/site-packages/psutil/__init__.py", line 1429, in __init__
      self.__subproc = subprocess.Popen(*args, **kwargs)
    File "/usr/lib64/python3.6/subprocess.py", line 729, in __init__
      restore_signals, start_new_session)
    File "/usr/lib64/python3.6/subprocess.py", line 1364, in _execute_child
      raise child_exception_type(errno_num, err_msg, err_filename)
  PermissionError: [Errno 13] Permission denied: '/etc/patroni/callbacks/callbacks.sh'
  2023-04-12 16:11:31 +0800 INFO: postmaster pid=125504
  2023-04-12 16:11:31 +0800 ERROR: Failed to get list of machines from https://10.1.8.31:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.31', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c14d198>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:31 +0800 ERROR: Failed to get list of machines from https://10.1.8.33:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.33', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8d9c90f0>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:31 +0800 ERROR: Failed to get list of machines from https://10.1.8.32:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.32', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8d9c9240>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:31 +0800 ERROR: KVCache.run EtcdException('Could not get the list of servers, maybe you provided the wrong host(s) to connect to?',)
  2023-04-12 16:11:31 +0800 INFO: postmaster pid=125505
  2023-04-12 16:11:31 +0800 ERROR: Failed to execute ['/etc/patroni/callbacks/callbacks.sh', on_role_change, 'replica', 'pg_cluster_test']
  Traceback (most recent call last):
    File "/usr/lib/python3.6/site-packages/patroni/postgresql/cancellable.py", line 30, in _start_process
      self._process = psutil.Popen(cmd, *args, **kwargs)
    File "/usr/lib64/python3.6/site-packages/psutil/__init__.py", line 1429, in __init__
      self.__subproc = subprocess.Popen(*args, **kwargs)
    File "/usr/lib64/python3.6/subprocess.py", line 729, in __init__
      restore_signals, start_new_session)
    File "/usr/lib64/python3.6/subprocess.py", line 1364, in _execute_child
      raise child_exception_type(errno_num, err_msg, err_filename)
  PermissionError: [Errno 13] Permission denied: '/etc/patroni/callbacks/callbacks.sh'
  2023-04-12 16:11:31 +0800 INFO: demoted self because DCS is not accessible and I was a leader

  2023-04-12 16:11:31 +0800 WARNING: Loop time exceeded, rescheduling immediately.
  2023-04-12 16:11:31 +0800 ERROR: Failed to execute ['/etc/patroni/callbacks/callbacks.sh', on_role_change, 'replica', 'pg_cluster_test']
  Traceback (most recent call last):
    File "/usr/lib/python3.6/site-packages/patroni/postgresql/cancellable.py", line 30, in _start_process
      self._process = psutil.Popen(cmd, *args, **kwargs)
    File "/usr/lib64/python3.6/site-packages/psutil/__init__.py", line 1429, in __init__
      self.__subproc = subprocess.Popen(*args, **kwargs)
    File "/usr/lib64/python3.6/subprocess.py", line 729, in __init__
      restore_signals, start_new_session)
    File "/usr/lib64/python3.6/subprocess.py", line 1364, in _execute_child
      raise child_exception_type(errno_num, err_msg, err_filename)
  PermissionError: [Errno 13] Permission denied: '/etc/patroni/callbacks/callbacks.sh'
  2023-04-12 16:11:32 +0800 ERROR: Failed to get list of machines from https://10.1.8.31:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.31', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c14d400>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:32 +0800 ERROR: Failed to get list of machines from https://10.1.8.33:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.33', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c14d630>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:32 +0800 ERROR: Failed to get list of machines from https://10.1.8.32:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.32', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8d9c90b8>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:11:32 +0800 ERROR: KVCache.run EtcdException('Could not get the list of servers, maybe you provided the wrong host(s) to connect to?',)

将node31 网线重新插上, 出现问题。
 
对应日志记录

.. code-block:: ini

  2023-04-12 16:12:21 +0800 ERROR: Failed to get list of machines from https://10.1.8.33:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.33', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c96d240>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:12:21 +0800 ERROR: Failed to get list of machines from https://10.1.8.32:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.32', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c96d160>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:12:21 +0800 ERROR: KVCache.run EtcdException('Could not get the list of servers, maybe you provided the wrong host(s) to connect to?',)
  2023-04-12 16:12:22 +0800 ERROR: Failed to get list of machines from https://10.1.8.31:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.31', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c975940>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:12:22 +0800 ERROR: Failed to get list of machines from https://10.1.8.33:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.33', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c98feb8>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:12:22 +0800 ERROR: Failed to get list of machines from https://10.1.8.32:2379/v3: MaxRetryError("HTTPSConnectionPool(host='10.1.8.32', port=2379): Max retries exceeded with url: /v3/cluster/member/list (Caused by NewConnectionError('<urllib3.connection.VerifiedHTTPSConnection object at 0x7ffb8c98fe10>: Failed to establish a new connection: [Errno 101] Network is unreachable',))",)
  2023-04-12 16:12:22 +0800 ERROR: KVCache.run EtcdException('Could not get the list of servers, maybe you provided the wrong host(s) to connect to?',)
  2023-04-12 16:12:23 +0800 INFO: Lock owner: node31; I am node31
  2023-04-12 16:12:27 +0800 ERROR: Request to server https://10.1.8.31:2379 failed: ReadTimeoutError("HTTPSConnectionPool(host='10.1.8.31', port=2379): Read timed out. (read timeout=3.333230980342099)",)
  2023-04-12 16:12:27 +0800 INFO: Reconnection allowed, looking for another server.
  2023-04-12 16:12:27 +0800 INFO: Retrying on https://10.1.8.33:2379
  2023-04-12 16:12:27 +0800 INFO: Selected new etcd server https://10.1.8.33:2379
  2023-04-12 16:12:27 +0800 ERROR: watchprefix failed: ProtocolError('Connection broken: IncompleteRead(0 bytes read)', IncompleteRead(0 bytes read))
  2023-04-12 16:12:27 +0800 INFO: promoted self to leader because I had the session lock
  2023-04-12 16:12:27 +0800 INFO: cleared rewind state after becoming the leader
  2023-04-12 16:12:27 +0800 ERROR: Failed to execute ['/etc/patroni/callbacks/callbacks.sh', on_role_change, 'master', 'pg_cluster_test']
  Traceback (most recent call last):
    File "/usr/lib/python3.6/site-packages/patroni/postgresql/cancellable.py", line 30, in _start_process
      self._process = psutil.Popen(cmd, *args, **kwargs)
    File "/usr/lib64/python3.6/site-packages/psutil/__init__.py", line 1429, in __init__
      self.__subproc = subprocess.Popen(*args, **kwargs)
    File "/usr/lib64/python3.6/subprocess.py", line 729, in __init__
      restore_signals, start_new_session)
    File "/usr/lib64/python3.6/subprocess.py", line 1364, in _execute_child
      raise child_exception_type(errno_num, err_msg, err_filename)
  PermissionError: [Errno 13] Permission denied: '/etc/patroni/callbacks/callbacks.sh'
  2023-04-12 16:12:28 +0800 INFO: no action. I am (node31), the leader with the lock
  2023-04-12 16:12:38 +0800 INFO: no action. I am (node31), the leader with the lock
