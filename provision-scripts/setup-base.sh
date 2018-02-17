#! /bin/bash

sudo su -

# update server
yum update -y

# disable firewall
systemctl disable firewalld

# disable SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux

# remove chrony and install ntp
yum remove chrony -y
yum install ntp -y
systemctl enable ntpd.service && systemctl start ntpd.service

# create repo file
cat <<EOF > /etc/yum.repos.d/virt7-docker-common-release.repo
name=virt7-docker-common-release
baseurl=http://cbs.centos.org/repos/virt7-docker-common-release/x86_64/os
gpgcheck=0
EOF

# install kubernetes, etcd and flannel
yum install -y --enablerepo=virt7-docker-common-release kubernetes etcd flannel

cat <<EOF > /etc/kubernetes/config
KUBE_LOGTOSTDERR="--logtostderr=true"
KUBE_LOG_LEVEL="--v=0"
KUBE_ALLOW_PRIV="--allow-privileged=false"
KUBE_MASTER="--master=http://k8s-master:8080"
EOF

HOSTNAME=$(hostname)
MY_IP=$(getent ahosts $HOSTNAME | grep RAW | grep -v '127.0.0.1' | sed 's/ RAW//g')
IFACE=$(ifconfig | grep -B1 $MY_IP | grep -o "^\w*")

cat <<EOF > /etc/sysconfig/flanneld
FLANNEL_ETCD_ENDPOINTS="http://k8s-master:2379"
FLANNEL_ETCD_PREFIX="/kube-centos/network"
FLANNEL_OPTIONS="--iface=$IFACE"
EOF
