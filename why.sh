#!/bin/bash

# --- Configuration ---
BASE_DIR="$(dirname "$(readlink -f "$0")")"
HISTORY_DIR="$BASE_DIR/history"
MANIFEST="$BASE_DIR/manifest.db"
INSTALL_LOG="$BASE_DIR/install.bash"

# Ensure environment is ready
mkdir -p "$HISTORY_DIR"
cd "$BASE_DIR" || exit
if [ ! -d ".git" ]; then
    git init > /dev/null
fi

# --- Helper Functions ---
get_registry() {
    # Extracts the first word of the command (ignoring sudo)
    echo "$1" | sed 's/sudo //' | awk '{print $1}'
}

log_history() {
    local registry=$1
    local pkg=$2
    local status=$3
    local reason=$4
    local timestamp=$(date "+%Y-%m-%d %H:%M")
    echo "[$timestamp] $pkg: $status $reason" >> "$HISTORY_DIR/${registry}.db"
}

# --- Command Logic ---

case "$1" in
    install|-S|add)
        CMD=$2
        PKGS=$3
        REASON=$4
        REGISTRY=$(get_registry "$CMD")

        if [[ -z "$CMD" || -z "$PKGS" || -z "$REASON" ]]; then
            echo "Usage: why install \"<command>\" \"<packages>\" \"<reason>\""
            exit 1
        fi

        # 1. Show existing history before proceeding
        for pkg in $PKGS; do
            if grep -q "$pkg" "$HISTORY_DIR/${REGISTRY}.db" 2>/dev/null; then
                echo -e "\nHistory for $pkg:"
                grep "$pkg" "$HISTORY_DIR/${REGISTRY}.db"
            fi
        done

        # 2. Execute
        echo -e "\nExecuting: $CMD $PKGS..."
        eval "$CMD $PKGS"
        
        if [ $? -eq 0 ]; then
            for pkg in $PKGS; do
                log_history "$REGISTRY" "$pkg" "[INSTALLED]" "$REASON"
                echo "$REGISTRY|$pkg" >> "$MANIFEST"
            done
            echo "$CMD $PKGS # Reason: $REASON" >> "$INSTALL_LOG"
            sort -u -o "$MANIFEST" "$MANIFEST"
            git add . && git commit -m "Install ($REGISTRY): $PKGS - $REASON" > /dev/null
            echo "Successfully logged."
        else
            echo "Command failed. Nothing logged."
        fi
        ;;

    uninstall|-Rs|-R|remove)
        CMD=$2
        PKGS=$3
        REASON=$4
        REGISTRY=$(get_registry "$CMD")

        eval "$CMD $PKGS"
        if [ $? -eq 0 ]; then
            for pkg in $PKGS; do
                log_history "$REGISTRY" "$pkg" "<REMOVED>" "$REASON"
                # Remove from manifest
                sed -i "/$REGISTRY|$pkg/d" "$MANIFEST"

                # CLEANUP: Remove the line from install.bash that installed this package
                # This uses a regex to find the package name in the install log and delete the whole line
                sed -i "/\b$pkg\b/d" "$INSTALL_LOG"
            done
            git add . && git commit -m "Uninstall ($REGISTRY): $PKGS - $REASON" > /dev/null
            echo "Removal logged."
        fi
        ;;

    reason|history|why)
        SEARCH=$2
        echo "Searching history for: $SEARCH"
        grep -h --color=always "$SEARCH" "$HISTORY_DIR"/*.db 2>/dev/null || echo "No history found for '$SEARCH'."
        ;;

    iterate|audit)
            LIST_CMD=$2
            REGISTRY=$3
            
            if [[ -z "$LIST_CMD" || -z "$REGISTRY" ]]; then
                echo "Usage: why iterate \"<list command>\" <registry_name>"
                exit 1
            fi

            # We use a different file descriptor (3) for the list
            # so that 'read' can still use the standard input for your keyboard
            while read -r pkg; do
                pkg_clean=$(echo "$pkg" | awk '{print $1}')
                if ! grep -q "$REGISTRY|$pkg_clean" "$MANIFEST" 2>/dev/null; then
                    echo -e "\n[UNKNOWN PACKAGE] $pkg_clean"
                    
                    # The trick: read from /dev/tty (your actual keyboard)
                    read -p "Why is this installed? (Leave empty to skip): " reason < /dev/tty
                    
                    if [[ -n "$reason" ]]; then
                        log_history "$REGISTRY" "$pkg_clean" "[AUDITED]" "$reason"
                        echo "$REGISTRY|$pkg_clean" >> "$MANIFEST"
                        git add . && git commit -m "Audit ($REGISTRY): $pkg_clean" > /dev/null
                    fi
                fi
            done < <(eval "$LIST_CMD") # This syntax keeps stdin free for the prompts
            ;;

    *)
        echo "Commands: install, uninstall, reason, iterate"
        exit 1
        ;;
esac
