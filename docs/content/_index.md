---
title: "🌻 Welcome to brennan.cafe"
date: 2026-01-26T00:00:00-07:00
draft: false
---

# Welcome to brennan.cafe

A privacy-focused, self-hosted personal infrastructure built on a ThinkPad W520, embracing IndieWeb and permacomputing principles.

## 🌟 What This Is

This is my journey of **de-Googling** my digital life and building ethical, privacy-respecting infrastructure. Here I share:

- Self-hosting experiments and tutorials
- Privacy tools and recommendations
- Homelab documentation and insights
- Thoughts on digital sovereignty
- Sustainable computing practices

## 🚀 Live Services

<div id="service-status">
  <p>Loading service status...</p>
</div>

<script>
// Fetch service status from Uptime Kuma
fetch('https://status.brennan.cafe/api/status-page/heartbeat')
  .then(response => response.json())
  .then(data => {
    const statusDiv = document.getElementById('service-status');
    let html = '<div class="services-grid">';
    
    // Process status data
    if (data.heartbeatList) {
      data.heartbeatList.forEach(service => {
        const status = service.status === '1' ? '🟢' : '🔴';
        html += `<div class="service-item">${status} ${service.name}</div>`;
      });
    }
    
    html += '</div>';
    statusDiv.innerHTML = html;
  })
  .catch(err => {
    document.getElementById('service-status').innerHTML = 
      '<p>Unable to load service status</p>';
  });
</script>

<style>
.services-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 0.5rem;
  margin: 1rem 0;
}
.service-item {
  padding: 0.5rem;
  background: var(--code-bg);
  border-radius: 4px;
  font-family: monospace;
}
</style>

## 📚 Recent Posts

Check out the [latest blog posts](/posts/) for tutorials, guides, and thoughts on privacy and self-hosting.

## 🔗 Connect

- **Website**: [brennan.day](https://brennan.day)
- **Email**: [mail@brennanbrown.ca](mailto:mail@brennanbrown.ca)
- **Mastodon**: [@brennan@social.lol](https://social.lol/@brennan)
- **GitHub**: [brennanbrown](https://github.com/brennanbrown)

---

Built with 🌻 on Treaty 7 territory
