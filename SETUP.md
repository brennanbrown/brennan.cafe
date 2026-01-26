# 🚀 brennan.cafe Homelab Setup Guide

This is the comprehensive setup guide for your brennan.cafe homelab on a ThinkPad W520.

---

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Hardware Requirements](#hardware-requirements)
- [Phase 1: System Installation](#phase-1-system-installation)
- [Phase 2: Initial Configuration](#phase-2-initial-configuration)
- [Phase 3: Security Hardening](#phase-3-security-hardening)
- [Phase 4: Docker Setup](#phase-4-docker-setup)
- [Phase 5: Cloudflare Tunnel](#phase-5-cloudflare-tunnel)
- [Phase 6: Service Configuration](#phase-6-service-configuration)
- [Phase 7: Hugo Site Setup](#phase-7-hugo-site-setup)
- [Phase 8: Service Deployment](#phase-8-service-deployment)
- [Phase 9: Final Configuration](#phase-9-final-configuration)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Prerequisites

Before you begin, ensure you have:

### Required Items
- [ ] ThinkPad W520 (or similar hardware)
- [ ] Lubuntu 24.04.3 LTS installation media
- [ ] Domain name (brennan.cafe from Porkbun)
- [ ] Cloudflare account (free tier is sufficient)
- [ ] External storage drive (recommended for media/files)
- [ ] Time: 3-4 hours for complete setup

### Knowledge Requirements
- Basic Linux command line familiarity
- Understanding of SSH keys
- Domain name management basics
- Docker concepts (helpful but not required)

---

## 💻 Hardware Requirements

### Minimum Specifications
- **CPU**: Intel Core i7-2860QM or equivalent
- **RAM**: 8GB DDR3 (12GB recommended)
- **Storage**: 250GB internal + external drive for media
- **Network**: Gigabit Ethernet or WiFi

### Thermal Considerations
- ThinkPad W520 runs hot under load
- Consider cooling pad for extended operation
- Monitor temperature with included scripts
- Performance tuning applied for older hardware

---

## 📦 Phase 1: System Installation

### 1.1 Install Lubuntu 24.04.3 LTS

1. **Download Lubuntu**
   ```bash
   # Download from official Ubuntu website
   # Use balenaEtcher or similar to create bootable USB
   ```

2. **Installation Settings**
   - Language: English (or your preference)
   - Timezone: America/Edmonton (Calgary)
   - Keyboard layout: US English
   - Installation type: "Erase disk and install Lubuntu"
   - User account: `brennan` with strong password

3. **Post-Installation Updates**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo reboot
   ```

### 1.2 Initial System Setup

1. **Connect to Network**
   - Prefer Ethernet for stability during setup
   - Configure WiFi if Ethernet unavailable

2. **Install Essential Tools**
   ```bash
   sudo apt install -y curl wget git micro htop tree net-tools dnsutils
   ```

3. **Verify System**
   ```bash
   # Check system info
   uname -a
   lsb_release -a
   free -h
   df -h
   ```

---

## ⚙️ Phase 2: Initial Configuration

### 2.1 Clone Repository

1. **Create Homelab Directory**
   ```bash
   mkdir -p ~/brennan.cafe
   cd ~/brennan.cafe
   ```

2. **Initialize Git Repository**
   ```bash
   # Option 1: Clone from GitHub (if you've pushed there)
   git clone https://github.com/brennanbrown/brennan.cafe.git .
   
   # Option 2: Initialize new repository
   git init
   git remote add origin https://github.com/brennanbrown/brennan.cafe.git
   ```

### 2.2 Install Dotfiles

1. **Run Dotfiles Installer**
   ```bash
   cd ~/brennan.cafe/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

2. **Reload Shell**
   ```bash
   source ~/.bashrc
   # Or simply log out and back in
   ```

3. **Verify Installation**
   ```bash
   # Test aliases
   homelab
   cddocker
   cafe-status
   
   # Test functions
   temp
   disk
   mem
   ```

---

## 🔒 Phase 3: Security Hardening

### 3.1 Run System Hardening Script

1. **Execute Hardening Script**
   ```bash
   cd ~/brennan.cafe/scripts/setup
   sudo ./01-system-hardening.sh
   ```

2. **What This Script Does**
   - ✅ Updates all system packages
   - ✅ Configures SSH for key-only authentication
   - ✅ Sets up UFW firewall (ports 22, 80, 443)
   - ✅ Installs and configures Fail2Ban
   - ✅ Enables automatic security updates
   - ✅ Applies kernel hardening parameters

3. **Critical: Test SSH Access**
   ```bash
   # From another computer BEFORE closing current session:
   ssh -i ~/.ssh/id_ed25519 brennan@your-thinkpad-ip
   
   # If this works, you're safe to continue
   ```

### 3.2 Verify Security Settings

1. **Check Firewall**
   ```bash
   sudo ufw status verbose
   ```

2. **Check Fail2Ban**
   ```bash
   sudo systemctl status fail2ban
   sudo fail2ban-client status sshd
   ```

3. **Check SSH Configuration**
   ```bash
   sudo sshd -t
   ```

---

## 🐳 Phase 4: Docker Setup

### 4.1 Install Docker

1. **Run Docker Installation Script**
   ```bash
   cd ~/brennan.cafe/scripts/setup
   sudo ./02-install-docker.sh
   ```

2. **What This Script Does**
   - ✅ Installs Docker Engine and Docker Compose
   - ✅ Adds user to docker group
   - ✅ Configures Docker daemon for older hardware
   - ✅ Enables IP forwarding
   - ✅ Creates directory structure
   - ✅ Applies performance tuning

3. **Log Out and Back In**
   ```bash
   # Required for docker group to take effect
   exit
   # Log back in
   ```

### 4.2 Verify Docker Installation

1. **Test Docker Commands**
   ```bash
   docker --version
   docker compose version
   docker ps
   ```

2. **Run Test Container**
   ```bash
   docker run --rm hello-world
   ```

---

## 🌐 Phase 5: Cloudflare Tunnel

### 5.1 Install Cloudflared

1. **Run Cloudflare Installation Script**
   ```bash
   cd ~/brennan.cafe/scripts/setup
   sudo ./03-install-cloudflared.sh
   ```

2. **Follow Interactive Prompts**
   - Authenticate with Cloudflare
   - Create tunnel named "brennan-cafe"
   - Configure DNS records
   - Set up systemd service

### 5.2 Configure DNS Records

Ensure these records exist in Cloudflare DNS:
- `brennan.cafe` → Tunnel
- `*.brennan.cafe` → Tunnel (wildcard)

### 5.3 Verify Tunnel

1. **Check Tunnel Status**
   ```bash
   sudo systemctl status cloudflared
   ```

2. **Test External Access**
   ```bash
   # From external network/internet
   curl -I https://brennan.cafe
   ```

---

## 🔧 Phase 6: Service Configuration

### 6.1 Configure Environment Variables

1. **Create Environment File**
   ```bash
   cd ~/brennan.cafe/docker
   cp .env.example .env
   chmod 600 .env
   ```

2. **Generate Secure Passwords**
   ```bash
   # Generate passwords for each service
   openssl rand -base64 32    # For database passwords
   openssl rand -hex 64       # For session secrets
   openssl rand -base64 64    # For secret keys
   ```

3. **Edit Environment File**
   ```bash
   micro .env
   ```

   Fill in these values:
   ```bash
   NEXTCLOUD_DB_PASSWORD=your_secure_password
   NEXTCLOUD_ADMIN_PASSWORD=your_admin_password
   HEDGEDOC_DB_PASSWORD=your_secure_password
   HEDGEDOC_SESSION_SECRET=your_session_secret
   PLAUSIBLE_DB_PASSWORD=your_secure_password
   PLAUSIBLE_SECRET_KEY=your_secret_key
   ```

### 6.2 Verify Docker Compose Configuration

1. **Test Configuration**
   ```bash
   cd ~/brennan.cafe/docker
   docker compose config
   ```

2. **Check Volume Paths**
   ```bash
   # Ensure external storage paths exist
   sudo mkdir -p /media/brennan/external
   sudo mkdir -p /media/brennan/media
   sudo chown brennan:brennan /media/brennan/external
   sudo chown brennan:brennan /media/brennan/media
   ```

---

## 📝 Phase 7: Hugo Site Setup

### 7.1 Install Hugo

1. **Install Hugo via Snap**
   ```bash
   sudo snap install hugo
   ```

2. **Verify Installation**
   ```bash
   hugo version
   ```

### 7.2 Create Hugo Site

1. **Initialize Site**
   ```bash
   cd ~/brennan.cafe
   hugo new site docs
   cd docs
   ```

2. **Install Theme (Optional)**
   ```bash
   # Option 1: Use a minimal theme
   git clone https://github.com/your-theme themes/theme-name
   
   # Option 2: Create your own theme
   mkdir themes/brennan-cafe
   ```

3. **Configure Hugo**
   ```bash
   micro config.toml
   ```

   Basic configuration:
   ```toml
   baseURL = "https://brennan.cafe"
   languageCode = "en-us"
   title = "brennan.cafe"
   theme = "brennan-cafe"  # or your chosen theme
   
   [params]
     description = "Personal homelab and blog"
     author = "Brennan Kenneth Brown"
   ```

### 7.3 Create First Content

1. **Create First Post**
   ```bash
   hugo new posts/welcome-to-brennan-cafe.md
   ```

2. **Edit Post**
   ```bash
   micro content/posts/welcome-to-brennan-cafe.md
   ```

3. **Test Site Locally**
   ```bash
   hugo server -D --bind 0.0.0.0 --port 1313
   # Visit http://localhost:1313
   ```

---

## 🚀 Phase 8: Service Deployment

### 8.1 Start All Services

1. **Start Docker Services**
   ```bash
   cd ~/brennan.cafe/docker
   docker compose up -d
   ```

2. **Monitor Startup**
   ```bash
   docker compose logs -f
   # Press Ctrl+C to exit logs
   ```

3. **Check Service Status**
   ```bash
   docker compose ps
   ```

### 8.2 Verify Each Service

1. **Main Site (brennan.cafe)**
   ```bash
   # Should show your Hugo site
   curl -I https://brennan.cafe
   ```

2. **Nextcloud (files.brennan.cafe)**
   - Visit in browser
   - Complete web installer
   - Create admin account

3. **Jellyfin (media.brennan.cafe)**
   - Visit in browser
   - Complete setup wizard
   - Add media libraries

4. **HedgeDoc (notes.brennan.cafe)**
   - Visit in browser
   - Create admin account
   - Configure authentication

5. **Uptime Kuma (status.brennan.cafe)**
   - Visit in browser
   - Create admin account
   - Add service monitors

6. **Plausible (analytics.brennan.cafe)**
   - Visit in browser
   - Create admin account
   - Add website

---

## 🎛️ Phase 9: Final Configuration

### 9.1 Deploy Hugo Site

1. **Build and Deploy Site**
   ```bash
   cd ~/brennan.cafe
   ./scripts/deployment/deploy-site.sh
   ```

2. **Verify Site**
   - Visit https://brennan.cafe
   - Check all pages load correctly

### 9.2 Configure Monitoring

1. **Set Up Uptime Kuma Monitors**
   - brennan.cafe (HTTP)
   - files.brennan.cafe (HTTP)
   - media.brennan.cafe (HTTP)
   - notes.brennan.cafe (HTTP)
   - status.brennan.cafe (HTTP)

2. **Test Health Check Script**
   ```bash
   cd ~/brennan.cafe/scripts/monitoring
   ./health-check.sh --verbose
   ```

### 9.3 Set Up Maintenance

1. **Test Maintenance Script**
   ```bash
   cd ~/brennan.cafe/scripts/maintenance
   sudo ./update-system.sh
   ```

2. **Set Up Cron Jobs** (Optional)
   ```bash
   # Edit crontab
   crontab -e
   
   # Add monthly maintenance
   0 2 1 * * /home/brennan/brennan.cafe/scripts/maintenance/update-system.sh
   
   # Add daily health check
   0 */6 * * * /home/brennan/brennan.cafe/scripts/monitoring/health-check.sh --notify
   ```

---

## 🔧 Troubleshooting

### Common Issues

#### "Can't access services"
```bash
# Check Caddy logs
docker compose logs caddy

# Check Cloudflare tunnel
sudo systemctl status cloudflared

# Check DNS resolution
dig brennan.cafe

# Check firewall
sudo ufw status
```

#### "Container won't start"
```bash
# Check logs
docker compose logs [service-name]

# Restart service
docker compose restart [service-name]

# Rebuild if needed
docker compose up -d --force-recreate [service-name]
```

#### "High CPU/temperature"
```bash
# Check temperature
temp

# Check resource usage
docker stats

# Limit container resources (edit docker-compose.yml)
```

#### "Disk space issues"
```bash
# Check usage
disk

# Clean Docker
docker system prune -af --volumes

# Clean apt cache
sudo apt clean
```

### Getting Help

1. **Check Logs First**
   ```bash
   cafe-logs
   ```

2. **Run Health Check**
   ```bash
   cd ~/brennan.cafe/scripts/monitoring
   ./health-check.sh --verbose
   ```

3. **Review Documentation**
   - README.md for overview
   - GETTING-STARTED.md for quick start
   - Inline comments in scripts

4. **Community Support**
   - r/selfhosted on Reddit
   - IndieWeb chat
   - Service-specific documentation

---

## 🎉 Congratulations!

Your brennan.cafe homelab is now fully operational!

### What You Have
- ✅ Secure, hardened server
- ✅ 6 self-hosted services
- ✅ Automatic HTTPS for all sites
- ✅ Privacy-first infrastructure
- ✅ Comprehensive monitoring
- ✅ Automated maintenance

### Next Steps
1. **Explore your services** - visit each subdomain
2. **Customize configurations** - tweak settings to your needs
3. **Set up backups** - configure Restic or manual backups
4. **Add content** - start blogging, add media, create notes
5. **Monitor performance** - use health-check and status pages

### Remember
- **Security**: Keep SSH keys secure, monitor logs
- **Performance**: Monitor temperature on W520
- **Backups**: Regularly backup important data
- **Updates**: Run maintenance scripts monthly

---

*Built with care on Treaty 7 territory 🌻*

Enjoy your self-hosted, privacy-respecting digital infrastructure!
