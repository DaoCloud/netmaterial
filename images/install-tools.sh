#!/bin/bash

set -x
set -e

mkdir -p /host/usr/bin

OS=$(grep -E '^ID=(.*)' /etc/os-release | awk -F '=' '{print $2}')
case "${OS}" in
    ubuntu)
        apt-get update
        apt-get install -y kmod
        apt-get install -y smc-tools
        mkdir /host/usr/lib && cp /usr/lib/libsmc-preload.so /host/usr/lib
        ;;
    centos,fedora)
        yum install -y smc-tools
        mkdir /host/usr/lib64 && cp /usr/lib64/libsmc-preload.so /host/usr/lib64
        ;;
esac

cp /usr/bin/smc* /host/usr/bin