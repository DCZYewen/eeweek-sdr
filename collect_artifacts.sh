#!/bin/bash

# Original file paths
BOOT_BIN="./build/boot.bin"
FSBL_ELF="./build/sdk/fsbl/Release/fsbl.elf"
BOOT_DFU="./build/boot.dfu"
UBOOT_ENV="./build/uboot-env.dfu"
PLUTO_DFU="./build/pluto.dfu"

# Output file paths
FIRMWARE_ZIP="./build/firmware.zip"
SDCARD_ZIP="./build/firmware_sdcard.zip"
SDCARD_FLASH_ZIP="./build/firmware_sdcard_flash.zip"

# Artifacts directory
ARTIFACTS_DIR="./artifacts"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Error handling
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

# Clean and create artifacts directory
clean_artifacts() {
    info_msg "Cleaning artifacts directory..."
    if [[ -d "$ARTIFACTS_DIR" ]]; then
        rm -rf "$ARTIFACTS_DIR" || error_exit "Failed to remove $ARTIFACTS_DIR"
    fi
    mkdir -p "$ARTIFACTS_DIR" || error_exit "Failed to create $ARTIFACTS_DIR"
}

# Check if required files exist
check_required_files() {
    info_msg "Checking required files..."
    
    local files=("$BOOT_BIN" "$PLUTO_DFU" "$FSBL_ELF" "$BOOT_DFU" "$UBOOT_ENV")
    local missing_files=()
    
    for file in "${files[@]}"; do
        if [[ ! -f "$file" ]]; then
            missing_files+=("$file")
        fi
    done
    
    if [[ ${#missing_files[@]} -gt 0 ]]; then
        echo "Missing required files:"
        for file in "${missing_files[@]}"; do
            echo "  - $file"
        done
        return 1
    fi
    
    return 0
}

# Create firmware.zip
create_firmware_zip() {
    info_msg "Creating firmware.zip..."
    
    if ! check_required_files; then
        error_exit "Cannot create firmware.zip, missing required files"
    fi
    
    zip -j "$FIRMWARE_ZIP" "$BOOT_BIN" "$PLUTO_DFU" "$UBOOT_ENV" "$FSBL_ELF" "$BOOT_DFU" || error_exit "Failed to create firmware.zip"
    
    if [[ -f "$FIRMWARE_ZIP" ]]; then
        success_msg "Successfully created $FIRMWARE_ZIP"
        ls -lh "$FIRMWARE_ZIP"
    fi
}

# Create firmware_sdcard.zip
create_sdcard_zip() {
    info_msg "Creating firmware_sdcard.zip..."
    
    local sdimg_dir="./build_sdimg"
    
    if [[ ! -d "$sdimg_dir" ]]; then
        error_exit "$sdimg_dir directory does not exist"
    fi
    
    if [[ -z "$(ls -A "$sdimg_dir" 2>/dev/null)" ]]; then
        error_exit "$sdimg_dir directory is empty"
    fi
    
    cd "$sdimg_dir" || error_exit "Cannot cd into $sdimg_dir"
    zip -r "../$SDCARD_ZIP" . || error_exit "Failed to create firmware_sdcard.zip"
    cd - > /dev/null || error_exit "Cannot return to parent directory"
    
    if [[ -f "$SDCARD_ZIP" ]]; then
        success_msg "Successfully created $SDCARD_ZIP"
        ls -lh "$SDCARD_ZIP"
    fi
}
# Create firmware_sdcard.zip
create_sdcard_zip_flash() {
    info_msg "Creating firmware_sdcard_flash.zip..."
    
    local sdimg_dir="./build_sdimg"
    
    if [[ ! -d "$sdimg_dir" ]]; then
        error_exit "$sdimg_dir directory does not exist"
    fi
    
    if [[ -z "$(ls -A "$sdimg_dir" 2>/dev/null)" ]]; then
        error_exit "$sdimg_dir directory is empty"
    fi
    
    cd "$sdimg_dir" || error_exit "Cannot cd into $sdimg_dir"
    cp "script/uEnvwithFlashCmd.env" "build_sdimg/uEnv.txt"
    zip -r "../$SDCARD_FLASH_ZIP" . || error_exit "Failed to create firmware_sdcard__flash.zip"
    cd - > /dev/null || error_exit "Cannot return to parent directory"
    
    if [[ -f "$SDCARD_FLASH_ZIP" ]]; then
        success_msg "Successfully created $SDCARD_FLASH_ZIP"
        ls -lh "$SDCARD_FLASH_ZIP"
    fi
}

# Move files to artifacts directory
move_to_artifacts() {
    info_msg "Moving files to artifacts directory..."
    
    if [[ ! -f "$FIRMWARE_ZIP" ]]; then
        error_exit "$FIRMWARE_ZIP does not exist"
    fi
    
    if [[ ! -f "$SDCARD_ZIP" ]]; then
        error_exit "$SDCARD_ZIP does not exist"
    fi

    if [[ ! -f "$SDCARD_ZIP_FLASH" ]]; then
        error_exit "$SDCARD_ZIP_FLASH does not exist"
    fi
    
    mv "$FIRMWARE_ZIP" "$ARTIFACTS_DIR/" || error_exit "Failed to move $FIRMWARE_ZIP"
    mv "$SDCARD_ZIP" "$ARTIFACTS_DIR/" || error_exit "Failed to move $SDCARD_ZIP"
    mv "$SDCARD_ZIP_FLASH" "$SDCARD_ZIP_FLASH/" || error_exit "Failed to move $SDCARD_ZIP_FLASH"
    
    success_msg "Files moved to $ARTIFACTS_DIR:"
    ls -lh "$ARTIFACTS_DIR/"
}

# Main function
main() {
    echo "Starting firmware packaging..."
    echo "========================================"
    
    clean_artifacts
    
    create_firmware_zip
    create_sdcard_zip
    create_sdcard_zip_flash
    
    move_to_artifacts
    
    echo "========================================"
    success_msg "Packaging completed successfully!"
    echo "Output files in: $(realpath "$ARTIFACTS_DIR")"
    echo ""
    echo "Files included:"
    echo "  - firmware.zip: boot.bin, pluto.dfu, uboot-env.dfu, fsbl.elf, boot.dfu"
    echo "  - firmware_sdcard.zip: all files from ./sdimg/"
}

# Execute main function
main "$@"