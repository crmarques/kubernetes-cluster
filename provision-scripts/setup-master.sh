#! /bin/bash

sudo su -

cat <<EOF > /etc/etcd/etcd.conf
ETCD_NAME=default
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_CLIENT=URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT=URLS="http://0.0.0.0:2379"
EOF

cat <<EOF > /etc/kubernetes/apiserver
KUBE_API_ADDRESS="--address=0.0.0.0"
KUBE_API_PORT="--port=8080"
KUBELET_PORT="--kubelet-port=10250"
KUBE_ETCD_SERVERS="--etcd-servers=http://k8s-master:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.254.0.0/16"
KUBE_API_ARGS=""
EOF

systemctl start etcd
etcdctl mkdir /kube-centos/network
etcdctl mk /kube-centos/network/config "{ \"Network\": \"172.30.0.0/16\", \"SubnetLen\": 24, \"Backend\": {\"Type\": \"vxlan\"} }"

for SERVICE in etcd kube-apiserver kube-controller-manager kube-scheduler flanneld
do
  systemctl restart $SERVICE
  systemctl enable $SERVICE
done
