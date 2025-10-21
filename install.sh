#!/bin/bash

#############################################
# Meta Ads MCP Agent - Automated Installation
# For Ubuntu 24.04 LTS
#############################################

set -e  # Exit on any error

echo "=========================================="
echo "Meta Ads MCP Agent Installation Script"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "Please run as root (use sudo or login as root)"
    exit 1
fi

print_success "Running as root user"

# Update system packages
print_info "Updating system packages..."
apt-get update -qq
print_success "System packages updated"

# Install Python3 and pip
print_info "Installing Python3 and pip..."
apt-get install -y python3 python3-pip python3-dev build-essential git -qq
print_success "Python3 and pip installed"

# Verify Python version
PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
print_success "Python version: $PYTHON_VERSION"

# Set installation directory
INSTALL_DIR="/root/meta-ads-mcp"

# Check if directory already exists
if [ -d "$INSTALL_DIR" ]; then
    print_info "Installation directory already exists. Removing old installation..."
    rm -rf "$INSTALL_DIR"
fi

# Clone the repository
print_info "Cloning Meta Ads MCP repository..."
git clone https://github.com/pipeboard-co/meta-ads-mcp.git "$INSTALL_DIR"
print_success "Repository cloned successfully"

# Change to installation directory
cd "$INSTALL_DIR"

# Install the package with workaround for typing-extensions conflict
print_info "Installing Meta Ads MCP package..."
pip3 install -e . --break-system-packages --ignore-installed typing-extensions 2>&1 | grep -v "WARNING: Running pip as the 'root' user" || true
print_success "Meta Ads MCP package installed"

# Verify installation
print_info "Verifying installation..."
if command -v meta-ads-mcp &> /dev/null; then
    VERSION=$(meta-ads-mcp --version 2>&1 | grep "Meta Ads MCP" | cut -d'v' -f2)
    print_success "Meta Ads MCP v$VERSION installed successfully"
else
    print_error "Installation verification failed"
    exit 1
fi

# Create environment configuration template
print_info "Creating environment configuration template..."
cat > /root/.meta-ads-mcp.env << 'EOF'
# Meta Ads MCP Environment Configuration
# 
# OPTION 1: Pipeboard Authentication (Recommended)
# Get your token from: https://pipeboard.co/api-tokens
# PIPEBOARD_API_TOKEN=your_pipeboard_token_here
#
# OPTION 2: Direct Meta App Authentication
# Create a Meta Developer App at: https://developers.facebook.com/apps/
# META_APP_ID=your_meta_app_id
# META_APP_SECRET=your_meta_app_secret
EOF

print_success "Environment configuration template created at /root/.meta-ads-mcp.env"

# Create systemd service file for running as HTTP server (optional)
print_info "Creating systemd service file..."
cat > /etc/systemd/system/meta-ads-mcp.service << 'EOF'
[Unit]
Description=Meta Ads MCP Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/meta-ads-mcp
EnvironmentFile=/root/.meta-ads-mcp.env
ExecStart=/usr/local/bin/meta-ads-mcp
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

print_success "Systemd service file created"

# Reload systemd
systemctl daemon-reload
print_success "Systemd daemon reloaded"

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
print_info "Next Steps:"
echo "1. Edit /root/.meta-ads-mcp.env and add your authentication credentials"
echo "2. Source the environment file: source /root/.meta-ads-mcp.env"
echo "3. Test the installation: meta-ads-mcp --version"
echo ""
print_info "Optional: Run as a service"
echo "1. Enable service: systemctl enable meta-ads-mcp"
echo "2. Start service: systemctl start meta-ads-mcp"
echo "3. Check status: systemctl status meta-ads-mcp"
echo ""
print_success "Installation script completed successfully!"

