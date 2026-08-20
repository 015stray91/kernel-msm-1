#!/system/bin/sh

SRC=${SRC:-/data/local/nh-docker}
LOG=${LOG:-/data/local/tmp/nh-docker-helper-service.log}
DEST_NAME=${DEST_NAME:-nh-docker}

log()
{
	mkdir -p "$(dirname "$LOG")" 2>/dev/null
	echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG"
}

install_helper_once()
{
	local installed root dest roots

	[ -f "$SRC" ] || return 0

	roots="/data/local/nhsystem/kali-arm64 /data/local/nhsystem/kali-*"
	installed=1

	for root in $roots; do
		[ -d "$root" ] || continue
		[ -d "$root/usr/bin" ] || mkdir -p "$root/usr/bin" 2>/dev/null || continue
		dest="$root/usr/bin/$DEST_NAME"

		cp "$SRC" "$dest" 2>/dev/null || {
			log "failed to copy helper to $dest"
			continue
		}
		chown 0:0 "$dest" 2>/dev/null
		chmod 0755 "$dest" 2>/dev/null || {
			log "failed to chmod helper at $dest"
			continue
		}

		log "installed $dest"
		installed=0
	done

	return "$installed"
}

install_helper_once >/dev/null 2>&1

exit 0
