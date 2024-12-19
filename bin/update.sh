#!/bin/sh
# version 0.1.0

OTA_GH_REPO="duhow/xiaoai-patch"
CONFIG=/data/ota.conf
DRY_RUN=0

[ -z "$SILENT" ] && SILENT=0
[ -e "$CONFIG" ] && source $CONFIG

SKIP_DOWNLOAD=0
GH_DOWNLOAD=0
OTA_FILE=""
[ -n "$OTA_URL" ] && OTA_FILE="/tmp/$(basename $OTA_URL)"
OTA_RL=/tmp/ota_release.json
OTA_ASSETS=/tmp/ota_assets.txt
MIN_MEMORY=45000

get_mico_version() { uci -c /usr/share/mico get version.version.$1; }
MODEL=$(get_mico_version HARDWARE)
MODEL_LCASE=$(echo "${MODEL}" | tr '[:upper:]' '[:lower:]')
ROM_VERSION=$(get_mico_version ROM)
BOOTPART="" # current boot partition
COMMANDS="wget grep awk tar md5sum dd tr jq"

echo_debug(){ [ "$DEBUG" = 1 ] && echo "[*] $@"; }
echo_error(){ echo "[!] $@"; }
fail(){ echo_error "$2"; exit $1; }
download_file() { wget -t3 -T30 -U "Mozilla/5.0 (X11; Linux arm) Chrome/128.0.0.0 ${MODEL}/${ROM_VERSION}" "$1" -O "$2" ; }
download_gh_asset() {
  update_ota_url_gh
  local asset=$(grep "$1" $OTA_ASSETS | awk '{print $1}')
  [ -z "$asset" ] && fail 1 "Asset $1 not found"
  wget -t3 -T30 --header="Accept: application/octet-stream" "${OTA_URL}/$asset" -O "$2"
}
update_ota_release_gh() { OTA_GH_RELEASE_URL="https://api.github.com/repos/${OTA_GH_REPO}/releases/${OTA_VERSION}" ; }
update_ota_url_gh() { OTA_URL="https://api.github.com/repos/${OTA_GH_REPO}/releases/assets" ; }
check_commands() {
  for cmd in $COMMANDS; do
    command -v $cmd >/dev/null || fail 1 "Command $cmd not found"
  done
}

set_boot() {
  if [ "$1" != "boot0" ] && [ "$1" != "boot1" ]; then return 1; fi

  if [ "$MODEL" = "LX01" ]; then
    write_misc -l ${1: -1}
  else
    # LX06 and others
    fw_env -s boot_part $1
  fi
}

switch_boot(){
  [ "$DRY_RUN" != 0 ] && return 0
  [ "$BOOTPART" = "boot0" ] && set_boot boot1
  [ "$BOOTPART" = "boot1" ] && set_boot boot0
}

get_boot_from_cmdline() {
  echo ""
  # TODO fill for LX01
}

get_boot_from_uboot() { strings /dev/nand_env | grep -e '^boot_part' | cut -d'=' -f2 ; }
get_boot_from_fwenv() { fw_env -g boot_part ; }

get_boot() {
  local boot=$(get_boot_from_fwenv)
  [ -z "$boot" ] && boot=$(get_boot_from_uboot)
  #[ -z "$boot" ] && boot=$(get_boot_from_cmdline)
  BOOTPART=$boot
  echo $boot
}

stop_processes() {
  local apps="mpd shairport-sync upmpdcli snapclient squeezelite"
  for app in $apps; do
    [ -e "/etc/init.d/$app" ] && {
      echo_debug "stopping $app"
      /etc/init.d/$app stop
    }
  done
}

# in kb
mem_available(){ grep MemAvailable /proc/meminfo | awk '{print $2}'; }

clean_memory() {
  stop_processes
  echo 3 > /proc/sys/vm/drop_caches
}

package_contains() { tar -tf ${OTA_FILE} "./$1" >/dev/null 2>&1 ; }
package_extract() { tar xf ${OTA_FILE} "./$1" -O ; }

set_target_partitions() {
  # $1 -> boot0/boot1, set the opposite partition

  if [ "$BOOTPART" = "boot0" ]; then
    mtdkrn=3
    mtdroot=5 # update sys1
  elif [ "$BOOTPART" = "boot1" ]; then
    mtdkrn=2
    mtdroot=4 # update sys0
  else
    echo "-----"
    fail 1 "Invalid boot partition: $BOOTPART"
  fi
}

flash_image(){
  local file=$1
  local mtd=$2

  if [ -z "$file" ] || [ -z "$mtd" ]; then
    fail 1 "Invalid parameters for flash_image"
  fi

  if [ "$file" != "-" ] && [ ! -f "$file" ]; then
    fail 1 "File $file not found"
  fi

  echo "Flashing $file to mtd$mtd"
  if [ "$DRY_RUN" = 0 ]; then
    mtd write "$file" /dev/mtd${mtd} || echo_error "Error flashing $file to mtd$mtd"
    # dd if=$file of=/dev/mtd$mtd
  fi
}

version_format(){ echo "$@" | awk -F. '{ printf("%d%03d%03d\n", $1,$2,$3); }'; }

verify_ota(){
  # PROCESS:
  # extract metadata (mico_version)
  # mico_version comes as a copy from original/built ROOTFS
  # add a "config core 'hash'" section with ROOTFS, LINUX
  # add as md5sum
  package_contains metadata || fail 1 "metadata not found in OTA package"
  OTATMP=`mktemp -d`
  package_extract metadata > ${OTATMP}/metadata

  check_package boot.img LINUX
  check_package root.squashfs ROOTFS
}

