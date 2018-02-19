#! /bin/bash

HOSTNAME=$(hostname)

cat <<EOF > /etc/kubernetes/kubelet
KUBELET_ADDRESS="--address=0.0.0.0"
KUBELET_PORT="--port=10250"
KUBELET_HOSTNAME="--hostname-override=$HOSTNAME"
KUBELET_API_SERVER="--api-servers=http://k8s-master:8080"
KUBELET_ARGS=""
EOF

for SERVICE in etcd kube-proxy kubelet flanneld docker
do
  systemctl restart $SERVICE
  systemctl enable $SERVICE
done

kubectl config set-cluster default-cluster --server=http://k8s-master:8080
kubectl config set-context default-context --cluster=default-cluster --user=default-admin
kubectl config use-context default-context
