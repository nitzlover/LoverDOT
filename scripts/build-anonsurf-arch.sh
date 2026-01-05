#!/bin/bash
# Build AnonSurf from source for Arch Linux
# AnonSurf is a Parrot OS tool for routing traffic through Tor

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

BUILD_DIR="$HOME/.cache/anonsurf-build"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         AnonSurf Build Script for Arch Linux              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo

# Install dependencies
install_deps() {
    log_step "Installing dependencies..."
    
    sudo pacman -Syu --noconfirm --needed \
        tor \
        iptables \
        python \
        python-stem \
        macchanger \
        sipcalc \
        curl \
        wget \
        net-tools \
        iproute2 \
        procps-ng \
        gawk \
        sed \
        grep \
        coreutils \
        util-linux \
        systemd \
        polkit \
        libnotify
    
    log_info "Dependencies installed"
}

# Clone and build AnonSurf
build_anonsurf() {
    log_step "Cloning AnonSurf repository..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    if [ -d "anonsurf" ]; then
        cd anonsurf
        git pull
    else
        git clone https://github.com/ParrotSec/anonsurf.git
        cd anonsurf
    fi
    
    log_step "Installing AnonSurf..."
    
    # Create directories
    sudo mkdir -p /usr/bin
    sudo mkdir -p /usr/share/anonsurf
    sudo mkdir -p /etc/anonsurf
    sudo mkdir -p /usr/lib/systemd/system
    
    # Copy main script
    sudo cp anonsurf /usr/bin/anonsurf
    sudo chmod +x /usr/bin/anonsurf
    
    # Copy library files
    if [ -d "usr/share/anonsurf" ]; then
        sudo cp -r usr/share/anonsurf/* /usr/share/anonsurf/
    fi
    
    # Copy config files
    if [ -d "etc/anonsurf" ]; then
        sudo cp -r etc/anonsurf/* /etc/anonsurf/
    fi
    
    # Create default config if not exists
    if [ ! -f "/etc/anonsurf/anonsurf.conf" ]; then
        sudo tee /etc/anonsurf/anonsurf.conf > /dev/null << 'EOF'
# AnonSurf Configuration
TOR_UID="tor"
TRANS_PORT="9040"
DNS_PORT="5353"
VIRT_ADDR="10.192.0.0/10"
NON_TOR="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"
EOF
    fi
    
    log_info "AnonSurf installed"
}

# Create systemd service
create_service() {
    log_step "Creating systemd service..."
    
    sudo tee /usr/lib/systemd/system/anonsurf.service > /dev/null << 'EOF'
[Unit]
Description=AnonSurf - Anonymous Mode
After=network.target tor.service
Wants=tor.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/anonsurf start
ExecStop=/usr/bin/anonsurf stop

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    log_info "Systemd service created"
}

# Create polkit rule for passwordless toggle
create_polkit_rule() {
    log_step "Creating polkit rule..."
    
    sudo mkdir -p /etc/polkit-1/rules.d
    sudo tee /etc/polkit-1/rules.d/50-anonsurf.rules > /dev/null << 'EOF'
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.policykit.exec" &&
        action.lookup("program") == "/usr/bin/anonsurf" &&
        subject.isInGroup("wheel")) {
        return polkit.Result.YES;
    }
});
EOF
    
    log_info "Polkit rule created"
}

# Configure Tor
configure_tor() {
    log_step "Configuring Tor..."
    
    # Backup original config
    if [ -f "/etc/tor/torrc" ] && [ ! -f "/etc/tor/torrc.backup" ]; then
        sudo cp /etc/tor/torrc /etc/tor/torrc.backup
    fi
    
    # Add AnonSurf specific config
    if ! grep -q "# AnonSurf Config" /etc/tor/torrc 2>/dev/null; then
        sudo tee -a /etc/tor/torrc > /dev/null << 'EOF'

# AnonSurf Config
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040
DNSPort 5353
EOF
    fi
    
    # Enable and start Tor
    sudo systemctl enable tor
    sudo systemctl start tor || log_warn "Tor service may need manual start"
    
    log_info "Tor configured"
}

# Verify installation
verify() {
    echo
    if command -v anonsurf &> /dev/null; then
        log_info "AnonSurf installed successfully!"
        echo
        echo "Usage:"
        echo "  anonsurf start     - Start anonymous mode"
        echo "  anonsurf stop      - Stop anonymous mode"
        echo "  anonsurf status    - Check status"
        echo "  anonsurf myip      - Show current IP"
        echo "  anonsurf changemac - Change MAC address"
        echo
    else
        log_error "Installation verification failed"
        exit 1
    fi
}

# Main
main() {
    install_deps
    echo
    
    build_anonsurf
    echo
    
    create_service
    create_polkit_rule
    configure_tor
    echo
    
    verify
    
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║              AnonSurf Installation Complete!              ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo
}

main "$@"
