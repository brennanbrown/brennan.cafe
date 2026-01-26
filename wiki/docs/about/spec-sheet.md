# brennan.page Homelab Specification v1.1

## Project Overview

**Purpose**: Self-hosted infrastructure on a DigitalOcean droplet showcasing backend/cloud development skills while providing personal productivity tools and community-building features.

**Domain**: `brennan.page`
**Server**: 2 GB Memory / 1 Intel vCPU / 70 GB Disk / TOR1 – Ubuntu 24.04 (LTS) x64
**Budget**: $200/year ($16/month)
**Management**: Local development + SSH deployment

**Key Change (v1.1)**

* Replace BookStack with a **Git-backed static wiki** at `wiki.brennan.page`
* Merge previous `docs` subproject into the same wiki (one unified documentation system)
* Wiki content is authored in the IDE (by you and AI), built locally, and deployed via SSH/rsync as static files.

---

## Core Development Principles

### 1. Local-First Workflow

* **ALWAYS** write and test files locally before deployment.
* Maintain complete local repository mirroring server structure.
* Use `rsync` or `scp` for file transfers; never write large files directly via remote shell.
* Keep local Git repository as the **source of truth**.
* Treat the wiki as a Git project: local Markdown → build → deploy.

### 2. Infrastructure as Code

* All configurations tracked in version control (Git).
* Docker Compose files for all services.
* `Caddyfile` versioned and backed up.
* Environment variables stored in `.env` files (gitignored).

### 3. Planning Before Execution

* Document intended changes in the wiki before applying them (change plans, runbooks).
* Test Docker Compose configurations locally when possible (`docker compose config`).
* Work on **one service at a time**, get it stable, then move on.
* Maintain a deployment log/journal in the wiki (`deployments/` section).

### 4. Resource Management (CRITICAL for 2GB RAM)

* Monitor RAM usage constantly (Glances, `free -h`, `docker stats`).
* Limit Docker container memory where possible.
* Prefer lightweight Alpine-based images.
* Implement swap file (4GB recommended) for burst capacity.
* Schedule resource-heavy tasks (backups, image pulls) during off-peak hours.

---

## Security & Access Control

### SSH Configuration

```bash
# Primary SSH port: 22 (NEVER close this)
# Backup SSH port: 2222 (configure early)
# Use SSH keys only (disable password auth)
# Configure fail2ban for brute force protection
```

### UFW Firewall Rules (Priority Order)

```bash
# CRITICAL: Always ensure SSH access before enabling UFW
sudo ufw allow 22/tcp    # Primary SSH
sudo ufw allow 2222/tcp  # Backup SSH
sudo ufw allow 80/tcp    # HTTP (for Let's Encrypt)
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 443/udp   # HTTP/3 QUIC
sudo ufw enable
```

### Password Management

* Create `/root/passwords/` directory (excluded from git).
* Store all service credentials in a proper password manager format.
* Document password storage practices/locations in the wiki (without actual secrets).
* **Add to .gitignore immediately**:

  * `/root/passwords/`
  * `*.env`
  * `secrets/`

### Additional Security Measures

* Weekly updates: `apt update && apt upgrade`.
* Configure automatic security updates (`unattended-upgrades`).
* Use strong passwords (20+ characters, random) for non-key auth.
* Enable 2FA for admin accounts where supported.
* Regularly **test backups** and recovery procedures.

---

## Core Infrastructure Stack

### 1. Docker Setup

```bash
# Install Docker and Docker Compose plugin
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Create Docker network structure
docker network create caddy
docker network create internal_db
docker network create monitoring
```

### 2. Caddy Reverse Proxy (Priority: FIRST)

**Why Caddy**: Automatic HTTPS, simple configuration, low resource usage (~100MB RAM).

`/opt/homelab/caddy/docker-compose.yml`:

```yaml
version: '3.8'
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
      - "443:443/udp"  # HTTP/3
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    networks:
      - caddy
    mem_limit: 256m  # Prevent runaway memory usage

volumes:
  caddy_data:
  caddy_config:

networks:
  caddy:
    external: true
```

**Caddyfile Structure (example)**:

```caddyfile
# Root domain - landing page
brennan.page {
    root * /var/www/brennan.page
    file_server
    encode gzip
}

# Unified wiki and docs
wiki.brennan.page {
    root * /opt/homelab/wiki
    file_server
    encode gzip
}

# Example app subdomain (reverse proxy)
blog.brennan.page {
    reverse_proxy writefreely:80
    encode gzip
}
```

