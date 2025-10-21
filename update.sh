#!/bin/bash

#############################################
# Meta Ads MCP Agent - Update Script
# For upgrading to latest version
#############################################

set -e  # Exit on any error

echo "=========================================="
echo "Meta Ads MCP Agent Update Script"
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

# Installation directory
INSTALL_DIR="/root/meta-ads-mcp"

# Check if installation exists
if [ ! -d "$INSTALL_DIR" ]; then
    print_error "Meta Ads MCP installation not found at $INSTALL_DIR"
    print_info "Please run install.sh first"
    exit 1
fi

# Get current version
print_info "Checking current version..."
CURRENT_VERSION=$(meta-ads-mcp --version 2>&1 | grep "Meta Ads MCP" | cut -d'v' -f2 || echo "unknown")
print_info "Current version: $CURRENT_VERSION"

# Stop service if running
if systemctl is-active --quiet meta-ads-mcp; then
    print_info "Stopping meta-ads-mcp service..."
    systemctl stop meta-ads-mcp
    print_success "Service stopped"
    SERVICE_WAS_RUNNING=true
else
    SERVICE_WAS_RUNNING=false
fi

# Backup current installation
print_info "Creating backup..."
BACKUP_DIR="/root/meta-ads-mcp-backup-$(date +%Y%m%d-%H%M%S)"
cp -r "$INSTALL_DIR" "$BACKUP_DIR"
print_success "Backup created at $BACKUP_DIR"

# Update repository
print_info "Updating repository..."
cd "$INSTALL_DIR"
git fetch origin
git pull origin main
print_success "Repository updated"

# Reinstall package
print_info "Updating package..."
pip3 install -e . --break-system-packages --ignore-installed typing-extensions --upgrade 2>&1 | grep -v "WARNING: Running pip as the 'root' user" || true
print_success "Package updated"

# Get new version
print_info "Checking new version..."
NEW_VERSION=$(meta-ads-mcp --version 2>&1 | grep "Meta Ads MCP" | cut -d'v' -f2 || echo "unknown")
print_success "New version: $NEW_VERSION"

# Restart service if it was running
if [ "$SERVICE_WAS_RUNNING" = true ]; then
    print_info "Starting meta-ads-mcp service..."
    systemctl start meta-ads-mcp
    sleep 2
    if systemctl is-active --quiet meta-ads-mcp; then
        print_success "Service started successfully"
    else
        print_error "Service failed to start"
        print_info "Check logs with: journalctl -u meta-ads-mcp -n 50"
        print_info "Restore backup if needed: rm -rf $INSTALL_DIR && mv $BACKUP_DIR $INSTALL_DIR"
        exit 1
    fi
fi

echo ""
echo "=========================================="
echo "Update Complete!"
echo "=========================================="
echo ""
print_info "Version changed: $CURRENT_VERSION → $NEW_VERSION"
print_info "Backup location: $BACKUP_DIR"
echo ""
print_success "Update completed successfully!"

# Cleanup old backups (keep last 5)
print_info "Cleaning up old backups..."
cd /root
ls -dt meta-ads-mcp-backup-* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true
print_success "Old backups cleaned"