check_package(){
  local file=$1
  local section=$2

  if package_contains $file && ! compare_hash $file $section; then
    fail 1 "$file hash is invalid"
  fi
}

compare_hash(){
  local file=$1
  local opt=$2

  local HASH=`package_extract $file | md5sum | awk '{print $1}'`
  local CHASH=`uci -c ${OTATMP} get metadata.hash.$opt`
  if [ -z "$CHASH" ]; then
    echo_error "Hash for $file not found in metadata"
  fi
  echo_debug "Package hash: $HASH, Metadata hash: $CHASH"
  [ "$HASH" = "$CHASH" ] && return 0
  return 1
}

compare_version() {
  local opt=$1

  local VERSION=`get_mico_version $opt`
  local CVERSION=`uci -c ${OTATMP} get metadata.version.$opt`

  if [ -z "$CVERSION" ]; then
    echo_error "Version for $opt not found in metadata"
  fi
  echo_debug "$opt: Installed version: $VERSION, Package version: $CVERSION"
  [ "$VERSION" = "$CVERSION" ] && return 0
  return 1
}

get_latest_version() {
  rm -f $OTA_RL

  # check latest version from upstream repository
  # and get OTA URL based on actual version
  if [ -z "${OTA_URL}" ]; then
    OTA_VERSION="latest"
    update_ota_release_gh
    download_file "${OTA_GH_RELEASE_URL}" ${OTA_RL}

    OTA_VERSION=`jq -r .tag_name $OTA_RL`
    if [ -z "${OTA_VERSION}" ]; then
      fail 1 "OTA version request was invalid!"
    fi
    # extract ID asset and filename
    jq -r '.assets[] | "\(.id) \(.name)"' $OTA_RL > $OTA_ASSETS
    
    rm -f $OTA_RL
  fi

  download_gh_asset metadata.json $OTA_RL
  local model_available=$(jq -r --arg model "$MODEL_LCASE" '.models | index($model) != null' $OTA_RL)

  if [ "$model_available" != "true" ]; then
    fail 1 "Model ${MODEL} not available in version ${OTA_VERSION}"
    # TODO: provide lower alternative version in metadata
  fi

  OTA_FILE=$(jq -r --arg model "$MODEL_LCASE" '.files[$model].name' $OTA_RL)
  if [ -z "${OTA_FILE}" ]; then
    fail 1 "OTA file not found in metadata"
  fi

  # set path
  OTA_FILE="/tmp/${OTA_FILE}"
}


download_ota() {
  local file=`basename ${OTA_FILE}`
  if [ "$GH_DOWNLOAD" = 1 ]; then
    download_gh_asset $file $OTA_FILE
  # if URL ends with file, then it's a direct download
  elif [ "${OTA_URL: -${#file}}" = "$file" ]; then
    download_file "${OTA_URL}" ${OTA_FILE}
  else
    download_file "${OTA_URL}/${file}" ${OTA_FILE}
  fi

  if [ "$?" != 0 ]; then
    shut_led 10
    # delete empty file
    if [ -f "$OTA_FILE" ] && [ ! -s "$OTA_FILE" ]; then
      rm -f "$OTA_FILE"
    fi
    fail 2 "Error while downloading OTA image"
  fi

  if [ "${file:0:5}" != "mico_" ]; then
    echo_error "WARNING: file not mico standard, cannot check container integrity!"
    return
  fi

  local HASH=`md5sum $OTA_FILE | awk '{print $1}'`
  local FNHASH=$(echo $file | cut -d'_' -f3)
  local x="${#FNHASH}"

  if [ "${FNHASH}" != "${HASH:(-${x})}" ]; then
    fail 2 "OTA integrity does not match: $HASH != $FNHASH"
  fi
}

run_ota() {
  if [ "$SKIP_DOWNLOAD" = 1 ]; then
    MIN_MEMORY=5000
  fi

  if [ `mem_available` -lt $MIN_MEMORY ]; then
    clean_memory
    if [ `mem_available` -lt $MIN_MEMORY ]; then
      fail 1 "There's not enough memory to execute, closing."
    fi
  fi

  if [ "$SKIP_DOWNLOAD" = 0 ]; then
    if [ -z "${OTA_URL}" ]; then
      GH_DOWNLOAD=1
      get_latest_version
    fi

    if [ -n "${OTA_FILE}" ] && [ ! -f "/tmp/${OTA_FILE}" ]; then
      download_ota
    fi
  fi

  verify_ota

  get_boot
  set_target_partitions

  echo "Ok, updating system$((mtdroot - 4)) in few seconds..."

  sleep 5

  [ "$SILENT" = 0 ] && show_led 10

  if package_contains boot.img && ! compare_version LINUX; then
    echo "Flashing kernel..."
    package_extract boot.img | flash_image - $mtdkrn
  fi
  package_extract root.squashfs | flash_image - $mtdroot
  switch_boot

  [ "$DRY_RUN" != 0 ] && {
    echo "dry-run: OTA update completed."
    shut_led 10
    return
  }

  echo "rebooting..."
  sleep 2

  reboot
  shut_led 10
}

if [ -n "$1" ] && [ -f "$1" ]; then
  OTA_FILE=$1
  SKIP_DOWNLOAD=1
fi

run_ota