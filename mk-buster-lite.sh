#!/bin/bash -e

# Directory contains the target rootfs
TARGET_ROOTFS_DIR="binary"

if [ ! $SOC ]; then
	SOC="rk3568"
fi

install_packages() {
    case $SOC in
        rk3399|rk3399pro)
		MALI=midgard-t86x-r18p0
		ISP=rkisp
		RGA=rga
		;;
        rk3328)
		MALI=utgard-450
		ISP=rkisp
		RGA=rga
		;;
        rk356x|rk3566|rk3568)
		MALI=bifrost-g52-g2p0
		ISP=rkaiq_rk3568
		RGA=rga
		MIRROR=carp-rk356x
		;;
        rk3588|rk3588s)
		ISP=rkaiq_rk3588
		MALI=valhall-g610-g6p0
		RGA=rga2
		# MIRROR=carp-rk3588
		;;
    esac
}

case "${ARCH:-$1}" in
	arm|arm32|armhf)
		ARCH=armhf
		;;
	*)
		ARCH=arm64
		;;
esac

echo -e "\033[36m Building for $ARCH \033[0m"

if [ ! $VERSION ]; then
	VERSION="release"
fi

if [ ! -e linaro-buster-lite-alip-*.tar.gz ]; then
	echo -e "\033[36m Run mk-base-debian.sh first \033[0m"
	exit -1
fi

finish() {
	sudo umount $TARGET_ROOTFS_DIR/dev
	exit -1
}
trap finish ERR

echo -e "\033[36m Extract image \033[0m"
sudo rm -rf $TARGET_ROOTFS_DIR
sudo tar -xpf linaro-buster-lite-alip-*.tar.gz

