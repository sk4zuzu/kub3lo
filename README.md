SIMPLE RKE2/K3S HA CLUSTER DEPLOYMENT (ANSIBLE)
===============================================

## 1. PURPOSE

Just a devops exercise.

To pre-create a pool of VMs for `kub3lo` you can try: [sk4zuzu/vm-pool](https://github.com/sk4zuzu/vm-pool.git) :+1:.

You can find packer scripts that pre-create airgapped images for `kub3lo` here: [sk4zuzu/vm-pool/packer/kub3lo](https://github.com/sk4zuzu/vm-pool/tree/master/packer/kub3lo) :ok\_hand:.

## 2. DEPLOY A `rke2` CLUSTER (UBUNTU 25.04)

Edit `kub3lo.ini` file:

```dosini
[all:vars]
cluster_name=k2
ansible_user=ubuntu
ansible_python_interpreter=/usr/bin/python3
k8s_distro=rke2
kubevip_vip_interface=br0
kubevip_address=10.2.41.86

[bastion]
k2 ansible_host=10.2.41.10

[master]
k2a1
k2a2
k2a3

[compute]
k2b1
k2b2
k2b3
```

Run provisioning:

```shell
$ make
```

## 3. DEPLOY A `k3s` CLUSTER (ALPINE 3.22.2)

Edit `kub3lo.ini` file:

```dosini
[all:vars]
cluster_name=k3
ansible_user=alpine
ansible_python_interpreter=/usr/bin/python3
k8s_distro=k3s
kubevip_vip_interface=br0
kubevip_address=10.2.42.86

[bastion]
k3 ansible_host=10.2.42.10

[master]
k3a1
k3a2
k3a3

[compute]
k3b1
k3b2
k3b3
```

Run provisioning:

```shell
$ make
```
