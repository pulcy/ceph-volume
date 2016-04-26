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

# Do the actual mount
echo "Mounting ${TARGET}"
mount -t ceph $MOUNT_SRC:/$PREFIX ${TARGET}

function cleanup {
    if [ -z "$TRAPPED" ]; then
        echo "Unmounting ${TARGET}"
        TRAPPED=1
        umount ${TARGET}
    fi
}

# Wait until termination
if [ ! -z "$WAIT" ]; then
    unset TRAPPED
    trap cleanup INT TERM KILL EXIT
    # Now sleep a long time
    while [ -z "$TRAPPED" ]
    do
        sleep 360000000 &
        BACKGROUND=$!
        wait $BACKGROUND
    done
fi
