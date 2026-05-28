#!/bin/bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# quickshell - for desktop overview replacing AGS
# installing via zypper with fallback messaging when unavailable

quick=(
    quickshell
    qt6-qt5compat-imports
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || {
    echo "${ERROR} Failed to change directory to $PARENT_DIR"
    exit 1
}

# Source the global functions script
if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
fi

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +'%d-%H%M%S')_quick.log"

# Ensure the darix-playground repository is added
printf "${NOTE} Adding ${SKY_BLUE}darix-playground${RESET} repository...\n"
if ! sudo zypper lr | grep -q "darix-playground"; then
    if ! sudo zypper ar -f https://download.opensuse.org/repositories/home:darix:playground/openSUSE_Tumbleweed/home:darix:playground.repo darix-playground 2>&1 | tee -a "$LOG"; then
        echo "${ERROR} Failed to add darix-playground repository." | tee -a "$LOG"
        exit 1
    fi
else
    echo "${INFO} darix-playground repository already configured." | tee -a "$LOG"
fi

# Refresh metadata for the quickshell repository
sudo zypper --gpg-auto-import-keys refresh darix-playground 2>&1 | tee -a "$LOG" || true

# Check if quickshell is currently available
printf "${NOTE} Checking ${SKY_BLUE}quickshell availability${RESET} in configured repositories...\n"
if ! sudo zypper --non-interactive info quickshell >/dev/null 2>&1; then
    printf "\n%s - ${YELLOW}quickshell package not found${RESET} in current repos\n" "${WARN}"
    printf "\n%s - ${SKY_BLUE}Fallback option available${RESET}: AGS (Aylur's GTK Shell) will be used instead\n" "${INFO}"
    printf "\n%s - The ${SKY_BLUE}Hyprland-Dots OverviewToggle.sh${RESET} script will automatically detect and use AGS\n" "${INFO}"
    printf "\n%s - You can install quickshell manually later if it becomes available for your openSUSE snapshot\n" "${NOTE}"
    echo "${WARN} quickshell unavailable from configured repositories. AGS fallback will be used." | tee -a "$LOG"
    printf "\n%.0s" {1..1}
    exit 0
fi

# Installing packages
printf "${NOTE} Installing ${SKY_BLUE}quickshell for Desktop Overview${RESET}...\n"
for pkg in "${quick[@]}"; do
    install_package "$pkg" "$LOG"
done

# Verify quickshell installation
if rpm -q quickshell &>/dev/null; then
    echo -e "\n${OK} ${SKY_BLUE}quickshell${RESET} installed successfully."
    echo "${OK} quickshell successfully installed." | tee -a "$LOG"
else
    printf "\n%s - ${YELLOW}quickshell installation failed${RESET}. AGS fallback will be used.\n" "${WARN}"
    echo "${WARN} quickshell installation failed. AGS fallback will be used." | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}
