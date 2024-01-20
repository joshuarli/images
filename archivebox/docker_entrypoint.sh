#!/bin/bash

# - Set the archivebox user to use the correct PUID & PGID
#     1. highest precedence is for valid PUID and PGID env vars passsed in explicitly
#     2. fall back to DETECTED_PUID of files found within existing data dir
#     3. fall back to DEFAULT_PUID if no data dir or its owned by root
# - Create a new /data dir if necessary and set the correct ownership on it
# - Create a new /browsers dir if necessary and set the correct ownership on it
# - Check whether we're running inside QEMU emulation and show a warning if so.
# - Check that enough free space is available on / and /data
# - Drop down to archivebox user permisisons and execute passed CMD command.

set -euo pipefail

export DATA_DIR="${DATA_DIR:-/data}"
export ARCHIVEBOX_USER="${ARCHIVEBOX_USER:-archivebox}"
export DEFAULT_PUID=911
export DEFAULT_PGID=911

# If data directory already exists, autodetect detect owner by looking at files within
export DETECTED_PUID="$(stat -c '%u' "$DATA_DIR/logs/errors.log" 2>/dev/null || echo "$DEFAULT_PUID")"
export DETECTED_PGID="$(stat -c '%g' "$DATA_DIR/logs/errors.log" 2>/dev/null || echo "$DEFAULT_PGID")"

# If data directory exists but is owned by root, use defaults instead of root because root is not allowed
[[ "$DETECTED_PUID" == "0" ]] && export DETECTED_PUID="$DEFAULT_PUID"

# Set archivebox user and group ids to desired PUID/PGID
usermod -o -u "${PUID:-$DETECTED_PUID}" "$ARCHIVEBOX_USER" > /dev/null 2>&1
groupmod -o -g "${PGID:-$DETECTED_PGID}" "$ARCHIVEBOX_USER" > /dev/null 2>&1

# re-set PUID and PGID to values reported by system instead of values we tried to set,
# in case wonky filesystems or Docker setups try to play UID/GID remapping tricks on us
export PUID="$(id -u archivebox)"
export PGID="$(id -g archivebox)"

# Check the permissions of the data dir (or create if it doesn't exist)
if [[ -d "$DATA_DIR/archive" ]]; then
    if touch "$DATA_DIR/archive/.permissions_test_safe_to_delete" 2>/dev/null; then
        # It's fine, we are able to write to the data directory (as root inside the container)
        rm -f "$DATA_DIR/archive/.permissions_test_safe_to_delete"
        # echo "[√] Permissions are correct"
    else
     # the only time this fails is if the host filesystem doesn't allow us to write as root (e.g. some NFS mapall/maproot problems, connection issues, drive dissapeared, etc.)
        echo -e "\n[X] Error: archivebox user (PUID=$PUID) is not able to write to your ./data dir (currently owned by $(stat -c '%u' "$DATA_DIR"):$(stat -c '%g' "$DATA_DIR")." >&2
        echo -e "    Change ./data to be owned by PUID=$PUID PGID=$PGID on the host and retry:" > /dev/stderr
        echo -e "       \$ chown -R $PUID:$PGID ./data\n" > /dev/stderr
        echo -e "    Configure the PUID & PGID environment variables to change the desired owner:" > /dev/stderr
        echo -e "       https://docs.linuxserver.io/general/understanding-puid-and-pgid\n" > /dev/stderr
        echo -e "    Hint: some NFS/SMB/FUSE/etc. filesystems force-remap/ignore all permissions," > /dev/stderr
        echo -e "          leave PUID/PGID unset, or use values the filesystem prefers (defaults to $DEFAULT_PUID:$DEFAULT_PGID)" > /dev/stderr
        echo -e "    https://linux.die.net/man/8/mount.cifs#:~:text=does%20not%20provide%20unix%20ownership" > /dev/stderr
        exit 3
    fi
else
    # create data directory
    mkdir -p "$DATA_DIR/logs"
fi

# force set the ownership of the data dir contents to the archivebox user and group
# this is needed because Docker Desktop often does not map user permissions from the host properly
chown -R $PUID:$PGID "$DATA_DIR"

export IN_QEMU="$(pmap 1 | grep qemu >/dev/null && echo 'True' || echo 'False')"
if [[ "$IN_QEMU" == "True" ]]; then
    echo -e "\n[!] Warning: Running $(uname -m) docker image using QEMU emulation, some things will break!" > /dev/stderr
    echo -e "    chromium (screenshot, pdf, dom), singlefile, and any dependencies that rely on inotify will not run in QEMU." > /dev/stderr
    echo -e "    See here for more info: https://github.com/microsoft/playwright/issues/17395#issuecomment-1250830493\n" > /dev/stderr
fi

set -- gosu "$PUID" archivebox -- "$@"
exec "$@"
