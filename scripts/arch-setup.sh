#!/bin/bash
# LoverDOT - Arch Linux Quick Setup
# For fresh Arch install with archinstall profile/type/desktop/hyprland
#
# Usage: curl -fsSL https://raw.githubusercontent.com/nitzlover/LoverDOT/main/scripts/arch-setup.sh | bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

echo -e "${BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          LoverDOT - Arch Linux Quick Setup                ║"
echo "║          For archinstall desktop/hyprland                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check if running on Arch
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        log_error "This script is for Arch Linux only"
        exit 1
    fi
    log_info "Arch Linux detected"
}

# Install yay if not present
install_yay() {
    if command -v yay &> /dev/null; then
        log_info "yay already installed"
        return
    fi
    
    log_step "Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    
    cd /tmp
    rm -rf yay
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd -
    
    log_info "yay installed"
}

# Install all required packages
install_packages() {
    log_step "Installing packages..."
    
    # Core Hyprland packages (may already be installed via archinstall)
    local hyprland_pkgs=(
        hyprland
        hyprpaper
        hypridle
        hyprlock
        xdg-desktop-portal-hyprland
    )
    
    # Wayland essentials
    local wayland_pkgs=(
        wayland
        wayland-protocols
        wlroots
        xorg-xwayland
        qt5-wayland
        qt6-wayland
    )
    
    # UI components
    local ui_pkgs=(
        waybar
        wofi
        swaync
        wlogout
    )
    
    # Terminal & apps
    local app_pkgs=(
        alacritty
        firefox
        thunar
        thunar-archive-plugin
        file-roller
        imv
        mpv
    )
    
    # System utilities
    local util_pkgs=(
        polkit-gnome
        gnome-keyring
        network-manager-applet
        blueman
        pavucontrol
        brightnessctl
        playerctl
        grim
        slurp
        swappy
        wl-clipboard
        cliphist
    )
    
    # Fonts
    local font_pkgs=(
        ttf-jetbrains-mono-nerd
        ttf-font-awesome
        noto-fonts
        noto-fonts-emoji
    )
    
    # Themes & icons
    local theme_pkgs=(
        adwaita-icon-theme
        papirus-icon-theme
        qt5ct
        kvantum
    )
    
    # Development (optional but useful)
    local dev_pkgs=(
        git
        curl
        wget
        unzip
        ripgrep
        fd
    )
    
    # Install via pacman
    log_step "Installing pacman packages..."
    sudo pacman -Syu --noconfirm --needed \
        "${hyprland_pkgs[@]}" \
        "${wayland_pkgs[@]}" \
        "${ui_pkgs[@]}" \
        "${app_pkgs[@]}" \
        "${util_pkgs[@]}" \
        "${font_pkgs[@]}" \
        "${theme_pkgs[@]}" \
        "${dev_pkgs[@]}" \
        sddm
    
    # AUR packages
    log_step "Installing AUR packages..."
    yay -S --noconfirm --needed \
        hyprpicker \
        swww \
        wlogout \
        || log_warn "Some AUR packages may have failed"
    
    log_info "Packages installed"
}

# Enable services
enable_services() {
    log_step "Enabling services..."
    
    sudo systemctl enable sddm
    sudo systemctl enable NetworkManager
    sudo systemctl enable bluetooth
    
    log_info "Services enabled"
}

# Clone and install LoverDOT
install_loverdot() {
    log_step "Installing LoverDOT dotfiles..."
    
    local repo_dir="$HOME/LoverDOT"
    
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir"
        git pull
    else
        git clone https://github.com/nitzlover/LoverDOT.git "$repo_dir"
        cd "$repo_dir"
    fi
    
    chmod +x install.sh
    ./install.sh --no-deps
    
    log_info "LoverDOT installed"
}

# Create user directories
create_dirs() {
    log_step "Creating user directories..."
    
    mkdir -p ~/Pictures/Screenshots
    mkdir -p ~/Pictures/Wallpapers
    mkdir -p ~/Downloads
    mkdir -p ~/Documents
    mkdir -p ~/Projects
    
    log_info "Directories created"
}

# Set default wallpaper
setup_wallpaper() {
    log_step "Setting up wallpaper..."
    
    local wallpaper_dir="$HOME/Pictures/Wallpapers"
    local default_wallpaper="$wallpaper_dir/carbon-black.png"
    
    # Create a simple dark wallpaper if ImageMagick is available
    if command -v convert &> /dev/null; then
        convert -size 3840x2160 \
            -define gradient:direction=south \
            gradient:'#121212'-'#0a0a0a' \
            "$default_wallpaper"
        log_info "Default wallpaper created"
    fi
    
    # Create hyprpaper config
    mkdir -p ~/.config/hypr
    cat > ~/.config/hypr/hyprpaper.conf << EOF
preload = $default_wallpaper
wallpaper = ,$default_wallpaper
splash = false
EOF
    
    log_info "Wallpaper configured"
}

# Final setup
final_setup() {
    log_step "Final setup..."
    
    # Make scripts executable
    chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null || true
    chmod +x ~/.config/waybar/scripts/*.sh 2>/dev/null || true
    
    # Set GTK theme
    mkdir -p ~/.config/gtk-3.0
    cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Adwaita-dark
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrains Mono 10
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF
    
    # Set Qt theme
    echo "QT_QPA_PLATFORMTHEME=qt5ct" | sudo tee -a /etc/environment > /dev/null
    
    log_info "Final setup complete"
}

# Show completion
show_complete() {
    echo ""
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║              Setup Complete!                              ║${NC}"
    echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo "    1. Reboot: ${CYAN}sudo reboot${NC}"
    echo "    2. Login with SDDM → select Hyprland"
    echo ""
    echo -e "  ${BOLD}Keybindings:${NC}"
    echo "    • ${CYAN}Super + D${NC}        → App launcher"
    echo "    • ${CYAN}Super + Return${NC}   → Terminal"
    echo "    • ${CYAN}Super + Q${NC}        → Close window"
    echo "    • ${CYAN}Super + A${NC}        → Toggle AnonSurf"
    echo ""
    echo -e "  ${BOLD}Optional:${NC}"
    echo "    • Install AnonSurf: ${CYAN}~/LoverDOT/scripts/build-anonsurf-arch.sh${NC}"
    echo ""
}

# Main
main() {
    check_arch
    echo ""
    
    install_yay
    echo ""
    
    install_packages
    echo ""
    
    enable_services
    echo ""
    
    create_dirs
    setup_wallpaper
    echo ""
    
    install_loverdot
    echo ""
    
    final_setup
    
    show_complete
}

main "$@"
