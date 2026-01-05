#!/bin/bash
# Hyprland launcher with VM/software rendering support

# Detect if running in VM
detect_vm() {
    if systemd-detect-virt -q 2>/dev/null; then
        return 0
    fi
    if grep -qi "hypervisor\|vmware\|virtualbox\|qemu\|kvm" /proc/cpuinfo 2>/dev/null; then
        return 0
    fi
    if [ -f /sys/class/dmi/id/product_name ]; then
        if grep -qi "virtual\|vmware\|virtualbox\|qemu\|kvm" /sys/class/dmi/id/product_name 2>/dev/null; then
            return 0
        fi
    fi
    return 1
}

# Set environment variables for Wayland
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland

# Qt
export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# GTK
export GDK_BACKEND=wayland,x11
export CLUTTER_BACKEND=wayland

# SDL
export SDL_VIDEODRIVER=wayland

# Firefox
export MOZ_ENABLE_WAYLAND=1

# If running in VM, use software rendering
if detect_vm; then
    echo "VM detected, enabling software rendering..."
    export WLR_RENDERER=pixman
    export WLR_NO_HARDWARE_CURSORS=1
    export LIBGL_ALWAYS_SOFTWARE=1
    export WLR_RENDERER_ALLOW_SOFTWARE=1
fi

# Start Hyprland
exec Hyprland "$@"
