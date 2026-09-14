#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       <Joel_Nartey_Annan>
# @index        <7352323>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates fake log data and analyzes it using pipes and text tools.
# @date         <14-09-2026>
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0"
    echo "  No arguments needed. Generates sample logs and analyzes them."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

LOGFILE="sample.log"
RESULTS="results.txt"

# --- Step 1: Generate fake log data ---
cat > "$LOGFILE" << 'LOGEOF'
2026-09-11 10:03:21 INFO 192.168.1.10 User login successful
2026-09-11 10:04:02 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:05:15 WARN 192.168.1.10 High memory usage above 80%
2026-09-11 10:06:44 INFO 192.168.1.15 User login successful
2026-09-11 10:07:01 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:08:30 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:09:12 WARN 192.168.1.45 Disk space low
2026-09-11 10:10:05 ERROR 192.168.1.10 Authentication failed
2026-09-11 10:11:20 INFO 192.168.1.23 User logout
2026-09-11 10:12:50 INFO 192.168.1.15 User login successful
LOGEOF

if [[ $? -ne 0 ]]; then
    echo "[ERROR] Failed to generate log file." >&2
    exit 1
fi
echo "[OK] Sample log file '$LOGFILE' created."

# --- Step 2: Build the summary report ---
{
    echo "=== Log Analysis Report ==="
    echo ""

    echo "Total number of log lines:"
    wc -l < "$LOGFILE"
    echo ""

    echo "Count of lines per log level:"
    awk '{print $3}' "$LOGFILE" | sort | uniq -c | sort -rn
    echo ""

    echo "Top 3 most frequent IP addresses:"
    awk '{print $4}' "$LOGFILE" | sort | uniq -c | sort -rn | head -3
    echo ""

    echo "All ERROR lines:"
    grep "ERROR" "$LOGFILE"
} > "$RESULTS" 2>> error.log

if [[ $? -eq 0 ]]; then
    echo "[OK] Report written to '$RESULTS'."
else
    echo "[ERROR] Something went wrong building the report. Check error.log." >&2
    exit 1
fi

echo "[DONE] Task 3 completed successfully."
