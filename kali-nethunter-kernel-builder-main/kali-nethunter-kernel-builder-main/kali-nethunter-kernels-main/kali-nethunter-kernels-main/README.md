# Kali NetHunter Kernels

This repository contains all the binary files (e.g. pre-compiled kernels, kernel modules), [custom scripts](https://gitlab.com/kalilinux/packages/nethunter-utils) and [bootanimation](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-bootanimation) necessary for [building an installer](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-installer) tailored for a supported device.
_If you are looking for our [kernel-builder, see here](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder)._

You will need to clone [kali-nethunter-installer](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-installer) repository before using `./build.py`. This has been automated using `./bootstrap.sh`.

## How to add a new/unsupported device

All devices are contained in `devices.yml`. If you want to add your own device you would add something like:

```yaml
- [codename]:               # The device's model name. e.g. angler
                            #   Note, replace [codename]
    model  :                # The device's manufacturer and product name . e.g. Nexus 6P
    images :                # This section is meant for the NetHunter team, as it handles images that will be pre-generated on kali.org
                            #   This is used by kali-nethunter-installer's generate-release.py & ./bin/generate-image*.py
      - id     :            # Prefix is the same as [codename], and if using a non-stock ROM, suffix will be ROM's abbreviation. e.g. angler-los
                            #   Note, <images>-<id> needs to match a <kernels>-<id>.
        name   :            # The public "friendly" name of the filename. e.g. Nexus 6P (LineageOS 17.1)
        android:            # Which (stock) Android version name. e.g. ten
                            #   Note, <image>-<android> needs to match a <kernels>-<versions>-<android>.
        rootfs :            # Which rootfs to include when generating pre-created images. e.g. full
        docs   :            # A link to any external documentation. e.g. "https://forum.xda-developers.com/t/rom-official-kali-nethunter-for-the-huawei-nexus-6p-los17-1.4079087/"
        note   :            # Any developer notes e.g. Nexmon support
    kernels:                # This section is used during building as its the metadata for any binary files placed in ./<android>/<kernel-id>
                                #   This is used by kali-nethunter-installer's build.py & ./bin/generate-*kernels.py
      - id     :            # Prefix is the same as [codename], and if using a non-stock ROM, suffix will be ROM's abbreviation. e.g. angler-los
                            #   Note, <kernels>-<id> needs to match a <images>-<id>.
        description :       # "friendly" name of the kernel, using the format: <model> for <ROM full name> w/ anything extra. e.g. Nexus 6P for LineageOS and Pixel Experience
                            #   Note, this is only used in this YAML file
        kernelstring:       # Name to call your kernel. e.g. NetHunter kernel for Nexus 6P
        devicenames :       # Which devices should this be installed on. e.g. angler
        arch        :       # Architecture of the device. e.g. arm64
        ramdisk     :       # Set's ramdisk_compression method for flasher
        resolution  :       # Manually set the device screen resolution. e.g. 1080x2340
        block       :       # Manually set the device boot partition. e.g. /dev/block/bootdevice/by-name/boot
        version     :       # Manually set the kernel version. e.g. 1.2
        supersu     :       # Method to install SuperSU. e.g. systemless
        modules     :       # Set's do.modules in anykernel flasher
        slot_device :       # Set's is_slot_device in anykernel flasher
        versions    :       # This lists all the supported Android version for this ROM
          - android    :    # Which (stock) Android version name. e.g. ten
            linux      :    # Which Linux kernel version is being used (only. e.g. 3.10
                            #   Note, this is only used on the generated web pages - https://nethunter.kali.org/
            description:    # Long "friendly" name of the ROM and version. e.g. LineageOS 17.1 & Pixel Experience 10
                            #   Note, this is only used on the generated web pages - https://nethunter.kali.org/
            author     :    # Who created the NetHunter kernel. e.g. Your Name/handle
            source     :    # Git command, path and branch for the NetHunter kernel source. e.g. 'git clone https://github.com/Re4son/android_kernel_huawei_angler_pixel -b nethunter-10.0'
                            #   Note, this is only used on the generated web pages - https://nethunter.kali.org/
            								#   Note, any binary files should be stored in ./<android>/<kernels-id>
            features   :    # Array of which features are supported in this NetHunter kernel. e.g. [BT_RFCOMM, HID, Injection, Nexmon, RTL8812AU, Internal_BT, RTL8188EUS]
                            #   Note, this is only used on the generated web pages - https://nethunter.kali.org/
```

- - -

It's recommended that you leave out any defaults from your device entry to keep it short.
Here are the \[codename\]'s defaults entry values:

```yaml
- [codename]:
    images :
        rootfs      : full
    kernels:
        kernelstring: NetHunter kernel
        devicenames : # empty, will install on any device
        arch        : armhf
        ramdisk     : auto
        resolution  : # empty
        block       : # empty, automatic searching for location
        version     : 1.0
        supersu:    : auto
        modules     : 0
        slot_device : 1
        versions:
            author  : Unknown
```

- - -

A reliable way to get the **\[codename\]** for your device is to run a terminal emulator or boot into recovery and do: `getprop ro.product.device`

<!-- Also looking at https://www.gsmarena.com -->

```shell
$ adb shell
bacon:/ $ getprop ro.product.device
A0001
bacon:/ $
```

If porting for something other than stock Android ROM, it is please append to the kernel-id (and image-id):

- CyanogenMod -> `-cm` (e.g. `[codename-cm]`)
- LineageOS -> `-los` (e.g. `[codename-los]`)
- One UI -> `-oui` (e.g. `[codename-oui]`)
- OxygenOS -> `-oos` (e.g. `[codename-oos]`)
- Paranoid Android -> `-pa` (e.g. `[codename-pa]`)
- TouchWiz -> `-tw` (e.g. `[codename-tw]`)
- VoltageOS -> `-vos` (e.g. `[codename-vos]`)

- - -

We recommend adding the product model & name <!--(as well as ro.product.device, ro.build.product, ro.product.vendor.device, ro.vendor.product.device)--> to `devicenames`, which you can get by doing:

```shell
$ adb shell
bacon:/ $ getprop ro.product.model
A0001
bacon:/ $
bacon:/ $ getprop ro.product.name
bacon
bacon:/ $
```

Some devices may have the need for more than one \[codename\] (aka devicename) _(like the OnePlus One - `bacon` & `A0001`)_, or their are variants _(like the Nexus 7 2012/2013 - `grouper` & `flo`)_.
For these, you should add these multiple values to **devicenames**, split by using `,` (comma). Example: `devicenames: bacon,A0001,oneplus1`

- - -

Getting the **block** location isn't too difficult, you can look at other kernels to see where they are installing their `boot.img` or you can also look at [LineageOS device repositories](https://github.com/LineageOS?q=android_device) for the `BoardConfig.mk` file.

- - -

If the installer cannot identify the **resolution** automatically, you are able specify it here manually.

- - -

[AnyKernel3](https://github.com/osm0sis/AnyKernel3) has the option `do.modules`, which can be defined by using **modules**. Same with AnyKernel3's `is_slot_device`, set using **slot_device**.

- - -

When it comes to supported **features**:

- `BT_RFCOMM`  : Kernel config with BT_RFCOMM and BT_RFCOMM_TTY enabled for BT-Arsenal support.
- `Internal_BT`: Patch to add support for internal Bluetooth, kernel config with BT_SMD or BT_HCIVHCI, BT_HCIUART, BT_HCIUART_H4, ANDROID_BINDER_IPC.
- `RTL-BT`     : Patch to add support for Realtek 8761B Bluetooth dongles.

- `CDROM`      : DriveDroid patch to mount image as a CD-ROM, generally not used anymore, as modern OS can be booted from USD devices.
- `HID`        : Patch to permanently enable keyboard and mouse gadgets for HID attacks.
                 Only used for 3.x kernels.
- `HID-4`      : Kernel config to enable all gadget modes and configfs support.
                 Used for 4.x kernels and above.

- `Injection`  : Patch(es) to enable Wi-Fi injection (at least for mac80211 based chipsets).
- `Nexmon`     : The kernel package supports Nexmon and installs nexmon utilities.
                 _Only available for Google Nexus 5 & 6P, Sony Xperia 5C, one or two Samsung Galaxy phones._
- `QCACLD`     : Qcacld-2.0 and -3.0 drivers from CAF that support monitor mode.
- `ATH9K_HTC`  : Patch to add support for Atheros ath9k_htc drivers.
- `RTL8188EUS` : Patch to add support for Realtek rtl8188eus drivers (rtl8188eu, rtl8188eus, rtl8188etv) from the [aircrack-ng repo](https://github.com/aircrack-ng/rtl8188eus).
- `RTL8812AU`  : Patch to add support for Realtek rtl8812au drivers.
- `RTL88XXAU`  : Patch to add support for Realtek rtl88xxau drivers (rtl8812au, rtl8821au, rtl8814au) from the [aircrack-ng repo](https://github.com/aircrack-ng/rtl8812au).

- `NFS`        : Some devices come without NFS support, it is recommended if needed in a pentest.

- - -

Once you have a device added to `devices.yml`, you need to add a pre-built kernel to the device's folder. It should be formatted as:

- `[androidversion]/[codename]/zImage` or `[androidversion]/[codename]/zImage-dtb` (for ARMv7 devices)
- `[androidversion]/[codename]/Image` or `[androidversion]/[codename]/Image.gz-dtb` (for ARMv8 devices)

Some devices may require a separate `dtb` file. You can place a `dtb.img` file in the same location as the kernel image, and it will be automatically added to the installer.

If you choose to build kernel modules for your device instead of including them in the kernel image, they can be placed at the location:

- `[androidversion]/[codename]/modules/*.ko` or
- `[androidversion]/[codename]/modules/[kernelversion]/...`

Please use the latter when possible by preparing your kernel modules for install (modprobe support) with the command: `make INSTALL_MOD_PATH="." INSTALL_MOD_STRIP=1 modules_install`

Alternatively, use the build-scripts mentioned below which do this already!

So really all you need is a kernel image and sometimes a `dtb.img` to build for a new device.

## Building a kernel for your device

There are scripts in the `example_scripts/` folder that you can copy to the root of your device's kernel sources.

They should be modified to match your device. It will make it easier to build your device's kernel outside of an Android source tree.

The binary output from the build will be self-contained in a `build/` folder, with the kernel modules properly stripped and installed with their modprobe data in `build/lib/modules`.

Using these scripts in your source tree will make it easier for others to make modifications and update your device in the future. It will also increase the likelihood your device will be accepted into the [nethunter-kernels](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernels) repository as an officially supported device!

- - -

## Toolchains

For > 4.x kernels, use the [NetHunter Kernel-Builder](https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder)

For older kernels, refer to:

- Google
    - `$ git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7`
    - `$ git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b lollipop-release`
- Linaro ARM optimized
    - ARMv7: `$ wget https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/arm-linux-gnueabihf/gcc-linaro-4.9-2016.02-x86_64_arm-linux-gnueabihf.tar.xz`
    - ARMv8: `$ wget https://releases.linaro.org/components/toolchain/binaries/4.9-2016.02/aarch64-linux-gnu/gcc-linaro-4.9-2016.02-x86_64_aarch64-linux-gnu.tar.xz`
- Uber Linaro
    - `$ git clone https://bitbucket.org/UBERTC/arm-eabi-4.9.git`
