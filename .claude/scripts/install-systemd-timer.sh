#!/usr/bin/env bash
#
# install-systemd-timer.sh - Install Claude Code cleanup systemd timer
#
# This script installs a user-level systemd timer that runs hourly
# to clean up orphaned Claude Code processes.
#
# Usage: ./install-systemd-timer.sh [--uninstall] [--status]

set -euo pipefail

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="$(dirname "$SCRIPT_DIR")/systemd"
CLEANUP_SCRIPT="$SCRIPT_DIR/claude-cleanup.sh"

# User systemd directory
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"

# Service and timer names
SERVICE_NAME="claude-cleanup.service"
TIMER_NAME="claude-cleanup.timer"

# Parse arguments
UNINSTALL=false
STATUS=false

for arg in "$@"; do
    case $arg in
        --uninstall)
            UNINSTALL=true
            ;;
        --status)
            STATUS=true
            ;;
        --help|-h)
            echo "Usage: $0 [--uninstall] [--status]"
            echo ""
            echo "Install a user-level systemd timer for automated Claude cleanup."
            echo ""
            echo "Options:"
            echo "  --uninstall  Remove the timer and service"
            echo "  --status     Show timer status"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            exit 1
            ;;
    esac
done

# Check if systemd is available
check_systemd() {
    if ! command -v systemctl &> /dev/null; then
        echo "Error: systemctl not found. This script requires systemd."
        exit 1
    fi

    # Check if user session is available
    if ! systemctl --user status &> /dev/null; then
        echo "Error: User systemd session not available."
        echo "Make sure you're running with a login session."
        exit 1
    fi
}

# Show status
show_status() {
    echo "Claude Code Cleanup Timer Status"
    echo "================================="
    echo ""

    if systemctl --user is-active "$TIMER_NAME" &> /dev/null; then
        echo "Timer: ACTIVE"
        echo ""
        systemctl --user status "$TIMER_NAME" --no-pager 2>/dev/null || true
        echo ""
        echo "Next run:"
        systemctl --user list-timers "$TIMER_NAME" --no-pager 2>/dev/null || true
    else
        echo "Timer: NOT INSTALLED or INACTIVE"
        echo ""
        echo "Run '$0' to install the timer."
    fi
}

# Install the timer
install_timer() {
    echo "Installing Claude Code cleanup timer..."
    echo ""

    # Create user systemd directory if needed
    mkdir -p "$USER_SYSTEMD_DIR"

    # Create service file with correct path
    cat > "$USER_SYSTEMD_DIR/$SERVICE_NAME" << EOF
[Unit]
Description=Claude Code orphaned process cleanup
Documentation=https://github.com/anthropics/claude-code

[Service]
Type=oneshot
ExecStart=$CLEANUP_SCRIPT --force

# Run with normal user permissions
User=$USER

# Environment
Environment=HOME=$HOME
Environment=PATH=/usr/bin:/bin

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=claude-cleanup

[Install]
WantedBy=default.target
EOF

    # Copy timer file
    cp "$SYSTEMD_DIR/$TIMER_NAME" "$USER_SYSTEMD_DIR/$TIMER_NAME"

    # Reload systemd
    systemctl --user daemon-reload

    # Enable and start timer
    systemctl --user enable "$TIMER_NAME"
    systemctl --user start "$TIMER_NAME"

    echo "Timer installed successfully!"
    echo ""
    echo "The cleanup will run every hour."
    echo ""
    echo "Commands:"
    echo "  Check status:    systemctl --user status $TIMER_NAME"
    echo "  View logs:       journalctl --user -u $SERVICE_NAME"
    echo "  Stop timer:      systemctl --user stop $TIMER_NAME"
    echo "  Disable timer:   systemctl --user disable $TIMER_NAME"
    echo "  Run manually:    systemctl --user start $SERVICE_NAME"
    echo ""

    show_status
}

# Uninstall the timer
uninstall_timer() {
    echo "Uninstalling Claude Code cleanup timer..."
    echo ""

    # Stop and disable
    systemctl --user stop "$TIMER_NAME" 2>/dev/null || true
    systemctl --user disable "$TIMER_NAME" 2>/dev/null || true

    # Remove files
    rm -f "$USER_SYSTEMD_DIR/$SERVICE_NAME"
    rm -f "$USER_SYSTEMD_DIR/$TIMER_NAME"

    # Reload systemd
    systemctl --user daemon-reload

    echo "Timer uninstalled successfully."
}

# Main
check_systemd

if $STATUS; then
    show_status
    exit 0
fi

if $UNINSTALL; then
    uninstall_timer
else
    install_timer
fi
