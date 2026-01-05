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

# Special handling for Hyprland on Parrot OS / Debian
install_hyprland_parrot() {
    if command -v Hyprland &> /dev/null; then
        log_info "Hyprland already installed: $(Hyprland --version 2>/dev/null | head -1)"
        return
    fi
    
    log_warn "Hyprland not installed"
    echo ""
    echo "Options:"
    echo "  1. Try apt install (may fail due to broken dependencies)"
    echo "  2. Build from source (recommended for Parrot OS)"
    echo "  3. Skip Hyprland installation"
    echo ""
    read -p "Choose option [1/2/3]: " -n 1 -r
    echo
    
    case $REPLY in
        1)
            log_step "Trying apt install..."
            if sudo apt install -y hyprland 2>/dev/null; then
                log_info "Hyprland installed via apt"
            else
                log_error "apt install failed (broken dependencies)"
                echo ""
                read -p "Build from source instead? [Y/n] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Nn]$ ]]; then
                    build_hyprland_from_source
                fi
            fi
            ;;
        2)
            build_hyprland_from_source
            ;;
        3)
            log_warn "Skipping Hyprland installation"
            log_info "Run scripts/build-hyprland-debian.sh manually later"
            ;;
        *)
            log_warn "Invalid option, skipping"
            ;;
    esac
}

# Build Hyprland from source
build_hyprland_from_source() {
    local build_script="$SCRIPT_DIR/scripts/build-hyprland-debian.sh"
    
    if [ -f "$build_script" ]; then
        log_step "Running Hyprland build script..."
        chmod +x "$build_script"
        bash "$build_script"
    else
        log_error "Build script not found: $build_script"
        echo "Clone the full repo and try again:"
        echo "  git clone https://github.com/nitzlover/LoverDOT.git"
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

# Install Hyprland session for display manager (SDDM, GDM, LightDM)
install_session() {
    log_step "Installing Hyprland session..."
    
    local session_file="$SCRIPT_DIR/.config/hypr/hyprland.desktop"
    local launcher_script="$SCRIPT_DIR/.config/hypr/start-hyprland.sh"
    local wayland_sessions="/usr/share/wayland-sessions"
    
    # Install launcher script with VM support
    if [ -f "$launcher_script" ]; then
        log_step "Installing Hyprland launcher script..."
        sudo cp "$launcher_script" /usr/local/bin/start-hyprland
        sudo chmod 755 /usr/local/bin/start-hyprland
        log_info "Launcher installed to /usr/local/bin/start-hyprland"
    else
        # Create launcher script inline
        log_step "Creating Hyprland launcher script..."
        sudo tee /usr/local/bin/start-hyprland > /dev/null << 'LAUNCHER'
#!/bin/bash
# Hyprland launcher with VM/software rendering support

detect_vm() {
    systemd-detect-virt -q 2>/dev/null && return 0
    grep -qi "hypervisor\|vmware\|virtualbox\|qemu\|kvm" /proc/cpuinfo 2>/dev/null && return 0
    return 1
}

export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_CURRENT_DESKTOP=Hyprland
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export GDK_BACKEND=wayland,x11
export MOZ_ENABLE_WAYLAND=1

if detect_vm; then
    export WLR_RENDERER=pixman
    export WLR_NO_HARDWARE_CURSORS=1
    export LIBGL_ALWAYS_SOFTWARE=1
    export WLR_RENDERER_ALLOW_SOFTWARE=1
fi

exec Hyprland "$@"
LAUNCHER
        sudo chmod 755 /usr/local/bin/start-hyprland
        log_info "Launcher script created"
    fi
    
    # Create session file if not exists
    if [ ! -f "$session_file" ]; then
        log_warn "Session file not found, creating..."
        cat > "/tmp/hyprland.desktop" << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=/usr/local/bin/start-hyprland
Type=Application
DesktopNames=Hyprland
EOF
        session_file="/tmp/hyprland.desktop"
    fi
    
    # Install session file
    sudo mkdir -p "$wayland_sessions"
    sudo cp "$session_file" "$wayland_sessions/hyprland.desktop"
    sudo chmod 644 "$wayland_sessions/hyprland.desktop"
    log_info "Session installed to $wayland_sessions"
}

# Install SDDM theme
install_sddm_theme() {
    log_step "Installing SDDM theme..."
    
    local sddm_theme_src="$SCRIPT_DIR/.config/sddm/themes/carbon-black"
    local sddm_theme_dst="/usr/share/sddm/themes/carbon-black"
    
    if [ ! -d "$sddm_theme_src" ]; then
        log_warn "SDDM theme not found in dotfiles"
        return
    fi
    
    # Copy theme
    sudo mkdir -p "$sddm_theme_dst"
    sudo cp -r "$sddm_theme_src/"* "$sddm_theme_dst/"
    
    # Create default background if not exists
    if [ ! -f "$sddm_theme_dst/background.png" ]; then
        # Create a simple dark gradient background
        if command -v convert &> /dev/null; then
            sudo convert -size 1920x1080 gradient:'#121212'-'#0a0a0a' "$sddm_theme_dst/background.png"
        else
            log_warn "ImageMagick not found, using placeholder background"
        fi
    fi
    
    # Configure SDDM to use theme
    if [ -f "/etc/sddm.conf" ] || [ -d "/etc/sddm.conf.d" ]; then
        sudo mkdir -p /etc/sddm.conf.d
        sudo tee /etc/sddm.conf.d/theme.conf > /dev/null << 'EOF'
[Theme]
Current=carbon-black
EOF
        log_info "SDDM theme configured"
    else
        log_warn "SDDM config not found, theme installed but not activated"
        log_info "Manually set theme in SDDM settings"
    fi
    
    log_info "SDDM theme installed to $sddm_theme_dst"
}

# Install AnonSurf (Arch Linux)
install_anonsurf() {
    if [ "$DISTRO" != "arch" ]; then
        return
    fi
    
    if command -v anonsurf &> /dev/null; then
        log_info "AnonSurf already installed"
        return
    fi
    
    echo ""
    read -p "Install AnonSurf (Tor anonymity)? [y/N] " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        local build_script="$SCRIPT_DIR/scripts/build-anonsurf-arch.sh"
        if [ -f "$build_script" ]; then
            chmod +x "$build_script"
            bash "$build_script"
        else
            log_warn "AnonSurf build script not found"
        fi
    fi
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
    
    install_session
    echo ""
    
    install_sddm_theme
    echo ""
    
    setup_firefox
    echo ""
    
    install_anonsurf
    echo ""
    
    post_install
    
    show_complete
}

main "$@"
