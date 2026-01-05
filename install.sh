#!/bin/bash
# LoverDOT - Universal Installer for Parrot OS / Arch Linux + Hyprland
# Usage: curl -fsSL https://raw.githubusercontent.com/nitzlover/LoverDOT/main/install.sh | bash
# Or:    ./install.sh [--no-deps] [--no-backup]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

# Flags
INSTALL_DEPS=true
BACKUP_ENABLED=true
DISTRO=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }
log_step()  { echo -e "${BLUE}[→]${NC} $1"; }

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-deps)    INSTALL_DEPS=false; shift ;;
            --no-backup)  BACKUP_ENABLED=false; shift ;;
            --help|-h)    show_help; exit 0 ;;
            *)            log_error "Unknown option: $1"; exit 1 ;;
        esac
    done
}

show_help() {
    echo "LoverDOT Installer"
    echo ""
    echo "Usage: ./install.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --no-deps     Skip dependency installation"
    echo "  --no-backup   Skip config backup"
    echo "  -h, --help    Show this help"
}

show_banner() {
    echo -e "${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║     ██╗      ██████╗ ██╗   ██╗███████╗██████╗             ║"
    echo "║     ██║     ██╔═══██╗██║   ██║██╔════╝██╔══██╗            ║"
    echo "║     ██║     ██║   ██║██║   ██║█████╗  ██████╔╝            ║"
    echo "║     ██║     ██║   ██║╚██╗ ██╔╝██╔══╝  ██╔══██╗            ║"
    echo "║     ███████╗╚██████╔╝ ╚████╔╝ ███████╗██║  ██║            ║"
    echo "║     ╚══════╝ ╚═════╝   ╚═══╝  ╚══════╝╚═╝  ╚═╝            ║"
    echo "║                   ██████╗  ██████╗ ████████╗              ║"
    echo "║                   ██╔══██╗██╔═══██╗╚══██╔══╝              ║"
    echo "║                   ██║  ██║██║   ██║   ██║                 ║"
    echo "║                   ██║  ██║██║   ██║   ██║                 ║"
    echo "║                   ██████╔╝╚██████╔╝   ██║                 ║"
    echo "║                   ╚═════╝  ╚═════╝    ╚═╝                 ║"
    echo "║                                                           ║"
    echo "║              Carbon Black Theme for Hyprland              ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            parrot|debian|ubuntu|kali|linuxmint)
                DISTRO="debian"
                log_info "Detected: ${CYAN}$PRETTY_NAME${NC} (Debian-based)"
                ;;
            arch|endeavouros|manjaro|garuda|artix)
                DISTRO="arch"
                log_info "Detected: ${CYAN}$PRETTY_NAME${NC} (Arch-based)"
                ;;
            fedora|rhel|centos)
                DISTRO="fedora"
                log_info "Detected: ${CYAN}$PRETTY_NAME${NC} (Fedora-based)"
                ;;
            *)
                log_warn "Unknown distro: $ID. Will try to detect package manager."
                detect_package_manager
                ;;
        esac
    else
        detect_package_manager
    fi
}

detect_package_manager() {
    if command -v apt &> /dev/null; then
        DISTRO="debian"
    elif command -v pacman &> /dev/null; then
        DISTRO="arch"
    elif command -v dnf &> /dev/null; then
        DISTRO="fedora"
    else
        log_error "Could not detect package manager"
        exit 1
    fi
}

# Package mappings per distro
declare -A PACKAGES_DEBIAN=(
    [hyprland]="hyprland"
    [waybar]="waybar"
    [wofi]="wofi"
    [alacritty]="alacritty"
    [swaync]="swaync"
    [grim]="grim"
    [slurp]="slurp"
    [wl-clipboard]="wl-clipboard"
    [polkit-gnome]="polkit-gnome"
    [thunar]="thunar"
    [pavucontrol]="pavucontrol"
    [network-manager-gnome]="network-manager-gnome"
    [brightnessctl]="brightnessctl"
    [playerctl]="playerctl"
    [fonts]="fonts-jetbrains-mono"
)

declare -A PACKAGES_ARCH=(
    [hyprland]="hyprland"
    [waybar]="waybar"
    [wofi]="wofi"
    [alacritty]="alacritty"
    [swaync]="swaync"
    [grim]="grim"
    [slurp]="slurp"
    [wl-clipboard]="wl-clipboard"
    [polkit-gnome]="polkit-gnome"
    [thunar]="thunar"
    [pavucontrol]="pavucontrol"
    [network-manager-gnome]="nm-connection-editor"
    [brightnessctl]="brightnessctl"
    [playerctl]="playerctl"
    [fonts]="ttf-jetbrains-mono-nerd"
)

