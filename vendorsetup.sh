#
# vendorsetup.sh untuk X625D di manifest fox_12.1 (test R12).
# Wiki OrangeFox: variabel FOX_* WAJIB di script/export, tidak terbaca dari .mk.
# OF_* boleh di .mk, tapi dikumpulkan di sini agar satu pintu dengan 12.1.
#

FDEVICE="X625D"

fox_get_target_device() {
  if echo "$BASH_SOURCE" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif set | grep BASH_ARGV | grep -w \"$FDEVICE\"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "${BASH_SOURCE[0]}" | grep -q "/$FDEVICE/"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  elif echo "$0" | grep -q "$FDEVICE"; then
      FOX_BUILD_DEVICE="$FDEVICE";
  fi
}

if [ -z "$1" -a -z "$FOX_BUILD_DEVICE" ]; then
   fox_get_target_device
fi

if [ "$1" = "$FDEVICE" -o "$FOX_BUILD_DEVICE" = "$FDEVICE" ]; then
	export OF_MAINTAINER="X625D-unofficial"
	export FOX_MAINTAINER_PATCH_VERSION=1
	export FOX_BUILD_TYPE=Unofficial
	export FOX_USE_TWRP_RECOVERY_IMAGE_BUILDER=1
	export OF_NO_TREBLE_COMPATIBILITY_CHECK=1
	export OF_NO_MIUI_PATCH_AUTOFS=1
	export OF_NO_ADDITIONAL_MIUI_PROPS_CHECK=1
	export OF_DISABLE_MIUI_OTA_BY_DEFAULT=1
	export OF_QUICK_BACKUP_LIST="/boot;/recovery;/data;/system;/vendor;"
	export OF_HIDE_NOTCH=1
	export OF_CLOCK_POS=1
	export OF_SCREEN_H=1520
	export OF_STATUS_H=80
	export OF_STATUS_INDENT_LEFT=48
	export OF_STATUS_INDENT_RIGHT=48
	export OF_ALLOW_DISABLE_NAVBAR=0
	export FOX_USE_BASH_SHELL=1
	export FOX_ASH_IS_BASH=1
	export FOX_USE_TAR_BINARY=1
	export FOX_USE_SED_BINARY=1
	export FOX_USE_XZ_UTILS=1
	export FOX_RECOVERY_SYSTEM_PARTITION="/dev/block/platform/bootdevice/by-name/system"
	export FOX_RECOVERY_VENDOR_PARTITION="/dev/block/platform/bootdevice/by-name/vendor"
	export OF_USE_GREEN_LED=0
	export OF_PATCH_AVB20=1
	export FOX_DELETE_AROMAFM=1
	export FOX_ENABLE_APP_MANAGER=1
	# Prebuilt kernel: lewati error NO KERNEL CONFIG di manifest 12.1
	export OF_FORCE_PREBUILT_KERNEL=1
	# Keymaster MT6765 versi 3.0 (lihat relink di BoardConfig.mk)
	export OF_DEFAULT_KEYMASTER_VERSION="3.0"
	# Hemat ukuran (limit recovery 32MB) - WAJIB paling akhir
	export FOX_DRASTIC_SIZE_REDUCTION=1
else
	if [ -z "$FOX_BUILD_DEVICE" -a -z "$BASH_SOURCE" ]; then
		echo "I: This script requires bash. Not processing the $FDEVICE $(basename $0)"
	fi
fi

# Penjaga: file ini di-source oleh envsetup.sh di dalam step CI yang jalan
# dengan bash -e. Status nonzero terakhir akan menggugurkan step tepat
# setelah baris "including ... vendorsetup.sh". Paksa status 0.
true
