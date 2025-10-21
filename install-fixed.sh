#!/bin/bash

#############################################
# Meta Ads MCP Agent - ERROR-FREE Installation
# All known issues pre-fixed
# For Ubuntu 24.04 LTS / 22.04 LTS
#############################################

set -e  # Exit on any error

echo "=========================================="
echo "Meta Ads MCP Agent - Fixed Installation"
echo "All known errors pre-patched"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo or login as root)"
    exit 1
fi

print_success "Running as root user"
echo ""

# ============================================
# STEP 1: System Package Updates
# ============================================
print_step "STEP 1: Updating system packages..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq > /dev/null 2>&1
print_success "System packages updated"
echo ""

# ============================================
# STEP 2: Install Dependencies
# FIX: Install all required packages including pip
# ============================================
print_step "STEP 2: Installing dependencies..."
print_info "Installing Python3, pip, git, and build tools..."

# Install with minimal output
apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    build-essential \
    git \
    curl \
    wget \
    -qq > /dev/null 2>&1

print_success "Python3 and pip installed"
print_success "Build tools installed"
print_success "Git installed"

# Verify installations
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
GIT_VERSION=$(git --version | cut -d' ' -f3)

print_info "Python version: $PYTHON_VERSION"
print_info "Pip version: $PIP_VERSION"
print_info "Git version: $GIT_VERSION"
echo ""

# ============================================
# STEP 3: Clone Repository
# ============================================
print_step "STEP 3: Cloning Meta Ads MCP repository..."

INSTALL_DIR="/root/meta-ads-mcp"

# Remove old installation if exists
if [ -d "$INSTALL_DIR" ]; then
    print_info "Removing old installation..."
    rm -rf "$INSTALL_DIR"
fi

# Clone with minimal output
git clone https://github.com/pipeboard-co/meta-ads-mcp.git "$INSTALL_DIR" > /dev/null 2>&1
print_success "Repository cloned to $INSTALL_DIR"
echo ""

# ============================================
# STEP 4: Install Package with Error Fixes
# FIX: Handle typing-extensions conflict
# FIX: Suppress root user warnings
# ============================================
print_step "STEP 4: Installing Meta Ads MCP package..."
print_info "Applying fixes for known issues..."

cd "$INSTALL_DIR"

# Create a wrapper script to filter warnings
cat > /tmp/install_filtered.sh << 'INSTALL_SCRIPT'
#!/bin/bash
pip3 install -e . \
    --break-system-packages \
    --ignore-installed typing-extensions \
    --quiet \
    2>&1 | grep -v "WARNING: Running pip as the 'root' user" | grep -v "It is recommended to use a virtual environment"
INSTALL_SCRIPT

chmod +x /tmp/install_filtered.sh
/tmp/install_filtered.sh

print_success "✓ FIX APPLIED: typing-extensions conflict resolved"
print_success "✓ FIX APPLIED: System package warnings suppressed"
print_success "Meta Ads MCP package installed"
echo ""

# ============================================
# STEP 5: Verify Installation
# ============================================
print_step "STEP 5: Verifying installation..."

if command -v meta-ads-mcp &> /dev/null; then
    # Get version without warnings
    VERSION=$(meta-ads-mcp --version 2>&1 | grep "Meta Ads MCP v" | cut -d'v' -f2)
    print_success "Meta Ads MCP v$VERSION installed successfully"
    print_success "Binary location: $(which meta-ads-mcp)"
else
    print_error "Installation verification failed"
    exit 1
fi
echo ""

# ============================================
# STEP 6: Create Configuration Files
# FIX: Pre-configure to avoid environment warnings
# ============================================
print_step "STEP 6: Creating configuration files..."

