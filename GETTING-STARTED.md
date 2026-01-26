# 🚀 Getting Started with brennan.cafe Homelab

Welcome to your homelab setup! This guide will walk you through getting everything running on your ThinkPad W520.

---

## 📋 What You Have

I've created a complete homelab infrastructure for you that includes:

### Configuration Files
- ✅ `.bashrc` - Shell configuration with homelab-specific settings
- ✅ `.bash_aliases` - Tons of helpful shortcuts (including IndieWeb-friendly ones)
- ✅ `micro/settings.json` - Editor configuration (since you prefer micro over vim)
- ✅ `ssh/config` - SSH client configuration for your ed25519 key
- ✅ `.gitignore` - Comprehensive ignore rules (protects secrets)

### Scripts
- ✅ `01-system-hardening.sh` - SSH, firewall, Fail2Ban, auto-updates
- ✅ `02-install-docker.sh` - Docker & Docker Compose installation
- ✅ `dotfiles/install.sh` - Automated dotfiles installation
- ✅ `deploy-site.sh` - Hugo site build and deployment

### Docker Services
- ✅ `docker-compose.yml` - All services configured
- ✅ `Caddyfile` - Reverse proxy with automatic HTTPS
- ✅ `.env.example` - Template for your secrets

### Documentation
- ✅ `README.md` - Comprehensive project documentation
- ✅ `SETUP.md` - Detailed setup instructions
- ✅ This getting started guide

---

## 🎯 Your Priorities (From Your Requirements)

Based on what you told me, here's the priority order:

1. **🔴 Critical**: Static blog/docs at brennan.cafe
2. **🟠 High**: Nextcloud file storage at files.brennan.cafe
3. **🟡 Medium**: Status monitoring for all services
4. **🟡 Medium**: Jellyfin media server at media.brennan.cafe
5. **🟡 Medium**: HedgeDoc collaborative notes at notes.brennan.cafe
6. **🟢 Low**: Analytics and forms

---

## 🏗️ Step-by-Step Setup Process

### Prerequisites Checklist

Before you begin, make sure you have:

- [x] Fresh Lubuntu 24.04.3 LTS installation
- [x] ThinkPad W520 connected to network
- [x] Domain (brennan.cafe) registered on Porkbun
- [x] Cloudflare account (for tunnel)
- [x] Your SSH key ready: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAYU6lvu3nmR49iW0mK/Lrqs4P02ouw2wZq1Sa5LkU2v brennan@omg.lol`

---

### Phase 1: Initial System Setup (30 minutes)

```bash
# 1. Create the homelab directory structure
mkdir -p ~/brennan.cafe
cd ~/brennan.cafe

# 2. Initialize git repository (using GitHub, as you prefer)
git init
git remote add origin https://github.com/brennanbrown/brennan.cafe.git
# (Or create the repo first on GitHub, then clone it)

# 3. Copy all the artifacts I created into the appropriate directories
# (You'll need to create these files from the artifacts I generated)

# 4. Install dotfiles
cd dotfiles
chmod +x install.sh
./install.sh

# 5. Reload your shell
source ~/.bashrc

# You should see the fancy greeting with uptime and disk info!
```

**Expected Result**: 
- ✅ Directory structure created
- ✅ Dotfiles installed
- ✅ New shell prompt active
- ✅ Helpful aliases available

---

### Phase 2: System Hardening (15 minutes)

```bash
cd ~/brennan.cafe/scripts/setup
chmod +x *.sh

# Run the system hardening script
sudo ./01-system-hardening.sh
```

**What this does**:
- Configures SSH for key-only authentication (using your ed25519 key)
- Sets up UFW firewall (ports 22, 80, 443 only)
- Installs and configures Fail2Ban
- Enables automatic security updates
- Applies kernel hardening

**⚠️ CRITICAL**: Before closing your current session, **test SSH access** from another terminal or computer!

```bash
# From another machine/terminal:
ssh -i ~/.ssh/id_ed25519 brennan@thinkpad-ip-address

