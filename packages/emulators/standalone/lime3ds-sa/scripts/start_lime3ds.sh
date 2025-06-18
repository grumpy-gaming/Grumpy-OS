#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "-9 lime3ds"

# Load gptokeyb support files
control-gen_init.sh
source /storage/.config/gptokeyb/control.ini
get_controls

# Filesystem vars
IMMUTABLE_CONF_DIR="/usr/config/lime3ds"
CONF_DIR="/storage/.config/lime3ds"
CONF_FILE="${CONF_DIR}/qt-config.ini"
ROMS_DIR="/storage/roms/3ds"

# Make sure Lime3DS config directory exists
[ ! -d ${CONF_DIR} ] && cp -r ${IMMUTABLE_CONF_DIR} /storage/.config

# Move sdmc & nand to 3ds roms folder
[ ! -d /storage/roms/3ds/lime3ds/sdmc ] && mkdir -p ${ROMS_DIR}/lime3ds/sdmc
rm -rf ${CONF_DIR}/sdmc
ln -sf ${ROMS_DIR}/lime3ds/sdmc ${CONF_DIR}/sdmc

[ ! -d ${ROMS_DIR}/lime3ds/nand ] && mkdir -p ${ROMS_DIR}/lime3ds/nand
rm -rf ${CONF_DIR}/nand
ln -sf ${ROMS_DIR}/lime3ds/nand ${CONF_DIR}/nand

# RK3588 - handle different config files for ACE / CM5
if [ "${HW_DEVICE}" = "RK3588" ] && [ ! -f "${CONF_FILE}" ]; then
  if echo ${QUIRK_DEVICE} | grep CM5; then
    cp ${IMMUTABLE_CONF_DIR}/qt-config_CM5.ini ${CONF_FILE}
  else
    cp ${IMMUTABLE_CONF_DIR}/qt-config_ACE.ini ${CONF_FILE}
  fi
fi

# Make sure QT config file exists
[ ! -f "${CONF_FILE}" ] && cp ${IMMUTABLE_CONF_DIR}/qt-config.ini ${CONF_DIR}

# Make sure gptokeyb mapping files exist
[ ! -f "${CONF_DIR}/lime3ds.gptk" ] && cp ${IMMUTABLE_CONF_DIR}/lime3ds.gptk ${CONF_DIR}
[ ! -f "${CONF_DIR}/lime3ds_mouse_addon.gptk" ] && cp ${IMMUTABLE_CONF_DIR}/lime3ds_mouse_addon.gptk ${CONF_DIR}

# Emulation Station Features
GAME=$(echo "${1}"| sed "s#^/.*/##")
PLATFORM=$(echo "${2}"| sed "s#^/.*/##")
CPU=$(get_setting cpu_speed "${PLATFORM}" "${GAME}")
EMOUSE=$(get_setting emulate_mouse "${PLATFORM}" "${GAME}")
RENDERER=$(get_setting graphics_backend "${PLATFORM}" "${GAME}")
RES=$(get_setting resolution_scale "${PLATFORM}" "${GAME}")
ROTATE=$(get_setting rotate_screen "${PLATFORM}" "${GAME}")
SLAYOUT=$(get_setting screen_layout "${PLATFORM}" "${GAME}")
CSHADERS=$(get_setting cache_shaders "${PLATFORM}" "${GAME}")
HSHADERS=$(get_setting hardware_shaders "${PLATFORM}" "${GAME}")
ACCURATE_HW_SHADERS=$(get_setting accurate_hardware_shaders "${PLATFORM}" "${GAME}")

#Set the cores to use
CORES=$(get_setting "cores" "${PLATFORM}" "${GAME}")
unset EMUPERF
[ "${CORES}" = "little" ] && EMUPERF="${SLOW_CORES}"
[ "${CORES}" = "big" ] && EMUPERF="${FAST_CORES}"

# CPU Underclock
sed -i '/^cpu_clock_percentage\\default=/c\cpu_clock_percentage\\default=false' ${CONF_FILE}

case "${CPU}" in
  0) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=100' ${CONF_FILE};;
  1) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=90' ${CONF_FILE};;
  2) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=80' ${CONF_FILE};;
  3) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=70' ${CONF_FILE};;
  4) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=60' ${CONF_FILE};;
  5) sed -i '/^cpu_clock_percentage=/c\cpu_clock_percentage=50' ${CONF_FILE};;
esac

# Resolution Scale
sed -i '/^resolution_factor\\default=/c\resolution_factor\\default=false' ${CONF_FILE}

