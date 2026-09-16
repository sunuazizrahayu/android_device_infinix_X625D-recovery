#!/sbin/sh
# dfe_patch.sh - Matikan force-encrypt X625D otomatis di tiap boot OrangeFox.
# Latar: stock vendor fstab.mt6765 pakai forcefdeorfbe=.../metadata, sehingga
# system (GSI) mengenkripsi ulang /data (FDE) setiap habis Format Data.
# FDE itu tidak bisa di-decrypt recovery ini (keymaster TEE microtrust
# menolak begin() dengan -1000), akibatnya /sdcard tidak terbaca.
# Script ini idempotent: hanya mengubah forcefdeorfbe= -> encryptable=
# kalau flag itu masih ada. Tidak pernah gagal (exit 0 selalu) agar
# tidak menghambat boot recovery.
export PATH=/sbin:/system/bin:/vendor/bin
LOG=/tmp/dfe_patch.log
VDEV=/dev/block/platform/bootdevice/by-name/vendor
[ -e "$VDEV" ] || VDEV=/dev/block/mmcblk0p19
MNT=/tmp/vndpatch
FSTAB=etc/fstab.mt6765

echo "--- dfe_patch jalan ---" >> $LOG 2>&1
mkdir -p $MNT
if ! mount -t ext4 -o rw $VDEV $MNT >> $LOG 2>&1; then
  echo "mount vendor gagal, lewati" >> $LOG 2>&1
  exit 0
fi
if grep -q 'forcefdeorfbe=' $MNT/$FSTAB 2>/dev/null; then
  [ -f $MNT/$FSTAB.bak ] || cp $MNT/$FSTAB $MNT/$FSTAB.bak
  sed -i 's/forcefdeorfbe=/encryptable=/' $MNT/$FSTAB
  echo "patched: forcefdeorfbe -> encryptable" >> $LOG 2>&1
else
  echo "sudah encryptable/tidak ada flag, lewati" >> $LOG 2>&1
fi
sync
umount $MNT >> $LOG 2>&1
exit 0
