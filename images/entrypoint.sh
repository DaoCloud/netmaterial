#!/bin/sh

set -e

check_kernel() {
    printf "[Step 1] Checking the kernel version is if too old.\n"
    KERNEL_VERSION=$(uname -r)
    KERNEL_MAJOR_VERSION=$(echo "${KERNEL_VERSION}" | awk -F . '{print $1}')
    KERNEL_MINOR_VERSION=$(echo "${KERNEL_VERSION}" | awk -F . '{print $2}')

    # requeir for kernel version > 4.11
    if { [ "$KERNEL_MAJOR_VERSION" -eq 4 ] && [ "$KERNEL_MINOR_VERSION" -le 11 ] ; } || [ "$KERNEL_MAJOR_VERSION" -lt 4 ]  ; then
      printf "[Step 1] kernel version: %s is less than 4.11, the kernel don't support smc.\n" "$KERNEL_VERSION"
      exit 1
    fi

    printf "[Step 1] kernel version %s is ok, Done.\n" "${KERNEL_VERSION}"
}

load_module() {
    printf "[Step 3] Try to load the kernel module.\n"
    # try to load the module, exit 0 with no error.
    # if any error happened, check the kernel version is
    if modprobe smc 2>&1 ; then
        echo "[Step 3] Success to load the kernel module, exit code 0."
        return
    fi

    KERNEL_VERSION=$(uname -r)
    OFED_VERSION=$(sh /usr/bin/ofed_info -s | awk -F 'MLNX_OFED_LINUX-'  '{print $2}' | tr -d :)
    echo "[Step 3] ofed driver ${OFED_VERSION} has installed, try to load compiled module."
    if [ -e "modules/${KERNEL_VERSION}/${OFED_VERSION}/smc.ko" ]; then
        modprobe -r smc
        insmod modules/${KERNEL_VERSION}/${OFED_VERSION}/smc.ko
        modprobe smc
    else
        echo "[Step 3] No compile smc module found: can't load smc module. exit code 1."
        exit 1
    fi
    printf "[Step 3] Done.\n"
}

coyp_files() {
    printf "[Step 2] Copy the library files and module to host.\n"
    if [ -e "/usr/lib/libsmc-preload.so" ] || [ -e "/usr/lib64/libsmc-preload.so" ]; then
        printf "[Step 2] libsmc-preload.so has found on host, skip copy.\n"
        return
    fi

    OS=$(grep -E '^ID=(.*)' /host/etc/os-release | awk -F '=' '{print $2}' | tr -d '.' | tr -d '"')
    VERSION_ID=$(grep -E '^VERSION_ID=(.*)' /host/etc/os-release | awk -F '=' '{print $2}' | tr -d '.' | tr -d '"')

    cp /host/${OS}${VERSION_ID}/usr/lib/libsmc-preload.so /usr/lib/
    cp /host/${OS}${VERSION_ID}/usr/lib/libsmc-preload.so /usr/lib64/
    cp -f /host/${OS}${VERSION_ID}/usr/bin/smc* /usr/bin/
    printf "[Step 2] Done.\n"
}

# 1. check the kernel version if >= 4.11, Or exit 1
check_kernel

# 2. check if the so exist. if not: copy the so from init-container to /usr/lib/xxx.
coyp_files

# 3. try to load the kernel module: modprobe smc
load_module