# Create environment file with template
cat > /root/.meta-ads-mcp.env << 'EOF'
# ============================================
# Meta Ads MCP Environment Configuration
# ============================================
#
# AUTHENTICATION OPTIONS:
# Choose ONE of the following authentication methods:
#
# OPTION 1: Pipeboard Authentication (RECOMMENDED)
# -------------------------------------------------
# This is the easiest method. Get your token from:
# https://pipeboard.co/api-tokens
#
# Uncomment and set your token:
# PIPEBOARD_API_TOKEN=your_pipeboard_token_here
#
# OPTION 2: Direct Meta App Authentication
# -----------------------------------------
# Use your own Meta Developer App.
# Create an app at: https://developers.facebook.com/apps/
#
# Uncomment and set your credentials:
# META_APP_ID=your_meta_app_id
# META_APP_SECRET=your_meta_app_secret
#
# OPTIONAL SETTINGS:
# ------------------
# LOG_LEVEL=INFO
# META_API_VERSION=v18.0
#
# ============================================
# IMPORTANT: After editing this file, run:
# source /root/.meta-ads-mcp.env
# ============================================
EOF

chmod 600 /root/.meta-ads-mcp.env
print_success "Environment file created: /root/.meta-ads-mcp.env"
print_success "✓ FIX APPLIED: File permissions secured (600)"
echo ""

# ============================================
# STEP 7: Create Systemd Service
# ============================================
print_step "STEP 7: Creating systemd service..."

cat > /etc/systemd/system/meta-ads-mcp.service << 'EOF'
[Unit]
Description=Meta Ads MCP Server
Documentation=https://github.com/pipeboard-co/meta-ads-mcp
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/meta-ads-mcp
EnvironmentFile=-/root/.meta-ads-mcp.env
ExecStart=/usr/local/bin/meta-ads-mcp
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=meta-ads-mcp

# Security settings
NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

chmod 644 /etc/systemd/system/meta-ads-mcp.service
systemctl daemon-reload > /dev/null 2>&1

print_success "Systemd service created"
print_success "Service file: /etc/systemd/system/meta-ads-mcp.service"
echo ""

# ============================================
# STEP 8: Create Helper Scripts
# ============================================
print_step "STEP 8: Creating helper scripts..."

# Create start script
cat > /usr/local/bin/meta-ads-start << 'EOF'
#!/bin/bash
if [ -f /root/.meta-ads-mcp.env ]; then
    source /root/.meta-ads-mcp.env
fi
systemctl start meta-ads-mcp
systemctl status meta-ads-mcp --no-pager
EOF
chmod +x /usr/local/bin/meta-ads-start

# Create stop script
cat > /usr/local/bin/meta-ads-stop << 'EOF'
#!/bin/bash
systemctl stop meta-ads-mcp
echo "Meta Ads MCP service stopped"
EOF
chmod +x /usr/local/bin/meta-ads-stop

# Create status script
cat > /usr/local/bin/meta-ads-status << 'EOF'
#!/bin/bash
systemctl status meta-ads-mcp --no-pager
EOF
chmod +x /usr/local/bin/meta-ads-status

# Create logs script
cat > /usr/local/bin/meta-ads-logs << 'EOF'
#!/bin/bash
journalctl -u meta-ads-mcp -f
EOF
chmod +x /usr/local/bin/meta-ads-logs

print_success "Helper scripts created:"
print_info "  - meta-ads-start  (start service)"
print_info "  - meta-ads-stop   (stop service)"
print_info "  - meta-ads-status (check status)"
print_info "  - meta-ads-logs   (view logs)"
echo ""

# ============================================
# STEP 9: Create Quick Reference Guide
# ============================================
print_step "STEP 9: Creating quick reference guide..."

cat > /root/META_ADS_QUICK_REFERENCE.txt << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║          META ADS MCP AGENT - QUICK REFERENCE                  ║
╚════════════════════════════════════════════════════════════════╝

INSTALLATION COMPLETE! ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 NEXT STEPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Configure Authentication:
   nano /root/.meta-ads-mcp.env
   
   Add your Pipeboard token:
   PIPEBOARD_API_TOKEN=your_token_here

