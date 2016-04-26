#!/bin/bash

# Variables
: ${TARGET:="/data"}

# Helpers
function join { local IFS="$1"; shift; echo "$*"; }

# Fetch monitor IP's
MON_HOSTS=$(etcdctl ls /ceph-config/ceph/mon_host)
MON_IPS=$(for h in ${MON_HOSTS}; do  etcdctl get $h; done)
MOUNT_SRC=$(join , $MON_IPS)

# Ensure prefix exists
if [ ! -z "$PREFIX" ]; then
    mkdir -p /mnt/control
    mount -t ceph $MOUNT_SRC:/ /mnt/control
    mkdir -p /mnt/control/$PREFIX
    umount /mnt/control
fi

mount -t ceph $MOUNT_SRC:/$PREFIX ${TARGET}
