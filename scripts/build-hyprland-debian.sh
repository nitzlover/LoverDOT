#!/bin/bash
# Build Hyprland from source for Debian/Parrot OS
# Run this if apt install hyprland fails due to broken dependencies

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[✓]${NC} $1"; }
log_step()  { echo -e "${CYAN}[→]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; }

BUILD_DIR="$HOME/.cache/hyprland-build"
HYPRLAND_VERSION="v0.45.0"  # Stable version

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║       Hyprland Build Script for Debian/Parrot OS          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo

# Install build dependencies
install_deps() {
    log_step "Installing build dependencies..."
    
    sudo apt update
    
    # Essential build tools first
    sudo apt install -y build-essential cmake meson ninja-build pkg-config git gettext || {
        log_error "Failed to install essential build tools"
        exit 1
    }
    
    # Wayland and graphics deps
    sudo apt install -y \
        libwayland-dev \
        wayland-protocols \
        libxkbcommon-dev \
        libpixman-1-dev \
        libdrm-dev \
        libgbm-dev \
        libegl-dev \
        libgles2-mesa-dev \
        libseat-dev \
        libinput-dev \
        libxcb-composite0-dev \
        libxcb-dri3-dev \
        libxcb-present-dev \
        libxcb-render-util0-dev \
        libxcb-res0-dev \
        libxcb-xfixes0-dev \
        libxcb-xinput-dev \
        libcairo2-dev \
        libpango1.0-dev \
        libtomlplusplus-dev \
        libzip-dev \
        librsvg2-dev \
        libmagic-dev \
        hwdata \
        edid-decode \
        libdisplay-info-dev \
        libliftoff-dev \
        libxcb-errors-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libswresample-dev \
        libpipewire-0.3-dev \
        libspa-0.2-dev \
        libpulse-dev \
        libglvnd-dev \
        glslang-tools || {
            log_warn "Some packages may not be available, continuing..."
        }
    
    log_info "Build dependencies installed"
}

# Build and install hyprlang
build_hyprlang() {
    log_step "Building hyprlang..."
    
    cd "$BUILD_DIR"
    if [ ! -d "hyprlang" ]; then
        git clone --depth 1 https://github.com/hyprwm/hyprlang.git
    fi
    cd hyprlang
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "hyprlang installed"
}

# Build and install hyprcursor
build_hyprcursor() {
    log_step "Building hyprcursor..."
    
    cd "$BUILD_DIR"
    if [ ! -d "hyprcursor" ]; then
        git clone --depth 1 https://github.com/hyprwm/hyprcursor.git
    fi
    cd hyprcursor
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "hyprcursor installed"
}

# Build and install hyprutils
build_hyprutils() {
    log_step "Building hyprutils..."
    
    cd "$BUILD_DIR"
    if [ ! -d "hyprutils" ]; then
        git clone --depth 1 https://github.com/hyprwm/hyprutils.git
    fi
    cd hyprutils
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "hyprutils installed"
}

# Build and install hyprwayland-scanner
build_hyprwayland_scanner() {
    log_step "Building hyprwayland-scanner..."
    
    cd "$BUILD_DIR"
    if [ ! -d "hyprwayland-scanner" ]; then
        git clone --depth 1 https://github.com/hyprwm/hyprwayland-scanner.git
    fi
    cd hyprwayland-scanner
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "hyprwayland-scanner installed"
}

# Build and install aquamarine
build_aquamarine() {
    log_step "Building aquamarine..."
    
    cd "$BUILD_DIR"
    if [ ! -d "aquamarine" ]; then
        git clone --depth 1 https://github.com/hyprwm/aquamarine.git
    fi
    cd aquamarine
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "aquamarine installed"
}

# Build and install hyprgraphics  
build_hyprgraphics() {
    log_step "Building hyprgraphics..."
    
    cd "$BUILD_DIR"
    if [ ! -d "hyprgraphics" ]; then
        git clone --depth 1 https://github.com/hyprwm/hyprgraphics.git
    fi
    cd hyprgraphics
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "hyprgraphics installed"
}

# Build and install Hyprland
build_hyprland() {
    log_step "Building Hyprland..."
    
    cd "$BUILD_DIR"
    if [ ! -d "Hyprland" ]; then
        git clone --recursive https://github.com/hyprwm/Hyprland.git
    fi
    cd Hyprland
    git checkout "$HYPRLAND_VERSION" 2>/dev/null || git checkout main
    git submodule update --init --recursive
    
    cmake -B build \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DNO_SYSTEMD=OFF
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "Hyprland installed"
}

# Install xdg-desktop-portal-hyprland
build_xdph() {
    log_step "Building xdg-desktop-portal-hyprland..."
    
    cd "$BUILD_DIR"
    if [ ! -d "xdg-desktop-portal-hyprland" ]; then
        git clone --depth 1 https://github.com/hyprwm/xdg-desktop-portal-hyprland.git
    fi
    cd xdg-desktop-portal-hyprland
    cmake -B build -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release
    cmake --build build -j$(nproc)
    sudo cmake --install build
    
    log_info "xdg-desktop-portal-hyprland installed"
}

# Create session file
create_session() {
    log_step "Creating Hyprland session..."
    
    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/hyprland.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland
Comment=An intelligent dynamic tiling Wayland compositor
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF
    
    log_info "Session file created"
}

# Update library cache
update_ldconfig() {
    log_step "Updating library cache..."
    sudo ldconfig
    log_info "Library cache updated"
}

# Verify installation
verify() {
    echo
    if command -v Hyprland &> /dev/null; then
        log_info "Hyprland installed successfully!"
        Hyprland --version
    else
        log_error "Installation failed"
        exit 1
    fi
}

# Main
main() {
    mkdir -p "$BUILD_DIR"
    
    install_deps
    echo
    
    # Build dependencies in order
    build_hyprutils
    build_hyprlang
    build_hyprcursor
    build_hyprwayland_scanner
    build_aquamarine
    build_hyprgraphics
    echo
    
    # Build Hyprland
    build_hyprland
    echo
    
    # Build portal
    build_xdph
    echo
    
    create_session
    update_ldconfig
    verify
    
    echo
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              Build Complete!                              ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo
    echo "Log out and select Hyprland from the session menu."
    echo
}

main "$@"
