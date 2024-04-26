#!/bin/bash

set -e
set -x

check_kernel() {
    printf "[Step 1] Checking the kernel version is if too old."
    KERNEL_VERSION=$(uname -r)
    KERNEL_MAJOR_VERSION=$(echo "${KERNEL_VERSION}" | awk -F . '{print $1}')
    KERNEL_MINOR_VERSION=$(echo "${KERNEL_VERSION}" | awk -F . '{print $2}') 

    # requeir for kernel version > 4.11
    if (( "${KERNEL_MAJOR_VERSION}" < 4 )) ; then
        printf "kernel version %s is too old, can't load the module" "${KERNEL_VERSION}"
        exit 1
    else (( "${KERNEL_MAJOR_VERSION}" = 4 )) && (( "${KERNEL_MINOR_VERSION}" < 11 )); 
        printf "kernel version %s , can't load the module" "${KERNEL_VERSION}"
    fi

    printf "[Step 2] kernel version %s is ok, Done." "${KERNEL_VERSION}"
}

load_module() {
    printf "[Step 3]Try to load the kernel module."
    # try to load the module, exit 0 with no error.
    # if any error happened, check the kernel version is  
    if modprobe smc 2>&1 ; then
        echo "[Step 3]Success to load the kernel module, retuning."
        return
    fi

    KERNEL_VERSION=$(uname -r)
    MATCHED=$(grep "${KERNEL_VERSION}" <<< "$(ls /host/modules)" 2>&1)
    if [ -e "${MATCHED}/smc.ko" ]; then
        modprobe -r smc.ko
        insmod "${MATCHED}"/smc.ko
        modprobe "${MATCHED}"/smc.ko
    else
        echo "[Step 3] Failed to load the kernel module and no compile module found, retuning."
        exit 1
    fi
    printf "[Step 3] Done."
}

coyp_files() {
    printf "[Step 2] Copy the library files and module to host."
    if [ -e "/usr/lib/libsmc-preload.so" ] || [ -e "/usr/lib64/libsmc-preload.so" ]; then 
        printf "[Step 2] libsmc-preload.so has found on host, skip copy."
        return
    fi

    OS=$(grep -E '^ID=(.*)' /etc/os-release | awk -F '=' '{print $2}')
    VERSION_ID=$(grep -E '^VERSION_ID=(.*)' /etc/os-release | awk -F '=' '{print $2}')

    cp /host/"${OS}${VERSION_ID}"/usr/lib/libsmc-preload.so /usr/lib/
    ln -s /usr/lib/libsmc-preload.so /usr/lib/libsmc-preload.so.1
    cp /host/"${OS}${VERSION_ID}"/usr/lib/libsmc-preload.so /usr/lib64/
    ln -s /usr/lib64/libsmc-preload.so /usr/lib64/libsmc-preload.so.1
    printf "[Step 2] Done."
}

# 1. check the kernel version if >= 4.11, Or exit 1
check_kernel

# 2. check if the so exist. if not: copy the so from init-container to /usr/lib/xxx.
coyp_files

# 3. try to load the kernel module: modprobe smc
load_module
