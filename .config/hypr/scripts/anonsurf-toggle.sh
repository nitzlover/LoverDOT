#!/bin/bash
# AnonSurf toggle script for Hyprland

STATUS=$(anonsurf status 2>/dev/null | grep -i "started\|running" && echo "on" || echo "off")

if [ "$STATUS" = "on" ]; then
    pkexec anonsurf stop
    notify-send -i network-offline "AnonSurf" "Anonymity mode disabled" -u normal
else
    pkexec anonsurf start
    notify-send -i security-high "AnonSurf" "Anonymity mode enabled" -u normal
fi
