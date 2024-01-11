#!/bin/bash

# exit on error
set -e
trap 'cleanup' ERR

generate_dockerfile() {
cat << EOF
FROM scratch
LABEL org.opencontainers.image.version=${ROOT_VERSION}
LABEL org.opencontainers.image.revision=${ROOT_COMMIT}
LABEL org.opencontainers.image.created=${ROOT_DATE}
LABEL org.opencontainers.image.source=${SOURCE}
LABEL org.opencontainers.image.base.digest=${FILE_MD5}
LABEL com.xiaomi.channel=${ROOT_CHANNEL}
LABEL com.xiaomi.model=${ROOT_MODEL}

COPY / /
EOF
}

mico_opt() {
  OPTION="$1"
  SPLIT="$2"
  FILE="$3"
  for N in mico_version version lx01_version; do
    [ -z "$FILE" ] && [ -e "$N" ] && FILE="$N"
  done
  [ -z "$SPLIT" ] && SPLIT=3

  grep "option ${OPTION}" "${FILE}" | awk "{print \$${SPLIT}}" | tr -d "'"
}

cleanup() {
  set -x
  cd "${OLDPWD}"
  sudo rm -rf "${WORKDIR}"
}

REGISTRY=ghcr.io
REPO=duhow/xiaoai-patch

SOURCE="$1"
if [[ $SOURCE != https://* ]]; then
  echo "[!] Invalid input, provide download URL."
  exit 1
fi

OLDPWD=`pwd`
WORKDIR=`mktemp -d`
FILE=`basename "${SOURCE}"`
SQUASHDIR="squashfs-root"

# start --------
cd ${WORKDIR}

echo "[*] Downloading file"
wget "${SOURCE}" 

FILE_MD5=`md5sum $FILE | awk '{print $1}'`
FILE_MD5_SHORT=${FILE_MD5: -5}
echo "[*] MD5: ${FILE_MD5}"

echo "[*] Validating and extracting update file"
${OLDPWD}/mico_firmware.py -e ${FILE} || exit 1

NEW_FOLDER=`basename $(find . -mindepth 1 -type d)`

cd "${NEW_FOLDER}"

echo "[*] Extracting squashfs"

SQUASHFILE=""
for N in root.squashfs rootfs.img; do
  [ -e "$N" ] && SQUASHFILE=$N
done
sudo unsquashfs -d ${SQUASHDIR} ${SQUASHFILE}

# extract info
ROOT_MODEL=`mico_opt HARDWARE`
ROOT_CHANNEL=`mico_opt CHANNEL`
ROOT_VERSION=`mico_opt ROM`
ROOT_BUILDTS=`mico_opt BUILDTS`
ROOT_DATE=`date -d @${ROOT_BUILDTS} --utc --iso-8601=seconds`
ROOT_COMMIT=`mico_opt GTAG 4`

generate_dockerfile > Dockerfile

echo "[*] Image to generate"
cat Dockerfile

IMAGE_TAGS="${FILE_MD5} ${FILE_MD5_SHORT} ${ROOT_VERSION}"
IMAGE_NAME=`echo "${REGISTRY}/${REPO}/${ROOT_MODEL}" | tr '[:upper:]' '[:lower:]'`

OPT_TAG=""

for N in $IMAGE_TAGS; do
  OPT_TAG="${OPT_TAG} -t ${IMAGE_NAME}:${N}"
done

cd ${SQUASHDIR}
docker buildx build --push --no-cache ${OPT_TAG} . -f ../Dockerfile

cleanup
