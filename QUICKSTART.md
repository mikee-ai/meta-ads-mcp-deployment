# Quick Start Guide - Meta Ads MCP Agent

## 🚀 5-Minute Installation

### Prerequisites
- Ubuntu 24.04 or 22.04 LTS
- Root access
- Internet connection

### Installation Command

```bash
# Download and run the automated installer
wget https://raw.githubusercontent.com/YOUR_USERNAME/meta-ads-deployment/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

### Configuration

1. **Get your Pipeboard API token**:
   - Visit https://pipeboard.co
   - Sign up or log in
   - Go to https://pipeboard.co/api-tokens
   - Generate a new token

2. **Configure the agent**:
   ```bash
   nano /root/.meta-ads-mcp.env
   ```
   
   Add your token:
   ```bash
   PIPEBOARD_API_TOKEN=your_token_here
   ```

3. **Load the configuration**:
   ```bash
   source /root/.meta-ads-mcp.env
   ```

4. **Test the installation**:
   ```bash
   meta-ads-mcp --version
   ```

## 🎯 Usage Examples

### Run as Command Line Tool
```bash
meta-ads-mcp
```

### Run as System Service
```bash
# Enable and start service
systemctl enable meta-ads-mcp
systemctl start meta-ads-mcp

# Check status
systemctl status meta-ads-mcp

# View logs
journalctl -u meta-ads-mcp -f
```

### Integrate with Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "meta-ads": {
      "command": "ssh",
      "args": ["root@72.60.175.85", "meta-ads-mcp"],
      "env": {
        "PIPEBOARD_API_TOKEN": "your_token"
      }
    }
  }
}
```

## 🔧 Common Commands

```bash
# Check version
meta-ads-mcp --version

# View help
meta-ads-mcp --help

# Check service status
systemctl status meta-ads-mcp

# Restart service
systemctl restart meta-ads-mcp

# View logs
journalctl -u meta-ads-mcp -n 50

# Update installation
cd /root/meta-ads-mcp
git pull
pip3 install -e . --break-system-packages --ignore-installed typing-extensions
systemctl restart meta-ads-mcp
```

## ❓ Troubleshooting

### Installation fails
```bash
# Check Python version (should be 3.8+)
python3 --version

# Check internet connectivity
ping -c 3 github.com

# Review logs
./install.sh 2>&1 | tee install.log
```

### Service won't start
```bash
# Check service status
systemctl status meta-ads-mcp

# View detailed logs
journalctl -u meta-ads-mcp -n 50 --no-pager

# Test manual execution
source /root/.meta-ads-mcp.env
meta-ads-mcp --version
```

### Authentication issues
```bash
# Verify token is set
echo $PIPEBOARD_API_TOKEN

# Check environment file
cat /root/.meta-ads-mcp.env
```

## 📚 Next Steps

1. **Read the full documentation**: See [README.md](README.md)
2. **Review deployment notes**: See [DEPLOYMENT_NOTES.md](DEPLOYMENT_NOTES.md)
3. **Join the community**: https://discord.gg/pipeboard
4. **Explore the API**: https://github.com/pipeboard-co/meta-ads-mcp

## 🆘 Support

- **Issues**: https://github.com/pipeboard-co/meta-ads-mcp/issues
- **Discord**: https://discord.gg/pipeboard
- **Email**: support@pipeboard.co

