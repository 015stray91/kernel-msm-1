#!/bin/bash
# Force injection past Qualcomm verification engines

# Part 1: Core Compression & Performance
export CONFIG_KERNEL_LZ4=y
export CONFIG_ZRAM=y
export CONFIG_ZSMALLOC=y
export CONFIG_ZCOMP_LZ4K=y
export CONFIG_CPU_FREQ_GOV_PERFORMANCE=y
export CONFIG_QCOM_EUD=y

# Part 2: KernelSU Next & SusFS
export CONFIG_KPROBES=y
export CONFIG_KPROBE_EVENTS=y
export CONFIG_KSU_SUSFS=y
export CONFIG_KSU_SUSFS_HAS_MEM_PAGES=y
export CONFIG_KSU_SUSFS_SUS_MOUNT=y
export CONFIG_KSU_SUSFS_ZERO_MOUNT=y

# Part 3: NetHunter Attack Module Drivers
export CONFIG_USB_GADGET=y
export CONFIG_USB_CONFIGFS=y
export CONFIG_USB_CONFIGFS_F_HID=y
export CONFIG_UHID=y
export CONFIG_NET=y
export CONFIG_WIRELESS=y
export CONFIG_CFG80211=m
export CONFIG_MAC80211=m
export CONFIG_NL80211_TESTMODE=y
export CONFIG_NETFILTER=y
export CONFIG_IP_NF_MANGLE=y
export CONFIG_IP6_NF_MANGLE=y