# If this works, you're good!
```

**Expected Result**:
- ✅ SSH works with your key
- ✅ Password authentication disabled
- ✅ Firewall active and configured
- ✅ Fail2Ban monitoring logins

---

### Phase 3: Docker Installation (15 minutes)

```bash
# Still in ~/brennan.cafe/scripts/setup
sudo ./02-install-docker.sh
```

**What this does**:
- Installs Docker Engine and Docker Compose
- Adds you to the docker group
- Configures Docker daemon for older hardware
- Creates all necessary directories
- Enables IP forwarding (required for Docker)

**⚠️ IMPORTANT**: After this completes, you **must log out and log back in** for the docker group to take effect!

```bash
# After logging back in, test Docker:
docker ps
# Should work without sudo!
```

**Expected Result**:
- ✅ Docker commands work without sudo
- ✅ Docker Compose available
- ✅ Test container runs successfully

---

### Phase 4: Cloudflare Tunnel Setup (20 minutes)

This is where you connect your server to the internet through Cloudflare.

**Option A: Using the script I'll create** (recommended)

```bash
# Install cloudflared
sudo ./03-install-cloudflared.sh

# Follow the prompts to:
# 1. Authenticate with Cloudflare
# 2. Create a tunnel
# 3. Configure DNS records
```

**Option B: Manual setup** (if you prefer more control)

1. Go to https://one.dash.cloudflare.com/
2. Navigate to Networks > Tunnels
3. Create a new tunnel named "brennan-cafe"
4. Install cloudflared on your server
5. Configure DNS records for:
   - brennan.cafe → tunnel
   - *.brennan.cafe → tunnel

**Expected Result**:
- ✅ Cloudflare tunnel running
- ✅ DNS records configured
- ✅ Tunnel persists after reboot

---

### Phase 5: Configure Services (30 minutes)

```bash
cd ~/brennan.cafe/docker

# 1. Copy the environment template
cp .env.example .env

# 2. Generate secure passwords
# Run this for each password you need:
openssl rand -base64 32

# 3. Edit .env file and fill in all passwords
micro .env

# The .env file needs these values:
# - NEXTCLOUD_DB_PASSWORD
# - NEXTCLOUD_ADMIN_PASSWORD
# - HEDGEDOC_DB_PASSWORD
# - HEDGEDOC_SESSION_SECRET (use: openssl rand -hex 64)
# - PLAUSIBLE_DB_PASSWORD
# - PLAUSIBLE_SECRET_KEY (use: openssl rand -base64 64)

# 4. Secure the .env file
chmod 600 .env

# 5. Verify your configuration
docker compose config
```

**Expected Result**:
- ✅ All passwords generated and saved
- ✅ .env file secured (not world-readable)
- ✅ Docker Compose configuration valid

---

### Phase 6: Hugo Site Setup (45 minutes)

Since you're familiar with Eleventy, Hugo will be easy for you!

```bash
cd ~/brennan.cafe

# 1. Install Hugo
sudo snap install hugo

# 2. Create your Hugo site
hugo new site docs

cd docs

# 3. Install a theme (or create your own!)
# For example, using a minimal theme:
git clone https://github.com/YOUR_THEME themes/THEME_NAME

# Or start from scratch with your own theme
# (Since you value accessibility and minimalism)

# 4. Create your first post
hugo new posts/hello-brennan-cafe.md

# 5. Configure config.toml
micro config.toml

# Update baseURL = "https://brennan.cafe"

# 6. Test locally
hugo server -D

# Visit http://localhost:1313 to see your site

