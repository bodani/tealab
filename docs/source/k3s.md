# k3s 安装

## 节点规划

```
10.10.2.11
10.10.2.12
10.10.2.13

ubuntu 2204
```

## 安装前准备

```
apt-get update; apt-get install lvm2 bc curl nfs-common open-iscsi jq git net-tools telnet wget sysstat chrony -yq
apt install linux-generic-hwe-22.04
```

## 第一个节点

```
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -s - server  --cluster-init --flannel-backend=none --disable-network-policy --tls-san=10.10.2.11 --node-external-ip=10.10.2.11 --node-ip=10.10.2.11
````

```
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

设置 register 代理 

```
cat  <<EOF > /var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl 

[plugins.cri.containerd]
  snapshotter = "overlayfs"
  default_runtime_name = "crun"
  disable_snapshot_annotations = true

[plugins.cri.containerd.runtimes.crun]
  runtime_type = "io.containerd.runc.v2"

[plugins.cri.containerd.runtimes.crun.options]
  SystemdCgroup = true

[plugins.cri.containerd.runtimes.runc]
  runtime_type = "io.containerd.runc.v2"

[plugins.cri.containerd.runtimes.runc.options]
        SystemdCgroup = true

[plugins.cri.containerd.runtimes.runsc]
  runtime_type = "io.containerd.runsc.v1"

[plugins.cri.containerd.runtimes.runsc.options]
  SystemdCgroup = true
  TypeUrl = "io.containerd.runsc.v1.options"
  ConfigPath = "/var/lib/rancher/k3s/agent/etc/containerd/runsc.toml"
[plugins.cri.registry.mirrors]
[plugins.cri.registry.mirrors."docker.io"]
  endpoint = ["https://docker-mirror.drycc.cc", "https://registry-1.docker.io"]
[plugins.cri.registry.mirrors."quay.io"]
  endpoint = ["https://quay-mirror.drycc.cc", "https://quay.io"]
[plugins.cri.registry.mirrors."gcr.io"]
  endpoint = ["https://quay-mirror.drycc.cc", "https://gcr.io"]
[plugins.cri.registry.mirrors."k8s.gcr.io"]
  endpoint = ["https://k8s-mirror.drycc.cc", "https://registry.k8s.io"]
[plugins.cri.registry.mirrors."registry.k8s.io"]
  endpoint = ["https://k8s-mirror.drycc.cc", "https://registry.k8s.io"]

EOF
```

## 安装helm

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## 安装网络插件
```
helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version 1.15.5 \
    --set endpointHealthChecking.enabled=false \
    --set healthChecking=false \
    --set operator.replicas=1 \
    --set bpf.masquerade=true \
    --set bandwidthManager.enabled=true \
    --set bandwidthManager.bbr=true \
    --set kubeProxyReplacement=true \
    --set hubble.enabled=false \
    --set hostPort.enabled=true \
    --set k8sServiceHost=10.10.2.11 \
    --set k8sServicePort=6443 \
    --set prometheus.enabled=true \
    --set operator.prometheus.enabled=true \
    --namespace kube-system --wait
````

## 第二,三个节点

第一个节点的token
```
cat /var/lib/rancher/k3s/server/node-token
````
第二个节点
```
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://10.10.2.11:6443 K3S_TOKEN=K10d31ffb6e30642f0d4fda7279e58997d40a68f30685618a6f56db5ea432960018::server:fb98c000fbbfe9fa437a384e5c5320e1 sh -s - server --flannel-backend=none --disable-network-policy --tls-san=10.10.2.12 --node-external-ip=10.10.2.12 --node-ip=10.10.2.12
```

第三个节点
```
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://10.10.2.11:6443 K3S_TOKEN=K10d31ffb6e30642f0d4fda7279e58997d40a68f30685618a6f56db5ea432960018::server:fb98c000fbbfe9fa437a384e5c5320e1 sh -s - server --flannel-backend=none --disable-network-policy --tls-san=10.10.2.13 --node-external-ip=10.10.2.13 --node-ip=10.10.2.13
```

加入agent
```
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn K3S_URL=https://10.10.2.11:6443 K3S_TOKEN=K10d31ffb6e30642f0d4fda7279e58997d40a68f30685618a6f56db5ea432960018::server:fb98c000fbbfe9fa437a384e5c5320e1 sh -s agent --node-external-ip=10.10.2.14 --node-ip=10.10.2.14
```

## 存储

