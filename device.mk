LOCAL_PATH := device/infinix/X625D

PRODUCT_USE_DYNAMIC_PARTITIONS := false
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    fastbootd

# Blob keymaster/gatekeeper MT6765 untuk decrypt FDE (footer di /metadata).
# Tanpa ini log error: "could not find any keystore module / Failed to init keymaster"
# dan "Unable to decrypt with default password" padahal tidak ada PIN.
# File di recovery/root/ -> recovery ramdisk /vendor/... (tempat libhardware mencari keystore.mt6765.so).
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,$(LOCAL_PATH)/recovery/root,recovery/root)
