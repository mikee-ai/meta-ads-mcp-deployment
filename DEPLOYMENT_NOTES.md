# Deployment Notes - Meta Ads MCP Agent

## Installation Summary

**Date**: October 21, 2025  
**Target Server**: 72.60.175.85  
**OS**: Ubuntu 24.04.3 LTS  
**Python Version**: 3.12.3  
**Meta Ads MCP Version**: 1.0.15

## Issues Encountered and Solutions

### Issue 1: pip3 Not Installed

**Problem**: The server had Python 3.12.3 installed but pip3 was missing.

**Error Message**:
```
bash: line 1: pip3: command not found
```

**Solution**:
```bash
apt-get update
apt-get install -y python3-pip python3-dev build-essential
```

**Packages Installed**:
- python3-pip (24.0+dfsg-1ubuntu1.3)
- python3-dev (3.12.3-0ubuntu2)
- build-essential (12.10ubuntu1)
- And 58+ dependencies including gcc, g++, make, etc.

**Time Required**: ~2 minutes

---

### Issue 2: typing-extensions Conflict

**Problem**: Ubuntu 24.04 comes with a pre-installed `typing-extensions` package managed by the Debian package system. When pip tries to upgrade it, it fails because the RECORD file is missing.

**Error Message**:
```
ERROR: Cannot uninstall typing_extensions 4.10.0, RECORD file not found. 
Hint: The package was installed by debian.
```

**Solution**:
Added `--ignore-installed typing-extensions` flag to pip install command:
```bash
pip3 install -e . --break-system-packages --ignore-installed typing-extensions
```

**Why This Works**:
- `--ignore-installed` tells pip to install a new version alongside the system version
- `--break-system-packages` allows pip to install packages system-wide on Debian/Ubuntu systems
- The new version takes precedence in Python's import path

**Alternative Solution** (for production):
Use a virtual environment to avoid system package conflicts:
```bash
python3 -m venv /opt/meta-ads-venv
source /opt/meta-ads-venv/bin/activate
pip install -e .
```

---

### Issue 3: Root User Warnings

**Problem**: Installing packages as root user generates warnings.

**Warning Message**:
```
WARNING: Running pip as the 'root' user can result in broken permissions 
and conflicting behaviour with the system package manager.
```

**Solution**:
This is a warning, not an error. For a dedicated server where the application runs as root, this is acceptable. The warning is filtered in the automated script.

**Best Practice for Production**:
- Create a dedicated service user
- Use virtual environments
- Apply principle of least privilege

---

### Issue 4: Environment Variable Warnings

**Problem**: When running `meta-ads-mcp --version`, warnings appear about missing environment variables.

**Warning Messages**:
```
WARNING: META_APP_ID environment variable is not set.
WARNING: META_APP_SECRET environment variable is not set.
```

**Solution**:
These warnings are informational. The application supports two authentication methods:
1. Pipeboard authentication (recommended) - requires `PIPEBOARD_API_TOKEN`
2. Direct Meta authentication - requires `META_APP_ID` and `META_APP_SECRET`

Create environment file and set appropriate variables:
```bash
# Create environment file
cat > /root/.meta-ads-mcp.env << 'EOF'
PIPEBOARD_API_TOKEN=your_token_here
EOF

# Load environment variables
source /root/.meta-ads-mcp.env
```

---

## Installation Steps (Verified Working)

### Step 1: System Preparation
```bash
apt-get update
apt-get install -y python3 python3-pip python3-dev build-essential git
```

### Step 2: Clone Repository
```bash
cd /root
git clone https://github.com/pipeboard-co/meta-ads-mcp.git
cd meta-ads-mcp
```

### Step 3: Install Package
```bash
pip3 install -e . --break-system-packages --ignore-installed typing-extensions
```

### Step 4: Verify Installation
```bash
which meta-ads-mcp
meta-ads-mcp --version
```

**Expected Output**:
```
/usr/local/bin/meta-ads-mcp
Meta Ads MCP v1.0.15
```

### Step 5: Configure Authentication
```bash
# Create environment file
nano /root/.meta-ads-mcp.env

# Add your token
PIPEBOARD_API_TOKEN=your_token_here

# Load environment
source /root/.meta-ads-mcp.env
```

---

## Dependencies Installed

### Core Python Packages
- mcp==1.12.2
- meta-ads-mcp==1.0.15
- httpx==0.28.1
- pydantic==2.12.3
- requests==2.32.5
- pillow==12.0.0
- python-dotenv==1.1.1

### Supporting Libraries
- uvicorn==0.38.0
- starlette==0.48.0
- typer==0.20.0
- pytest==8.4.2
- rich==14.2.0

### Total Package Count: 43 packages

---

## Server Specifications

### System Information
```
OS: Ubuntu 24.04.3 LTS
Kernel: 6.8.0-85-generic
Architecture: x86_64
```

### Resource Usage
```
System load: 0.0
Memory usage: 10%
Disk usage: 5.8% of 47.39GB
```

### Network Configuration
```
IPv4: 72.60.175.85
IPv6: 2a02:4780:2d:924c::1
```

---

## Performance Metrics

### Installation Time Breakdown
1. System package update: ~30 seconds
2. Python and dependencies installation: ~90 seconds
3. Repository cloning: ~5 seconds
4. Package installation: ~45 seconds
5. **Total Time**: ~3 minutes

### Disk Space Usage
- Repository size: ~172 KB
- Installed packages: ~50 MB
- **Total**: ~50 MB

---

## Security Considerations

