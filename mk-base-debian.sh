#!/bin/bash -e

if [ ! $TARGET ]; then
    echo "---------------------------------------------------------"
    echo "please enter TARGET version number:"
    echo "请输入要构建的根文件系统版本:"
    echo "[0] Exit Menu"
    echo "[1] lite"
    echo "[2] xfce"
    echo "[3] xfce-full"
    echo "---------------------------------------------------------"
    read input

    case $input in
        0)
            exit;;
        1)
            TARGET=lite
            ;;
        2)
            TARGET=xfce
            ;;
        3)
            TARGET=xfce-full
            ARCH=arm64
            ;;
        *)
            echo -e "\033[47;36m input TARGET version number error, exit ! \033[0m"
            exit;;
    esac
    echo -e "\033[47;36m set TARGET=$TARGET...... \033[0m"
fi

if [[ "$RELEASE" == "stretch" || "$RELEASE" == "9" ]]; then
    RELEASE='stretch'
elif [[ "$RELEASE" == "buster" || "$RELEASE" == "10" ]]; then
    RELEASE='buster'
else
    RELEASE='buster'
    echo -e "\033[47;36m set default RELEASE='buster'...... \033[0m"
fi

if [ "$ARCH" == "armhf" ]; then
    ARCH='armhf'
elif [ "$ARCH" == "arm64" ]; then
    ARCH='arm64'
else
    ARCH="arm64"
    echo -e "\033[47;36m set default ARCH=arm64...... \033[0m"
fi

if [ -e linaro-$RELEASE-$TARGET-alip-*.tar.gz ]; then
    rm linaro-$RELEASE-$TARGET-alip-*.tar.gz
fi

sudo rm -rf binary/

cd ubuntu-build-service/$RELEASE-$TARGET-$ARCH

echo -e "\033[36m Staring Download...... \033[0m"

make clean

./configure

make

DATE=$(date +%Y%m%d)
if [ -e linaro-$RELEASE-alip-*.tar.gz ]; then
    sudo chmod 0666 linaro-$RELEASE-alip-*.tar.gz
    mv linaro-$RELEASE-alip-*.tar.gz ../../linaro-$RELEASE-$TARGET-alip-$DATE.tar.gz
else
    echo -e "\e[31m Failed to run livebuild, please check your network connection. \e[0m"
fi
