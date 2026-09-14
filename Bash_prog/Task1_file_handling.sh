#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       <spendylove>
# @index        <7351923>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Creates a directory, writes/appends/reads a file in it, backs it up, then deletes the original.
# @date         <Date you wrote it>
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0 <target-directory>"
    echo "  <target-directory>  directory to create/use for file operations"
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

if [[ $# -ne 1 ]]; then
    echo "Error: you must give exactly 1 argument."
    usage
fi

TARGET_DIR="$1"
FILE="$TARGET_DIR/data.txt"
BACKUP="$FILE.bak"

if [[ -d "$TARGET_DIR" ]]; then
    echo "[INFO] Directory '$TARGET_DIR' already existed."
else
    mkdir -p "$TARGET_DIR"
    if [[ $? -eq 0 ]]; then
        echo "[SUCCESS] Directory '$TARGET_DIR' created."
    else
        echo "[ERROR] Could not create directory. Stopping."
        exit 1
    fi
fi

echo "Hello, this is the initial content." > "$FILE"
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] File created and content written."
else
    echo "[ERROR] Could not write file. Stopping."
    exit 1
fi

echo "This line was appended afterward." >> "$FILE"
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Content appended."
else
    echo "[ERROR] Could not append. Stopping."
    exit 1
fi

echo "[INFO] File contents:"
cat "$FILE"

cp "$FILE" "$BACKUP"
if [[ $? -eq 0 ]]; then
    echo "[SUCCESS] Backup created at $BACKUP."
else
    echo "[ERROR] Backup failed. Stopping."
    exit 1
fi

if [[ -f "$FILE" ]]; then
    echo "[INFO] Deleting original file (backup is safe)."
    rm "$FILE"
    if [[ $? -eq 0 ]]; then
        echo "[SUCCESS] Original file deleted."
    else
        echo "[ERROR] Could not delete file."
        exit 1
    fi
else
    echo "[ERROR] File does not exist, nothing to delete."
    exit 1
fi

echo "[DONE] Task 1 completed successfully."