### Applied Security Measures
1. **File Permissions**: Environment file should be restricted
   ```bash
   chmod 600 /root/.meta-ads-mcp.env
   ```

2. **API Token Storage**: Tokens stored in environment file, not in code

3. **System Updates**: Applied latest security patches during installation

### Recommended Additional Security
1. Configure firewall rules (ufw/iptables)
2. Enable automatic security updates
3. Use SSH key authentication instead of password
4. Implement fail2ban for SSH protection
5. Regular backup of configuration files

---

## Testing Performed

### Installation Verification
✓ Python version check (3.12.3)  
✓ Git installation check (2.43.0)  
✓ Repository cloning  
✓ Package installation  
✓ Binary availability in PATH  
✓ Version command execution  

### Not Yet Tested
- Actual API connectivity with Pipeboard token
- Meta Ads API integration
- MCP client integration (Claude, Cursor)
- Service daemon mode
- Performance under load

---

## Known Limitations

1. **Root Installation**: Current deployment uses root user. Production should use dedicated service account.

2. **System-Wide Installation**: Uses `--break-system-packages` which may conflict with system package manager in the future.

3. **No Automatic Updates**: Manual update process required for new versions.

4. **No Health Monitoring**: No built-in monitoring or alerting system.

5. **Single Server**: No high availability or load balancing configuration.

---

## Future Improvements

### Priority 1 (Essential)
- [ ] Add health check endpoint
- [ ] Implement logging rotation
- [ ] Add automatic backup script
- [ ] Create update script for version upgrades

### Priority 2 (Recommended)
- [ ] Docker containerization
- [ ] Kubernetes deployment manifests
- [ ] CI/CD pipeline integration
- [ ] Monitoring and alerting setup (Prometheus/Grafana)

### Priority 3 (Nice to Have)
- [ ] Multi-server deployment guide
- [ ] Load balancer configuration
- [ ] Database backup automation
- [ ] Performance optimization guide

---

## Rollback Procedure

If installation fails or causes issues:

```bash
# Stop service if running
systemctl stop meta-ads-mcp

# Uninstall package
pip3 uninstall meta-ads-mcp -y

# Remove installation directory
rm -rf /root/meta-ads-mcp

# Remove configuration
rm /root/.meta-ads-mcp.env

# Remove service file
rm /etc/systemd/system/meta-ads-mcp.service
systemctl daemon-reload
```

---

## Support Contacts

- **Official Repository**: https://github.com/pipeboard-co/meta-ads-mcp
- **Discord**: https://discord.gg/pipeboard
- **Email**: support@pipeboard.co

---

## Deployment Checklist

### Pre-Installation
- [ ] Server meets minimum requirements (Ubuntu 22.04+, Python 3.8+)
- [ ] Root or sudo access available
- [ ] Internet connectivity verified
- [ ] Backup of existing configurations

### Installation
- [ ] System packages updated
- [ ] Python and pip installed
- [ ] Repository cloned
- [ ] Package installed successfully
- [ ] Installation verified with version check

### Configuration
- [ ] Environment file created
- [ ] Authentication credentials added
- [ ] Environment variables loaded
- [ ] File permissions secured (chmod 600)

### Post-Installation
- [ ] Service file created (if using daemon mode)
- [ ] Service enabled and started
- [ ] Service status verified
- [ ] Logs reviewed for errors
- [ ] Documentation updated with server-specific details

### Testing
- [ ] Version command works
- [ ] API connectivity tested
- [ ] MCP client integration tested
- [ ] Performance baseline established

### Production Readiness
- [ ] Firewall configured
- [ ] Monitoring setup
- [ ] Backup procedure established
- [ ] Update procedure documented
- [ ] Rollback procedure tested

---

## Appendix A: Full Package List

```
annotated-types==0.7.0
anyio==4.11.0
attrs==25.4.0
certifi==2025.10.5
charset-normalizer==3.4.4
click==8.3.0
h11==0.16.0
httpcore==1.0.9
httpx==0.28.1
httpx-sse==0.4.3
idna==3.11
iniconfig==2.3.0
jsonschema==4.25.1
jsonschema-specifications==2025.9.1
markdown-it-py==4.0.0
mcp==1.12.2
mdurl==0.1.2
meta-ads-mcp==1.0.15
packaging==25.0
pathlib==1.0.1
pillow==12.0.0
pluggy==1.6.0
pydantic==2.12.3
pydantic-core==2.41.4
pydantic-settings==2.11.0
pygments==2.19.2
pytest==8.4.2
pytest-asyncio==1.2.0
python-dateutil==2.9.0.post0
python-dotenv==1.1.1
python-multipart==0.0.20
referencing==0.37.0
requests==2.32.5
rich==14.2.0
rpds-py==0.27.1
shellingham==1.5.4
six==1.17.0
sniffio==1.3.1
sse-starlette==3.0.2
starlette==0.48.0
typer==0.20.0
typing-extensions==4.15.0
typing-inspection==0.4.2
urllib3==2.5.0
uvicorn==0.38.0
```

---

## Appendix B: System Logs

### Installation Log Snippet
```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  python3-pip
Successfully installed meta-ads-mcp-1.0.15
```

### Service Status (if running)
```
● meta-ads-mcp.service - Meta Ads MCP Server
     Loaded: loaded (/etc/systemd/system/meta-ads-mcp.service; enabled)
     Active: active (running)
```

---

**Document Version**: 1.0  
**Last Updated**: October 21, 2025  
**Maintained By**: Deployment Team

