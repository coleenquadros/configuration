# Running a Quay Smoke Test

Quay's critical function is to be able to push and pull images. A basic smoke test is pushing and pulling an image from Quay.

## Prerequisites 

- A docker or podman installation
- A quay.io account

## Steps

1. Pull an image from another source, ie. `nginx`, `podman pull docker.io/library/nginx`
2. Tag the image with the Quay hostname `podman tag docker.io/library/nginx quay.io/youraccount/nginx`
3. Log into quay.io, use Redhat credentials when prompted `podman login quay.io`
4. Push the image to quay.io `podman push quay.io/youraccount/nginx`
5. Remove the local images `podman rmi docker.io/library/nginx quay.io/youraccount/nginx`
6. Pull the remote image `podman pull quay.io/youraccount/nginx`
