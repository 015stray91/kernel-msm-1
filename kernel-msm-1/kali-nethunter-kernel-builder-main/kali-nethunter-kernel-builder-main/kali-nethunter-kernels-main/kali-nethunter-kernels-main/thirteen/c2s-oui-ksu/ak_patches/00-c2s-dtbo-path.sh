#!/system/bin/sh

# Samsung c2s exposes dtbo as /dev/block/by-name/dtbo on Android. Some
# recoveries also provide /dev/block/bootdevice/by-name/dtbo, so accept both.

flash_dtbo() {
	local i dtbo dtboblock candidate

	ab_slot

	cd "$home"
	for i in dtbo dtbo.img; do
		if [ -f "$i" ]; then
			dtbo=$i
			break
		fi
	done

	[ "$dtbo" ] || return 0

	for candidate in \
		"/dev/block/bootdevice/by-name/dtbo$SLOT" \
		"/dev/block/by-name/dtbo$SLOT" \
		/dev/block/platform/*/by-name/dtbo$SLOT; do
		if [ -e "$candidate" ]; then
			dtboblock=$candidate
			break
		fi
	done

	[ "$dtboblock" ] || abort "dtbo partition could not be found. Aborting..."

	blockdev --setrw "$dtboblock" 2>/dev/null
	if [ -f "$bin/flash_erase" ] && [ -f "$bin/nandwrite" ]; then
		"$bin/flash_erase" "$dtboblock" 0 0
		"$bin/nandwrite" -p "$dtboblock" "$dtbo"
	elif [ "$customdd" ]; then
		dd if=/dev/zero of="$dtboblock" 2>/dev/null
		dd if="$dtbo" of="$dtboblock"
	else
		cat "$dtbo" /dev/zero > "$dtboblock" 2>/dev/null || true
	fi

	if [ $? != 0 ]; then
		abort "Flashing dtbo failed. Aborting..."
	else
		ui_print "- Flashed new dtbo"
	fi
}

# Source-safe AnyKernel3 wrapper. NetHunter's installer sources ak_patches
# scripts, so keep all c2s install work in this one sourced file.

nh_print() {
	if command -v ui_print >/dev/null 2>&1; then
		ui_print "$1"
	fi
}

nh_find_busybox() {
	for bb in "$BB" /tmp/scripts/busybox "$bin/busybox" /sbin/busybox /system/bin/busybox busybox; do
		[ -n "$bb" ] || continue
		if [ -x "$bb" ] || command -v "$bb" >/dev/null 2>&1; then
			printf '%s\n' "$bb"
			return 0
		fi
	done

	return 1
}

nh_run_script() {
	local script bb

	script=$1
	shift
	bb=$(nh_find_busybox 2>/dev/null)

	if [ -n "$bb" ]; then
		"$bb" sh "$script" "$@"
	else
		sh "$script" "$@"
	fi
}

nh_copy_file() {
	local src dst bb

	src=$1
	dst=$2
	bb=$(nh_find_busybox 2>/dev/null)

	if [ -n "$bb" ]; then
		"$bb" cp "$src" "$dst"
	else
		cp "$src" "$dst"
	fi
}

nh_find_payload() {
	local rel candidate

	rel=$1
	for candidate in \
		"$home/data/local/$rel" \
		"/data/local/$rel" \
		"$home/$rel"; do
		if [ -e "$candidate" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done

	return 1
}

nh_prepare_ksu_dirs() {
	if [ ! -d /data ]; then
		return 1
	fi

	if [ ! -d /data/adb ]; then
		mkdir -p /data/adb || return 1
		chown 0:0 /data/adb 2>/dev/null
		chmod 0700 /data/adb 2>/dev/null
	fi

	mkdir -p /data/adb/modules /data/adb/service.d || return 1
	chown 0:0 /data/adb/modules /data/adb/service.d 2>/dev/null
	chmod 0755 /data/adb/modules /data/adb/service.d 2>/dev/null

	return 0
}

nh_install_usb_service() {
	local script

	nh_print "- Installing NetHunter USB Arsenal compatibility service"

	script=$(nh_find_payload "nethunter-usb-arsenal-compat.sh" 2>/dev/null) || {
		nh_print "- Warning: USB Arsenal compatibility script missing"
		return 0
	}

	if ! nh_prepare_ksu_dirs; then
		nh_print "- Warning: /data unavailable; USB Arsenal compatibility service install deferred"
		return 0
	fi

	nh_run_script "$script" --install ||
		nh_print "- Warning: USB Arsenal compatibility service install deferred"
}

nh_install_nexmon_module_service() {
	local module_zip service_payload service_target

	nh_print "- Installing Nexmon BCM4375B1 firmware module autoinstaller"

	module_zip=$(nh_find_payload "ksu_modules/nexmon-bcm4375b1.zip" 2>/dev/null) || {
		nh_print "- Warning: Nexmon firmware module zip missing"
		return 0
	}

	chmod 0644 "$module_zip" 2>/dev/null
	chown 0:0 "$module_zip" 2>/dev/null
	chmod 0644 /data/local/ksu_modules/nexmon-bcm4375b1.zip 2>/dev/null
	chown 0:0 /data/local/ksu_modules/nexmon-bcm4375b1.zip 2>/dev/null

	service_payload=$(nh_find_payload "nexmon-bcm4375b1-autoinstall.sh" 2>/dev/null) || {
		nh_print "- Warning: Nexmon firmware module autoinstaller missing"
		return 0
	}

	if ! nh_prepare_ksu_dirs; then
		nh_print "- Warning: /data unavailable; Nexmon firmware module autoinstall deferred"
		return 0
	fi

	service_target=/data/adb/service.d/nexmon-bcm4375b1-autoinstall.sh
	if nh_copy_file "$service_payload" "$service_target"; then
		chown 0:0 "$service_target" 2>/dev/null
		chmod 0755 "$service_target" 2>/dev/null
		nh_print "- Installed Nexmon firmware module autoinstaller"
	else
		nh_print "- Warning: Nexmon firmware module autoinstaller install failed"
	fi
}

nh_install_docker_helper_service() {
	local helper service_payload service_target

	nh_print "- Installing NetHunter Docker helper service"

	helper=$(nh_find_payload "nh-docker" 2>/dev/null) || {
		nh_print "- Warning: nh-docker helper payload missing"
		return 0
	}

	chmod 0755 "$helper" 2>/dev/null
	chown 0:0 "$helper" 2>/dev/null
	chmod 0755 /data/local/nh-docker 2>/dev/null
	chown 0:0 /data/local/nh-docker 2>/dev/null

	service_payload=$(nh_find_payload "nh-docker-helper-service.sh" 2>/dev/null) || {
		nh_print "- Warning: nh-docker service payload missing"
		return 0
	}

	if ! nh_prepare_ksu_dirs; then
		nh_print "- Warning: /data unavailable; nh-docker service install deferred"
		return 0
	fi

	service_target=/data/adb/service.d/nh-docker-helper-service.sh
	if nh_copy_file "$service_payload" "$service_target"; then
		chown 0:0 "$service_target" 2>/dev/null
		chmod 0755 "$service_target" 2>/dev/null
		nh_run_script "$service_target" ||
			nh_print "- Warning: nh-docker helper copy deferred until next boot"
		nh_print "- Installed nh-docker helper service"
	else
		nh_print "- Warning: nh-docker service install failed"
	fi
}

nh_install_usb_service
nh_install_nexmon_module_service
nh_install_docker_helper_service
