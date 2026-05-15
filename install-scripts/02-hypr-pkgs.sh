#!/bin/bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Hyprland-Dots Packages #
# edit your packages desired here.
# WARNING! If you remove packages here, dotfiles may not work properly.
# and also, ensure that packages are present in OpenSuse Software repo or in OBS

# add packages wanted here
Extra=(
    # for btrfs snaposhots
    timeshift
    cronie
    debianutils
)

# packages neeeded
hypr_package=(
    bc
    curl
    cliphist
    findutils
    gawk
    git
    go
    grim
    gvfs
    gvfs-backends
    hyprsunset
    ImageMagick
    inxi
    jq
    kitty
    kvantum-manager
    kvantum-qt5
    kvantum-qt6
    kvantum-themes
    libqt5-qtdeclarative-tools
    libQt5QuickControls2-devel
    qt6-declarative-imports
    qt6-declarative-tools
    libnotify-tools
    nano
    openssl
    pamixer
    pavucontrol
    pulseaudio-utils
    playerctl
    polkit-gnome
    xfce-polkit
    python312-requests
    python312-pip
    python311-pyquery
    python312-pyquery
    qt5ct
    qt6ct
    qt6-svg-devel
    rofi
    rsync
    slurp
    swappy
    SwayNotificationCenter
    awww
    unzip # required later
    wget
    wayland-protocols-devel
    wl-clipboard
    xdg-user-dirs
    xdg-utils
    xwayland
)

# the following packages can be deleted. however, dotfiles may not work properly
hypr_package_2=(
    brightnessctl
    btop
    cava
    fastfetch
    mousepad
    mpv
    mpv-mpris
    nvtop
    qalculate-gtk
    yad
)

# The following will be installed with NO recommends
package_no_recommends=(
    waybar
    loupe
    gnome-system-monitor
    NetworkManager-applet
)

# List of packages to uninstall as it conflicts some packages
uninstall=(
    mako
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
LOG="Install-Logs/install-$(date +%d-%H%M%S)_hypr-pkgs.log"
# Check rofi presence and version (skip if >= 2.00)
skip_rofi=false
if rpm -q rofi &>/dev/null; then
    rofi_version=$(rpm -q --qf '%{VERSION}' rofi 2>/dev/null)
    if [ -n "$rofi_version" ] && [ "$(printf '%s\n' "2.00" "$rofi_version" | sort -V | head -n1)" = "2.00" ]; then
        skip_rofi=true
        echo "${NOTE} Rofi $rofi_version detected (>= 2.00). Skipping removal/reinstall." | tee -a "$LOG"
    fi
fi

# conflicting packages removal
overall_failed=0
printf "\n%s - ${SKY_BLUE}Removing some packages${RESET} as it conflicts with KooL's Hyprland Dots \n" "${NOTE}"
for PKG in "${uninstall[@]}"; do
    if [ "$PKG" = "rofi" ] && [ "$skip_rofi" = "true" ]; then
        continue
    fi
    uninstall_package "$PKG" 2>&1 | tee -a "$LOG"
    if [ $? -ne 0 ]; then
        overall_failed=1
    fi
done

if [ $overall_failed -ne 0 ]; then
    echo -e "${ERROR} Some packages failed to uninstall. Please check the log."
fi

printf "\n%.0s" {1..1}

# Installation of main components
printf "\n%s - Installing ${SKY_BLUE}KooL's hyprland necessary packages${RESET} .... \n" "${NOTE}"

for PKG1 in "${hypr_package[@]}" "${hypr_package_2[@]}" "${Extra[@]}"; do
    if [ "$PKG1" = "rofi" ] && [ "$skip_rofi" = "true" ]; then
        continue
    fi
    install_package "$PKG1" "$LOG"
done

for PKG_N in "${package_no_recommends[@]}"; do
    install_package_no "$PKG_N" "$LOG"
done
# Ensure rofi is installed (some repos may fail during the main batch)
if ! rpm -q rofi &>/dev/null; then
    echo "${WARN} rofi is missing after the main install batch. Attempting install..." | tee -a "$LOG"
    install_package rofi "$LOG"
    if ! rpm -q rofi &>/dev/null; then
        echo "${WARN} rofi still missing after zypper install. Trying opi..." | tee -a "$LOG"
        install_package_opi rofi "$LOG"
    fi
fi

# update home libraries
xdg-user-dirs-update

printf "\n%.0s" {1..2}
