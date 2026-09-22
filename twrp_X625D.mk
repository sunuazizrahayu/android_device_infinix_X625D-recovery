# TWRP product untuk manifest fox_12.1 (test R12).
# Dipakai via: lunch twrp_X625D-eng (dengan FOX_BUILD_DEVICE=X625D).
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, vendor/twrp/config/common.mk)
$(call inherit-product, device/infinix/X625D/device.mk)

PRODUCT_DEVICE := X625D
PRODUCT_NAME := twrp_X625D
PRODUCT_BRAND := Infinix
PRODUCT_MODEL := Infinix X625D
PRODUCT_MANUFACTURER := INFINIX MOBILITY LIMITED
PRODUCT_RELEASE_NAME := Infinix HOT 7 PRO
