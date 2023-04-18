## 介绍

A set of shell scripts that will build GNU/Linux distribution rootfs image
for rockchip platform.

## 适用板卡

- 使用RK3566处理器的LubanCat板卡
- 使用RK3568处理器的LubanCat板卡

## 依赖安装

构建主机环境最低要求Ubuntu18.04及以上版本，推荐使用Ubuntu20.04

```
sudo apt-get install binfmt-support qemu-user-static
sudo dpkg -i ubuntu-build-service/packages/*
sudo apt-get install -f
```

## 构建 Debian10 镜像（仅支持64bit）

- lite：控制台版，无桌面
- xfce：桌面版，使用xfce4桌面套件
- xfce-full：桌面版，使用xfce4桌面套件+更多推荐软件包


#### step1.构建基础 Debian 系统。

```
# 运行以下脚本，根据提示选择要构建的版本
./mk-base-debian.sh
```
#### step2.添加 rk overlay 层,并打包linaro-rootfs镜像

```
# 运行以下脚本，根据提示选择要构建Debian的版本
./mk-buster-rootfs.sh
```