# 7. Build for production
hugo --minify
```

**Since you already have brennan.day**, you might want to:
- Migrate some content from your Eleventy site
- Keep the same accessibility principles (no-JS option, semantic HTML)
- Maintain your IndieWeb features (microformats, webmentions)

**Expected Result**:
- ✅ Hugo site created
- ✅ First post published
- ✅ Site builds successfully

---

### Phase 7: Start All Services (15 minutes)

```bash
cd ~/brennan.cafe/docker

# Start everything!
docker compose up -d

# Watch the logs to ensure everything starts
docker compose logs -f

# Check status
docker compose ps

# All services should show "Up"
```

**Expected Result**:
```
NAME                STATUS              PORTS
caddy               Up                  80/tcp, 443/tcp
nextcloud           Up
nextcloud_db        Up
jellyfin            Up
hedgedoc            Up
hedgedoc_db         Up
uptime-kuma         Up
plausible           Up
plausible_db        Up
plausible_events    Up
```

---

### Phase 8: Configure Each Service (1-2 hours)

Now visit each service and complete setup:

#### 1. Main Site (brennan.cafe)
- Should already be live!
- Deploy with: `~/brennan.cafe/scripts/deployment/deploy-site.sh`

#### 2. Nextcloud (files.brennan.cafe)
- Complete web installer
- Create admin account (user: brennan)
- Install recommended apps
- Set up client sync on your devices

#### 3. Jellyfin (media.brennan.cafe)
- Complete setup wizard
- Add media libraries
- Create user account
- Configure transcoding (optional)

#### 4. HedgeDoc (notes.brennan.cafe)
- Create admin account
- Configure authentication
- Create first note

#### 5. Uptime Kuma (status.brennan.cafe)
- Create admin account
- Add monitors for all services:
  - brennan.cafe (HTTP)
  - files.brennan.cafe (HTTP)
  - media.brennan.cafe (HTTP)
  - notes.brennan.cafe (HTTP)

#### 6. Plausible (analytics.brennan.cafe)
- Create admin account
- Add website (brennan.cafe)
- Get tracking script
- Add to your Hugo templates (optional - since you value privacy)

---

## 🎨 Customization for Your Style

Based on brennan.day, I know you value:

### Accessibility
- Progressive enhancement (works without JS)
- Semantic HTML
- No-JS option with clear messaging
- High contrast, readable typography

### IndieWeb
- Webmentions support
- Microformats (h-card, h-entry)
- RSS feeds
- Own your content

### Privacy & Ethics
- No tracking without consent
- Privacy-respecting analytics only
- FOSS everything
- Self-hosted where possible

### Your Hugo Theme Should Include:
```html
<!-- In your layouts/partials/head.html -->
<noscript>
  <style>.js-only { display: none !important; }</style>
</noscript>

<!-- Microformats for IndieWeb -->
<article class="h-entry">
  <h1 class="p-name">{{ .Title }}</h1>
  <time class="dt-published" datetime="{{ .Date }}">{{ .Date.Format "2006-01-02" }}</time>
  <div class="e-content">{{ .Content }}</div>
</article>
```

---

## 📊 Daily Workflow

Once everything is set up, your typical day looks like:

### Morning Check-in
```bash
# SSH into your server (if working remotely)
ssh brennan@thinkpad

# Or just open a terminal if working locally

# Check service status
cafe-logs

# Check disk space
disk

# Check temperature (important for W520!)
temp
```

### Writing a New Blog Post
```bash
# Create new post
cd ~/brennan.cafe/docs
hugo new posts/my-new-post.md

# Edit it
micro content/posts/my-new-post.md

# Preview locally
hugo server -D

# Deploy when ready
~/brennan.cafe/scripts/deployment/deploy-site.sh
```

### Accessing Your Files
- Visit files.brennan.cafe
- Or mount as WebDAV on your local machine
- Sync with Nextcloud desktop/mobile clients

---

## 🔧 Maintenance Schedule

### Daily (automated)
- ✅ Security updates (unattended-upgrades)
- ✅ Docker container updates (Watchtower)
- ✅ SSL certificate renewal (Caddy)
- ✅ Service monitoring (Uptime Kuma)

### Weekly (manual)
```bash
# Check for issues
check-services

