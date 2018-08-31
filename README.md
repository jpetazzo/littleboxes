# Littleboxes

This is a collection of scripts (well, just one script for now!) to
manage local VMs running with QEMU/KVM. It is purely for educational
purposes.


## Prerequirements

You need the following:
- QEMU
- VDE
- cloud-localds (ArchLinux package: "cloud-utils")
- tmux


## How to use

```bash
./lbx.sh pull xenial
./lbx.sh create xenial node1
./lbx.sh create xenial node2
./lbx.sh start node1
./lbx.sh start node2
tmux attach
```

Use `Ctrl-B X` (where `X` is a number) to switch between tmux tabs.
Login and password are `ubuntu`. VMs should have outbound network
access. The VMs are also connected by a private network (using VDE)
but it's not configured (yet).


## TODO

- find a way to setup the internal network
  - some cloud init wizardry?
  - also, pre-allocate addresses, or DHCP appliance?
- find a way to SSH to all machines
  - perhaps with a vde_plug to tap into the internal network
  - or a network appliance

