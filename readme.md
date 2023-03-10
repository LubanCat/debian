## Introduction

A set of shell scripts that will build GNU/Linux distribution rootfs image
for rockchip platform.

## Available Distro

* Debian 10 (Buster-X11 and Wayland)~~

```
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## Usage for 32bit Debian 10 (Buster-32)

### Building debian system from linaro

Building a base debian system by ubuntu-build-service from linaro.

```
	RELEASE=buster TARGET=base ARCH=armhf ./mk-base-debian.sh
```

Building a desktop debian system by ubuntu-build-service from linaro.

```
	RELEASE=buster TARGET=desktop ARCH=armhf ./mk-base-debian.sh
```

### Building overlay with rockchip audio/video hardware accelerated

Building with overlay with rockchip debian rootfs:

```
	RELEASE=buster ARCH=armhf ./mk-rootfs.sh
```

Building with overlay with rockchip debug debian rootfs:

```
	VERSION=debug ARCH=armhf ./mk-rootfs-buster.sh
```

### Creating roofs image

Creating the ext4 image(linaro-rootfs.img):

```
	./mk-image.sh
```

---

## Usage for 64bit Debian 10 (Buster-64)

如果需要构建console版本（控制台版，无桌面），执行1.a、2.a。
如果需要构建desktop版本（带桌面），执行1.b、2.b。

Building a base debian system by ubuntu-build-service from linaro.

构建一个基本的 debian 系统。

```
# 1.a 构建无桌面基础 debian 系统
RELEASE=buster TARGET=lite ARCH=arm64 ./mk-base-debian.sh

# 1.b 构建带桌面基础 debian 系统
RELEASE=buster TARGET=desktop ARCH=arm64 ./mk-base-debian.sh
```

Building the rk-debian rootfs and creating the ext4 image

添加根文件系统 rk overlay 层，并打包ubuntu-rootfs镜像

```
# 2.a 
VERSION=debug ARCH=arm64 ./mk-buster-lite.sh

# 2.b
# SOC参数根据实际情况选择，如rk356x、rk3588
VERSION=debug ARCH=arm64 SOC=rk356x ./mk-buster-desktop.sh
```

---

## Cross Compile for ARM Debian

[Docker + Multiarch](http://opensource.rock-chips.com/wiki_Cross_Compile#Docker)

## Package Code Base

Please apply [those patches](https://github.com/rockchip-linux/rk-rootfs-build/tree/master/packages-patches) to release code base before rebuilding!

## License information

Please see [debian license](https://www.debian.org/legal/licenses/)

## FAQ

- noexec or nodev issue
noexec or nodev issue /usr/share/debootstrap/functions: line 1450:
../rootfs/ubuntu-build-service/buster-desktop-arm64/chroot/test-dev-null:
Permission denied E: Cannot install into target
...
mounted with noexec or nodev

Solution: mount -o remount,exec,dev xxx (xxx is the mount place), then rebuild it.