本机存储预备
```
pvcreate 
vgcreate 
```

存储插件
```
helm charts https://github.com/topolvm/topolvm/releases/download/topolvm-chart-v15.0.0/topolvm-15.0.0.tgz
```
```
kubectl label namespace kube-system topolvm.io/webhook=ignore
helm -n kube-system install topolvm ./topolvm --version 15.0.0 -f ./topolvm.yaml
```

vi  topolvm.yaml
```
scheduler:
  enabled: false

lvmd:
  deviceClasses:
  - name: ssd
    volume-group: ubuntu-vg
    default: true
    spare-gb: 10

webhook:
  podMutatingWebhook:
    enabled: false
  pvcMutatingWebhook:
    enabled: false

controller:
  replicaCount: 3
  podDisruptionBudget:
    enabled: false

podSecurityPolicy:
  create: false

priorityClass:
  enabled: true

storageClasses:
  - name: topolvm-ssd
    storageClass:
      fsType: xfs
      reclaimPolicy:
      annotations: {}
      isDefaultClass: true
      volumeBindingMode: WaitForFirstConsumer
      allowVolumeExpansion: true
      additionalParameters:
        "topolvm.cybozu.com/device-class": "ssd"

cert-manager:
  enabled: false
```

## 驱逐一个节点

```
kubectl drain node4 --ignore-daemonsets=true --delete-emptydir-data
```

## 服务迁移

通常指有状态的statefulset pod，既pv 的迁移。

场景如节点故障维护，pod

查看节点上存在的pv
```
#!/bin/bash

# 确保输入了节点名称
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <node-name>"
    exit 1
fi

NODE_NAME="$1"

# 获取在指定节点上运行的所有 Pod 及其命名空间
pods=$(kubectl get pods --all-namespaces -o jsonpath='{range .items[?(@.spec.nodeName=="'"$NODE_NAME"'")]}{.metadata.namespace}{" "}{.metadata.name}{"\n"}{end}')

# 遍历 Pod 列表，查找使用的 PVC
echo "Listing PVCs along with their namespaces and pods on node $NODE_NAME:"
echo "NAMESPACE POD_NAME PVC_NAME VOLUME_NAME"


while read -r pod_namespace pod_name; do
    # 获取 Pod 使用的 PVC 名称
    pvc_names=$(kubectl get pod "$pod_name" -n "$pod_namespace" -o jsonpath='{.spec.volumes[*].persistentVolumeClaim.claimName}')

    for pvc_name in $pvc_names; do
        # 如果 pvc_name 为空，则跳过
        [ -z "$pvc_name" ] && continue
        # 输出 PVC 信息以及它所在的命名空间和对应的 Pod 名称
        pvc_info=$(kubectl get pvc "$pvc_name" -n "$pod_namespace" -o jsonpath='{.metadata.name}{" "}{.spec.volumeName}{" "}')
        echo "$pod_namespace $pod_name $pvc_info"
    done
done <<< "$pods"
```

访问pv中的数据
```
---
apiVersion: v1
kind: Pod
metadata:
  name: my-busybox
spec:
  containers:
  - name: my-busybox-container
    image: busybox
    command:
      - sleep
      - "3600"
    volumeMounts:
    - name: my-volume
      mountPath: "/data"
  volumes:
  - name: my-volume
    persistentVolumeClaim:
      claimName: pvc-name-xxxxx
```

## 节点SchedulingDisabled

避免新pod 调度到 node上
```
kubectl cordon node4
```

```
服务主从切换
```

删除pod 既 pvc 
```
kuberctl delete pod xxxx
kuberctl delete pvc xxxx
```

将其他节点自动补齐新的pod，pv。pv的内容为空。

主要是利用服务集群的自身高可用特性恢复数据。过程是集群的缩容后在扩容。

## mysql cluster

进入管理pod ，连接到集群。
```
# 连接到集群
mysqlsh -uroot -h hb-mysql-cluster-standard-10-1 -p${MYSQL_ROOT_PASSWORD}
# 查看集群状态
dba.getCluster().status();
# 删除失联服务(缩容)
dba.getCluster().rescan();
# 加入新服务（扩容）
dba.getCluster().addInstance('hb-mysql-cluster-standard-10-0:3306');
```
## postges cluster

不需要干预，可自动缩容扩容
```
patronictl list
```

## mongo 
```
 mongosh -u root -p ${MONGODB_ROOT_PASSWORD}
 rs.status();
```

