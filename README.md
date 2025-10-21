# Meta Ads MCP Agent - Deployment Guide

This repository contains automated deployment scripts and documentation for installing the Meta Ads MCP (Model Context Protocol) Agent on Ubuntu servers.

## Overview

The Meta Ads MCP Agent is an AI-powered interface for managing and optimizing Meta advertising campaigns across Facebook, Instagram, and other Meta platforms. This deployment package provides a streamlined installation process that handles all dependencies and configuration automatically.

## System Requirements

- **Operating System**: Ubuntu 24.04 LTS (tested) or Ubuntu 22.04 LTS
- **Python**: 3.8 or higher (automatically installed)
- **RAM**: Minimum 1GB recommended
- **Disk Space**: Minimum 500MB free space
- **Network**: Internet connection required for installation
- **Privileges**: Root access required

## Quick Start

### One-Command Installation

```bash
wget -O - https://raw.githubusercontent.com/mikee-ai/meta-ads-mcp-deployment/master/install-fixed.sh | bash
```

### Manual Installation

1. **Clone this repository**:
   ```bash
   git clone https://github.com/mikee-ai/meta-ads-mcp-deployment.git
   cd meta-ads-mcp-deployment
   ```

2. **Run the installation script**:
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

3. **Configure authentication**:
   ```bash
   nano /root/.meta-ads-mcp.env
   ```
   Add your Pipeboard API token or Meta App credentials.

4. **Load environment variables**:
   ```bash
   source /root/.meta-ads-mcp.env
   ```

5. **Verify installation**:
   ```bash
   meta-ads-mcp --version
   ```

## Authentication Setup

You have two options for authentication:

### Option 1: Pipeboard Authentication (Recommended)

Pipeboard provides a simplified OAuth flow that handles all Meta API authentication complexity.

