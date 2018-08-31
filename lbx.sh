#!/bin/bash
#set -ex

_help="$(basename "$0") - a tool to manipulate little boxes"
_cmd () {
	COMMAND=$1
	HELP=$2
	_help=$(printf "%s\n%-10s\t%s" "$_help" "$COMMAND" "$HELP")
}

_cmd_ () {
	echo "$_help"
}

_check_image () {
	if [ ! -n "$1" ]; then
		echo "Specify image name"
		exit 1
	fi
	if [ "$2" = "exists" ]; then
		if [ ! -d images/$1 ]; then
			echo "Image $1 does not exist"
			exit 1
		fi
	fi
}

_check_vm () {
	if [ ! -n "$1" ]; then
		echo "Specify VM name"
		exit 1
	fi
	if [ "$2" = "exists" ]; then
		if [ ! -d vms/$1 ]; then
			echo "VM $1 does not exist"
			exit 1
		fi
	fi
}

_cmd pull "Pull a VM image"
_cmd_pull () {
	IMAGE=$1
	_check_image $IMAGE
	mkdir images/$IMAGE
	wget https://cloud-images.ubuntu.com/$IMAGE/current/$IMAGE-server-cloudimg-amd64-disk1.img -O images/$IMAGE/hda
}

_cmd create "Create a VM from an image"
_cmd_create () {
	IMAGE=$1
	VM=$2
	_check_image $IMAGE exists
	_check_vm $VM
	mkdir vms/$VM
	qemu-img create -f qcow2 -b ../../images/$IMAGE/hda vms/$VM/hda
	cloud-localds --disk-format qcow2 --hostname $VM vms/$VM/hdb cloud-init
	_cmd_config $VM
}

_cmd config "(Re)configure a VM"
_cmd_config () {
	VM=$1
	_check_vm "$VM" exists
	MAC=$(printf "52:54:00:%02x:%02x:%02x" $(($RANDOM%256)) $(($RANDOM%256)) $(($RANDOM%256)))
	cat >vms/$VM/run.sh <<EOF
#extra=,hostfwd=tcp:127.0.0.1:22001-:22
qemu-system-x86_64 -m 1024 -enable-kvm \
	-nographic \
	-pidfile vms/$VM/pid \
	-hda vms/$VM/hda -hdb vms/$VM/hdb \
	-device e1000,netdev=n01 \
	-netdev user,id=n01\$extra \
	-device e1000,netdev=n02,mac=$MAC \
	-netdev vde,id=n02
EOF
}

_cmd vde "Make sure that VDE is running"
_cmd_vde () {
	if [ ! -S /tmp/vde.ctl/ctl ]; then
		vde_switch -d
	fi
}

_cmd start "Start a VM"
_cmd_start () {
	VM=$1
	_check_vm "$VM" exists
	if [ -f vms/$VM/pid ]; then
		PID=$(cat vms/$VM/pid)
		if [ -d /proc/$PID ]; then
			echo "pid file exists and process exists"
			echo "the VM is already running?"
			exit 1
		fi
		echo "found pid file but process doesn't exist"
		rm vms/$VM/pid
	fi
	_cmd_vde
	tmux has-session || tmux new-session -d
	tmux new-window -d -n $VM sh vms/$VM/run.sh
	echo "VM started"
}

_cmd stop "Stop a VM"
_cmd_stop () {
	VM=$1
	_check_vm "$VM" exists
	if [ ! -f vms/$VM/pid ]; then
		echo "pid file not found"
		exit 1
	fi
	PID=$(cat vms/$VM/pid)
	if [ ! -d /proc/$PID ]; then
		echo "process doesn't seem to be running"
		exit 1
	fi
	kill $PID
	echo "Sent signal to stop VM"
}

_cmd lsi "List images"
_cmd_lsi () {
	ls images
}

_cmd lsv "List VMs"
_cmd_lsv () {
	ls vms
}

cmd=$1
fun=_cmd_$cmd
shift
$fun "$@"
