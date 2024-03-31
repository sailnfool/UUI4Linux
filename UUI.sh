#!/bin/bash

#  Universal USB Installer is free software: you can redistribute
#  it and/or modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation, either
#  version 2 of the License, or any later version.

#  It is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this software. If not,
#  see <https://www.gnu.org/licenses/>.

#  Universal USB Installer Copyright https://pendrivelinux.com
#  Updates by Robert E. Novak aka REN
#  sailnfool@gmail.com
#  Cebu, Philippines
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|03/30/2024| Initial Update by Robert E. Novak
#                    | Fixed read choice to force to lower case
#                    | Fixed Menu prompt to reflect that
#                    | defined mnemonic name to ansi code for clearing
#                    | the screen and put it in rentoy_lib.sh
#_____________________________________________________________________
#
VENT_VER="ventoy-1.0.97"
# . ./$VENT_VER/tool/ventoy_lib.sh
source ./${VENT_VER}/tool/rentoy_lib.sh
  echo -e ${ansi_ClearScreen}

# Declare arrays to store device names, sizes, and models
declare -a devices
declare -a sizes
declare -a models

# Detect the package manager and set package manager-specific variables
if command -v yum &> /dev/null; then
  # echo "Looks like you might be using CentOS or related"
  PACKAGE_MANAGER="yum"
  INSTALL_COMMAND="install"
  PRE_INST="rpm -v --import http://li.nux.ro/download/nux/RPM-GPG-KEY-nux.ro"
  PRE_INST2="sudo rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm"
  PACKAGE_NAME="exfat-utils fuse-exfat"
elif command -v dnf &> /dev/null; then
  PACKAGE_MANAGER="dnf"
  INSTALL_COMMAND="install"
elif command -v apt-get &> /dev/null; then
  PACKAGE_MANAGER="apt-get"
  INSTALL_COMMAND="install"
  PACKAGE_NAME="exfat-fuse"
elif command -v apt &> /dev/null; then
  PACKAGE_MANAGER="apt"
  INSTALL_COMMAND="install"
  PACKAGE_NAME="exfat-fuse"
else
  echo "Unsupported distribution. Exiting..."
  exit 1
fi

# Check if exFAT support is installed, and if not, install it
check_exfat_support() {
  if ! command -v exfatfsck &> /dev/null; then
    echo "exFAT support is not installed. Installing exfat-fuse..."
    sudo $PACKAGE_MANAGER update
    sudo $PRE_INST
    sudo $PRE_INST2
    sudo $PACKAGE_MANAGER $INSTALL_COMMAND $PACKAGE_NAME -y
  else
    echo "exFAT support is already installed."
  fi
}

########################################################################
# Fixed to allow upper/lower case input and document that
########################################################################
declare -l choice
choice="a"
# Function to refresh the list of devices
refresh_devices() {
  echo "***************** UUI.sh for Linux ***********************"
  # echo ''
  echo "      Welcome to the UUI shell script for Linux."
  echo " This script is used to prepare a drive for use with UUI."
  echo " To get started, find your USB device from the list below."
  echo " Input values are case insensitive."
  echo ''
  echo "   Press the 'r' key to refresh devices. Redetects drives,"
  echo "   'a' key to show all drives (WARNING! be cautious),"
  echo "   'q' key to quit the program, returns you to terminal."
  # echo ''
  echo "**********************************************************"
  echo ''

########################################################################
# The choice for the user is not set before it is used
########################################################################

  devices=()
  sizes=()
  models=()


  # Use lsblk to list all drives
  while read -r device size model rm; do
    # Skip the header line
    # Note that this should never happen due to the '-n' option given
    # to lsblk
    if [ "$device" == "NAME" ] && [ "$size" == "SIZE" ] && \
	    [ "$model" == "MODEL" ] && [ "$rm" == "RM" ]; then
      continue
    fi

    # Set show_all to "a" if the 'a' option is selected
    if [ "$choice" == "a" ]; then
      show_all="a"
    fi

    # Check if the user wants to display all drives
    if [ "$show_all" == "a" ] || [ "$rm" == "1" ] || [ "$rm" == "0" ]; then
      devices+=("$device")
      sizes+=("$size")
      models+=("$model")
    fi

  done < <(lsblk -ndo NAME,SIZE,MODEL,RM /dev/sd[a-z])

  # Remove entries for devices that are no longer present
  local i=0
  while [ $i -lt ${#devices[@]} ]; do
    if [ ! -e "/dev/${devices[$i]}" ]; then
      unset devices[$i]
      unset sizes[$i]
      unset models[$i]
    else
      ((i++))
    fi
  done

  # Reindex the arrays to eliminate gaps
  devices=("${devices[@]}")
  sizes=("${sizes[@]}")
  models=("${models[@]}")
}

# Function to unmount and install Ventoy boot files
install_ventoy() {
  local selected_device="$1"
  echo
  echo "Selected: $selected_device"

# Getting mountpoint
  echo "Checking /dev/${selected_device}1 mountpoint"
  mountpoint=$(df -P "/dev/${selected_device}1" | awk 'NR==2 {print $6}')
  echo "${mountpoint}"

# Change directory to where the other scripts are run.
# echo Your current directory is "$(pwd)"
if [ -d "${VENT_VER}" ]; then
   # echo "Changing directory to ${VENT_VER}"
    cd $VENT_VER
else
   # echo "Changing directory to /UUI4Linux/${VENT_VER}"
    cd $(pwd)/UUI4Linux/$VENT_VER
fi

   if [ -d "${mountpoint}/UUI" ]; then
     sudo umount "/dev/$selected_device"
     echo -e "\n*************************************************"
     echo " UUI is installed. But we can upgrade or reinstall."
     sudo ./UUI2Disk.sh -u -L UUI "/dev/$selected_device"
   else
     sudo umount "/dev/$selected_device"
     echo -e "\n*************************************************"
     echo " This device has not yet been prepared."
     sudo ./UUI2Disk.sh -I -L UUI "/dev/$selected_device"
   fi
  exit
}

# Initial refresh of devices
refresh_devices

while true; do
  # Display the list of available USB devices
  echo "Available USB devices:"
  echo
  for ((i = 0; i < ${#devices[@]}; i++)); do
    echo "$(($i + 1))) ${devices[$i]} - ${sizes[$i]} - ${models[$i]}"
  done

  # Prompt the user to choose an action
  echo
  read -p "Enter the number corresponding to your USB device: " choice

  case "$choice" in
    [1-9]*)
      selected_device_index="$((choice - 1))"
      if [ "$selected_device_index" -ge 0 ] && \
	      [ "$selected_device_index" -lt "${#devices[@]}" ]; then
        selected_device="${devices[$selected_device_index]}"
        install_ventoy "$selected_device"
        break
      else
        echo "Invalid selection."
      fi
      ;;
    r)
      echo -e ${ansi_ClearScreen}
      refresh_devices
      echo "Refreshed devices..."
      echo
      ;;
    a)
      echo -e ${ansi_ClearScreen}
      show_all=true
      refresh_devices
      echo "Showing all drives..."
      echo
      ;;
    q)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid choice."
      ;;
  esac
done
