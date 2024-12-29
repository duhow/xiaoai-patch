#!/bin/sh

LIBC_VERSIONS=$(find $ROOTFS/lib -name 'libc-*.so' -type f -exec basename {} \; | cut -d '-' -f2 | sort -n -r)
LIBC_NEW=$(echo $LIBC_VERSIONS | awk '{print $1}')
LIBC_OLD=$(echo $LIBC_VERSIONS | awk '{print $2}')

if [ "$LIBC_NEW" = "$LIBC_OLD" ]; then
  echo "[*] Found unique libc version $LIBC_NEW, skipping."
  exit
fi

if [ "${MODEL}" = "lx01" ] ; then
  echo "[!] Fixing libs for ${MODEL}"
  # NOTE: this cannot be done in build package process
  # as generates issues with gcc builds of multiple programs (glibc -> gcc, openssl)

  FILE="libgcc_s.so"
  LIB_TARGET="$ROOTFS/usr/lib/${FILE}"
  rm -vf ${LIB_TARGET}
  ln -svf ${FILE}.1 ${LIB_TARGET}

  # this file is old, the new one is in /lib
  FILE="libuuid.so.1.3.0"
  LIB_TARGET="$ROOTFS/usr/lib/${FILE}"
  rm -vf ${LIB_TARGET}
  ln -svf ../../lib/${FILE} ${LIB_TARGET}

  for FILE in libc libpthread ; do
    LIB_TARGET="$ROOTFS/usr/lib/${FILE}.so"
    rm -vf ${LIB_TARGET}
    ln -svf ../../lib/${FILE}-${LIBC_NEW} ${LIB_TARGET}
  done
fi

if [ -z "$LIBC_OLD" ]; then
  echo "[*] libc not found (musl?), skipping."
  exit
fi

echo "[!] Replacing libc version $LIBC_OLD by $LIBC_NEW"
for FILE in $ROOTFS/lib/*${LIBC_OLD}; do
  rm -f $FILE
  FILENAME=$(basename $FILE)
  NEW_FILENAME=$(echo $FILENAME | sed "s/${LIBC_OLD}/${LIBC_NEW}/")
  ln -svf $NEW_FILENAME $ROOTFS/lib/$FILENAME
done
