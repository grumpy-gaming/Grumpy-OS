# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lime3ds-sa"
PKG_VERSION="2119.1"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/Lime3DS/Lime3DS"
PKG_URL="https://github.com/ROCKNIX/packages/raw/main/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain ffmpeg mesa SDL2 boost zlib libusb boost zstd control-gen spirv-tools qt6"
PKG_LONGDESC="Lime3DS - Nintendo 3DS emulator"
PKG_TOOLCHAIN="cmake"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi


PKG_CMAKE_OPTS_TARGET+=" -DENABLE_QT_TRANSLATION=OFF \
                         -DENABLE_QT=ON \
                         -DENABLE_SDL2=ON \
                         -DENABLE_SDL2_FRONTEND=OFF \
                         -DENABLE_TESTS=OFF \
                         -DENABLE_DEDICATED_ROOM=OFF \
                         -DUSE_DISCORD_PRESENCE=OFF"

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/.${TARGET_NAME}/bin/MinSizeRel/lime3ds ${INSTALL}/usr/bin/lime3ds
  cp ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/lime3ds
  cp -rf ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/lime3ds
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/lime3ds
}
