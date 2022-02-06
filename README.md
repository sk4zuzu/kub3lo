SIMPLE K3S HA CLUSTER DEPLOYMENT (ANSIBLE)
==========================================

## 1. PURPOSE

Just a devops exercise.

To pre-create a pool of VMs for `kub3lo` you can try [sk4zuzu/vm-pool](https://github.com/sk4zuzu/vm-pool.git) :ok\_hand:.

## 2. REUSE CLUSTER NODE AS A BASTION

Let's say we want to reuse `k3a1` (10.44.2.10) as a bastion host `b1` (please note, `k3a1` cannot be used directly):

```dosini
[all:vars]
cluster_name=k3
ansible_user=alpine
ansible_python_interpreter=/usr/bin/python3

[bastion]
b1 ansible_host=10.44.2.10

[master]
k3a1
k3a2
k3a3

[compute]
k3b1
k3b2
k3b3
```
