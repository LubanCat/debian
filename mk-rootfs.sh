#!/bin/bash -e
if [[ "$RELEASE" == "stretch" || "$RELEASE" == "9" ]]; then
	RELEASE='stretch'
elif [[ "$RELEASE" == "buster" || "$RELEASE" == "10" ]]; then
	RELEASE='buster'
else
    echo -e "\033[36m please input the os type,stretch or buster...... \033[0m"
fi

echo "VERSION="$RK_ROOTFS_DEBUG "TARGET="$RK_ROOTFS_TARGET "SOC="$SOC "./mk-"$RELEASE"-rootfs.sh"

./mk-"$RELEASE"-rootfs.sh