case "${RES}" in
  0) sed -i '/^resolution_factor=/c\resolution_factor=0' ${CONF_FILE};;
  1) sed -i '/^resolution_factor=/c\resolution_factor=1' ${CONF_FILE};;
  2) sed -i '/^resolution_factor=/c\resolution_factor=2' ${CONF_FILE};;
  3) sed -i '/^resolution_factor=/c\resolution_factor=3' ${CONF_FILE};;
esac

# Rotate Screen
sed -i '/^upright_screen\\default=/c\upright_screen\\default=false' ${CONF_FILE}

case "${ROTATE}" in
  0) sed -i '/^upright_screen=/c\upright_screen=false' ${CONF_FILE};;
  1) sed -i '/^upright_screen=/c\upright_screen=true' ${CONF_FILE};;
esac

# Cache Shaders
sed -i '/^use_disk_shader_cache\\default=/c\use_disk_shader_cache\\default=false' ${CONF_FILE}

case "${CSHADERS}" in
  0) sed -i '/^use_disk_shader_cache=/c\use_disk_shader_cache=false' ${CONF_FILE};;
  1) sed -i '/^use_disk_shader_cache=/c\use_disk_shader_cache=true' ${CONF_FILE};;
esac

# Hardware Shaders
sed -i '/^use_hw_shader\\default=/c\use_hw_shader\\default=false' ${CONF_FILE}

case "${HSHADERS}" in
  1) sed -i '/^use_hw_shader=/c\use_hw_shader=true' ${CONF_FILE};;
  *) sed -i '/^use_hw_shader=/c\use_hw_shader=false' ${CONF_FILE};;
esac

# Use accurate multiplication in hardware shaders
sed -i '/^shaders_accurate_mul\\default=/c\shaders_accurate_mul\\default=false' ${CONF_FILE}

case "${ACCURATE_HW_SHADERS}" in
  1) sed -i '/^shaders_accurate_mul=/c\shaders_accurate_mul=true' ${CONF_FILE};;
  *) sed -i '/^shaders_accurate_mul=/c\shaders_accurate_mul=false' ${CONF_FILE};;
esac

# Screen Layout
sed -i '/^layout_option\\default=/c\layout_option\\default=false' ${CONF_FILE}
sed -i '/^swap_screen\\default=/c\swap_screen\\default=false' ${CONF_FILE}

case "${SLAYOUT}" in
  0)
    # Default (Top / Bottom)
    sed -i '/^layout_option=/c\layout_option=0' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=false' ${CONF_FILE}
    ;;
  1a)
    # Single Screen (TOP)
    sed -i '/^layout_option=/c\layout_option=1' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=false' ${CONF_FILE}
    ;;
  1b)
    # Single Screen (BOTTOM)
    sed -i '/^layout_option=/c\layout_option=1' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=true' ${CONF_FILE}
    ;;
  2)
    # Large Screen, Small Screen
    sed -i '/^layout_option=/c\layout_option=2' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=false' ${CONF_FILE}
    ;;
  3)
    # Side by Side
    sed -i '/^layout_option=/c\layout_option=3' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=false' ${CONF_FILE}
    ;;
  4)
    # Hybrid
    sed -i '/^layout_option=/c\layout_option=5' ${CONF_FILE}
    sed -i '/^swap_screen=/c\swap_screen=false' ${CONF_FILE}
    ;;
esac

# Video Backend
sed -i '/^graphics_api\\default=/c\graphics_api\\default=false' ${CONF_FILE}

case "${RENDERER}" in
  1) sed -i '/^graphics_api=/c\graphics_api=1' ${CONF_FILE};;
  *) sed -i '/^graphics_api=/c\graphics_api=2' ${CONF_FILE};;
esac

rm -rf /storage/.local/share/lime3ds
ln -sf ${CONF_DIR} /storage/.local/share/lime3ds

# Run Lime Emulator
if [ "${EMOUSE}" = "0" ]; then
  # Use base gptk file
  ${GPTOKEYB} lime3ds -c ${CONF_DIR}/lime3ds.gptk &
else
  # Combine base gptk file with mouse control gptk file, inserting line break in between
  cat ${CONF_DIR}/lime3ds.gptk <(echo) ${CONF_DIR}/lime3ds_mouse_addon.gptk > /tmp/lime3ds.gptk
  ${GPTOKEYB} lime3ds -c /tmp/lime3ds.gptk &
fi

${EMUPERF} /usr/bin/lime3ds "${1}"
kill -9 $(pidof gptokeyb)
