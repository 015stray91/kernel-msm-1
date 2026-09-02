After flashing Nethunter ZIP in Magisk, reboot and follow these step :

1. Reboot to TWRP

2. Mount System and Vendor partition (or everything to be sure)

3. Enter into a terminal

```
rm /system_root/system/vendor/etc/ueventd.rc
cp /system_root/ueventd.rc /system_root/system/vendor/etc/
cp /system_root/init.nethunter.rc /system_root/system/vendor/etc/init/
chmod 644 /system_root/system/vendor/etc/ueventd.rc
chmod 644 /system_root/system/vendor/etc/init/init.nethunter.rc
mknod -m 666 /dev/hidg0 c 240 0
mknod -m 666 /dev/hidg1 c 240 1
```
4. Reboot to system. Now you can start HID from USB Arsenal.

Done.
