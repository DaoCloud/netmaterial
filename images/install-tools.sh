#!/bin/bash

set -x
set -e

OS=$(grep -E '^ID=(.*)' /etc/os-release | awk -F '=' '{print $2}' | tr -d '"')
VERSION_ID=$(grep -E '^VERSION_ID=(.*)' /etc/os-release | awk -F '=' '{print $2}' | tr -d '"' | tr -d '.')
mkdir -p /host/${OS}${VERSION_ID}/usr/bin && mkdir -p /host/${OS}${VERSION_ID}/usr/lib
case "${OS}" in
    ubuntu)
        apt-get update
        apt-get install -y kmod
        apt-get install -y smc-tools
        if [ "${VERSION_ID}" == "2004" ]; then
            cp /usr/lib/x86_64-linux-gnu/libsmc-preload.so /host/${OS}${VERSION_ID}/usr/lib
        else 
            cp /usr/lib/libsmc-preload.so /host/${OS}${VERSION_ID}/usr/lib
        fi
        ;;
    centos|fedora)
        yum install -y smc-tools
        cp /usr/lib64/libsmc-preload.so /host/${OS}${VERSION_ID}/usr/lib
        ;;
    *)
        echo "Unsupported OS: ${OS}${VERSION_ID}."
        exit 1
        ;;
esac

cp /usr/bin/smc* /host/${OS}${VERSION_ID}/usr/bin
