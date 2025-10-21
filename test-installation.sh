#!/bin/bash

#############################################
# Meta Ads MCP Agent - Installation Test Script
# Verifies all components are working
#############################################

echo "=========================================="
echo "Meta Ads MCP Installation Test"
echo "=========================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

test_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    ((PASS++))
}

test_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    ((FAIL++))
}

test_info() {
    echo -e "${YELLOW}ℹ INFO${NC}: $1"
}

# Test 1: Check if running as root
echo "Test 1: Root privileges"
if [ "$EUID" -eq 0 ]; then
    test_pass "Running as root"
else
    test_fail "Not running as root"
fi
echo ""

# Test 2: Python installation
echo "Test 2: Python installation"
if command -v python3 &> /dev/null; then
    VERSION=$(python3 --version)
    test_pass "Python3 installed: $VERSION"
else
    test_fail "Python3 not found"
fi
echo ""

# Test 3: Pip installation
echo "Test 3: Pip installation"
if command -v pip3 &> /dev/null; then
    VERSION=$(pip3 --version | cut -d' ' -f1-2)
    test_pass "Pip3 installed: $VERSION"
else
    test_fail "Pip3 not found"
fi
echo ""

# Test 4: Git installation
echo "Test 4: Git installation"
if command -v git &> /dev/null; then
    VERSION=$(git --version)
    test_pass "Git installed: $VERSION"
else
    test_fail "Git not found"
fi
echo ""

# Test 5: Repository cloned
echo "Test 5: Repository cloned"
if [ -d "/root/meta-ads-mcp" ]; then
    test_pass "Repository exists at /root/meta-ads-mcp"
    if [ -f "/root/meta-ads-mcp/pyproject.toml" ]; then
        test_pass "Project files present"
    else
        test_fail "Project files missing"
    fi
else
    test_fail "Repository not found"
fi
echo ""

# Test 6: Package installed
echo "Test 6: Package installation"
if command -v meta-ads-mcp &> /dev/null; then
    test_pass "meta-ads-mcp binary found"
    LOCATION=$(which meta-ads-mcp)
    test_info "Binary location: $LOCATION"
else
    test_fail "meta-ads-mcp binary not found"
fi
echo ""

# Test 7: Version check
echo "Test 7: Version check"
if command -v meta-ads-mcp &> /dev/null; then
    VERSION=$(meta-ads-mcp --version 2>&1 | grep "Meta Ads MCP v" | cut -d'v' -f2)
    if [ -n "$VERSION" ]; then
        test_pass "Version: $VERSION"
    else
        test_fail "Could not determine version"
    fi
else
    test_fail "Cannot check version - binary not found"
fi
echo ""

# Test 8: Configuration file
echo "Test 8: Configuration file"
if [ -f "/root/.meta-ads-mcp.env" ]; then
    test_pass "Environment file exists"
    PERMS=$(stat -c %a /root/.meta-ads-mcp.env)
    if [ "$PERMS" = "600" ]; then
        test_pass "File permissions correct (600)"
    else
        test_fail "File permissions incorrect ($PERMS, should be 600)"
    fi
else
    test_fail "Environment file not found"
fi
echo ""

# Test 9: Systemd service
echo "Test 9: Systemd service"
if [ -f "/etc/systemd/system/meta-ads-mcp.service" ]; then
    test_pass "Service file exists"
    if systemctl list-unit-files | grep -q meta-ads-mcp.service; then
        test_pass "Service registered with systemd"
    else
        test_fail "Service not registered"
    fi
else
    test_fail "Service file not found"
fi
echo ""

# Test 10: Helper scripts
echo "Test 10: Helper scripts"
HELPERS=("meta-ads-start" "meta-ads-stop" "meta-ads-status" "meta-ads-logs")
for helper in "${HELPERS[@]}"; do
    if [ -f "/usr/local/bin/$helper" ] && [ -x "/usr/local/bin/$helper" ]; then
        test_pass "$helper script exists and is executable"
    else
        test_fail "$helper script missing or not executable"
    fi
done
echo ""

# Test 11: Python package dependencies
echo "Test 11: Python package dependencies"
REQUIRED_PACKAGES=("mcp" "httpx" "pydantic" "requests")
for package in "${REQUIRED_PACKAGES[@]}"; do
    if pip3 list 2>/dev/null | grep -q "^$package "; then
        VERSION=$(pip3 list 2>/dev/null | grep "^$package " | awk '{print $2}')
        test_pass "$package installed (v$VERSION)"
    else
        test_fail "$package not installed"
    fi
done
echo ""

# Test 12: Quick reference guide
echo "Test 12: Documentation"
if [ -f "/root/META_ADS_QUICK_REFERENCE.txt" ]; then
    test_pass "Quick reference guide exists"
else
    test_fail "Quick reference guide not found"
fi
echo ""

# Summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo -e "${GREEN}Passed: $PASS${NC}"
echo -e "${RED}Failed: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "Installation is complete and working correctly."
    echo ""
    echo "Next steps:"
    echo "1. Edit /root/.meta-ads-mcp.env and add your API token"
    echo "2. Run: source /root/.meta-ads-mcp.env"
    echo "3. Test: meta-ads-mcp --version"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Please review the failed tests above and:"
    echo "1. Re-run the installation script"
    echo "2. Check the installation logs"
    echo "3. Contact support if issues persist"
    exit 1
fi