1. Sign up at [Pipeboard.co](https://pipeboard.co)
2. Generate an API token at [pipeboard.co/api-tokens](https://pipeboard.co/api-tokens)
3. Add to `/root/.meta-ads-mcp.env`:
   ```bash
   PIPEBOARD_API_TOKEN=your_pipeboard_token_here
   ```

### Option 2: Direct Meta App Authentication

If you prefer to use your own Meta Developer App:

1. Create a Meta Developer App at [developers.facebook.com/apps](https://developers.facebook.com/apps/)
2. Configure OAuth settings and permissions
3. Add to `/root/.meta-ads-mcp.env`:
   ```bash
   META_APP_ID=your_meta_app_id
   META_APP_SECRET=your_meta_app_secret
   ```

For detailed instructions, see [CUSTOM_META_APP.md](https://github.com/pipeboard-co/meta-ads-mcp/blob/main/CUSTOM_META_APP.md)

## Installation Details

### What the Script Does

The automated installation script performs the following operations:

1. **System Updates**: Updates package lists and installs security patches
2. **Dependency Installation**: Installs Python 3, pip, development tools, and git
3. **Repository Cloning**: Clones the official Meta Ads MCP repository
4. **Package Installation**: Installs the Python package with all dependencies
5. **Configuration Setup**: Creates environment configuration templates
6. **Service Creation**: Sets up systemd service for optional daemon mode
7. **Verification**: Confirms successful installation

### Known Issues and Solutions

#### Issue 1: typing-extensions Conflict

**Problem**: Debian/Ubuntu systems have a pre-installed `typing-extensions` package that conflicts with pip installation.

**Solution**: The script uses `--ignore-installed typing-extensions` flag to bypass this conflict.

#### Issue 2: System Package Manager Warnings

**Problem**: Installing pip packages system-wide triggers warnings about conflicts with apt.

**Solution**: The script uses `--break-system-packages` flag (safe for dedicated servers) or alternatively creates a virtual environment.

#### Issue 3: Root User Warnings

**Problem**: Running pip as root generates warnings about permissions.

**Solution**: These warnings are informational only and filtered in the script output. For production, consider using a dedicated user account.

## Usage Examples

### Basic Command Line Usage

```bash
# Check version
meta-ads-mcp --version

# Run in interactive mode
meta-ads-mcp

# Run with specific configuration
PIPEBOARD_API_TOKEN=your_token meta-ads-mcp
```

### Running as a System Service

```bash
# Enable service to start on boot
systemctl enable meta-ads-mcp

# Start the service
systemctl start meta-ads-mcp

# Check service status
systemctl status meta-ads-mcp

# View service logs
journalctl -u meta-ads-mcp -f

# Stop the service
systemctl stop meta-ads-mcp

# Disable service
systemctl disable meta-ads-mcp
```

### Integration with MCP Clients

The Meta Ads MCP agent can be integrated with various AI clients:

#### Claude Desktop

Add to `~/Library/Application Support/Claude/claude_desktop_config.json` (macOS) or `%APPDATA%\Claude\claude_desktop_config.json` (Windows):

```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "meta-ads-mcp",
      "env": {
        "PIPEBOARD_API_TOKEN": "your_pipeboard_token"
      }
    }
  }
}
```

#### Cursor IDE

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "meta-ads-mcp",
      "env": {
        "PIPEBOARD_API_TOKEN": "your_pipeboard_token"
      }
    }
  }
}
```

## Advanced Configuration

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `PIPEBOARD_API_TOKEN` | Recommended | Pipeboard authentication token |
| `META_APP_ID` | Alternative | Meta Developer App ID |
| `META_APP_SECRET` | Alternative | Meta Developer App Secret |
| `META_ACCESS_TOKEN` | Optional | Direct Meta API access token |
| `LOG_LEVEL` | Optional | Logging level (DEBUG, INFO, WARNING, ERROR) |

### Custom Installation Directory

To install in a custom directory, modify the `INSTALL_DIR` variable in the script:

```bash
INSTALL_DIR="/opt/meta-ads-mcp"
```

### Virtual Environment Installation

For isolated Python environment (recommended for production):

```bash
# Create virtual environment
python3 -m venv /opt/meta-ads-venv

# Activate virtual environment
source /opt/meta-ads-venv/bin/activate

# Install package
pip install meta-ads-mcp

# Update systemd service to use venv
# Modify ExecStart in /etc/systemd/system/meta-ads-mcp.service:
# ExecStart=/opt/meta-ads-venv/bin/meta-ads-mcp
```

## Troubleshooting

### Installation Fails

1. **Check Python version**:
   ```bash
   python3 --version
   ```
   Should be 3.8 or higher.

2. **Check internet connectivity**:
   ```bash
   ping -c 3 github.com
   ```

3. **Check disk space**:
   ```bash
   df -h
   ```

4. **Review installation logs**:
   ```bash
   ./install.sh 2>&1 | tee install.log
   ```

### Service Won't Start

1. **Check service status**:
   ```bash
   systemctl status meta-ads-mcp
   ```

2. **View detailed logs**:
   ```bash
   journalctl -u meta-ads-mcp -n 50 --no-pager
   ```

3. **Verify environment file**:
   ```bash
   cat /root/.meta-ads-mcp.env
   ```

4. **Test manual execution**:
   ```bash
   source /root/.meta-ads-mcp.env
   meta-ads-mcp --version
   ```

### Authentication Issues

1. **Verify token is set**:
   ```bash
   echo $PIPEBOARD_API_TOKEN
   ```

2. **Test API connectivity**:
   ```bash
   curl -H "Authorization: Bearer $PIPEBOARD_API_TOKEN" https://api.pipeboard.co/health
   ```

3. **Check Meta API permissions**: Ensure your Meta App has the required permissions:
   - `ads_management`
   - `ads_read`
   - `business_management`

## Uninstallation

To completely remove the Meta Ads MCP agent:

```bash
# Stop and disable service
systemctl stop meta-ads-mcp
systemctl disable meta-ads-mcp

# Remove service file
rm /etc/systemd/system/meta-ads-mcp.service
systemctl daemon-reload

# Uninstall package
pip3 uninstall meta-ads-mcp -y

# Remove installation directory
rm -rf /root/meta-ads-mcp

# Remove configuration
rm /root/.meta-ads-mcp.env
```

## Security Considerations

1. **API Token Security**: Never commit API tokens to version control
2. **File Permissions**: Ensure `.meta-ads-mcp.env` has restricted permissions:
   ```bash
   chmod 600 /root/.meta-ads-mcp.env
   ```
3. **Network Security**: Consider using firewall rules to restrict access
4. **Regular Updates**: Keep the package updated for security patches:
   ```bash
   pip3 install --upgrade meta-ads-mcp
   ```

## Support and Resources

- **Official Repository**: [pipeboard-co/meta-ads-mcp](https://github.com/pipeboard-co/meta-ads-mcp)
- **Documentation**: [LOCAL_INSTALLATION.md](https://github.com/pipeboard-co/meta-ads-mcp/blob/main/LOCAL_INSTALLATION.md)
- **Discord Community**: [Join Discord](https://discord.gg/pipeboard)
- **Email Support**: support@pipeboard.co
- **Issue Tracker**: [GitHub Issues](https://github.com/pipeboard-co/meta-ads-mcp/issues)

## Features

The Meta Ads MCP Agent provides the following capabilities:

- **Campaign Analysis**: AI-powered analysis of ad campaign performance
- **Strategic Recommendations**: Data-backed optimization suggestions
- **Automated Monitoring**: Track metrics and detect significant changes
- **Budget Optimization**: Intelligent budget reallocation recommendations
- **Creative Improvement**: Feedback on ad copy and creative elements
- **Dynamic Creative Testing**: A/B testing support with multiple variants
- **Campaign Management**: Create, update, and manage campaigns programmatically
- **Cross-Platform Support**: Works with Facebook, Instagram, and all Meta platforms
- **Universal LLM Support**: Compatible with Claude, GPT, and other MCP clients

## API Tools Available

The agent exposes the following MCP tools:

- `mcp_meta_ads_get_ad_accounts` - List accessible ad accounts
- `mcp_meta_ads_get_account_info` - Get detailed account information
- `mcp_meta_ads_get_account_pages` - List pages associated with account
- `mcp_meta_ads_get_campaigns` - List campaigns with filtering
- `mcp_meta_ads_get_campaign_details` - Get detailed campaign information
- `mcp_meta_ads_create_campaign` - Create new campaigns
- `mcp_meta_ads_update_campaign` - Update existing campaigns
- `mcp_meta_ads_get_ad_sets` - List ad sets
- `mcp_meta_ads_create_ad_set` - Create new ad sets
- `mcp_meta_ads_get_ads` - List ads
- `mcp_meta_ads_create_ad` - Create new ads
- `mcp_meta_ads_get_insights` - Retrieve performance insights
- And many more...

For complete API documentation, see the [official README](https://github.com/pipeboard-co/meta-ads-mcp/blob/main/README.md).

## License

This deployment package is provided as-is for facilitating installation of the Meta Ads MCP agent.

The Meta Ads MCP agent itself is licensed under the Business Source License 1.1. See the [LICENSE](https://github.com/pipeboard-co/meta-ads-mcp/blob/main/LICENSE) file in the official repository.

## Contributing

Contributions to improve the deployment process are welcome! Please submit issues or pull requests to this repository.

## Changelog

### Version 1.0.0 (2025-10-21)
- Initial release
- Automated installation script for Ubuntu 24.04 LTS
- Systemd service configuration
- Comprehensive documentation
- Error handling for common installation issues

## Disclaimer

This is an unofficial third-party deployment tool and is not associated with, endorsed by, or affiliated with Meta or Pipeboard. This project is maintained independently to facilitate installation of the Meta Ads MCP agent.

