# Littleboxes

This is a tool to manage local VMs running with QEMU/KVM.

It was initially written for educational purposes, but the
author (@jpetazzo) uses this to manage local development
machines.


## Prerequirements

You need the following dependencies:

| Dependency        | Binary               | Debian/Ubuntu package | ArchLinux package |
| ------------------|----------------------|-----------------------|-------------------|
| qemu              | `qemu-system-x86_64` |                       | `qemu`            |
| VDE               | `vde_switch`         |                       | `vde2`            |
| Cloud Init helper | `cloud-localds`      |                       | `cloud-utils`     |
| tmux              | `tmux`               | `tmux`                | `tmux`            |
| socat             | `socat`              | `socat`               | `socat`           |


## Installation

1. Make sure that you have the dependencies listed above.
2. Clone this repository anywhere.
3. (Optionally) create a symlink to the `lbx` script in your `$PATH`.

For instance:

```bash
cd ~
git clone https://github.com/jpetazzo/littleboxes
sudo ln -s $PWD/littleboxes/lbx /usr/local/bin
```

**DO NOT** copy the script to your path!
Make sure to create a symlink instead.

The `lbx` script will find out the target of the symlink, and `cd`
to that directory when running. It will create VM images and disks there.


## Getting started

After `lbx` is in your path, you can do:

```bash
lbx pull xenial
lbx create xenial node1
lbx create xenial node2
lbx start node1
lbx start node2
lbx attach node1
lbx ssh node1
```

Login and password are `ubuntu`. VMs should have outbound network
access. The VMs are also connected by a private network (using VDE)
but it's not configured (yet).


## SSH proxy

If you want to use SSH transparently with your VMs, 
and add this to your `~/.ssh/config` file:

```
Host *.lbx
  ProxyCommand lbx sshproxy %h
```

Then you can do e.g. `scp foo.conf ubuntu@node1.lbx:`.

**Note:** this requires the `lbx` script to be in your path.


## Tweaking

You can edit the `cloud-init` file to specify a custom
Cloud Init payload. (For instance, you might want to change
the SSH public key that's in there, since it's mine, and
put yours instead.)


## Internals

Images are stored in `images`, VMs are stored in `vms`.

Each image and each VM has its own directory.

For VMs and images, the directory contains the following files:

- `hda`: QCOW3 disk image

For VMs, the directory also contains the following additional files:

- `hdb`: Cloud Init payload 
- `threebytes`: three random bytes
- `run.sh`: script starting the VM
- `pid`: PID file for the QEMU process

The three bytes in the `threebytes` file are used to generate
the MAC address of the VM A SSH redirection is also setup on 127.X.Y.Z:22222 (and used by the `lb ssh` command).


## TODO

- find a way to setup the internal network
  - some cloud init wizardry?
  - also, pre-allocate addresses, or DHCP appliance?