# Review logs
cafe-logs | grep -i error

# Check disk space
disk
```

### Monthly (manual)
```bash
# Full system update
update-all

# Backup verification
restic snapshots

# Security audit
sudo journalctl -u fail2ban --since "1 month ago"

# Clean up old Docker images
docker-clean
```

---

## 🚨 Troubleshooting Quick Reference

### "Can't connect to my site"
```bash
# Check Caddy
docker compose logs caddy

# Check Cloudflare tunnel
sudo systemctl status cloudflared

# Check DNS
dig brennan.cafe

# Check firewall
sudo ufw status
```

### "Container won't start"
```bash
# Check logs
docker compose logs [service-name]

# Restart service
docker compose restart [service-name]

# Rebuild if needed
docker compose up -d --force-recreate [service-name]
```

### "Running hot / performance issues"
```bash
# Check temperature
temp

# Check resource usage
docker stats

# Limit a container's resources (edit docker-compose.yml)
```

### "Disk full"
```bash
# Check usage
df -h

# Find large files
du -sh /* | sort -hr | head

# Clean Docker
docker system prune -af --volumes

# Clean apt cache
sudo apt clean
```

---

## 🎯 What Makes This Setup Different

### Aligned with Your Values
- ✅ **No Google**: Nextcloud replaces Drive, self-hosted everything
- ✅ **Privacy First**: Plausible instead of Google Analytics, no tracking
- ✅ **IndieWeb**: Ready for webmentions, microformats, RSS
- ✅ **FOSS Only**: Every single service is open source
- ✅ **Accessibility**: Progressive enhancement, works without JS
- ✅ **Ethical**: No surveillance capitalism, own your data

### Built for Your Experience Level
- ✅ **Well Documented**: Every script has comments explaining what it does
- ✅ **Safe Defaults**: Confirmations on destructive operations
- ✅ **Helpful Aliases**: Quick access to common tasks
- ✅ **GitHub Ready**: Uses GitHub (not GitLab) as you prefer
- ✅ **Micro Editor**: Uses your preferred editor everywhere

### Optimized for Your Hardware
- ✅ **Thermal Aware**: Scripts monitor CPU temperature
- ✅ **Resource Limited**: Docker daemon configured for 12GB RAM
- ✅ **Minimal Services**: No bloat, just what you need
- ✅ **Alpine Images**: Smaller footprint where possible

---

## 🌻 Next Steps

1. **Start with Phase 1** (Directory setup and dotfiles)
2. **Work through each phase** in order
3. **Take your time** - this is a weekend project, not a rush job
4. **Document as you go** - add notes to docs/content/ about your experience
5. **Share your setup** - blog about it on brennan.cafe!

---

## 📚 Additional Resources

### Learning More
- [IndieWeb Getting Started](https://indieweb.org/Getting_Started)
- [Hugo Documentation](https://gohugo.io/documentation/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Caddy Docs](https://caddyserver.com/docs/)
- [r/selfhosted](https://reddit.com/r/selfhosted)

### Communities
- [IndieWeb Chat](https://indieweb.org/discuss)
- [omg.lol Discord](https://discord.omg.lol)
- [Homebrew Homelab Discord](https://discord.gg/homelab)

---

## 💬 Questions?

If you run into issues:

1. Check the troubleshooting section above
2. Review the logs: `docker compose logs [service]`
3. Check GitHub Issues for the specific service
4. Ask in r/selfhosted or IndieWeb chat

---

**Built with care on Treaty 7 territory 🌻**

*This setup respects the principles of accessibility, privacy, and Indigenous sovereignty that are core to your work.*

---

Ready to begin? Start with Phase 1 and work your way through. Take breaks, especially when working on that W520 - it can get hot! 😊

Good luck with brennan.cafe! 🚀