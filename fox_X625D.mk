# OrangeFox R11.3 (Android 9.0 branch, fox_9.0)
# CATATAN R11.3: FOX_VERSION sudah OBSOLETE dan bikin build error.
# Versi R11.3 diset otomatis oleh source; pakai FOX_MAINTAINER_PATCH_VERSION
# untuk suffix maintainer (mis. R11.3_1).
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

$(call inherit-product, device/infinix/X625D/device.mk)

# OrangeFox common - manifest fox_9.0 (R11.3)
$(call inherit-product, vendor/fox/config/common.mk)

PRODUCT_DEVICE := X625D
PRODUCT_NAME := fox_X625D
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X625D
PRODUCT_MANUFACTURER := INFINIX MOBILITY LIMITED
PRODUCT_RELEASE_NAME := Infinix HOT 7 PRO

# Fox flags (R11.3, fox_9.0)
OF_MAINTAINER := X625D-unofficial
FOX_MAINTAINER_PATCH_VERSION := 1
OF_VERSION_VARIANT := unofficial
FOX_BUILD_TYPE := Unofficial
OF_USE_TWRP_RECOVERY_IMAGE_BUILDER := 1
# R11.3: magiskboot + dont-patch-encrypted selalu aktif otomatis -> tidak perlu diset
OF_NO_TREBLE_COMPATIBILITY_CHECK := 1
OF_NO_MIUI_PATCH_AUTOFS := 1
# Non-Xiaomi: skip cek props MIUI tambahan (boot sedikit lebih cepat)
OF_NO_ADDITIONAL_MIUI_PROPS_CHECK := 1
OF_DISABLE_MIUI_OTA_BY_DEFAULT := 1
OF_QUICK_BACKUP_LIST := /boot;/recovery;/data;/system;/vendor;
OF_HIDE_NOTCH := 1
OF_CLOCK_POS := 1
OF_SCREEN_H := 1520
OF_STATUS_H := 80
OF_STATUS_INDENT_LEFT := 48
OF_STATUS_INDENT_RIGHT := 48
OF_ALLOW_DISABLE_NAVBAR := 0
FOX_USE_BASH_SHELL := 1
FOX_ASH_IS_BASH := 1
FOX_USE_TAR_BINARY := 1
FOX_USE_SED_BINARY := 1
FOX_USE_XZ_UTILS := 1
FOX_RECOVERY_SYSTEM_PARTITION := /dev/block/platform/bootdevice/by-name/system
FOX_RECOVERY_VENDOR_PARTITION := /dev/block/platform/bootdevice/by-name/vendor
OF_USE_GREEN_LED := 0
OF_PATCH_AVB20 := 1
# Splash changer OrangeFox gagal di device ini (unpack path kosong, efek domino
# repack "unknown compression type") -> sembunyikan menunya agar tidak membingungkan
OF_NO_SPLASH_CHANGE := 1
# A-only: FOX_AB_DEVICE default 0, tidak perlu diset eksplisit
FOX_DELETE_AROMAFM := 1
FOX_ENABLE_APP_MANAGER := 1
