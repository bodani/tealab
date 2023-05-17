# -*- coding: utf-8 -*-
"""
pip install --upgrade pip           # upgrade pip to at least 20.3
pip install "psycopg[binary]"
"""

"""
create table TEST_TABLE(id int, ts timestamp,info text);
"""

from psycopg import OperationalError
import time
import psycopg

def show_message(conn):
    # 获得游标对象
    cur = conn.cursor()
    # sql语句
    sql = "SELECT VERSION(), pg_is_in_recovery(),inet_server_addr(),now()"
    # 执行语句
    cur.execute(sql)
    # 获取单条数据.
    row = cur.fetchone()
    # 打印结果
    print("version: %s " % (row[0]))
    print("master : %s , server_ip : %s , time: %s " % (row[1]==False,row[2],row[3]))

def pg_connetion(conn_attrs):
    try:
        conn = psycopg.connect(dbname="pgdb",host="10.1.8.31,10.1.8.32,10.1.8.33", user="pguser", password="123456", port="5432", target_session_attrs=conn_attrs)
        conn.autocommit=True
    except OperationalError :
        time.sleep(2)
    return conn


def pg_insert(conn,id):
    try:
         # 获得游标对象
        cur = conn.cursor()
        # sql语句
        sql = "insert into TEST_TABLE(id,ts ,info ) values ( %s,now(),'hello')" % (id) 
        cur.execute(sql)
        print("%d insert success!!" % id)
    except Exception as e :
       print("Insert data Error !!!", e)
       time.sleep(3)

def pg_query(conn):
    try:
        # 获得游标对象
        cur = conn.cursor()
        # sql语句
        sql = "SELECT id, ts,info FROM TEST_TABLE order by ts desc limit 1"
        cur.execute(sql)
        # 获取单条数据.
        row = cur.fetchone()
        # 打印结果
        print(row[0],row[1],row[2])
       
    except Exception as e:
       print("Query data Error !!!",e)
       time.sleep(3)

def close_connection(conn):
    # 关闭数据库连接
    conn.close()


"""
 在故障转移后，自动连接到新主节点。
"""
if __name__ == '__main__':

    for i in range(1,30000):
        try:
            print("=========================== write =============================")
            conn = pg_connetion("read-write") # read-write 、 any
            # 当前连接服务信息
            show_message(conn)
            # 插入数据
            pg_insert(conn,i)
            # 查询最后插入的数据
            pg_query(conn)
            close_connection(conn)
            time.sleep(1)
        except Exception as e:
            print("Oops! id : %d fail. Retry a moment later" % i ,e)
            time.sleep(3)



