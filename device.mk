LOCAL_PATH := device/infinix/X625D

PRODUCT_USE_DYNAMIC_PARTITIONS := false
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# ro.hardware sejak awal boot: init meng-import init.recovery.${ro.hardware}.rc
# saat parse, dan nilai itu belum ada sepagi itu di device ini -> file
# init.recovery.mt6765.rc (service dt2w_enable, dll) tidak pernah di-parse
# (hasil debug ADB: tidak ada init.svc.* terkait).
# WAJIB via PRODUCT_DEFAULT_PROPERTY_OVERRIDES (masuk prop.default recovery):
# direct ADDITIONAL_DEFAULT_PROPERTIES += ditolak build (main.mk: "must not
# be set before here").
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += ro.hardware=mt6765

# Blob keymaster/gatekeeper MT6765 untuk decrypt FDE (footer di /metadata).
# Tanpa ini log error: "could not find any keystore module / Failed to init keymaster"
# dan "Unable to decrypt with default password" padahal tidak ada PIN.
# File di recovery/root/ -> recovery ramdisk /vendor/... (tempat libhardware mencari keystore.mt6765.so).
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root,recovery/root)
