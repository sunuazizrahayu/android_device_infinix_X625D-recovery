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

# Cuma VENDOR yang dipatch: hasil cek live (adb) partisi system stock X625D
# TIDAK berisi fstab (/etc/fstab.mt6765 tidak ada), dan mount rw system gagal
# (Invalid argument). fstab forcefdeorfbe cuma ada di vendor/etc/fstab.mt6765.
# Salinan di ramdisk boot.img tidak bisa dipatch dari sini - itu urusan
# patcher OrangeFox / DFE zip saat install ROM.
VDEV=/dev/block/platform/bootdevice/by-name/vendor
[ -e "$VDEV" ] || VDEV=/dev/block/mmcblk0p19
MNT=/tmp/vndpatch
mkdir -p $MNT
# Kalau recovery sudah mount vendor sendiri, jangan mount ulang (remount rw saja)
if ! grep -q " $MNT " /proc/mounts 2>/dev/null; then
  if grep -q " /vendor " /proc/mounts 2>/dev/null; then
    mount -o remount,rw /vendor >> $LOG 2>&1
    MNT=/vendor
    DIDMOUNT=0
  elif ! mount -t ext4 -o rw $VDEV $MNT >> $LOG 2>&1; then
    echo "mount vendor gagal, lewati" >> $LOG 2>&1
    exit 0
  else
    DIDMOUNT=1
  fi
else
  DIDMOUNT=0
fi
for F in etc/fstab.mt6765 etc/recovery.fstab; do
  if grep -q 'forcefdeorfbe=' $MNT/$F 2>/dev/null; then
    [ -f $MNT/$F.bak ] || cp $MNT/$F $MNT/$F.bak
    sed -i 's/forcefdeorfbe=/encryptable=/' $MNT/$F
    echo "vendor: patched $F forcefdeorfbe -> encryptable" >> $LOG 2>&1
  else
    echo "vendor: $F sudah encryptable/tidak ada flag" >> $LOG 2>&1
  fi
done
if [ "$DIDMOUNT" = "1" ]; then
  sync
  umount $MNT >> $LOG 2>&1
fi
echo "dfe_patch selesai" >> $LOG 2>&1
exit 0
