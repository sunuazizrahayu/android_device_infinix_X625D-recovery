#!/sbin/sh
# dfe_patch.sh - Matikan force-encrypt X625D otomatis di tiap boot OrangeFox.
# Latar: stock vendor fstab.mt6765 pakai forcefdeorfbe=.../metadata, sehingga
# system mengenkripsi ulang /data (FDE) setiap habis Format Data.
# FDE itu tidak bisa di-decrypt recovery ini (keymaster TEE microtrust
# menolak begin() dengan -1000), akibatnya /sdcard tidak terbaca.
# Script ini idempotent: hanya mengubah forcefdeorfbe= -> encryptable=
# kalau flag itu masih ada. Tidak pernah gagal (exit 0 selalu) agar
# tidak menghambat boot recovery.
# REVISI: patch VENDOR + SYSTEM (dulu cuma vendor). Alasan enkripsi balik lagi
# setelah boot system: fstab forcefdeorfbe ada di DUA tempat (vendor/etc/fstab.mt6765
# dan system/etc/fstab.mt6765 / ramdisk boot). Kalau cuma vendor yang dipatch,
# system boot tetap lihat force flag dari salinan system -> enkripsi ulang jalan lagi.
# Plus: OF_DONT_PATCH_ENCRYPTED_DEVICE=1 di fox_X625D.mk mematikan patcher bawaan
# OrangeFox, jadi script ini satu-satunya pertahanan - harus robust.
export PATH=/sbin:/system/bin:/vendor/bin
LOG=/tmp/dfe_patch.log
echo "--- dfe_patch jalan ---" >> $LOG 2>&1

patch_one() {
  # $1 = mount point sementara, $2 = block device, $3 = label log
  MNT=$1
  VDEV=$2
  LBL=$3
  mkdir -p $MNT
  # Kalau partisi sudah di-mount recovery (vendor/system auto-mount), jangan mount ulang
  if ! grep -q " $MNT " /proc/mounts 2>/dev/null; then
    if ! mount -t ext4 -o rw $VDEV $MNT >> $LOG 2>&1; then
      echo "$LBL: mount $VDEV gagal, lewati" >> $LOG 2>&1
      return 0
    fi
    DIDMOUNT=1
  else
    # Sudah mount read-only? remount rw biar bisa tulis
    mount -o remount,rw $MNT >> $LOG 2>&1
    DIDMOUNT=0
  fi
  for F in etc/fstab.mt6765 etc/recovery.fstab fstab.mt6765; do
    if grep -q 'forcefdeorfbe=' $MNT/$F 2>/dev/null; then
      [ -f $MNT/$F.bak ] || cp $MNT/$F $MNT/$F.bak
      sed -i 's/forcefdeorfbe=/encryptable=/' $MNT/$F
      echo "$LBL: patched $F forcefdeorfbe -> encryptable" >> $LOG 2>&1
    fi
  done
  # fileencrypt= juga bisa picu enkripsi FBE di system baru - netralkan juga
  # (hanya kalau baris data masih pakai force* / fileencryption paksa)
  if [ "$DIDMOUNT" = "1" ]; then
    sync
    umount $MNT >> $LOG 2>&1
  fi
}

VDEV_V=/dev/block/platform/bootdevice/by-name/vendor
[ -e "$VDEV_V" ] || VDEV_V=/dev/block/mmcblk0p19
VDEV_S=/dev/block/platform/bootdevice/by-name/system
[ -e "$VDEV_S" ] || VDEV_S=/dev/block/mmcblk0p18
patch_one /tmp/vndpatch $VDEV_V vendor
patch_one /tmp/syspatch $VDEV_S system
# Salinan fstab yang dipakai first-stage boot ada di root ramdisk boot.img,
# tidak bisa dipatch dari sini - user WAJIB centang "Disable Forced Encryption"
# di OrangeFox (menu) atau flash DFE zip setelah install ROM, kalau ROM bawa boot.img stock.
echo "dfe_patch selesai" >> $LOG 2>&1
exit 0
