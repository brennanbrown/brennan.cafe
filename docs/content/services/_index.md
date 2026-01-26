---
title: "Services"
date: 2026-01-26T00:00:00-07:00
draft: false
menu:
  main:
    weight: 20
---

# 🛠️ Homelab Services

Welcome to my self-hosted infrastructure! All services run on my ThinkPad W520 homelab, powered by Docker and accessible through Cloudflare tunnels.

## 📊 Live Service Status

<div id="full-status">
  <p>Loading service status...</p>
</div>

<script>
fetch('https://status.brennan.cafe/api/status-page/heartbeat')
  .then(response => response.json())
  .then(data => {
    const statusDiv = document.getElementById('full-status');
    let html = '<div class="status-container">';
    
    if (data.heartbeatList) {
      data.heartbeatList.forEach(service => {
        const status = service.status === '1' ? '🟢 Online' : '🔴 Offline';
        const uptime = service.uptime || 'N/A';
        html += `
          <div class="status-card">
            <h3>${service.name}</h3>
            <p>Status: ${status}</p>
            <p>Uptime: ${uptime}</p>
            <a href="${service.url || '#'}" target="_blank">Visit →</a>
          </div>
        `;
      });
    }
    
    html += '</div>';
    statusDiv.innerHTML = html;
  })
  .catch(err => {
    document.getElementById('full-status').innerHTML = 
      '<p>Unable to load service status</p>';
  });
</script>

<style>
.status-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
  margin: 2rem 0;
}
.status-card {
  padding: 1.5rem;
  background: var(--code-bg);
  border-radius: 8px;
  border: 1px solid var(--border-color);
}
.status-card h3 {
  margin-top: 0;
}
.status-card p {
  margin: 0.5rem 0;
}
</style>

## 📦 Service List

### File Storage
- **Nextcloud** ([files.brennan.cafe](https://files.brennan.cafe))
  - Personal cloud storage and file sync
  - Calendar and contacts sync
  - Collaborative document editing

### Media Streaming
- **Jellyfin** ([media.brennan.cafe](https://media.brennan.cafe))
  - Personal media server
  - Movies, TV shows, music
  - Transcoding on the fly

### Knowledge Management
- **HedgeDoc** ([notes.brennan.cafe](https://notes.brennan.cafe))
  - Collaborative markdown notes
  - Real-time editing
  - Diagram support with Mermaid

### System Monitoring
- **Uptime Kuma** ([status.brennan.cafe](https://status.brennan.cafe))
  - Service uptime monitoring
  - Incident notifications
  - Beautiful status pages

### Analytics
- **Plausible** ([analytics.brennan.cafe](https://analytics.brennan.cafe))
  - Privacy-friendly website analytics
  - Cookie-free tracking
  - Open source and self-hosted

## 🏗️ Infrastructure Stack

- **Hardware**: ThinkPad W520 (16GB RAM, 1TB SSD)
- **OS**: Lubuntu 22.04 LTS
- **Containerization**: Docker & Docker Compose
- **Reverse Proxy**: Caddy
- **Tunneling**: Cloudflare Tunnel
- **Monitoring**: Uptime Kuma
- **Automation**: Custom shell scripts

## 🔧 Configuration Details

All service configurations are open source and available in the [brennan.cafe repository](https://github.com/brennanbrown/brennan.cafe).

### Key Technologies
- **Docker**: Container orchestration
- **Caddy**: Automatic HTTPS and reverse proxy
- **PostgreSQL**: Primary database
- **Redis**: Caching and session storage
- **Cloudflare**: DNS and tunneling

---

*Last updated: January 2026*
