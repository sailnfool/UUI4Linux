#  Universal USB Installer Copyright https://pendrivelinux.com
#  Updates by Robert E. Novak aka REN
#  sailnfool@gmail.com
#  Cebu, Philippines
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|03/30/2024| Update by Robert E. Novak
#                    | moved function mount_disk to rentoy_lib.sh
#                    | REN version of ventoy_lib.sh
#_____________________________________________________________________
#
#if [[ -z "${__rentoy_lib}" ]]; then
	export __rentoy_lib=1

########################################################################
# Shouldn't the following function be in "ventoy_lib.sh"?
# Note that the only invocation of this function in UUIWorker is
# commented out. (REN)
# moved this function to rentoy_lib.sh
########################################################################
mount_disk() {
    DiskOrPart="$1"
    # Define the mount point (where the disk/partition will be mounted)
    MOUNT_POINT="/mnt/mounted_disk"  # You can choose a different mount point

    # Check if the mount point directory exists, and if not, create it
    if [ ! -d "$MOUNT_POINT" ]; then
        mkdir -p "$MOUNT_POINT"
    fi

    # Mount the disk/partition to the specified mount point
    mount "$DiskOrPart" "$MOUNT_POINT"
    
    # Check if the mount was successful
    if [ $? -eq 0 ]; then
        echo "Disk/Partition $DiskOrPart has been successfully mounted to $MOUNT_POINT."
    else
        echo "Failed to mount $DiskOrPart to $MOUNT_POINT."
    fi
}

########################################################################
# Define ansi escape codes (should be self-evident)
########################################################################
	ansi_RESTORE='\033[0m'
	ansi_RED='\033[00;31m'
	ansi_GREEN='\033[00;32m'
	ansi_YELLOW='\033[00;33m'
	ansi_ClearScreen='\0033\0143'
#endif #if [[ -z "${__rentoy_lib}" ]]; then

