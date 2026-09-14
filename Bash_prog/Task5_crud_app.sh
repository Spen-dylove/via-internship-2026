#!/usr/bin/env bash
# ------------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       <Joel_Nartey_Annan>
# @index        <7352323>
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven CRUD Todo list app storing data in data.txt.
# @date         <14-09-2026>
# ------------------------------------------------------------------

usage() {
    echo "Usage: $0"
    echo "  No arguments needed. Launches an interactive Todo list menu."
    exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

DATAFILE="data.txt"
BACKUP="data.txt.bak"

# Make sure the data file exists
touch "$DATAFILE"

# --- Backup before destructive changes ---
backup_data() {
    cp "$DATAFILE" "$BACKUP"
    if [[ $? -ne 0 ]]; then
        echo "[ERROR] Failed to create backup. Aborting operation."
        return 1
    fi
    return 0
}

# --- Generate next available ID ---
next_id() {
    if [[ ! -s "$DATAFILE" ]]; then
        echo 1
    else
        awk -F'|' '{print $1}' "$DATAFILE" | sort -n | tail -1 | awk '{print $1+1}'
    fi
}

# --- Create ---
create_task() {
    read -rp "Enter task description: " desc
    if [[ -z "$desc" ]]; then
        echo "[ERROR] Task description cannot be empty."
        return
    fi
    local id
    id=$(next_id)
    echo "${id}|${desc}|pending" >> "$DATAFILE"
    if [[ $? -eq 0 ]]; then
        echo "[OK] Task added with ID $id."
    else
        echo "[ERROR] Failed to add task."
    fi
}

# --- Read ---
read_tasks() {
    if [[ ! -s "$DATAFILE" ]]; then
        echo "[INFO] No tasks found."
        return
    fi
    echo "ID | Description | Status"
    echo "-----------------------------"
    while IFS='|' read -r id desc status; do
        echo "$id | $desc | $status"
    done < "$DATAFILE"
}

# --- Update ---
update_task() {
    read -rp "Enter ID of task to update: " id
    if [[ -z "$id" ]]; then
        echo "[ERROR] ID cannot be empty."
        return
    fi
    if ! grep -q "^${id}|" "$DATAFILE"; then
        echo "[ERROR] No task found with ID $id."
        return
    fi
    read -rp "Enter new description (leave blank to keep current): " new_desc
    read -rp "Mark as done? (y/n): " done_ans

    local status="pending"
    if [[ "$done_ans" == "y" || "$done_ans" == "Y" ]]; then
        status="done"
    fi

    backup_data || return

    local old_line new_line
    old_line=$(grep "^${id}|" "$DATAFILE")
    IFS='|' read -r oid odesc ostatus <<< "$old_line"

    if [[ -z "$new_desc" ]]; then
        new_desc="$odesc"
    fi

    new_line="${id}|${new_desc}|${status}"
    sed -i "s|^${id}|.*|${new_line}|" "$DATAFILE" 2>/dev/null

    # Safer replace using awk since sed with pipes gets messy
    awk -F'|' -v id="$id" -v line="$new_line" 'BEGIN{OFS="|"} {if ($1==id) print line; else print $0}' "$DATAFILE" > "${DATAFILE}.tmp" && mv "${DATAFILE}.tmp" "$DATAFILE"

    if [[ $? -eq 0 ]]; then
        echo "[OK] Task $id updated."
    else
        echo "[ERROR] Failed to update task $id."
    fi
}

# --- Delete ---
delete_task() {
    read -rp "Enter ID of task to delete: " id
    if [[ -z "$id" ]]; then
        echo "[ERROR] ID cannot be empty."
        return
    fi
    if ! grep -q "^${id}|" "$DATAFILE"; then
        echo "[ERROR] No task found with ID $id."
        return
    fi

    read -rp "Are you sure you want to delete task $id? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "[INFO] Delete cancelled."
        return
    fi

    backup_data || return

    awk -F'|' -v id="$id" 'BEGIN{OFS="|"} {if ($1!=id) print $0}' "$DATAFILE" > "${DATAFILE}.tmp" && mv "${DATAFILE}.tmp" "$DATAFILE"

    if [[ $? -eq 0 ]]; then
        echo "[OK] Task $id deleted."
    else
        echo "[ERROR] Failed to delete task $id."
    fi
}

# --- Main menu loop ---
while true; do
    echo ""
    echo "===== Todo List Menu ====="
    echo "1) Create task"
    echo "2) Read tasks"
    echo "3) Update task"
    echo "4) Delete task"
    echo "5) Exit"
    read -rp "Choose an option [1-5]: " choice

    case "$choice" in
        1) create_task ;;
        2) read_tasks ;;
        3) update_task ;;
        4) delete_task ;;
        5) echo "[INFO] Exiting. Goodbye!"; exit 0 ;;
        *) echo "[ERROR] Invalid option. Please choose 1-5." ;;
    esac
done
