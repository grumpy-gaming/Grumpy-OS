# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="mednafen"
PKG_VERSION="1.32.1"
PKG_LICENSE="mixed"
PKG_SITE="https://mednafen.github.io/"
PKG_URL="${PKG_SITE}/releases/files/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain SDL2 flac"
PKG_TOOLCHAIN="configure"

case ${DEVICE} in
  H700)
    PKG_PATCH_DIRS+=" sdl-input"
  ;;
esac

pre_configure_target() {

export CFLAGS="${CFLAGS} -flto -fipa-pta"
export CXXFLAGS="${CXXFLAGS} -flto -fipa-pta"
export LDFLAGS="${LDFLAGS} -flto -fipa-pta"

# unsupported modules
DISABLED_MODULES+=" --disable-apple2 \
                    --disable-sasplay \
                    --disable-ssfplay"

case ${DEVICE} in
  RK3326|RK3566*|H700)
    DISABLED_MODULES+=" --disable-snes \
                        --disable-ss \
                        --disable-psx"
  ;;
  RK3399)
    DISABLED_MODULES+=" --disable-snes \
                        --disable-ss"
  ;;
  RK3588*)
    DISABLED_MODULES+=" --disable-snes"
  ;;
esac

PKG_CONFIGURE_OPTS_TARGET="${DISABLED_MODULES}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/src/mednafen ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/start_mednafen.sh
  chmod +x ${INSTALL}/usr/bin/mednafen_gen_config.sh

  mkdir -p ${INSTALL}/usr/config/${PKG_NAME}
  cp ${PKG_DIR}/config/common/* ${INSTALL}/usr/config/${PKG_NAME}
}