declare -A PACKAGES_FEDORA=(
    [hyprland]="hyprland"
    [waybar]="waybar"
    [wofi]="wofi"
    [alacritty]="alacritty"
    [swaync]="SwayNotificationCenter"
    [grim]="grim"
    [slurp]="slurp"
    [wl-clipboard]="wl-clipboard"
    [polkit-gnome]="polkit-gnome"
    [thunar]="thunar"
    [pavucontrol]="pavucontrol"
    [network-manager-gnome]="nm-connection-editor"
    [brightnessctl]="brightnessctl"
    [playerctl]="playerctl"
    [fonts]="jetbrains-mono-fonts"
)

# Install dependencies
install_deps() {
    if [ "$INSTALL_DEPS" = false ]; then
        log_warn "Skipping dependency installation (--no-deps)"
        return
    fi

    log_step "Installing dependencies..."

    local packages=()
    local -n pkg_map="PACKAGES_${DISTRO^^}"
    
    for key in "${!pkg_map[@]}"; do
        packages+=("${pkg_map[$key]}")
    done

    case "$DISTRO" in
        debian)
            log_step "Updating package lists..."
            sudo apt update
            
            log_step "Installing packages: ${packages[*]}"
            sudo apt install -y "${packages[@]}" || {
                log_warn "Some packages may not be available in default repos"
                log_info "For Parrot OS, hyprland may need manual installation"
                install_hyprland_parrot
            }
            ;;
        arch)
            log_step "Installing packages: ${packages[*]}"
            sudo pacman -Syu --noconfirm --needed "${packages[@]}"
            
            # Install AUR packages if yay available
            if command -v yay &> /dev/null; then
                log_step "Installing AUR packages..."
                yay -S --noconfirm --needed hyprpaper hypridle hyprlock || true
            elif command -v paru &> /dev/null; then
                log_step "Installing AUR packages..."
                paru -S --noconfirm --needed hyprpaper hypridle hyprlock || true
            fi
            ;;
        fedora)
            log_step "Installing packages: ${packages[*]}"
            sudo dnf install -y "${packages[@]}"
            ;;
    esac

    log_info "Dependencies installed"
}

# Special handling for Hyprland on Parrot OS
install_hyprland_parrot() {
    if ! command -v hyprland &> /dev/null; then
        log_warn "Hyprland not found in repos"
        echo ""
        echo "For Parrot OS, you may need to:"
        echo "  1. Add the hyprland repo or build from source"
        echo "  2. Or use the Debian Sid backports"
        echo ""
        echo "Quick install (if available):"
        echo "  sudo apt install hyprland"
        echo ""
        read -p "Try to install hyprland from available repos? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt install -y hyprland || log_error "Failed to install hyprland"
        fi
    fi
}

# Backup existing configs
backup_configs() {
    if [ "$BACKUP_ENABLED" = false ]; then
        log_warn "Skipping backup (--no-backup)"
        return
    fi

    local configs=("alacritty" "hypr" "waybar" "wofi" "swaync")
    local need_backup=false
    
    for cfg in "${configs[@]}"; do
        if [ -d "$CONFIG_DIR/$cfg" ] || [ -f "$CONFIG_DIR/$cfg" ]; then
            need_backup=true
            break
        fi
    done
    
    if [ "$need_backup" = true ]; then
        log_step "Backing up existing configs..."
        mkdir -p "$BACKUP_DIR"
        for cfg in "${configs[@]}"; do
            if [ -d "$CONFIG_DIR/$cfg" ]; then
                cp -r "$CONFIG_DIR/$cfg" "$BACKUP_DIR/"
                log_info "Backed up: $cfg"
            elif [ -f "$CONFIG_DIR/$cfg" ]; then
                cp "$CONFIG_DIR/$cfg" "$BACKUP_DIR/"
                log_info "Backed up: $cfg"
            fi
        done
        log_info "Backup saved to: ${CYAN}$BACKUP_DIR${NC}"
    fi
}