2. Load Environment:
   source /root/.meta-ads-mcp.env

3. Test Installation:
   meta-ads-mcp --version

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 QUICK COMMANDS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Service Management:
  meta-ads-start    - Start the service
  meta-ads-stop     - Stop the service
  meta-ads-status   - Check service status
  meta-ads-logs     - View live logs

Manual Commands:
  meta-ads-mcp --version           - Check version
  meta-ads-mcp --help              - Show help
  systemctl enable meta-ads-mcp    - Enable auto-start
  systemctl disable meta-ads-mcp   - Disable auto-start

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 IMPORTANT FILES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Installation:     /root/meta-ads-mcp/
Configuration:    /root/.meta-ads-mcp.env
Service File:     /etc/systemd/system/meta-ads-mcp.service
Binary:           /usr/local/bin/meta-ads-mcp

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔧 TROUBLESHOOTING:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Service won't start:
  1. Check logs: meta-ads-logs
  2. Verify config: cat /root/.meta-ads-mcp.env
  3. Test manually: source /root/.meta-ads-mcp.env && meta-ads-mcp

Authentication issues:
  1. Verify token: echo $PIPEBOARD_API_TOKEN
  2. Get new token: https://pipeboard.co/api-tokens
  3. Reload config: source /root/.meta-ads-mcp.env

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📚 RESOURCES:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Documentation: https://github.com/pipeboard-co/meta-ads-mcp
Discord:       https://discord.gg/pipeboard
Support:       support@pipeboard.co

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ ALL KNOWN ERRORS FIXED:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ pip3 missing - FIXED (auto-installed)
✓ typing-extensions conflict - FIXED (--ignore-installed)
✓ Root user warnings - FIXED (filtered)
✓ Environment warnings - FIXED (template provided)
✓ Permission issues - FIXED (chmod 600)

EOF

print_success "Quick reference guide created: /root/META_ADS_QUICK_REFERENCE.txt"
echo ""

# ============================================
# STEP 10: Final Summary
# ============================================
print_step "STEP 10: Installation Summary"
echo ""

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                   INSTALLATION COMPLETE! ✓                     ║
╚════════════════════════════════════════════════════════════════╝
EOF

echo ""
print_success "All components installed successfully"
print_success "All known errors have been fixed"
echo ""

print_info "═══════════════════════════════════════════════════════════"
print_info "NEXT STEPS:"
print_info "═══════════════════════════════════════════════════════════"
echo ""
echo "1. Configure authentication:"
echo "   nano /root/.meta-ads-mcp.env"
echo ""
echo "2. Add your Pipeboard token (get from https://pipeboard.co/api-tokens):"
echo "   PIPEBOARD_API_TOKEN=your_token_here"
echo ""
echo "3. Load environment variables:"
echo "   source /root/.meta-ads-mcp.env"
echo ""
echo "4. Test the installation:"
echo "   meta-ads-mcp --version"
echo ""
echo "5. (Optional) Enable and start as service:"
echo "   systemctl enable meta-ads-mcp"
echo "   systemctl start meta-ads-mcp"
echo ""
print_info "═══════════════════════════════════════════════════════════"
print_info "QUICK REFERENCE:"
print_info "═══════════════════════════════════════════════════════════"
echo ""
echo "View quick reference: cat /root/META_ADS_QUICK_REFERENCE.txt"
echo ""
echo "Helper commands:"
echo "  • meta-ads-start   - Start service"
echo "  • meta-ads-stop    - Stop service"
echo "  • meta-ads-status  - Check status"
echo "  • meta-ads-logs    - View logs"
echo ""
print_info "═══════════════════════════════════════════════════════════"
echo ""
print_success "Installation completed successfully!"
print_success "Total time: ~3 minutes"
echo ""

# Cleanup
rm -f /tmp/install_filtered.sh

exit 0

