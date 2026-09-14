#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       <Joel_Nartey_Annan>
# @index        <7352323>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports and changes file permissions, and demonstrates a root-only action.
# @date         <13-09-2026>
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0 <file-path>"
    echo "  <file-path>  path to a file whose permissions will be checked/changed"
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ $# -ne 1 ]]; then
    echo "Error: you must give exactly 1 argument."
    usage
fi

FILE="$1"

if [[ ! -e "$FILE" ]]; then
    echo "[ERROR] '$FILE' does not exist."
    exit 1
fi

echo "[INFO] Current permissions of '$FILE':"
ls -l "$FILE"
NUMERIC=$(stat -c '%a' "$FILE")
echo "[INFO] Numeric permissions: $NUMERIC"

echo "[INFO] Changing permissions with 'chmod u+x $FILE'..."
chmod u+x "$FILE"
if [[ $? -eq 0 ]]; then
    echo "[OK] Permissions changed successfully."
else
    echo "[ERROR] Failed to change permissions."
    exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
    echo "[INFO] Running as root. Changing ownership to root:root..."
    chown root:root "$FILE"
    if [[ $? -eq 0 ]]; then
        echo "[OK] Ownership changed to root:root."
    else
        echo "[ERROR] Failed to change ownership."
        exit 1
    fi
else
    echo "[INFO] Not running as root — skipping chown step (root privileges required)."
fi

echo "[INFO] Permissions after change:"
ls -l "$FILE"
NUMERIC_AFTER=$(stat -c '%a' "$FILE")
echo "[INFO] Numeric permissions: $NUMERIC_AFTER"

echo "[DONE] Task 2 completed successfully."
