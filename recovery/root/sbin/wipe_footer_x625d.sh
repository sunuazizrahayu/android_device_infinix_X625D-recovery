#!/sbin/sh
# wipe_footer_x625d.sh - Hapus footer kripto FDE X625D setelah Format Data di OrangeFox.
#
# MASALAH: X625D menyimpan footer FDE di partisi mentah `metadata` (32MB),
# BUKAN di ekor userdata. "Format Data" bawaan TWRP/OrangeFox hanya memformat
# userdata -> footer basi tertinggal. Akibatnya system gagal boot dan selalu
# jatuh ke recovery ("masuk recovery terus"). Format Data ala stock recovery
# membersihkan keduanya, itu sebabnya flash stock recovery + format menyembuhkan.
#
# CARA PAKAI (Terminal OrangeFox - bash aktif via FOX_USE_BASH_SHELL):
#   1. Di OrangeFox: Wipe -> Format Data -> ketik yes
#   2. Masih di recovery, buka Menu -> Terminal, jalankan:
#        /sbin/wipe_footer_x625d.sh
#   3. Reboot -> System. System boot dengan /data bersih tanpa enkripsi
#      (vendor sudah dipatch dfe_patch service: forcefdeorfbe -> encryptable).
#
# PENGAMAN (fail-closed, script menolak jalan kalau ragu):
#   - Node block harus ada.
#   - Ukuran partisi harus TEPAT 32MB (33554432 byte). Salah partisi = abort.
#   - Magic footer "aes-cbc-essiv" harus ketemu (bukti ada footer basi).
#     Tidak ada magic = tidak ada yang perlu dihapus = skip aman.
#   - Script ini TIDAK menyentuh userdata (itu urusan Format Data di UI).
export PATH=/sbin:/system/bin:/vendor/bin
LOG=/tmp/footer_wipe.log
META=/dev/block/platform/bootdevice/by-name/metadata
[ -e "$META" ] || META=/dev/block/mmcblk0p30
EXPECT_SIZE=33554432

log() {
  echo "$1" | tee -a $LOG 2>/dev/null
  echo "$1" >> $LOG 2>&1
}

log "--- wipe_footer_x625d jalan ---"

if [ ! -e "$META" ]; then
  log "ABORT: node $META tidak ada. Boot ke system? (script cuma untuk di recovery)"
  exit 1
fi

SZ=$(blockdev --getsize64 "$META" 2>/dev/null)
if [ "$SZ" != "$EXPECT_SIZE" ]; then
  log "ABORT: ukuran $META = '${SZ:-tidak terbaca}', harus $EXPECT_SIZE."
  log "Refusing - partisi salah, footer TIDAK dihapus."
  exit 1
fi
log "OK: $META ukuran 32MB sesuai partisi metadata."

if dd if="$META" bs=4096 2>/dev/null | grep -q 'aes-cbc-essiv'; then
  log "OK: magic footer FDE ketemu (footer basi, wajib dihapus)."
else
  log "SKIP: tidak ada magic footer di $META, tidak ada yang dihapus."
  exit 0
fi

log "Menghapus 32MB footer..."
if dd if=/dev/zero of="$META" bs=1048576 2>>$LOG; then
  sync
  if dd if="$META" bs=4096 2>/dev/null | grep -q 'aes-cbc-essiv'; then
    log "GAGAL: magic masih ada setelah wipe, JANGAN reboot ke system."
    exit 1
  fi
  log "SELESAI: footer bersih. Aman reboot ke System."
  exit 0
else
  log "GAGAL: dd error, footer TIDAK dihapus."
  exit 1
fi
