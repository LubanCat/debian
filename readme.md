## 介绍

A set of shell scripts that will build GNU/Linux distribution rootfs image
for rockchip platform.

## 依赖安装

构建环境建议使用Ubuntu18.04级以上版本，推荐使用Ubuntu20.04

```
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## 构建 Debian10 镜像（仅支持64bit）

注意：此分支仅支持构建RK3566或RK3568处理器使用的Debian10镜像

如果需要构建console版本（控制台版，无桌面），执行1.a、2.a。
如果需要构建desktop版本（带桌面），执行1.b、2.b。

step.1 构建一个基本的 debian 系统。

运行以下脚本，根据提示选择将要构建的debian系统类型

- lite：无桌面版本，可以通过终端连接板卡
- xfce：安装了xfce4套件的桌面版
- xfce-full：安装了xfce4套件+更多推荐软件包

```
# 构建基础debain系统
./mk-base-debian.sh
```


step.2 添加根文件系统 rk overlay 层，并打包ubuntu-rootfs镜像

运行以下脚本，根据提示选择将要构建的debian系统类型

```
./mk-buster-rootfs.sh
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
