# Jenkins disk space cleanup steps
## Example alert
```
Device /dev/vda1 of node 10.0.132.76:9100 will be full within the next 24 hours.
```

## Connect to the node
- (optional) Was pretty sure this was Jenkins, but just to verify vs blindly sshing:
```
$ egrep -l 10.0.132.76 ansible/hosts/host_vars/*
ci-int-jenkins-node-02-uhc
prometheus.centralci.devshift.net
```
- Be on the RedHat network and ssh into the node

## Check node state
- Validate what's eating up the disk, verify if it's (probably) Jenkins related
  stale build artifacts:
```
$ df -h /
/dev/vda1        60G   52G  8.3G  87% /

$ du -hsc /var/lib/* | egrep G
1.7G    docker
46G    jenkins
48G    total

$ du -hsc /var/lib/jenkins/.local/share/containers/storage/vfs/dir
31G    total
```

## Become The Jenkins and prune stale build leftovers
```
$ sudo su - jenkins
```
- A number of builds user buildah/podman which by default uses the
  $HOME/.local/share/containers/storage path for caching non-root builds
- Check for active Docker activity via podman
  - If something is running, we'd want to just be cautious about tampering with
    running dependencies
- Verify what images are out there
  - May be a large list and may take a second or two to resolve

```
$ podman ps -a
CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES

$ podman container ls -a
CONTAINER ID  IMAGE  COMMAND  CREATED  STATUS  PORTS  NAMES

$ podman image list -a
REPOSITORY                                     TAG      IMAGE ID       CREATED          SIZE
quay.io/app-sre/ocm-clusters-service-sandbox   227      9f05f5b02d4c   11 minutes ago   303 MB
<none>                                         <none>   dc32adcb8370   11 minutes ago   303 MB
{snip}
```
- In this case, podman returned many any images, along with when they were created
- This can be helpful, if you need to further troubleshoot a sudden significant
  spike in disk utilization, as to what may have caused it and when
- It should then be safe to prune un-used images. These will be images not tied
  to a running container or "dangling" (images un-associated with any defined
  container).
- Active/In-use images can only be purged with --force parameters

```
$ podman image prune -a
{snip: many image hashes, after several seconds}
```
- If there hasn't been a clean up in a while, this can take several seconds.
  - Relax. Brew some tea. Work on crafting a new SOP doc! etc.
- If you get following error

```
$ podman image prune -a
Error: failed to prune image: Image used by 90b9fa5820c4f1a050ce1bd00f937a5cc63a5e3e4b08a52cf0333a8d9eb45f94: image is in use by a container
```

then you need to use `buildah` for cleanup.

```
$ buildah containers -a
$ buildah images -a
$ buildah rm -a && buildah rmi -a
$ podman system prune -a && podman image prune -a
```

## Verify cleanup
- Check image list and disk usage
```
$ podman image list
REPOSITORY                                     TAG   IMAGE ID       CREATED          SIZE
quay.io/app-sre/ocm-clusters-service-sandbox   227   9f05f5b02d4c   40 seconds ago   303 MB
docker.io/library/centos                       7     67fa590cfc1c   2 months ago     210 MB

$ df -hl  /
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        60G   22G   38G  37% /

$ du -hsc ~/.local/share/containers/
1.1G  /var/lib/jenkins/.local/share/containers/
1.1G  total
```
- Verify alert has resolved, usually within 5-10 minutes
