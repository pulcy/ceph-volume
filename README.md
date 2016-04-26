# ceph-volume

This container is a helper to mount ceph volumes onto a system without need for all ceph binaries to be on the system.

The ceph monitor IP's are fetched from etcd. It assumes that the data is put there by ceph-docker (with KV_TYPE=etcd).

Note. etcdctl is required by this container. You must map it into the container using a volume map.

## Usage

```
docker run -it --net=host --privileged \
    -v /hostmount:/data:shared \
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
