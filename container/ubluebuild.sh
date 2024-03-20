# cd /work
# sudo dnf update -y
# sudo dnf install git make -y
# git clone https://github.com/ublue-os/isogenerator
# cd isogenerator
# make install-deps

IMAGE_NAME=base-main
IMAGE_REPO=ghcr.io/ublue-os
IMAGE_TAG=${VERSION}
VERSION=39
ARCH=x86_64
VARIANT=Silverblue
WEB_UI=true

make output/${IMAGE_NAME}-${IMAGE_TAG}.iso \
  ARCH=${ARCH} \
  VERSION=${VERSION} \
  IMAGE_REPO=${IMAGE_REPO} \
  IMAGE_NAME=${IMAGE_NAME} \
  IMAGE_TAG=${IMAGE_TAG} \
  VARIANT=${VARIANT} \
  WEB_UI=${WEB_UI}


# make container/${IMAGE_NAME}-${VERSION} \
#           ARCH=${ARCH} \
#           IMAGE_NAME=${IMAGE_NAME} \
#           IMAGE_REPO=${IMAGE_REPO} \
#           IMAGE_TAG=${VERSION} \
#           VARIANT=${VARIANT} \
#           VERSION=${VERSION} \
#           WEB_UI=${WEB_UI}

#   make boot.iso \
#           ARCH=${ARCH} \
#           IMAGE_NAME=${IMAGE_NAME} \
#           IMAGE_REPO=${IMAGE_REPO} \
#           IMAGE_TAG=${VERSION} \
#           VARIANT=${VARIANT} \
#           VERSION=${VERSION} \
#           WEB_UI=${WEB_UI}