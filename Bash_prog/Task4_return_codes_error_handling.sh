#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       <Joel_Annan_Nartey>
# @index        <7352323>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks with disciplined exit codes.
# @date         <14-09-2026>
# ------------------------------------------------------------------
# Exit codes:
# 0 = all checks passed
# 1 = host unreachable
# 2 = insufficient disk space
# 3 = required file missing or unreadable
# 4 = required command not found
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0"
    echo "  No arguments needed. Runs a series of system health checks."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

TMPFILE=$(mktemp)

# Clean up temp file on exit, whether normal or interrupted (Ctrl+C)
cleanup() {
    echo "[INFO] Cleaning up temporary file '$TMPFILE'..."
    rm -f "$TMPFILE"
}
trap cleanup EXIT INT TERM

check_host() {
    local host="$1"
    echo "[CHECK] Pinging $host..."
    ping -c 1 -W 2 "$host" > "$TMPFILE" 2>&1
    if [[ $? -eq 0 ]]; then
        echo "[PASS] $host is reachable."
    else
        echo "[FAIL] $host is unreachable."
        exit 1
    fi
}

check_disk_space() {
    local min_kb=1000000
    echo "[CHECK] Checking free disk space on /..."
    local available
    available=$(df / | awk 'NR==2 {print $4}')
    if [[ "$available" -ge "$min_kb" ]]; then
        echo "[PASS] Sufficient disk space available (${available}KB)."
    else
        echo "[FAIL] Insufficient disk space (${available}KB available)."
        exit 2
    fi
}

check_file() {
    local file="$1"
    echo "[CHECK] Checking if '$file' exists and is readable..."
    if [[ -f "$file" && -r "$file" ]]; then
        echo "[PASS] '$file' exists and is readable."
    else
        echo "[FAIL] '$file' is missing or unreadable."
        exit 3
    fi
}

check_command() {
    local cmd="$1"
    echo "[CHECK] Checking if command '$cmd' is installed..."
    if command -v "$cmd" > /dev/null 2>&1; then
        echo "[PASS] Command '$cmd' is available."
    else
        echo "[FAIL] Command '$cmd' not found."
        exit 4
    fi
}

# --- Run the checks ---
check_host "8.8.8.8"
check_disk_space
check_file "/etc/hostname"
check_command "grep"

echo "[DONE] All checks passed successfully."
exit 0
