#!/bin/bash

## Minio Cloud Storage, (C) 2017 Minio, Inc.
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

for i in $(ls -d /sys/block/*/queue/iosched | grep -v 'sr' 2>/dev/null); do
    iosched_dir=$(echo $i | awk '/iosched/ {print $1}')
    [ -z $iosched_dir ] && {
        continue
    }
    ## Change each disk ioscheduler to be "deadline"
    ## Deadline dispatches I/Os in batches. A batch is a
    ## sequence of either read or write I/Os which are in
    ## increasing LBA order (the one-way elevator). After
    ## processing each batch, the I/O scheduler checks to
    ## see whether write requests have been starved for too
    ## long, and then decides whether to start a new batch
    ## of reads or writes
    path=$(dirname $iosched_dir)
    [ -f $path/scheduler ] && {
        echo "deadline" > $path/scheduler
    }
    ## This controls how many requests may be allocated
    ## in the block layer for read or write requests.
    ## Note that the total allocated number may be twice
    ## this amount, since it applies only to reads or
    ## writes (not the accumulate sum).
    [ -f $path/nr_requests ] && {
        echo "256" > $path/nr_requests
    }
    ## This is the maximum number of kilobytes
    ## supported in a single data transfer at
    ## block layer.
    [ -f $path/max_sectors_kb ] && {
        echo "1024" > $path/max_sectors_kb
    }
done

#!/bin/bash
 
cat > sysctl.conf <<EOF
# maximum number of open files/file descriptors
fs.file-max = 4194303
 
# use as little swap space as possible
vm.swappiness = 1
 
# prioritize application RAM against disk/swap cache
vm.vfs_cache_pressure = 50
 
# minimum free memory
vm.min_free_kbytes = 1000000
 
# follow mellanox best practices https://community.mellanox.com/s/article/linux-sysctl-tuning
# the following changes are recommended for improving IPv4 traffic performance by Mellanox
 
# disable the TCP timestamps option for better CPU utilization
net.ipv4.tcp_timestamps = 0
 
# enable the TCP selective acks option for better throughput
net.ipv4.tcp_sack = 1
 
# increase the maximum length of processor input queues
net.core.netdev_max_backlog = 250000
 
# increase the TCP maximum and default buffer sizes using setsockopt()
net.core.rmem_max = 4194304
net.core.wmem_max = 4194304
net.core.rmem_default = 4194304
net.core.wmem_default = 4194304
net.core.optmem_max = 4194304
 
# increase memory thresholds to prevent packet dropping:
net.ipv4.tcp_rmem = "4096 87380 4194304"
net.ipv4.tcp_wmem = "4096 65536 4194304"
 
# enable low latency mode for TCP:
net.ipv4.tcp_low_latency = 1
 
# the following variable is used to tell the kernel how much of the socket buffer
# space should be used for TCP window size, and how much to save for an application
# buffer. A value of 1 means the socket buffer will be divided evenly between.
# TCP windows size and application.
net.ipv4.tcp_adv_win_scale = 1
 
# maximum number of incoming connections
net.core.somaxconn = 65535
 
# maximum number of packets queued
net.core.netdev_max_backlog = 10000
 
# queue length of completely established sockets waiting for accept
net.ipv4.tcp_max_syn_backlog = 4096
 
# time to wait (seconds) for FIN packet
net.ipv4.tcp_fin_timeout = 15
 
# disable icmp send redirects
net.ipv4.conf.all.send_redirects = 0
 
# disable icmp accept redirect
net.ipv4.conf.all.accept_redirects = 0
 
# drop packets with LSR or SSR
net.ipv4.conf.all.accept_source_route = 0
 
# MTU discovery, only enable when ICMP blackhole detected
net.ipv4.tcp_mtu_probing = 1
 
EOF
 
echo "Enabling system level tuning params"
sysctl --quiet --load sysctl.conf && rm -f sysctl.conf
 
# `Transparent Hugepage Support`*: This is a Linux kernel feature intended to improve
# performance by making more efficient use of processor’s memory-mapping hardware.
# But this may cause https://blogs.oracle.com/linux/performance-issues-with-transparent-huge-pages-thp
# for non-optimized applications. As most Linux distributions set it to `enabled=always` by default,
# we recommend changing this to `enabled=madvise`. This will allow applications optimized
# for transparent hugepages to obtain the performance benefits, while preventing the
# associated problems otherwise. Also, set `transparent_hugepage=madvise` on your kernel
# command line (e.g. in /etc/default/grub) to persistently set this value.
 
echo "Enabling THP madvise"
echo madvise | sudo tee /sys/kernel/mm/transparent_hugepage/enabled