* `brennan.page` → landing/status page (static, later).
* `wiki.brennan.page` → Git-backed static wiki (ops + technical docs).
* Application services (WriteFreely, Flarum, etc.) are proxied via Caddy.

### 3. Directory Structure

On the server:

```text
/opt/homelab/
├── caddy/
│   ├── Caddyfile
│   └── docker-compose.yml
├── wiki/               # built static site for wiki.brennan.page
│   └── (deployed files from homelab-wiki build)
├── services/
│   ├── writefreely/
│   ├── flarum/
│   ├── vikunja/
│   ├── hedgedoc/
│   ├── freshrss/
│   ├── filebrowser/
│   ├── portainer/
│   └── [other services]/
├── backups/
│   ├── scripts/
│   └── data/
├── monitoring/
│   └── glances/
└── shared/
    ├── passwords/      # .gitignored
    └── ssl-certs/
```

Local Git repo (example mono-repo layout):

```text
homelab/
├── .gitignore
├── README.md
├── caddy/
│   ├── Caddyfile
│   └── docker-compose.yml
├── wiki/
│   ├── mkdocs.yml          # or Hugo config
│   └── docs/               # Markdown content for wiki
├── services/
│   └── [each service folder with docker-compose.yml, .env, etc.]
├── scripts/
│   ├── backup.sh
│   ├── health-check.sh
│   ├── deploy-wiki.sh
│   └── deploy-service.sh   # optional generic deployment helper
└── docs/                   # optional: internal dev docs about the repo itself
```

---

## Service Deployment Order & Configuration

### Phase 1: Foundation (Week 1)

1. **SSH & UFW** – Secure access.
2. **Micro editor** – Set as default: `update-alternatives --set editor /usr/bin/micro`.
3. **Docker & Docker Compose** – Container runtime.
4. **Caddy** – Reverse proxy with auto-SSL.
5. **Portainer** (`docker.brennan.page`) – Docker management UI.

### Phase 2: Monitoring & Documentation (Week 2)

6. **Glances** (`monitor.brennan.page`) – System monitoring.
7. **Git-backed Wiki** (`wiki.brennan.page`) – Unified ops + docs site:

   * Authored locally in Git (`homelab/wiki/`).
   * Built with MkDocs or Hugo.
   * Deployed as static files to `/opt/homelab/wiki` via `rsync`.
8. **FileBrowser** (`files.brennan.page`) – File management.

### Phase 3: Personal Productivity (Week 3–4)

9. **Vikunja** (`tasks.brennan.page`) – Task management.
10. **HedgeDoc** (`notes.brennan.page`) – Collaborative markdown notes.
11. **Linkding** (`bookmarks.brennan.page`) – Bookmark manager.
12. **Navidrome** (`music.brennan.page`) – Music streaming.

### Phase 4: Content & Community (Week 5–6)

13. **WriteFreely** (`blog.brennan.page`) – Minimal blog.
14. **Flarum** (`forum.brennan.page`) – Community forum.
15. **FreshRSS** (`rss.brennan.page`) – RSS reader.

### Phase 5: Utilities (Week 7)

16. **Plik** (`share.brennan.page`) – Temporary file sharing.
17. **Rallly** (`poll.brennan.page`) – Meeting/poll scheduler.

### Phase 6: Optional/Future

18. **Duplicati** (`backup.brennan.page`) – Only if storage and RAM allow.

---

## Resource Allocation Budget

| Service           | RAM Estimate | Priority | Notes                                        |
| ----------------- | -----------: | -------- | -------------------------------------------- |
| System (Ubuntu)   |       300 MB | CRITICAL | Base OS overhead                             |
| Docker daemon     |       150 MB | CRITICAL | Container runtime                            |
| Caddy             |       100 MB | CRITICAL | Reverse proxy                                |
| Portainer         |       100 MB | HIGH     | Docker management                            |
| Glances           |        50 MB | HIGH     | Monitoring                                   |
| Git Wiki (static) |  ~0 MB extra | HIGH     | Static files served by Caddy (no app/server) |
| FileBrowser       |        50 MB | MEDIUM   | File manager                                 |
| WriteFreely       |       100 MB | MEDIUM   | Blog                                         |
| Flarum            |       200 MB | MEDIUM   | Forum                                        |
| Vikunja           |       100 MB | MEDIUM   | Tasks                                        |
| HedgeDoc          |       100 MB | MEDIUM   | Notes                                        |
| FreshRSS          |       100 MB | LOW      | RSS reader                                   |
| Others            |  ~50 MB each | LOW      | Remaining services (Plik, Rallly, etc.)      |
| **Total Est.**    | **~1400 MB** |          | **~600 MB buffer on a 2GB droplet**          |

