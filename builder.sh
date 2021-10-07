#!/bin/bash
#
set -x

[[ "$1" != "-" ]] && BRANCH="$1"
[[ "$BRANCH" == "-" ]] && BRANCH=dev

[[ "$BRANCH" == "main" ]] && TAG="latest" || TAG="$BRANCH"

PLATFORMS=linux/armhf,linux/arm64,linux/amd64
#PLATFORMS=linux/armhf,linux/arm64

# rebuild the container
pushd ~/git/modesfiltered
git checkout $BRANCH || exit 2
git pull

# make the build certs root_certs folder:
# Note that this is normally done as part of the github actions - we don't have those here, so we need to do it ourselves before building:
#ls -la /etc/ssl/certs/
#mkdir -p ./root_certs/etc/ssl/certs
#mkdir -p ./root_certs/usr/share/ca-certificates/mozilla
#mkdir -p ./rootfs/root

#cp -P /etc/ssl/certs/*.crt ./root_certs/etc/ssl/certs
#cp -P /etc/ssl/certs/*.pem ./root_certs/etc/ssl/certs
#cp -P /usr/share/ca-certificates/mozilla/*.crt ./root_certs/usr/share/ca-certificates/mozilla

#echo "$(git branch --show-current)_($(git rev-parse --short HEAD))_$(date +%y-%m-%d-%T%Z)" > rootfs/root/branch

#DOCKER_BUILDKIT=1 docker buildx build --progress=plain --compress --push $2 --platform $PLATFORMS --tag kx1t/planefence:$TAG .
# local build only:
DOCKER_BUILDKIT=1 docker buildx build --progress=plain --compress $2 --tag kx1t/modesfiltered:$TAG --load .
rm -rf ./root_certs ./rootfs/root
popd
