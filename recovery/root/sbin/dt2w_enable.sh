#!/sbin/sh
# dt2w_enable.sh - Aktifkan Double Tap to Wake (NVT36xxx-ts / NT36672A) di OrangeFox.
# Kenapa perlu script (bukan cuma `write` di init.rc):
#  - Node /proc/gesture_function baru muncul SETELAH driver touchscreen probe
#    (~1.8 detik atau lebih), sedangkan trigger `on boot` di init bisa jalan
#    SEBELUM node ada -> write gagal diam-diam dan tidak pernah diulang.
#    (Modul Magisk referensi menangani ini dengan loop tunggu s/d 60 detik.)
#  - Format write HARUS tepat 3 char tanpa newline ("cc1"). printf '%s'
#    menjamin tidak ada newline. JANGAN tulis ke /proc/gesture_state
#    (itu read-only status). JANGAN format "cc:1" (pakai titik dua) — bikin hang.
# Dijalankan sebagai oneshot service dari init.recovery.mt6765.rc
# (tidak menghambat boot). Hasil/verifikasi dicatat di /tmp/dt2w.log.
# CATATAN URUTAN BOOT (hasil debug ADB 2026-09-18, dmesg):
#  - Recovery binary (pid recovery) menulis ctp_gesture_fun_enable=0 di ~2.6 detik,
#    JAUH setelah node proc muncul (~1.8 detik). Jadi enable sekali di awal akan
#    ditimpa disable oleh recovery -> script ini sleep 5 detik dulu, lalu
#    tulis + VERIFIKASI + tulis ulang s/d 3 ronde sampai gesture_state memuat cc:1.
export PATH=/sbin:/system/bin:/vendor/bin
LOG=/tmp/dt2w.log
PROC_FUN=/proc/gesture_function
PROC_STATE=/proc/gesture_state

echo "--- dt2w_enable jalan ---" >> $LOG 2>&1
i=0
while [ ! -e "$PROC_FUN" ] && [ $i -lt 30 ]; do
  sleep 1
  i=$((i + 1))
done
if [ ! -e "$PROC_FUN" ]; then
  echo "GAGAL: $PROC_FUN tidak muncul setelah 30 detik" >> $LOG 2>&1
  exit 0
fi
# Beri waktu recovery menyelesaikan disable gesture-nya sebelum kita enable.
sleep 5
r=0
while [ $r -lt 3 ]; do
  if grep -q '^cc:1;' "$PROC_STATE" 2>/dev/null; then
    echo "OK: gesture cc sudah aktif (ronde $r)" >> $LOG 2>&1
    break
  fi
  if printf '%s' 'cc1' > "$PROC_FUN" 2>>$LOG; then
    echo "OK: tulis cc1 ke $PROC_FUN (ronde $r)" >> $LOG 2>&1
  else
    echo "WARN: tulis cc1 gagal (ronde $r)" >> $LOG 2>&1
  fi
  sleep 2
  r=$((r + 1))
done
if [ -r "$PROC_STATE" ]; then
  echo "--- $PROC_STATE ---" >> $LOG 2>&1
  cat "$PROC_STATE" >> $LOG 2>&1
fi
dmesg 2>/dev/null | grep -i -m5 'gesture' >> $LOG 2>&1
exit 0
