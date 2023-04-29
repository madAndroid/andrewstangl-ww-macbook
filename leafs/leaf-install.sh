#!/usr/bin/env bash

# Utility to install software and configuring Ubuntu to run k8s
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] " >&2
    echo "This script will install software and configuring Ubuntu to run k8s" >&2
}

function args() {
  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--debug") set -x;;
               "-h") usage; exit;;
           "--help") usage; exit;;
               "-?") usage; exit;;
        *) if [ "${arg_list[${arg_index}]:0:2}" == "--" ];then
               echo "invalid argument: ${arg_list[${arg_index}]}" >&2
               usage; exit
           fi;
           break;;
    esac
    (( arg_index+=1 ))
  done
}

args "$@"

export PATH=$PATH:/usr/local/bin
export HOME=/root

echo "Updating system packages & installing required utilities"
apt-get update
apt-get install -y ca-certificates curl jq iproute2 git unzip apt-transport-https gnupg2 vim

curl -s https://fluxcd.io/install.sh | bash

echo "$(hostname -I | awk '{print $2}') $(hostname)" >> /etc/hosts

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

# only needed to set up multicast on Equinix
cat <<EOF | tee /etc/modules-load.d/gre.conf
ip_gre
EOF

modprobe overlay
modprobe br_netfilter
modprobe ip_gre

# sysctl params required by setup, params persist across reboots
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sysctl --system

systemctl stop apparmor
systemctl disable apparmor 

# Install containerd
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y containerd.io 

# Generate and save containerd configuration file to its standard location
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# Restart containerd to ensure new configuration file usage:
systemctl restart containerd

# Verify containerd is running.
systemctl status containerd | head -5

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

apt update
apt -y install kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet
