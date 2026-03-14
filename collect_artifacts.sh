#!/usr/bin/env bash
set -euo pipefail

# ==============================
# Paths
# ==============================

BOOT_BIN="./build/boot.bin"
FSBL_ELF="./build/sdk/fsbl/Release/fsbl.elf"
BOOT_DFU="./build/boot.dfu"
UBOOT_ENV="./build/uboot-env.dfu"
PLUTO_DFU="./build/pluto.dfu"

FIRMWARE_ZIP="./build/firmware.zip"
SDCARD_ZIP="./build/firmware_sdcard.zip"
SDCARD_FLASH_ZIP="./build/firmware_sdcard_flash.zip"

SDIMG_DIR="./build_sdimg"
FLASH_ENV="./scripts/uEnvwithFlashCmd.env"

ARTIFACTS_DIR="./artifacts"

# ==============================
# Colors
# ==============================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ==============================
# Helpers
# ==============================

error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

success_msg() {
    echo -e "${GREEN}$1${NC}"
}

info_msg() {
    echo -e "${YELLOW}$1${NC}"
}

require_file() {
    [[ -f "$1" ]] || error_exit "Missing required file: $1"
}

require_dir() {
    [[ -d "$1" ]] || error_exit "Missing required directory: $1"
}

dir_not_empty() {
    find "$1" -mindepth 1 -print -quit | grep -q .
}

# ==============================
# Prepare artifacts dir
# ==============================

clean_artifacts() {

    info_msg "Preparing artifacts directory..."

    rm -rf "$ARTIFACTS_DIR"
    mkdir -p "$ARTIFACTS_DIR"
}

# ==============================
# firmware.zip
# ==============================

create_firmware_zip() {

    info_msg "Creating firmware.zip..."

    require_file "$BOOT_BIN"
    require_file "$PLUTO_DFU"
    require_file "$UBOOT_ENV"
    require_file "$FSBL_ELF"
    require_file "$BOOT_DFU"

    rm -f "$FIRMWARE_ZIP"

    zip -j "$FIRMWARE_ZIP" \
        "$BOOT_BIN" \
        "$PLUTO_DFU" \
        "$UBOOT_ENV" \
        "$FSBL_ELF" \
        "$BOOT_DFU"

    success_msg "Created $FIRMWARE_ZIP"
    ls -lh "$FIRMWARE_ZIP"
}

# ==============================
# SD image zip (normal)
# ==============================

create_sdcard_zip() {

    info_msg "Creating firmware_sdcard.zip..."

    require_dir "$SDIMG_DIR"

    if ! dir_not_empty "$SDIMG_DIR"; then
        error_exit "$SDIMG_DIR is empty"
    fi

    rm -f "$SDCARD_ZIP"

    (cd "$SDIMG_DIR" && zip -r "../$SDCARD_ZIP" .)

    success_msg "Created $SDCARD_ZIP"
    ls -lh "$SDCARD_ZIP"
}

# ==============================
# SD image zip (flash version)
# ==============================

create_sdcard_zip_flash() {

    info_msg "Creating firmware_sdcard_flash.zip..."

    require_dir "$SDIMG_DIR"
    require_file "$FLASH_ENV"

    local tmpdir
    tmpdir=$(mktemp -d)

    cp -r "$SDIMG_DIR/"* "$tmpdir/"

    # replace env
    cp "$FLASH_ENV" "$tmpdir/uEnv.txt"

    rm -f "$SDCARD_FLASH_ZIP"

    (zip -r "$tmpdir/firmware_sdcard_flash.zip" "$tmpdir"  && cp "$tmpdir/../firmware_sdcard_flash.zip" "$SDCARD_FLASH_ZIP")

    rm -rf "$tmpdir"

    success_msg "Created $SDCARD_FLASH_ZIP"
    ls -lh "$SDCARD_FLASH_ZIP"
}

# ==============================
# Move outputs
# ==============================

move_to_artifacts() {

    info_msg "Moving artifacts..."

    require_file "$FIRMWARE_ZIP"
    require_file "$SDCARD_ZIP"
    require_file "$SDCARD_FLASH_ZIP"

    mv "$FIRMWARE_ZIP" "$ARTIFACTS_DIR/"
    mv "$SDCARD_ZIP" "$ARTIFACTS_DIR/"
    mv "$SDCARD_FLASH_ZIP" "$ARTIFACTS_DIR/"

    success_msg "Artifacts:"
    ls -lh "$ARTIFACTS_DIR"
}

# ==============================
# Main
# ==============================

main() {

    echo "========================================"
    echo "Firmware packaging"
    echo "========================================"

    clean_artifacts

    create_firmware_zip
    create_sdcard_zip
    create_sdcard_zip_flash

    move_to_artifacts

    echo "========================================"
    success_msg "Packaging completed"

    echo "Artifacts location:"
    realpath "$ARTIFACTS_DIR"
}

main "$@"