#!/bin/bash

set -e

# Variables
: ${TARGET:="/data"}

# Helpers
function join { local IFS="$1"; shift; echo "$*"; }

function cleanup {
    if [ -z "$TRAPPED" ]; then
        echo "Unmounting ${TARGET}"
        TRAPPED=1
        umount -l ${TARGET}
    fi
}

# Fetch monitor IP's
MON_HOSTS=$(etcdctl ls /ceph-config/ceph/mon_host)
MON_IPS=$(for h in ${MON_HOSTS}; do  etcdctl get $h; done)
MOUNT_SRC=$(join , $MON_IPS)

# Ensure prefix exists
if [ ! -z "$PREFIX" ]; then
    echo "Creating /${PREFIX}"
    mkdir -p /mnt/control
    mount -v -t ceph $MOUNT_SRC:/ /mnt/control
    mkdir -p /mnt/control/$PREFIX
    umount /mnt/control
fi

# Do the actual mount
echo "Mounting ${TARGET}"
mount -v -t ceph -o noatime,nodiratime $MOUNT_SRC:/$PREFIX ${TARGET}

if [ ! -z "$WAIT" ]; then
    echo "Trapping cleanup on exit"
    unset TRAPPED
    trap cleanup INT TERM KILL EXIT
fi

if [ ! -z "$UID" -a "$UID" != "0" ]; then
    echo "Changing owner to $UID"
    chown -R ${UID} ${TARGET}
fi
if [ ! -z "$GID" -a "$GID" != "0" ]; then
    echo "Changing group to $GID"
    chgrp -R ${GID} ${TARGET}
fi

# Wait until termination
if [ ! -z "$WAIT" ]; then
    # Now sleep a long time
    echo "Waiting for termination"
    while [ -z "$TRAPPED" ]
    do
        sleep 360000000 &
        BACKGROUND=$!
        wait $BACKGROUND
    done
fi