# Install configs
install_configs() {
    log_step "Installing configurations..."
    
    mkdir -p "$CONFIG_DIR"
    
    # Copy all configs
    cp -r "$SCRIPT_DIR/.config/"* "$CONFIG_DIR/"
    
    # Set permissions
    chmod -R u+rw "$CONFIG_DIR/hypr" 2>/dev/null || true
    chmod -R u+rw "$CONFIG_DIR/waybar" 2>/dev/null || true
    chmod -R u+rw "$CONFIG_DIR/wofi" 2>/dev/null || true
    chmod -R u+rw "$CONFIG_DIR/swaync" 2>/dev/null || true
    chmod -R u+rw "$CONFIG_DIR/alacritty" 2>/dev/null || true
    
    log_info "Configs installed to: ${CYAN}$CONFIG_DIR${NC}"
}

# Setup Firefox theme
setup_firefox() {
    log_step "Setting up Firefox theme..."
    
    local firefox_dir="$HOME/.mozilla/firefox"
    
    if [ ! -d "$firefox_dir" ]; then
        log_warn "Firefox profile directory not found"
        log_info "Run Firefox once, then re-run this script"
        return
    fi
    
    # Find default profile
    local profile_dir=$(find "$firefox_dir" -maxdepth 1 -name "*.default*" -type d | head -n 1)
    
    if [ -z "$profile_dir" ]; then
        log_warn "No Firefox profile found"
        show_firefox_manual
        return
    fi
    
    # Copy chrome folder
    mkdir -p "$profile_dir/chrome"
    cp -r "$SCRIPT_DIR/.config/firefox/chrome/"* "$profile_dir/chrome/"
    
    log_info "Firefox theme installed to: ${CYAN}$profile_dir/chrome${NC}"
    echo ""
    echo -e "${YELLOW}[!]${NC} Enable Firefox CSS support:"
    echo "    1. Open ${CYAN}about:config${NC} in Firefox"
    echo "    2. Set ${CYAN}toolkit.legacyUserProfileCustomizations.stylesheets${NC} = ${GREEN}true${NC}"
    echo "    3. Restart Firefox"
}

show_firefox_manual() {
    echo ""
    echo -e "${YELLOW}[!]${NC} Manual Firefox setup required:"
    echo "    1. Open ${CYAN}about:profiles${NC} in Firefox"
    echo "    2. Find your profile directory"
    echo "    3. Copy: ${CYAN}cp -r $SCRIPT_DIR/.config/firefox/chrome/ YOUR_PROFILE/${NC}"
    echo "    4. Enable in ${CYAN}about:config${NC}:"
    echo "       ${CYAN}toolkit.legacyUserProfileCustomizations.stylesheets${NC} = ${GREEN}true${NC}"
}

# Post-install actions
post_install() {
    log_step "Post-installation tasks..."
    
    # Reload Hyprland if running
    if pgrep -x "Hyprland" > /dev/null; then
        log_info "Reloading Hyprland config..."
        hyprctl reload 2>/dev/null || true
    fi
    
    # Restart waybar if running
    if pgrep -x "waybar" > /dev/null; then
        log_info "Restarting Waybar..."
        killall waybar 2>/dev/null || true
        nohup waybar &>/dev/null &
    fi
    
    # Restart swaync if running
    if pgrep -x "swaync" > /dev/null; then
        log_info "Restarting SwayNC..."
        killall swaync 2>/dev/null || true
        nohup swaync &>/dev/null &
    fi
}

# Show completion message
show_complete() {
    echo ""
    echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║              Installation Complete!                       ║${NC}"
    echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${CYAN}Theme:${NC}     Carbon Black"
    echo -e "  ${CYAN}Config:${NC}    $CONFIG_DIR"
    if [ "$BACKUP_ENABLED" = true ] && [ -d "$BACKUP_DIR" ]; then
        echo -e "  ${CYAN}Backup:${NC}    $BACKUP_DIR"
    fi
    echo ""
    echo -e "  ${BOLD}Next steps:${NC}"
    echo "    • Log out and select Hyprland session"
    echo "    • Or run: ${CYAN}Hyprland${NC}"
    echo ""
    echo -e "  ${BOLD}Keybindings:${NC}"
    echo "    • ${CYAN}Super + D${NC}        → Wofi launcher"
    echo "    • ${CYAN}Super + Return${NC}   → Alacritty terminal"
    echo "    • ${CYAN}Super + Q${NC}        → Close window"
    echo "    • ${CYAN}Super + N${NC}        → Notification center"
    echo ""
}

# Main
main() {
    parse_args "$@"
    show_banner
    
    detect_distro
    echo ""
    
    install_deps
    echo ""
    
    backup_configs
    echo ""
    
    install_configs
    echo ""
    
    setup_firefox
    echo ""
    
    post_install
    
    show_complete
}

main "$@"
