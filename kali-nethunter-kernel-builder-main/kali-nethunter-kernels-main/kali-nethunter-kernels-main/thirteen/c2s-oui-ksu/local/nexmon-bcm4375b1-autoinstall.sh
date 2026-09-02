#!/system/bin/sh

MODID=nexmon-bcm4375b1
ZIP=${ZIP:-/data/local/ksu_modules/nexmon-bcm4375b1.zip}
LOG=${LOG:-/data/local/tmp/${MODID}-autoinstall.log}

log()
{
	mkdir -p "$(dirname "$LOG")" 2>/dev/null
	echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}

find_ksud()
{
	for ksud in /data/adb/ksud /debug_ramdisk/ksud ksud; do
		if [ -x "$ksud" ] || command -v "$ksud" >/dev/null 2>&1; then
			printf '%s\n' "$ksud"
			return 0
		fi
	done

	return 1
}

wait_boot_completed()
{
	local count value

	count=0
	while [ "$count" -lt 120 ]; do
		value=$(/system/bin/getprop sys.boot_completed 2>/dev/null || getprop sys.boot_completed 2>/dev/null)
		[ "$value" = 1 ] && return 0
		count=$((count + 1))
		sleep 5
	done

	return 1
}

module_present()
{
	[ -f "/data/adb/modules/$MODID/module.prop" ]
}

self_disable()
{
	case "$0" in
		/data/adb/service.d/*)
			rm -f "$0" 2>/dev/null
			;;
	esac
}

module_present && {
	self_disable
	exit 0
}

[ -f "$ZIP" ] || exit 0
wait_boot_completed || {
	log "boot_completed did not become ready"
	exit 0
}

KSUD=$(find_ksud 2>/dev/null) || {
	log "ksud not available"
	exit 0
}

if "$KSUD" module install "$ZIP" >> "$LOG" 2>&1; then
	log "installed $MODID through KernelSU; reboot required for firmware overlay"
else
	log "failed to install $MODID through KernelSU"
fi

exit 0
