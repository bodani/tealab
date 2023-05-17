
import time
import etcd3
from tenacity import retry, wait_random

class Etcd3ClientHelper(object):

    def __init__(self,endpoints,ca_cert,cert_key,cert_cert,timeout=10): 
        self._endpoints = endpoints.split(",")
        self._ca_cert = ca_cert
        self._cert_key = cert_key
        self._cert_cert = cert_cert
        self._timeout = timeout
        # self._user = user
        # self._password = password
        self._current_endpoint = self._endpoints[0]


    def get_etcd3_client(self):
        client = None
        try:
            host = self._current_endpoint.split(":")[0]
            port = self._current_endpoint.split(":")[1]
            # print("host %s: port %s" % (host,port))
            print("try: %s" % self._current_endpoint)
            client = etcd3.client(host=host, port=port, ca_cert=ca_cert, cert_key=cert_key, cert_cert=cert_cert, timeout=None, user=None, password=None, grpc_options=None)
            # ?? 如何判断client 是否可用
            client.get("/")
            # client
         
        except Exception as e:
            print(e)
            client = None
        return client

    @retry(wait=wait_random(min=5, max=10))
    def client(self):  
        client = self.get_etcd3_client()
        # 故障转移
        if client is None:
            cache_members = []
            for endpoint in  self._endpoints:
                if self._current_endpoint == endpoint:
                    continue
                self._current_endpoint = endpoint
                client = self.get_etcd3_client()
                if client is not None:
                    for mem in client.members:
                        cache_members.append(mem.client_urls[0].split("//")[1])
                    break
            # all members can't connect
            if client is None:
               raise Exception
            self._endpoints = cache_members
        return client

if __name__ == '__main__':
    endpoints= "10.10.2.10:2379,10.10.11.11:2379,10.10.11.12:2379,10.10.11.13:2379"
    ca_cert = '/etc/ssl/certs/tealabs/etcd001/ca.pem'
    cert_key = '/etc/ssl/certs/tealabs/etcd001/client-key.pem'
    cert_cert = '/etc/ssl/certs/tealabs/etcd001/client-crt.pem'
    etc_helper = Etcd3ClientHelper(endpoints,ca_cert,cert_key,cert_cert)

    while True:
       
        print("do ============================ @ %s" % time.strftime("%Y-%m-%d %H:%M:%S",time.localtime()))
        client = etc_helper.client()
        # s = client.status
        print("current_point: %s" , etc_helper._current_endpoint)
        print("cache_members: %s", etc_helper._endpoints)
        # print(client)
        # etcd = etcd3.client(host='10.10.2.11', port=2379, ca_cert=ca_cert, cert_key=cert_key, cert_cert=cert_cert, timeout=None, user=None, password=None, grpc_options=None)

        client.put('/pay/bar', 'doot',client.lease(ttl=1))
        print(client.get('/pay/bar')[0])
        time.sleep(3)
        print(client.get('/pay/bar')[0])