**Memory Management Strategy**

* 4GB swap file for burst capacity.
* Continuous monitoring via Glances and `docker stats`.
* Disable or stop low-priority containers when not using them.
* Identify memory hogs and tune their limits (`mem_limit` / `mem_reservation`).

---

## Design & UX Standards

### Visual Consistency

* **Theme**: Dark mode with Gruvbox or similar palette where configurable.
* **Typography**: Monospace fonts (JetBrains Mono, Fira Code) where possible.
* Minimal custom CSS; prefer built-in themes and defaults.
* Respect mobile-friendliness and accessibility.

### Landing Page (`brennan.page`)

**Requirements**:

* Single-page design showcasing all services.
* Live server stats (CPU, RAM, uptime) via Glances API.
* Status indicators for each service (up/down).
* Links to all subdomains with brief descriptions.
* Technology stack overview.
* Personal branding / about section.
* Contact information.
* Implementation: static HTML/CSS, optionally generated via the same toolkit as the wiki.

### Wiki (`wiki.brennan.page`)

* Unified home for:

  * Homelab architecture.
  * Service runbooks.
  * Deployment logs.
  * Troubleshooting guides.
  * Public-facing technical writeups (merged “docs” subproject).
* Clearly structured navigation:

  * `Overview`, `Services`, `Deployments`, `Incidents`, `How-To`, `Reference`.

---

## Documentation Standards

* **Single documentation system**: `wiki.brennan.page` (Git-backed static site).
* All documentation authored as Markdown in the `homelab/wiki/` directory.
* Each service gets a set of pages, e.g.:

  ```text
  wiki/docs/services/
  ├── caddy.md
  ├── writefreely.md
  ├── flarum.md
  ├── vikunja.md
  └── [others].md
  ```

  And optionally:

  ```text
  wiki/docs/deployments/
  wiki/docs/incidents/
  wiki/docs/playbooks/
  ```

For each service page, include:

* Purpose and use case.
* Installation steps.
* Configuration details (without secrets).
* Resource usage notes.
* Troubleshooting tips.
* Links to official documentation.

---

## Database Strategy

### Shared Database Approach (Recommended)

Use a small number of shared PostgreSQL/MySQL containers rather than one per service.

Example PostgreSQL container:

```yaml
postgres:
  image: postgres:15-alpine
  container_name: shared_postgres
  restart: unless-stopped
  environment:
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: ${POSTGRES_ROOT_PASSWORD}
  volumes:
    - postgres_data:/var/lib/postgresql/data
  networks:
    - internal_db
  mem_limit: 256m
```

**Services using shared DB** (example set):

* Flarum (MySQL/MariaDB often preferred – possibly separate DB container).
* Vikunja (PostgreSQL or MySQL).
* FreshRSS (PostgreSQL or MySQL).
* Any future apps needing relational storage.

Create separate databases per service:

```sql
CREATE DATABASE flarum;
CREATE DATABASE vikunja;
CREATE DATABASE freshrss;
```

Document DB credentials and connection strings in the wiki (without secrets; refer to `.env` keys instead).

---

## Backup Strategy

### Critical Data to Backup

1. `/opt/homelab/` – All configs and Compose files.
2. Docker volumes – particularly DB volumes.
3. Caddy SSL certificates (stored in `caddy_data` volume).
4. `/opt/homelab/wiki` – built static wiki (can be rebuilt from Git, but useful for quick restore).
5. Git repositories (remote, e.g., GitHub/GitLab, serve as code backup).

### Backup Methods

**Option 1: Local Backups (Primary)**

