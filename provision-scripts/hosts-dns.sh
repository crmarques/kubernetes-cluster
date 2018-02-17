#! /bin/bash

sudo cat <<EOF >> /etc/hosts
192.168.1.100   k8s-master
192.168.1.101   k8s-node01
192.168.1.102   k8s-node02
EOF
