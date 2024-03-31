#!/bin/sh

# This file was modified from Ventoy2Disk to be used with UUI.

# UUI is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 

#  Universal USB Installer Copyright https://pendrivelinux.com
#  Updates by Robert E. Novak aka REN
#  sailnfool@gmail.com
#  Cebu, Philippines
#_____________________________________________________________________
# Rev.|Aut| Date     | Notes
#_____________________________________________________________________
# 1.0 |REN|03/30/2024| Update by Robert E. Novak
#                    | Added directions on how to re-do the initial
#                    | installation of the package
#                    | moved the logfile into /tmp (to avoid permission
#                    | trouble.  Gave the logfile a distinctive name
#                    | that identifies the creating script, date and
#                    | time of the logfile.
#_____________________________________________________________________
#

OLDDIR=$(pwd)

if ! [ -f ./tool/ventoy_lib.sh ]; then
    if [ -f ${0%UUI2Disk.sh}/tool/ventoy_lib.sh ]; then
        cd ${0%UUI2Disk.sh}    
    fi
fi

if [ -f ./ventoy/version ]; then
    curver=$(cat ./ventoy/version) 
fi

if uname -m | grep -E -q 'aarch64|arm64'; then
    export TOOLDIR=aarch64
elif uname -m | grep -E -q 'x86_64|amd64'; then
    export TOOLDIR=x86_64
elif uname -m | grep -E -q 'mips64'; then
    export TOOLDIR=mips64el
else
    export TOOLDIR=i386
fi
export PATH="./tool/$TOOLDIR:$PATH"

logger=/tmp/${0##*/}_$(date '+%F%R')_$$_log.txt
echo "log is found in ${logger}" | tee -a ${logger}

echo " The following packages will be installed:" | tee -a ${logger}
echo " UUI files with Ventoy Bootloader: $curver  $TOOLDIR" | tee -a ${logger}
echo "*************************************************" | tee -a ${logger}
echo "" | tee -a ${logger}

if ! [ -f ./boot/boot.img ]; then
    if [ -d ./grub ]; then
        echo "Don't run this script here,"
	echo "please download the released install package,"
	echo "and run the script in it."
	echo "As of March 30, 2024 perform the following steps:"
	echo "cd ~/Desktop"
	echo "wget https://pendrivelinux.com/downloads/UUI4Linux.tar.gz"
	echo "tar xzvf UUI4Linux.tar.gz"
	echo "cd UUI4Linux"
	echo "chmod +x UUI.sh && ./UUI.sh"
    else
        echo "Please run under the correct directory!" 
    fi
    exit 1
fi

whoami | tee -a ${logger}
echo "############# $* [$TOOLDIR] ################" | tee -a ${logger}
date |tee -a ${logger}

#decompress tool
echo "decompress tools" |tee -a ${logger}
cd ./tool/$TOOLDIR

ls *.xz > /dev/null 2>&1
if [ $? -eq 0 ]; then
    # The following is dangerous!
    [ -f ./xzcat ] && chmod +x ./xzcat

    for file in $(ls *.xz); do
        echo "decompress $file" |tee -a ${logger}
        xzcat $file > ${file%.xz}
        [ -f ./${file%.xz} ] && chmod +x ./${file%.xz}
        [ -f ./$file ] && rm -f ./$file
    done
fi

cd ../../
chmod +x -R ./tool/$TOOLDIR


if [ -f /bin/bash ]; then
    /bin/bash ./tool/UUIWorker.sh $*
else
    ash ./tool/UUIWorker.sh $*
fi

if [ -n "$OLDDIR" ]; then 
    CURDIR=$(pwd)
    if [ "$CURDIR" != "$OLDDIR" ]; then
        cd "$OLDDIR"
    fi
fi
