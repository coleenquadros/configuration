#!/bin/bash

docker_push() {
    docker --config="$DOCKER_CONF" push $1
}

IMAGE_NAME_APP_INTERFACE="quay.io/app-sre/app-interface"
IMAGE_NAME_NGINX_GATE="quay.io/app-sre/app-interface-nginx-gate"
IMAGE_TAG=$(git rev-parse --short=7 HEAD)

DOCKER_CONF="$PWD/.docker"
mkdir -p "$DOCKER_CONF"
docker --config="$DOCKER_CONF" login -u="$QUAY_USER" -p="$QUAY_TOKEN" quay.io

# build images
make build-app-interface build-nginx-gate

# tag images
docker --config="$DOCKER_CONF" tag $IMAGE_NAME_APP_INTERFACE:latest $IMAGE_NAME_APP_INTERFACE:$IMAGE_TAG
docker --config="$DOCKER_CONF" tag $IMAGE_NAME_NGINX_GATE:latest $IMAGE_NAME_NGINX_GATE:$IMAGE_TAG

# push images
docker_push "$IMAGE_NAME_APP_INTERFACE:latest"
docker_push "$IMAGE_NAME_APP_INTERFACE:$IMAGE_TAG"
docker_push "$IMAGE_NAME_NGINX_GATE:latest"
docker_push "$IMAGE_NAME_NGINX_GATE:$IMAGE_TAG"
