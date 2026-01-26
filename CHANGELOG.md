# 📝 CHANGELOG

All notable changes to brennan.cafe homelab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete homelab infrastructure setup
- System hardening script with SSH, firewall, Fail2Ban
- Docker installation with performance tuning for older hardware
- Cloudflare tunnel integration for secure remote access
- Hugo static site deployment pipeline
- Comprehensive monitoring and maintenance scripts
- Privacy-first service stack (Nextcloud, Jellyfin, HedgeDoc, Uptime Kuma, Plausible)

### Security
- SSH key-only authentication
- UFW firewall with minimal open ports
- Fail2Ban intrusion prevention
- Automatic security updates
- Kernel hardening parameters
- Security headers in Caddy configuration

### Documentation
- Comprehensive README with setup instructions
- Detailed GETTING STARTED guide
- Inline documentation in all scripts
- Architecture and philosophy explanations

---

## [1.0.0] - 2026-01-25

### 🌻 Initial Release

#### Core Infrastructure
- **System Setup**
  - Lubuntu 24.04.3 LTS optimized for ThinkPad W520
  - Automated system hardening with security best practices
  - Docker and Docker Compose installation
  - Cloudflare tunnel for secure external access

- **Services Stack**
  - **Caddy** - Reverse proxy with automatic HTTPS
  - **Nextcloud** - Personal cloud storage (files.brennan.cafe)
  - **Jellyfin** - Media streaming server (media.brennan.cafe)
  - **HedgeDoc** - Collaborative notes (notes.brennan.cafe)
  - **Uptime Kuma** - Service monitoring (status.brennan.cafe)
  - **Plausible** - Privacy-friendly analytics (analytics.brennan.cafe)
  - **Watchtower** - Automatic container updates

#### Configuration Files
- **Docker Compose** - Complete multi-service orchestration
- **Caddyfile** - Reverse proxy with security headers
- **Environment templates** - Secure configuration management
- **Nginx configs** - Optimized for Nextcloud
- **SSH configs** - Secure client configuration

#### Scripts and Automation
- **Setup Scripts**
  - `01-system-hardening.sh` - Security hardening
  - `02-install-docker.sh` - Container platform
  - `03-install-cloudflared.sh` - Tunnel setup
  - `dotfiles/install.sh` - Environment configuration

- **Maintenance Scripts**
  - `update-system.sh` - Comprehensive system maintenance
  - `health-check.sh` - System and service monitoring
  - `deploy-site.sh` - Hugo site deployment

- **Dotfiles**
  - `.bashrc` - Rich shell environment with homelab functions
  - `.bash_aliases` - Comprehensive command shortcuts
  - `.micro/settings.json` - Editor configuration
  - `.ssh/config` - Secure SSH client setup

#### Documentation
- **README.md** - Complete project overview and setup guide
- **GETTING-STARTED.md** - Step-by-step installation instructions
- **CHANGELOG.md** - Version history and changes
- **Inline documentation** - Comments in all configuration files

#### Security Features
- SSH key-based authentication only
- UFW firewall (ports 22, 80, 443 only)
- Fail2Ban with aggressive SSH protection
- Automatic security updates
- Kernel hardening parameters
- Security headers on all web services
- No tracking or analytics without consent

#### Performance Optimizations
- Docker daemon configuration for older hardware
- Resource limits for containers
- Optimized Nginx configuration for Nextcloud
- Gzip/Zstd compression in Caddy
- Efficient logging with rotation

#### Privacy and Ethics
- 100% FOSS software stack
- No Google services or dependencies
- Self-hosted alternatives to corporate cloud
- Privacy-respecting analytics only
- IndieWeb-compatible (microformats, webmentions)
- Progressive enhancement (works without JavaScript)

#### Accessibility
- Semantic HTML throughout
- High contrast, readable typography
- No-JavaScript options with clear messaging
- Keyboard navigation support
- Screen reader friendly

#### Hardware Support
- Optimized for ThinkPad W520 (2011)
- Thermal management considerations
- DDR3 memory constraints addressed
- NVIDIA Quadro 1000M support (optional)
- External storage mounting support

---

## Philosophy and Principles

### 🌻 Core Values
- **Privacy First**: No surveillance, no tracking without consent
- **FOSS Only**: Every component is open source
- **Self-Reliance**: Own your data, control your infrastructure
- **Accessibility**: Works for everyone, including those with disabilities
- **Sustainability**: Runs efficiently on older hardware
- **Ethics**: No exploitation, respects user autonomy

### 🏗️ Architecture Decisions
- **Containerization**: Docker for isolation and portability
- **Reverse Proxy**: Caddy for automatic HTTPS and simplicity
- **Tunnel Access**: Cloudflare for secure external access
- **Static Site**: Hugo for performance and security
- **Database Choice**: PostgreSQL for reliability
- **Monitoring**: Uptime Kuma for self-hosted monitoring

### 🌍 Ethical Considerations
- Built on Treaty 7 territory with respect for Indigenous sovereignty
- No reliance on corporate cloud services
- Minimal resource consumption
- Long-term maintainability
- Community knowledge sharing

---

## Version History

### Future Roadmap
- [ ] Backup automation with Restic
- [ ] Email server (Postfix/Dovecot)
- [ ] Git server (Gitea)
- [ ] Password manager (Vaultwarden)
- [ ] RSS reader (FreshRSS)
- [ ] Matrix chat server
- [ ] Photo management (PhotoPrism)
- [ ] Document management (Paperless-ngx)

### Known Limitations
- Single-server setup (no high availability)
- Limited by ThinkPad W520 hardware
- External storage recommended for media files
- Manual backup configuration required
- No automated scaling

---

## Support and Community

### Getting Help
- Check the troubleshooting section in README.md
- Review logs with provided scripts
- Join r/selfhosted community
- IndieWeb chat for web-specific questions

### Contributing
- This is a personal homelab project
- Questions and suggestions welcome
- Bug reports appreciated
- Share your own homelab setups!

---

*Built with care on Treaty 7 territory 🌻*
