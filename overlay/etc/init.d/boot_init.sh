#!/bin/bash -e

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
board_info() {
    if [[ "$2" == "rk3566" ||  "$2" == "rk3568" ]]; then
        case $1 in
            0000)
                BOARD_NAME='LubanCat-1'
                BOARD_DTB='rk3566-lubancat-1.dtb'
                BOARD_uEnv='uEnvLubanCat1.txt'
                ;;
            0001)
                BOARD_NAME='LubanCat-1IOF'
                BOARD_DTB='rk3566-lubancat-1io.dtb'
                BOARD_uEnv='uEnvLubanCat1IO.txt'
                ;;
            0002)
                BOARD_NAME='LubanCat-1IOB'
                BOARD_DTB='rk3566-lubancat-1io.dtb'
                BOARD_uEnv='uEnvLubanCat1IO.txt'
                ;;
            0100)
                BOARD_NAME='LubanCat-1N'
                BOARD_DTB='rk3566-lubancat-1n.dtb'
                BOARD_uEnv='uEnvLubanCat1N.txt'
                ;;
            0102)
                BOARD_NAME='LubanCat-2IOBI'
                BOARD_DTB='rk3568-lubancat-2io.dtb'
                BOARD_uEnv='uEnvLubanCat2IO.txt'
                ;;
            0200)
                BOARD_NAME='LubanCat-0N'
                BOARD_DTB='rk3566-lubancat-0.dtb'
                BOARD_uEnv='uEnvLubanCatZN.txt'
                ;;
            0201)
                BOARD_NAME='LubanCat-1H'
                BOARD_DTB='rk3566-lubancat-1h.dtb'
                BOARD_uEnv='uEnvLubanCat1H.txt'
                ;;                
            0300)
                BOARD_NAME='LubanCat-0W'
                BOARD_DTB='rk3566-lubancat-0.dtb'
                BOARD_uEnv='uEnvLubanCatZW.txt'
                ;;
            0400)
                BOARD_NAME='LubanCat-2'
                BOARD_DTB='rk3568-lubancat-2.dtb'
                BOARD_uEnv='uEnvLubanCat2.txt'
                ;;
            0402)
                BOARD_NAME='LubanCat-2 v1'
                BOARD_DTB='rk3568-lubancat-2-v1.dtb'
                BOARD_uEnv='uEnvLubanCat2-V1.txt'
                ;;
            0403)
                BOARD_NAME='LubanCat-2 v2'
                BOARD_DTB='rk3568-lubancat-2-v2.dtb'
                BOARD_uEnv='uEnvLubanCat2-V2.txt'
                ;;
            0500 |\
            0600)
                BOARD_NAME='LubanCat-2N'
                BOARD_DTB='rk3568-lubancat-2n.dtb'
                BOARD_uEnv='uEnvLubanCat2N.txt'
                ;;
            0501)
                BOARD_NAME='LubanCat-2H'
                BOARD_DTB='rk3568-lubancat-2h.dtb'
                BOARD_uEnv='uEnvLubanCat2H.txt'
                ;;    
            0700)
                BOARD_NAME='LubanCat-2IOF'
                BOARD_DTB='rk3568-lubancat-2io.dtb'
                BOARD_uEnv='uEnvLubanCat2IO.txt'
                ;;
            0701)
                BOARD_NAME='LubanCat-2IOB'
                BOARD_DTB='rk3568-lubancat-2io.dtb'
                BOARD_uEnv='uEnvLubanCat2IO.txt'
                ;;
            *)
                echo "Device ID Error !!!"
                BOARD_NAME='LubanCat-series.dtb'
                BOARD_DTB='rk356x-lubancat-rk_series.dtb'
                BOARD_uEnv='uEnvLubanCat-series.txt'
                ;;
        esac
    elif [[ "$2" == "rk3588" ||  "$2" == "rk3588s" ]]; then
            case $1 in
            0101)
                BOARD_NAME='LubanCat-4'
                BOARD_DTB='rk3588s-lubancat-4.dtb'
                BOARD_uEnv='uEnvLubanCat4.txt'
                ;;
            0201)
                BOARD_NAME='LubanCat-4IOF'
                BOARD_DTB='rk3588s-lubancat-4io.dtb'
                BOARD_uEnv='uEnvLubanCat4IO.txt'
                ;;
            0301)
                BOARD_NAME='LubanCat-4IOB'
                BOARD_DTB='rk3588s-lubancat-4io.dtb'
                BOARD_uEnv='uEnvLubanCat4IO.txt'
                ;;
            0401)
                BOARD_NAME='LubanCat-5'
                BOARD_DTB='rk3588-lubancat-5.dtb'
                BOARD_uEnv='uEnvLubanCat5.txt'
                ;;
            0501)
                BOARD_NAME='LubanCat-5IOF'
                BOARD_DTB='rk3588-lubancat-5io.dtb'
                BOARD_uEnv='uEnvLubanCat5IO.txt'
                ;;
            0601)
                BOARD_NAME='LubanCat-5IOB'
                BOARD_DTB='rk3588-lubancat-5io.dtb'
                BOARD_uEnv='uEnvLubanCat5IO.txt'
                ;;
            *)
                echo "Device ID Error !!!"
                BOARD_NAME='LubanCat-series.dtb'
                BOARD_DTB='rk3588-lubancat-rk_series.dtb'
                BOARD_uEnv='uEnvLubanCat-series.txt'
                ;;
        esac
    fi

    echo "BOARD_NAME:"$BOARD_NAME
    echo "BOARD_DTB:"$BOARD_DTB
    echo "BOARD_uEnv:"$BOARD_uEnv
}