# packages folder
sudo mkdir -p $TARGET_ROOTFS_DIR/packages
sudo cp -rf packages/$ARCH/* $TARGET_ROOTFS_DIR/packages

#GPU/RGA/CAMERA packages folder
install_packages
sudo mkdir -p $TARGET_ROOTFS_DIR/packages/install_packages
sudo cp -rpf packages/$ARCH/libmali/libmali-*$MALI*-x11*.deb $TARGET_ROOTFS_DIR/packages/install_packages
sudo cp -rpf packages/$ARCH/camera_engine/camera_engine_$ISP*.deb $TARGET_ROOTFS_DIR/packages/install_packages
sudo cp -rpf packages/$ARCH/$RGA/*.deb $TARGET_ROOTFS_DIR/packages/install_packages

# overlay folder
sudo cp -rf overlay/* $TARGET_ROOTFS_DIR/

# overlay-firmware folder
sudo cp -rf overlay-firmware/* $TARGET_ROOTFS_DIR/

# overlay-debug folder
# adb, video, camera  test file
if [ "$VERSION" == "debug" ]; then
	sudo cp -rf overlay-debug/* $TARGET_ROOTFS_DIR/
fi

# adb
if [[ "$ARCH" == "armhf" && "$VERSION" == "debug" ]]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-32 $TARGET_ROOTFS_DIR/usr/bin/adbd
elif [[ "$ARCH" == "arm64" && "$VERSION" == "debug" ]]; then
	sudo cp -f overlay-debug/usr/local/share/adb/adbd-64 $TARGET_ROOTFS_DIR/usr/bin/adbd
fi

echo -e "\033[36m Change root.....................\033[0m"
if [ "$ARCH" == "armhf" ]; then
	sudo cp /usr/bin/qemu-arm-static $TARGET_ROOTFS_DIR/usr/bin/
elif [ "$ARCH" == "arm64"  ]; then
	sudo cp /usr/bin/qemu-aarch64-static $TARGET_ROOTFS_DIR/usr/bin/
fi
sudo mount -o bind /dev $TARGET_ROOTFS_DIR/dev

cat << EOF | sudo chroot $TARGET_ROOTFS_DIR

if [ $MIRROR ]; then
	echo "deb [arch=arm64] https://cloud.embedfire.com/mirrors/ebf-debian $MIRROR main" | sudo tee -a /etc/apt/sources.list
	curl https://Embedfire.github.io/keyfile | sudo apt-key add -
fi

apt-get update
apt-get upgrade -y

chmod o+x /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod +x /etc/rc.local

export APT_INSTALL="apt-get install -fy --allow-downgrades"

echo -e "\033[47;36m ---------- LubanCat -------- \033[0m"
\${APT_INSTALL} toilet xinput

passwd root <<IEOF
root
root
IEOF

systemctl disable apt-daily.service
systemctl disable apt-daily.timer

systemctl disable apt-daily-upgrade.timer
systemctl disable apt-daily-upgrade.service

# set localtime
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# allow root login
sed -i '/pam_securetty.so/s/^/# /g' /etc/pam.d/login

apt install -fy --allow-downgrades /packages/install_packages/*.deb

\${APT_INSTALL} ttf-wqy-zenhei xfonts-intl-chinese

echo -e "\033[47;36m ----- power management ----- \033[0m"
\${APT_INSTALL} pm-utils triggerhappy
cp /etc/Powermanager/triggerhappy.service  /lib/systemd/system/triggerhappy.service

echo -e "\033[47;36m ------ Setup Video---------- \033[0m"
\${APT_INSTALL} /packages/mpp/*
\${APT_INSTALL} /packages/gst-rkmpp/*.deb
# \${APT_INSTALL} /packages/gstreamer/*.deb
# \${APT_INSTALL} /packages/gst-plugins-base1.0/*.deb
# \${APT_INSTALL} /packages/gst-plugins-good1.0/*.deb
# \${APT_INSTALL} /packages/gst-plugins-ugly1.0/*.deb

echo -e "\033[47;36m -----  Install Camera ----- - \033[0m"
# \${APT_INSTALL} /packages/libv4l/*.deb

echo -e "\033[47;36m ------- Install libdrm ------ \033[0m"
\${APT_INSTALL} /packages/libdrm/*.deb

echo -e "\033[47;36m ----- Install pcmanfm ------- \033[0m"
#\${APT_INSTALL} /packages/pcmanfm/*.deb

# echo -e "\033[47;36m ------ Install blueman ------ \033[0m"
# \${APT_INSTALL} blueman
# echo exit 101 > /usr/sbin/policy-rc.d
# chmod +x /usr/sbin/policy-rc.d
# \${APT_INSTALL} blueman
# rm -f /usr/sbin/policy-rc.d

if [ -e "/usr/lib/aarch64-linux-gnu" ] ;
then
echo -e "\033[47;36m ------- move rknpu2 --------- \033[0m"
mv /packages/rknpu2/*.tar  /
fi

echo -e "\033[47;36m ----- Install rktoolkit ----- \033[0m"
\${APT_INSTALL} /packages/rktoolkit/*.deb

echo -e "\033[47;36m ----- Install pulseaudio ---- \033[0m"
mv /etc/pulse/daemon.conf /
mv /etc/pulse/default.pa /
yes|\${APT_INSTALL} /packages/pulseaudio/*.deb
mv /daemon.conf /default.pa /etc/pulse/

echo -e "\033[47;36m --- remove unused packages -- \033[0m"
apt remove --purge -fy linux-firmware*

# mark package to hold
apt list --installed | grep -v oldstable | cut -d/ -f1 | xargs apt-mark hold

# mark rga package to unhold
apt-mark unhold librga2 librga-dev librga2-dbgsym

echo -e "\033[47;36m ------- Custom Script ------- \033[0m"
systemctl mask systemd-networkd-wait-online.service
systemctl mask NetworkManager-wait-online.service
rm /lib/systemd/system/wpa_supplicant@.service

echo -e "\033[47;36m  ---------- Clean ----------- \033[0m"
if [ -e "/usr/lib/arm-linux-gnueabihf/dri" ] ;
then
        cd /usr/lib/arm-linux-gnueabihf/dri/
        cp kms_swrast_dri.so swrast_dri.so /
        rm /usr/lib/arm-linux-gnueabihf/dri/*.so
        mv /*.so /usr/lib/arm-linux-gnueabihf/dri/
elif [ -e "/usr/lib/aarch64-linux-gnu/dri" ];
then
        cd /usr/lib/aarch64-linux-gnu/dri/
        cp kms_swrast_dri.so swrast_dri.so /
        rm /usr/lib/aarch64-linux-gnu/dri/*.so
        mv /*.so /usr/lib/aarch64-linux-gnu/dri/
        rm /etc/profile.d/qt.sh
fi
cd -

rm -rf /var/lib/apt/lists/*
rm -rf /var/cache/
rm -rf /packages/

EOF

sudo umount $TARGET_ROOTFS_DIR/dev

IMAGE_VERSION=lite ./mk-image.sh 