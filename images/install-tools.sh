#!/bin/bash

set -x
set -e

make -p /host/"${OS}${VERSION_ID}"/usr/bin && make -p /host/"${OS}${VERSION_ID}"/usr/lib
OS=$(grep -E '^ID=(.*)' /etc/os-release | awk -F '=' '{print $2}')
VERSION_ID=$(grep -E '^VERSION_ID=(.*)' /etc/os-release | awk -F '=' '{print $2}')
case "${OS}" in
    ubuntu)
        apt-get update
        apt-get install -y kmod
        apt-get install -y smc-tools
        cp /usr/lib/libsmc-preload.so /host/"${OS}${VERSION_ID}"/usr/lib
        ;;
    centos,fedora)
        yum install -y smc-tools
        cp /usr/lib64/libsmc-preload.so /host/"${OS}${VERSION_ID}"/usr/lib
        ;;
esac

cp /usr/bin/smc* /host/"${OS}${VERSION_ID}"/usr/bin
