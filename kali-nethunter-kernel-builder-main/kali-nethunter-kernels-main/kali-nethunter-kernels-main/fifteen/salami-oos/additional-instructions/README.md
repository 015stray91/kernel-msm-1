## Installation instructions: 

- Flash AK3 zip in kernel flasher or flash the boot.img from latest release of EmberHeart kernel repo or use the one here 
- Flash Wireless Firmware for Nethunter provided in the releases or use the one here
- Download and Unzip kernel modules in internal storage and load them using `insmod module_name.ko`

Release link : https://github.com/nullptr-t-oss/EmberHeart_OnePlus11/releases/tag/v1.5.12-r12

---

## Loading rtw88 drivers

If you have unzipped all the drivers in internal storage and want to load drivers for let's say rtl8821au chipset,

- Step 0: cd into the directory where all kernel modules are unzipped 
- Step 1: `rmmod mac80211`
- Step 2: `insmod mac80211.ko`

> [!WARNING] 
> The first two steps are necessary otherwise you'll get unknown symbol error (__ieee80211_create_tpt_led_trigger) 

- Step 2: `insmod rtw_core.ko`
- Step 3: `insmod rtw_usb.ko`
- Step 4: `insmod rtw_88xxa.ko`
- Step 5: `insmod rtw_8821a.ko`
- Step 6: `insmod rtw_8821au.ko`

Tested wifi adaptors : [TP-Link Archer T2U Plus](https://amzn.in/d/76Ka5nB)

REPO LINK : https://github.com/nullptr-t-oss/EmberHeart_OnePlus11