#!/bin/bash
#
# Xiaomi Qualcomm logo.img generator
# Author: Sebastiano Barezzi <barezzisebastiano@gmail.com>
#

# Set your resolution here
RESOLUTION_X="1080"
RESOLUTION_Y="2400"

# Set what splashes set you wanna use
IMAGES_DIR="lineageos"

# ---------------------------------------------------
# You should't need to touch anything after this line
# ---------------------------------------------------

set -e

NORMAL="normal.png"
FASTBOOT="fastboot.png"
NORMAL_UNLOCKED="normal-unlocked.png"
SYSTEM_DESTROYED="system-destroyed.png"

BIN_DIR="bin"
OUTPUT_DIR="output"
TEMP_DIR="temp"

LOGO_OUTPUT="${OUTPUT_DIR}/logo.img"

mkdir -p "${OUTPUT_DIR}"
mkdir -p "${TEMP_DIR}"

for image in "${NORMAL}" "${FASTBOOT}" "${NORMAL_UNLOCKED}" "${SYSTEM_DESTROYED}"; do
    if [ ! -f "${IMAGES_DIR}/${image}" ]; then
        echo "${IMAGES_DIR}/${image} missing"
        exit
    fi
done

if ! which ffmpeg &> /dev/null; then
    echo "Missing ffmpeg, please install it"
    exit
fi

for image in "${NORMAL}" "${FASTBOOT}" "${NORMAL_UNLOCKED}" "${SYSTEM_DESTROYED}"; do
    ffmpeg -hide_banner -loglevel quiet -i "${IMAGES_DIR}/${image}" -pix_fmt rgb24 -s "${RESOLUTION_X}x${RESOLUTION_Y}" -y "${TEMP_DIR}/${image}.bmp" &> /dev/null
done

cat "${BIN_DIR}/header.bin" > "${LOGO_OUTPUT}"
for image in "${NORMAL}" "${FASTBOOT}" "${NORMAL_UNLOCKED}" "${SYSTEM_DESTROYED}"; do
    cat "${TEMP_DIR}/${image}.bmp" "${BIN_DIR}/footer.bin" >> "${LOGO_OUTPUT}"
done

rm -rf "${TEMP_DIR}"

echo "Done! Output: ${LOGO_OUTPUT}"