```bash
#!/usr/bin/env bash
# /opt/homelab/backups/scripts/backup.sh
set -euo pipefail

BACKUP_DIR="/opt/homelab/backups/data"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup docker volumes (example: caddy_data)
docker run --rm \
  -v caddy_caddy_data:/source \
  -v "$BACKUP_DIR":/backup \
  alpine \
  tar czf "/backup/caddy_data_${DATE}.tar.gz" -C /source .

# Backup configs
tar czf "${BACKUP_DIR}/configs_${DATE}.tar.gz" /opt/homelab/services/ /opt/homelab/caddy/

# Rotate old backups (keep last 7 days)
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete
```

**Option 2: DigitalOcean Snapshots**

* Weekly automated snapshots (+20% droplet cost).
* Full server backup, easy whole-droplet restore.

**Option 3: Duplicati (Optional)**

* Encrypted backups to offsite cloud storage.
* Run during low-traffic hours.

### Backup Schedule

* **Daily**: Scripted backups for configs + volumes (e.g., 03:00).
* **Weekly**: DigitalOcean snapshot.
* **Monthly**: Restore test and verification.

Document backup locations and verification procedures in the wiki.

---

## Monitoring & Maintenance

### Daily Checks

* Glances dashboard review (5 minutes).
* Verify service availability from landing page and/or simple health script.
* Review system logs for anomalies:

  ```bash
  journalctl -xe --since today
  ```

### Weekly Maintenance

* `apt update && apt upgrade`.
* Review Docker logs and `docker ps -a`.
* Check disk usage: `df -h`.
* Confirm backup jobs ran successfully.
* Update wiki with any operational notes.

### Monthly Tasks

* Security review (fail2ban logs, UFW logs).
* Review resource usage trends (Glances, `docker stats`).
* Test restore from backup.
* Update Docker images and redeploy.
* Clean up unused Docker images/volumes.

### Key Commands

```bash
# System resource checks
htop
docker stats
df -h
free -h

# Container/service health
docker ps -a
systemctl status docker
systemctl status ufw

# Logs
docker compose -f /opt/homelab/services/[service]/docker-compose.yml logs
journalctl -u docker
tail -f /var/log/auth.log  # SSH attempts
```

---

## Troubleshooting & Recovery

### Common Issues & Solutions

**1. Service Won’t Start**

```bash
# Check service logs
docker compose logs [service]

# Check port conflicts
sudo netstat -tulpn | grep [port]

# Check resource usage
docker stats
```

**2. Out of Memory**

```bash
free -h
docker stats --no-stream

# Restart heavy services
docker compose restart [service]

# Verify swap is active
sudo swapon -s
```

**3. Locked Out of SSH**

* Use DigitalOcean console (Control Panel → Droplet → Console).
* Check UFW: `sudo ufw status`.
* Ensure: `sudo ufw allow 22`.

**4. SSL Certificate Issues**

```bash
# Caddy logs
docker logs caddy

# Verify DNS A/AAAA records point to droplet IP
# Check that ports 80/443 are reachable
docker exec caddy caddy reload
```

### Disaster Recovery

1. Use DigitalOcean console to access server.
2. Restore from latest snapshot if necessary.
3. Or rebuild from local Git plus backup archives:

   * Recreate `/opt/homelab` structure.
   * Restore Docker volumes from tar archives.
4. Rebuild wiki from Git and deploy to `/opt/homelab/wiki`.

---

## Performance Optimization

### Docker Optimization

In each `docker-compose.yml`:

```yaml
services:
  service_name:
    # ...
    mem_limit: 256m
    mem_reservation: 128m
    cpus: 0.5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Database Tuning (PostgreSQL Example)

`postgresql.conf`:

```ini
shared_buffers = 128MB
work_mem = 4MB
maintenance_work_mem = 64MB
effective_cache_size = 512MB
max_connections = 20
```

### Caddy Optimization

```caddyfile
{
    # Global options
    admin off
}

(compression) {
    encode gzip zstd
}

brennan.page {
    import compression
    # ...
}
```

---

## Deployment Workflow

### Initial Server Setup

```bash
# 1. SSH into droplet
ssh root@brennan.page

# 2. Create non-root user
adduser brennan
usermod -aG sudo brennan
usermod -aG docker brennan

# 3. Configure SSH keys (from local machine)
ssh-copy-id brennan@brennan.page

# 4. Disable root SSH login
# Edit /etc/ssh/sshd_config: PermitRootLogin no
sudo systemctl restart sshd

# 5. Set up UFW
sudo ufw allow 22
sudo ufw allow 2222
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable

