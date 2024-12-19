#!/bin/sh

PROFILE_DIR=$ROOTFS/etc/profile.d
mkdir -p $PROFILE_DIR

create_profile_script() {
  local filename="${PROFILE_DIR}/$1"
  local newpath=$2

  cat << EOF > $filename
#!/bin/sh
export PATH=\$PATH:$newpath
EOF
  chmod +x $filename
}

PYTHON_BIN=$(find $ROOTFS/usr/bin -name "python3.*" -type f | grep -v config | head -n 1)

if [ -n "$PYTHON_BIN" ]; then
  PYTHON_VERSION=3.$(basename $PYTHON_BIN | awk -F '.' '{print $2}')

  echo "[*] Creating profile.d script for Python ${PYTHON_VERSION} site-packages bin folder"

  SITE_PACKAGES_BIN="/usr/lib/python${PYTHON_VERSION}/site-packages/bin/"
  create_profile_script python-site-packages-bin.sh $SITE_PACKAGES_BIN
fi

#mkdir -p $ROOTFS/root/.local
#ln -svf /data/bin $ROOTFS/root/.local/bin
#create_profile_script root-bin.sh /root/.local/bin