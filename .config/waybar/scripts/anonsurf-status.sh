#!/bin/bash
# AnonSurf status script for Waybar

check_status() {
    if command -v anonsurf &> /dev/null; then
        if anonsurf status 2>/dev/null | grep -qi "started\|running\|active"; then
            echo '{"text": "󰒃", "tooltip": "AnonSurf: Active (Tor)", "class": "active", "alt": "active"}'
        else
            echo '{"text": "󰦞", "tooltip": "AnonSurf: Inactive", "class": "inactive", "alt": "inactive"}'
        fi
    else
        echo '{"text": "󰦞", "tooltip": "AnonSurf: Not installed", "class": "unavailable", "alt": "unavailable"}'
    fi
}

check_status
