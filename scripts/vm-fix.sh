#!/bin/bash
# LoverDOT - VM Fix Script
# Fixes Hyprland black screen on VMs (VirtualBox, QEMU, VMware, Boxes)

echo "Creating Hyprland VM launcher..."

cat > /usr/local/bin/start-hyprland << 'EOF'
#!/bin/bash
export WLR_RENDERER=pixman
export WLR_NO_HARDWARE_CURSORS=1
export LIBGL_ALWAYS_SOFTWARE=1
export WLR_RENDERER_ALLOW_SOFTWARE=1
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export GDK_BACKEND=wayland,x11
export MOZ_ENABLE_WAYLAND=1
exec Hyprland "$@"
EOF

chmod +x /usr/local/bin/start-hyprland

# Update session file
mkdir -p /usr/share/wayland-sessions
cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=Hyprland (VM mode)
Exec=/usr/local/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
EOF

echo "Done! Reboot now: sudo reboot"
