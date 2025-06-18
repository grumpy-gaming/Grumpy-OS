# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="d1c4eba0c495c3c4a32924efe0f590a4759aa6d5"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/RetroidPocket/${PKG_NAME}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain gnutls:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="qcom_defconfig retroidpocket.config"
  PKG_DEVICE_TREE="qcom/sm8250-retroidpocket-rp5"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make DEVICE_TREE=${PKG_DEVICE_TREE}

  gzip ${PKG_BUILD}/u-boot-nodtb.bin -c > ${PKG_BUILD}/u-boot-nodtb.bin.gz
  cat ${PKG_BUILD}/u-boot-nodtb.bin.gz ${PKG_BUILD}/dts/upstream/src/arm64/${PKG_DEVICE_TREE}.dtb > ${PKG_BUILD}/kernel.dtb
  ${TOOLCHAIN}/bin/python ${PKG_BUILD}/mkbootimg.py --kernel_offset 0x00008000 --pagesize 4096 --kernel ${PKG_BUILD}/kernel.dtb -o ${PKG_BUILD}/u-boot.img --cmdline nodtbo
}

makeinstall_target() {
  :
}
