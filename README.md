# 🌻 brennan.cafe Homelab

**A privacy-focused, self-hosted personal infrastructure built on a ThinkPad W520**

[![Built with Docker](https://img.shields.io/badge/built%20with-docker-blue.svg)](https://www.docker.com/)
[![Powered by Caddy](https://img.shields.io/badge/powered%20by-caddy-green.svg)](https://caddyserver.com/)
[![License: CC BY-NC 4.0](https://img.shields.io/badge/License-CC%20BY--NC%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc/4.0/)

---

## 📍 Quick Reference: Server Paths

**Blog Content**: `/home/brennan/Documents/brennan.cafe/docs/content/`
**Blog Scripts**: `/home/brennan/scripts/blog/`
**Hugo Site (served by Caddy)**: `/home/brennan/Documents/brennan.cafe/docker/caddy/site/`
**Docker Compose**: `/home/brennan/Documents/brennan.cafe/docker/docker-compose.yml`

## 🎨 Local Development with Tailwind CSS

The site uses **Tailwind CSS** for styling. To develop locally:

```bash
# Navigate to docs directory
cd docs/

# Install dependencies (first time only)
npm install

# Build the site with Tailwind CSS
../scripts/blog/build.sh

# Or build and serve locally
../scripts/blog/build.sh serve

# Watch for changes and auto-rebuild
../scripts/blog/watch.sh
```

### Tailwind CSS Commands

```bash
# Build CSS for production
npm run build-css

# Watch CSS changes during development
npm run watch-css
```

### Project Structure

```
docs/
├── assets/css/
│   ├── input.css      # Tailwind input file
│   └── style.css      # Generated CSS (do not edit)
├── layouts/           # Hugo templates
├── content/           # Markdown content
├── static/            # Static assets
├── tailwind.config.js # Tailwind configuration
├── package.json       # Node.js dependencies
└── hugo.yaml         # Hugo configuration
```

---

## 💻 SSH Commands

### Required SSH Command Format

```bash
# Always use this format for SSH commands:
ssh -i ~/.ssh/id_ed25519 -T -o BatchMode=yes brennan@brennan-ssh "your-command-here"
```

**Critical Flags:**
- `-i ~/.ssh/id_ed25519` - Specifies your SSH key
- `-T` - Disables pseudo-terminal (prevents hanging)
- `-o BatchMode=yes` - Non-interactive mode (no password prompts)

### Common Examples for AI Assistants

```bash
# Check system status
ssh -i ~/.ssh/id_ed25519 -T -o BatchMode=yes brennan@brennan-ssh "
  cd /home/brennan/Documents/brennan.cafe/docs
  hugo --gc
  ls -la public/
"

# Deploy blog
ssh -i ~/.ssh/id_ed25519 -T -o BatchMode=yes brennan@brennan-ssh "
  cd /home/brennan/scripts/blog
  ./deploy.sh quick
"

# Check Docker services
ssh -i ~/.ssh/id_ed25519 -T -o BatchMode=yes brennan@brennan-ssh "
  cd /home/brennan/Documents/brennan.cafe/docker
  docker compose ps
"

# Create a new blog post
ssh -i ~/.ssh/id_ed25519 -T -o BatchMode=yes brennan@brennan-ssh "
  cd /home/brennan/scripts/blog
  ./new-post.sh 'New Post Title' 'homelab,tutorial'
"
```

### File Operations

```bash
# Upload files (from local to server)
rsync -avz -e "ssh -i ~/.ssh/id_ed25519" ./local-file brennan@brennan-ssh:/remote/path/

# Download files (from server to local)
scp -i ~/.ssh/id_ed25519 brennan@brennan-ssh:/remote/file ./local-file/

# Edit files: Download → Edit → Upload
scp -i ~/.ssh/id_ed25519 brennan@brennan-ssh:/path/to/file ./
# [Edit the file locally]
scp -i ~/.ssh/id_ed25519 ./file brennan@brennan-ssh:/path/to/file/
```

### ❌ NEVER Do These (Will Hang)

```bash
# DON'T - Interactive editors will hang
ssh ... "nano file.txt"
ssh ... "vim file.txt"
ssh ... "micro file.txt"

# DON'T - Commands that wait for input
ssh ... "apt install package"  # Use -y flag
ssh ... "read -p 'Input: ' var"
```

### ✅ Best Practices

1. **Always use `-T -o BatchMode=yes`**
2. **Use `-y` flag for apt commands** (`apt install -y package`)
3. **Use full paths** when possible
4. **Quote complex commands** with `"` or `'`
5. **Test commands manually first** before having AI run them

---

## � Remote Access

### SSH via Cloudflare Tunnel

Access your server securely from anywhere without opening ports:

```bash
# Install cloudflared on your client machine
# Then add to ~/.ssh/config:
Host brennan-ssh
    Hostname ssh.brennan.cafe
    User brennan
    ProxyCommand cloudflared access ssh --hostname %h
    IdentityFile ~/.ssh/id_ed25519

# Connect with:
ssh brennan-ssh
```

**Benefits**: No public IP required, DDoS protection, works from any network, end-to-end encrypted.

---

## 📖 Table of Contents

- [Remote Access](#-remote-access)
- [SSH Commands](#-ssh-commands)
- [About](#-about)
- [System Specifications](#-system-specifications)
- [Services](#-services)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Directory Structure](#-directory-structure)
- [Maintenance](#-maintenance)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)

---

## 🌟 About

This repository contains the complete configuration for my personal homelab server running on a 2011 ThinkPad W520. It's a practical exploration of **de-Googling**, **self-hosting**, and building a more **ethical, privacy-respecting** digital infrastructure.

### Goals

- **Privacy First**: Self-host alternatives to corporate cloud services
- **Cost Reduction**: Use owned hardware instead of cloud subscriptions
- **Learning**: Hands-on experience with backend/server administration
- **Modularity**: Easy to adapt, extend, or swap components
- **Minimalism**: Simple, well-documented, no bloat
- **Ethics**: FOSS only, no surveillance, no tracking

### Philosophy

This project embodies the principles of the [IndieWeb](https://indieweb.org/), [Permacomputing](https://permacomputing.net/), and digital self-reliance. It's built with care on Treaty 7 territory (Mohkínstsis/Calgary) and respects the values of accessibility, progressive enhancement, and sustainable computing.

---

## 💻 System Specifications

**Hardware**: Lenovo ThinkPad W520 (2011)

- **CPU**: Intel Core i7-2860QM (4 cores, 8 threads, 2.50-3.60 GHz)
- **RAM**: 12 GB DDR3-1333
- **GPU**: NVIDIA Quadro 1000M (2 GB)
- **Storage**: 250 GB (expandable)
- **Network**: Gigabit Ethernet, WiFi

**Software**: 

- **OS**: Lubuntu 24.04.3 LTS (LXQt desktop)
- **Containerization**: Docker + Docker Compose
- **Reverse Proxy**: Caddy 2
- **Tunnel**: Cloudflare Tunnel (cloudflared)

**Constraints**:

- ⚠️ **Thermal Management**: This is 12+ year old hardware that runs hot
- 📦 **Limited Storage**: Plan for external storage expansion
- 🔋 **Older Architecture**: DDR3 memory, Sandy Bridge CPU

---

## 🚀 Services

| Service | URL | Purpose | Priority |
|---------|-----|---------|----------|
| **Main Site** | [brennan.cafe](https://brennan.cafe) | Hugo static blog & docs | 🔴 Critical |
| **File Storage** | [files.brennan.cafe](https://files.brennan.cafe) | Nextcloud (personal cloud) | 🟠 High |
| **Media Server** | [media.brennan.cafe](https://media.brennan.cafe) | Jellyfin (streaming) | 🟡 Medium |
| **Collaborative Notes** | [notes.brennan.cafe](https://notes.brennan.cafe) | HedgeDoc (markdown) | 🟡 Medium |
| **Status Monitoring** | [status.brennan.cafe](https://status.brennan.cafe) | Uptime Kuma | 🟡 Medium |
| **Analytics** | [analytics.brennan.cafe](https://analytics.brennan.cafe) | Plausible (privacy-first) | 🟢 Low |

### Service Details

#### 🌻 Main Site (brennan.cafe)
- Static site generated with Hugo
- Contains blog posts and homelab documentation
- Uses Simple CSS framework for clean, minimal design
- Progressive enhancement (works without JavaScript)
- Optimized for accessibility and performance
- Dark mode support with system preference detection

### Blog Management Workflow

The blog is managed via SSH scripts located in `/home/brennan/scripts/blog/` on the server:

```bash
# SSH to server
ssh brennan@brennan-ssh

# Create a new post
cd /home/brennan/scripts/blog
./new-post.sh "Post Title" "tag1,tag2"

# Edit a post
./edit-post.sh "post-title" local  # Downloads, edits locally
./edit-post.sh "post-title" remote # Edit directly on server

# List all posts
./list-posts.sh

# Deploy changes
./deploy.sh quick    # Content only
./deploy.sh full     # Entire site
```

**Local Development** (optional):
```bash
# Clone repo locally
git clone https://github.com/brennanbrown/brennan.cafe.git
cd brennan.cafe/docs

# Run Hugo dev server
hugo server -D

# Deploy from local
../scripts/blog/deploy.sh
```

#### 📁 File Storage (Nextcloud)
- Replace Google Drive/Dropbox
- File sync across devices
- Calendar and contacts
- Document collaboration

#### 🎬 Media Server (Jellyfin)
- Self-hosted alternative to Netflix/Plex
- Stream your own media library
- No tracking, no subscriptions
- Hardware transcoding support (NVIDIA Quadro)

#### 📝 Collaborative Notes (HedgeDoc)
- Markdown-based collaborative editing
- Real-time collaboration
- Replace Google Docs for notes
- Privacy-respecting

#### 📊 Status Monitoring (Uptime Kuma)
- Monitor all services
- Get alerts when things go down
- Beautiful status page
- Self-hosted alternative to UptimeRobot

#### 📈 Analytics (Plausible)
- Privacy-friendly website analytics
- No cookies, no tracking
- GDPR compliant
- Self-hosted alternative to Google Analytics

---

## ⚡ Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/brennanbrown/brennan.cafe.git ~/brennan.cafe
cd ~/brennan.cafe

# 2. Install dotfiles
cd dotfiles
./install.sh

# 3. Run setup scripts (in order)
cd ../scripts/setup
sudo ./01-system-hardening.sh
sudo ./02-install-docker.sh
sudo ./03-install-cloudflared.sh

# 4. Configure environment variables
cd ../../docker
cp .env.example .env
micro .env  # Fill in your passwords

# 5. Start services
docker compose up -d

# 6. Check status
docker compose ps
```

---

## 📚 Detailed Setup

### Prerequisites

- Fresh install of Lubuntu 24.04.3 LTS
- Internet connection
- Domain name (brennan.cafe from Porkbun)
- Cloudflare account (for tunnel)

### Step 1: System Hardening

```bash
cd ~/brennan.cafe/scripts/setup
sudo ./01-system-hardening.sh
```

This script will:
- ✅ Update system packages
- ✅ Configure SSH (key-only authentication)
- ✅ Set up UFW firewall
- ✅ Install and configure Fail2Ban
- ✅ Enable automatic security updates
- ✅ Apply kernel hardening

**Important**: Test SSH access before logging out!

### Step 2: Docker Installation

```bash
sudo ./02-install-docker.sh
```

This script will:
- ✅ Install Docker Engine
- ✅ Install Docker Compose
- ✅ Configure Docker daemon
- ✅ Add user to docker group
- ✅ Set up directory structure

**Important**: Log out and back in for docker group to take effect!

### Step 3: Cloudflare Tunnel

```bash
sudo ./03-install-cloudflared.sh
```

This script will:
- ✅ Install cloudflared
- ✅ Authenticate with Cloudflare
- ✅ Create tunnel configuration
- ✅ Set up systemd service

Follow the prompts to authenticate and configure your tunnel.

### Step 4: Configure Services

```bash
cd ~/brennan.cafe/docker

# Copy example environment file
cp .env.example .env

# Generate secure passwords
openssl rand -base64 32  # Run this for each password

# Edit .env file
micro .env
```

Fill in all the `change_me_*` values with secure passwords.

### Step 5: Deploy Services

```bash
# Start all services
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Access specific service logs
docker compose logs -f nextcloud
```

### Step 6: Initial Configuration

Visit each service and complete the setup:

1. **Nextcloud** (files.brennan.cafe)
   - Complete the web installer
   - Set up external storage (if using external drive)
   - Install recommended apps

2. **Jellyfin** (media.brennan.cafe)
   - Complete initial setup wizard
   - Add media libraries
   - Configure hardware acceleration (optional)

3. **HedgeDoc** (notes.brennan.cafe)
   - Create admin account
   - Configure authentication

4. **Uptime Kuma** (status.brennan.cafe)
   - Create admin account
   - Add monitors for each service

5. **Plausible** (analytics.brennan.cafe)
   - Create admin account
   - Add website
   - Install tracking script on main site

---

## 📂 Directory Structure

```
brennan.cafe/                          # Local repository
├── README.md                          # This file
├── SETUP.md                           # Detailed setup guide
├── CHANGELOG.md                       # Version history
├── LICENSE                            # CC BY-NC 4.0
├── .gitignore                         # Git ignore rules
│
├── docs/                              # Hugo static site (local)
│   ├── hugo.yaml                      # Hugo configuration
│   ├── content/                       # Site content
│   │   ├── _index.md                  # Homepage
│   │   ├── posts/                     # Blog posts
│   │   ├── tutorials.md               # Tutorials index
│   │   └── services.md                # Services overview
│   ├── layouts/                       # Hugo templates
│   │   └── _default/
│   │       ├── baseof.html            # Base template
│   │       ├── list.html              # List pages
│   │       └── single.html            # Single posts
│   ├── assets/                        # Static assets
│   │   └── css/
│   │       └── style.css              # Custom styles
│   ├── archetypes/                    # Content templates
│   │   ├── default.md                 # Default template
│   │   └── blog.md                    # Blog post template
│   └── public/                        # Built site (generated)
│
├── scripts/                           # Automation scripts
│   ├── blog/                          # Blog management scripts
│   │   ├── new-post.sh                # Create new posts
│   │   ├── edit-post.sh               # Edit posts
│   │   ├── list-posts.sh              # List all posts
│   │   ├── deploy.sh                  # Deploy blog
│   │   └── README.md                  # Blog scripts documentation
│   ├── setup/                         # Initial setup
│   ├── maintenance/                   # Regular maintenance
│   ├── monitoring/                    # Monitoring scripts
│   └── deployment/                    # Deployment helpers
│
├── docker/                            # Docker services
│   ├── docker-compose.yml             # Main compose file
│   ├── .env                           # Environment variables (git-ignored)
│   ├── caddy/
│   │   └── Caddyfile
│   └── [service-dirs]/                # Individual service configs
│
└── dotfiles/                          # System configuration
    ├── .bashrc
    ├── .bash_aliases
    ├── .ssh/
    └── install.sh

# Server Structure (Remote)
/home/brennan/Documents/brennan.cafe/   # Server repository copy
├── docs/                              # Hugo site source
│   ├── content/                       # Blog content
│   ├── layouts/                       # Templates
│   └── public/                        # Generated Hugo site
├── scripts/blog/                      # Blog management scripts
└── docker/caddy/site/                 # Caddy serves from here
    ├── index.html                     # Homepage
    ├── posts/                         # Blog posts
    ├── css/                           # Stylesheets
    └── ...                            # Other static files
```

---

## 🛠️ Maintenance

### Daily Tasks

```bash
# Check service status
docker compose ps

# View resource usage
docker stats

# Check disk space
df -h
```

### Weekly Tasks

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Clean Docker
docker system prune -f

# Check logs for errors
docker compose logs --tail=100

# Check blog for new comments or issues (if applicable)
cd /home/brennan/scripts/blog
./list-posts.sh
```

### Monthly Tasks

```bash
# Full system update
~/brennan.cafe/scripts/maintenance/update-system.sh

# Backup verification
restic snapshots

# Review security logs
sudo journalctl -u fail2ban --since "1 month ago"

# Blog maintenance
cd /home/brennan/Documents/brennan.cafe/docs
hugo --gc  # Clean up unused files
./scripts/blog/deploy.sh full  # Full deployment
```

### Blog-Specific Tasks

```bash
# Creating new content
cd /home/brennan/scripts/blog
./new-post.sh "Your Post Title" "tag1,tag2,tag3"

# Managing drafts
./list-posts.sh | grep "draft"

# Publishing drafts
# Edit the post, change draft: false, then deploy
./deploy.sh quick

# Checking site build locally
cd /home/brennan/Documents/brennan.cafe/docs
hugo server --bind=0.0.0.0 --port=1313
# Visit http://server-ip:1313 to preview
```

### Automated Tasks

The following are handled automatically:

- ✅ Security updates (unattended-upgrades)
- ✅ Docker container updates (Watchtower)
- ✅ Certificate renewal (Caddy)
- ✅ Fail2Ban monitoring

---

## 📚 Additional Resources

### Wiki Documentation
This repository includes a comprehensive wiki in the `wiki/` directory, which contains troubleshooting guides and detailed documentation from the brennan.page project (DigitalOcean homelab). This includes:
- Service-specific troubleshooting
- Deployment procedures  
- Operational maintenance tasks
- Common issues and solutions

See the [wiki index](wiki/docs/index.md) for detailed reference material.

### Learning More

```bash
# Check service logs
docker compose logs [service-name]

# Check container status
docker compose ps

# Restart service
docker compose restart [service-name]

# Rebuild service
docker compose up -d --force-recreate [service-name]
```

---

## 🐛 Troubleshooting

### Service Won't Start

```bash
# Check service logs
docker compose logs [service-name]

# Check container status
docker compose ps

# Restart service
docker compose restart [service-name]

# Rebuild service
docker compose up -d --force-recreate [service-name]
```

### Blog Issues

#### Hugo Build Fails
```bash
# Check Hugo syntax
cd /home/brennan/Documents/brennan.cafe/docs
hugo --verbose  # Shows detailed error messages

# Common issues:
# - Missing closing braces in templates
# - Incorrect YAML frontmatter
# - Missing required fields
```

#### Site Not Updating
```bash
# Check if files are in the right place
ls -la /home/brennan/Documents/brennan.cafe/docker/caddy/site/

# Rebuild and redeploy
cd /home/brennan/Documents/brennan.cafe/docs
hugo --gc
rsync -av --delete public/ /home/brennan/Documents/brennan.cafe/docker/caddy/site/

# Reload Caddy
docker compose restart caddy
```

#### Cloudflare Cache Issues
```bash
# Add cache-busting parameter to URLs
# Or wait for cache to expire (typically 1-4 hours)
# Hard refresh browser: Ctrl+Shift+R (Cmd+Shift+R on Mac)
```

### Can't Access Service

```bash
# Check Caddy logs
docker compose logs caddy

# Test DNS resolution
dig brennan.cafe

# Check firewall
sudo ufw status

# Check Cloudflare Tunnel
sudo systemctl status cloudflared
```

### High CPU/Memory Usage

```bash
# Check resource usage
docker stats

# Check system temperature
sensors

# View top processes
htop

# Limit container resources (edit docker-compose.yml)
```

### Disk Space Issues

```bash
# Check disk usage
df -h

# Find large files
du -sh /* | sort -hr | head -n 10

# Clean Docker
docker system prune -af --volumes

# Clean apt cache
sudo apt clean
```

---

## 🤝 Contributing

This is a personal homelab project, but I'm happy to share knowledge!

- **Questions?** Open an issue
- **Suggestions?** Open an issue or submit a PR
- **Found a bug?** Please let me know!

---

## 📜 License

This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International License** (CC BY-NC 4.0).

You are free to:
- **Share** — copy and redistribute the material
- **Adapt** — remix, transform, and build upon the material

Under the following terms:
- **Attribution** — You must give appropriate credit
- **NonCommercial** — You may not use the material for commercial purposes

See [LICENSE](LICENSE) for full details.

---

## 🙏 Acknowledgments

### Built With

- [Docker](https://www.docker.com/) - Containerization
- [Caddy](https://caddyserver.com/) - Reverse proxy & automatic HTTPS
- [Cloudflare](https://www.cloudflare.com/) - Tunnel and DNS
- [Hugo](https://gohugo.io/) - Static site generator
- [Nextcloud](https://nextcloud.com/) - File storage
- [Jellyfin](https://jellyfin.org/) - Media server
- [HedgeDoc](https://hedgedoc.org/) - Collaborative notes
- [Uptime Kuma](https://github.com/louislam/uptime-kuma) - Monitoring
- [Plausible](https://plausible.io/) - Analytics

### Inspiration

- The [IndieWeb](https://indieweb.org/) community
- [Permacomputing](https://permacomputing.net/) principles
- [/r/selfhosted](https://reddit.com/r/selfhosted)
- Everyone sharing their homelab setups!

---

## 📬 Contact

- **Website**: [brennan.day](https://brennan.day)
- **Email**: [mail@brennanbrown.ca](mailto:mail@brennanbrown.ca)
- **Mastodon**: [@brennan@social.lol](https://social.lol/@brennan)
- **GitHub**: [@brennanbrown](https://github.com/brennanbrown)

---

Built with 🌻 on Treaty 7 territory | 2026