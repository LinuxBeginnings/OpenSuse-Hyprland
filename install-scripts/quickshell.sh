#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# quickshell - for desktop overview replacing AGS
# installing via opi

quick=(
  quickshell
  qt6-qt5compat-imports
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

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
  sudo zypper ar -f https://download.opensuse.org/repositories/home:darix:playground/openSUSE_Tumbleweed/home:darix:playground.repo darix-playground 2>&1 | tee -a "$LOG"
fi

# Installing packages via zypper
printf "${NOTE} Installing ${SKY_BLUE}quickshell for Desktop Overview${RESET} ...\n"
for pkg in "${quick[@]}"; do
  printf "${NOTE} Installing ${SKY_BLUE}${pkg}${RESET}...\n" | tee -a "$LOG"
  sudo zypper in -y "$pkg" 2>&1 | tee -a "$LOG"
done