# voltage_scale
# 1.7578125 8bit
# 0.439453125 12bit
get_index(){
    ADC_RAW=$1
    INDEX=0xff

    if [ $(echo "$ADC_voltage_scale > 1 "|bc) -eq 1 ] ; then
        declare -a ADC_INDEX=(229 344 460 595 732 858 975 1024)
    else
        declare -a ADC_INDEX=(916 1376 1840 2380 2928 3432 3900 4096)
    fi

    for i in 00 01 02 03 04 05 06 07; do
        if [ $ADC_RAW -lt ${ADC_INDEX[$i]} ]; then
            INDEX=$i
            break
        fi
    done
}

board_id() {
    ADC_voltage_scale=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage_scale)
    echo "ADC_voltage_scale:"$ADC_voltage_scale

    SOC_type=$(cat /proc/device-tree/compatible | cut -d,  -f 3)
    echo "SOC_type:"$SOC_type

    ADC_CH2_RAW=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage2_raw)
    echo "ADC_CH2_RAW:"$ADC_CH2_RAW
    ADC_CH3_RAW=$(cat /sys/bus/iio/devices/iio\:device0/in_voltage3_raw)
    echo "ADC_CH3_RAW:"$ADC_CH3_RAW

    get_index $ADC_CH2_RAW
    ADC_CH2_INDEX=$INDEX

    get_index $ADC_CH3_RAW
    ADC_CH3_INDEX=$INDEX

    BOARD_ID=$ADC_CH2_INDEX$ADC_CH3_INDEX
    echo "BOARD_ID:"$BOARD_ID
}

board_id
board_info ${BOARD_ID} ${SOC_type}

# first boot configure

until [ -e "/dev/disk/by-partlabel/boot" ]
do
    echo "wait /dev/disk/by-partlabel/boot"
    sleep 0.1
done

if [ ! -e "/boot/boot_init" ] ; then
    if [ ! -e "/dev/disk/by-partlabel/userdata" ] ; then
        if [ ! -L "/boot/rk-kernel.dtb" ] ; then
            for x in $(cat /proc/cmdline); do
                case $x in
                root=*)
                    Root_Part=${x#root=}
                    Boot_Part="${Root_Part::-2}"p2
                    ;;
                esac
            done

            mount "$Boot_Part" /boot
            echo "$Boot_Part  /boot  auto  defaults  0 2" >> /etc/fstab
        fi

        service lightdm stop || echo "skip error"

        apt install -fy --allow-downgrades /boot/kerneldeb/* || true
        apt-mark hold linux-headers-$(uname -r) linux-image-$(uname -r) || true

        ln -sf dtb/$BOARD_DTB /boot/rk-kernel.dtb
        ln -sf $BOARD_uEnv /boot/uEnv/uEnv.txt

        touch /boot/boot_init
        rm -f /boot/kerneldeb/*
        cp -f /boot/logo_kernel.bmp /boot/logo.bmp
        reboot
    else
        echo "PARTLABEL=oem  /oem  ext2  defaults  0 2" >> /etc/fstab
        echo "PARTLABEL=userdata  /userdata  ext2  defaults  0 2" >> /etc/fstab
        touch /boot/boot_init
    fi
fi