# 6. Install micro as default editor
sudo apt install micro
sudo update-alternatives --set editor /usr/bin/micro
```

### Generic Service Deployment Pattern

```bash
# LOCAL: create/update service config
mkdir -p ~/homelab/services/[service-name]
cd ~/homelab/services/[service-name]
# Edit docker-compose.yml, .env, etc.

docker compose config   # validate
# Optionally test locally if relevant

git add .
git commit -m "Add/update [service-name]"

# DEPLOY: sync to server
rsync -avz --exclude '.git' ~/homelab/ brennan@brennan.page:/opt/homelab/

# SERVER: deploy service
ssh brennan@brennan.page
cd /opt/homelab/services/[service-name]
docker compose up -d

# Update Caddyfile if needed
cd /opt/homelab/caddy
# edit Caddyfile
docker exec caddy caddy reload
```

### Wiki Deployment Workflow (Git-Backed Static Site)

Assuming MkDocs:

`homelab/wiki/mkdocs.yml` and `homelab/wiki/docs/`.

**Local:**

```bash
cd ~/homelab/wiki

# AI/human edits docs/*.md

# Build wiki
mkdocs build    # outputs to site/

# Deploy via rsync
./deploy-wiki.sh
```

Example `deploy-wiki.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

SITE_DIR="site"
REMOTE="brennan@brennan.page"
REMOTE_DIR="/opt/homelab/wiki"

mkdocs build

rsync -avz --delete "${SITE_DIR}/" "${REMOTE}:${REMOTE_DIR}/"
```

---

## Additional Best Practices

### 1. Swap File Configuration

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Swappiness
sudo sysctl vm.swappiness=10
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

### 2. Docker Log Limits (Global)

```bash
sudo tee /etc/docker/daemon.json >/dev/null <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
EOF

sudo systemctl restart docker
```

### 3. Automated Security Updates

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 4. Fail2ban

```bash
sudo apt install fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
# Configure jail.local for SSH hardening
```

### 5. HTTPS Everywhere

* All subdomains served via HTTPS (Caddy manages certificates).
* HTTP → HTTPS redirect.
* Consider HSTS headers once stable.

### 6. Health Checks

Example script:

```bash
#!/usr/bin/env bash
# /opt/homelab/scripts/health-check.sh
services=(
  "https://wiki.brennan.page"
  "https://blog.brennan.page"
  "https://forum.brennan.page"
)

for service in "${services[@]}"; do
  status=$(curl -o /dev/null -s -w "%{http_code}" "$service")
  if [ "$status" -ne 200 ]; then
    echo "ALERT: $service returned $status"
    # TODO: add notification hook (email/webhook)
  fi
done
```

### 7. Git Practices

* Commit small, atomic changes.
* Include service name and intent in commit messages.
* Use branches for big changes; merge after testing.
* Keep wiki content and homelab configs consistent.

### 8. Community Building Features

For forum/community spaces:

* Clear code of conduct and guidelines.
* Moderation plan and admin accounts.
* Spam protection, CAPTCHA where needed.
* Compliance thinking around user data (GDPR-style basics).

---

## Success Metrics

### Technical Goals

* [ ] All services accessible via HTTPS.
* [ ] System uptime > 99%.
* [ ] Average response time < 2 seconds.
* [ ] RAM usage < 1.8 GB sustained.
* [ ] No known security incidents.
* [ ] Weekly backups tested successfully.

### Professional Development Goals

* [ ] Wiki contains complete documentation for each service.
* [ ] Infrastructure fully described as code + docs.
* [ ] Create a portfolio-ready writeup of the homelab (hosted on `wiki.brennan.page`).
* [ ] Implement minimal alerting (email or webhook).

### Community Goals (Optional)

* [ ] Launch forum with seed content.
* [ ] Achieve 10+ active community members.
* [ ] Publish regular posts about homelab progress and lessons.

---

## Version History

* **v1.1 (2026-01-16)**:

  * Replaced BookStack wiki with Git-backed static wiki (`wiki.brennan.page`).
  * Merged technical docs (previous `docs` subproject) into the same wiki.
  * Updated directory structure, Caddy config, resource budget, and workflows accordingly.

* **v1.0 (2026-01-16)**: Initial specification document (BookStack-based wiki, separate docs site).

---

If you want, next step can be: I can draft a concrete `mkdocs.yml` and starter navigation tree for `homelab/wiki` that matches these sections exactly (services, deployments, incidents, runbooks, etc.).
