# ceph-volume

This container is a helper to mount ceph volumes onto a system without need for all ceph binaries to be on the system.

The ceph monitor IP's are fetched from etcd. It assumes that the data is put there by ceph-docker (with KV_TYPE=etcd).

Note. etcdctl is required by this container. You must map it into the container using a volume map.

## Usage

```
docker run -it --net=host --privileged \
    -v /media/ceph:/data:shared \
    -v /usr/bin/etcdctl:/usr/bin/etcdctl \
    pulcy/ceph-volume:latest
```

## Prefix

If you want to mount a subdirectory of the ceph filesystem, set the PREFIX environment variable.
The container will then first mount the ceph filesystem (at root) and ensure the subdirectory exists, after which
the subdirectory itself is mounted.

```
docker run -it --net=host --privileged -e PREFIX=mysubdir \
    -v /hostmount:/data:shared \
    -v /usr/bin/etcdctl:/usr/bin/etcdctl \
    pulcy/ceph-volume:latest
```

## Mountpoint

By default the ceph filesystem is mounted on `/data`. To customize this, set a `TARGET` environment variable.

```
docker run -it --net=host --privileged -e TARGET=/foo \
    -v /hostmount:/foo:shared \
    -v /usr/bin/etcdctl:/usr/bin/etcdctl \
    pulcy/ceph-volume:latest
```

## Waiting

By default, ceph-volume will mount and then exit. If you set the WAIT environment variable to something non-empty,
it will wait until being terminated. Upon termination it will unmount the mounted volume.

```
docker run -it --net=host --privileged -e WAIT=1 \
    -v /hostmount:/data:shared \
    -v /usr/bin/etcdctl:/usr/bin/etcdctl \
    pulcy/ceph-volume:latest
```

## User, Group

If you need a specific user/group id set on the mounted files, use the UID=<id> and/or GID=<id> environment variable.

```
docker run -it --net=host --privileged -e UID=999 GID=999 \
    -v /hostmount:/data:shared \
    -v /usr/bin/etcdctl:/usr/bin/etcdctl \
    pulcy/ceph-volume:latest
```
