# Networking

Networking configuration for the brennan.page homelab ensures secure and efficient communication between services.

## Overview

The homelab uses a layered networking approach with Docker networks, Caddy reverse proxy, and proper security controls.

## Network Architecture

### External Network
- **Public IP**: 159.203.44.169
- **Domain**: brennan.page with subdomains
- **SSL**: Automatic HTTPS via Let's Encrypt
- **Firewall**: UFW with essential ports only

### Internal Networks
Three Docker networks provide isolation and security:

#### caddy Network
```yaml
networks:
  caddy:
    external: true
    driver: bridge
```
- **Purpose**: External web access
- **Services**: Caddy, all web-facing services
- **Access**: Internet accessible via Caddy
- **Security**: Controlled by Caddy configuration

#### internal_db Network
```yaml
networks:
  internal_db:
    external: true
    driver: bridge
    internal: true
```
- **Purpose**: Database communication
- **Services**: PostgreSQL, connected services
- **Access**: Internal only, no internet access
- **Security**: Isolated from external networks

#### monitoring Network
```yaml
networks:
  monitoring:
    external: true
    driver: bridge
```
- **Purpose**: Service monitoring
- **Services**: Monitoring tools
- **Access**: Limited monitoring access
- **Security**: Restricted access to monitoring data

## Subdomain Configuration

### Current Subdomains
| Subdomain | Service | Port | Status |
|-----------|---------|------|--------|
| brennan.page | Landing page | 80 | ✅ Active |
| docker.brennan.page | Portainer | 80 | ✅ Active |
| monitor.brennan.page | Monitor | 80 | ✅ Active |
| files.brennan.page | FileBrowser | 80 | ✅ Active |
| wiki.brennan.page | Wiki | 80 | ✅ Active |
| tasks.brennan.page | Vikunja | 3456 | ✅ Active |
| notes.brennan.page | HedgeDoc | 3000 | ✅ Active |
| bookmarks.brennan.page | Linkding | 9090 | ✅ Active |
| music.brennan.page | Navidrome | 4533 | ✅ Active |

### Future Subdomains
| Subdomain | Service | Port | Status |
|-----------|---------|------|--------|
| blog.brennan.page | WriteFreely | 80 | 📋 Planned |
| forum.brennan.page | Flarum | 8080 | 📋 Planned |
| rss.brennan.page | FreshRSS | 80 | 📋 Planned |
| share.brennan.page | Plik | 8080 | 📋 Planned |
| poll.brennan.page | Rallly | 3000 | 📋 Planned |

## Caddy Configuration

### Reverse Proxy Setup
Caddy acts as the reverse proxy, handling SSL termination and routing:

```caddy
# Task management
tasks.brennan.page {
    import compression
    import security
    
    reverse_proxy vikunja:3456
    handle_errors {
        respond "Task management service unavailable" 503
    }
}
```

### Security Headers
All services get consistent security headers:

```caddy
(security) {
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
}
```

### Compression
```caddy
(compression) {
    encode zstd gzip
}
```

## Docker Networking

### Network Creation
```bash
# Create networks
docker network create caddy
docker network create internal_db --internal
docker network create monitoring
```

### Container Network Assignment
Each service connects to appropriate networks:

```yaml
services:
  service_name:
    networks:
      - caddy          # For web access
      - internal_db    # For database access
```

### Network Isolation
- **caddy**: External access, internet connected
- **internal_db**: Internal only, no internet access
- **monitoring**: Limited monitoring access

## Port Mappings

### Internal Ports
Services use internal ports for container-to-container communication:

| Service | Internal Port | External Port |
|---------|---------------|---------------|
| Caddy | 80, 443 | 80, 443 |
| PostgreSQL | 5432 | None |
| Vikunja | 3456 | None |
| HedgeDoc | 3000 | None |
| Linkding | 9090 | None |
| Navidrome | 4533 | None |
| Portainer | 9000 | None |
| FileBrowser | 80 | None |
| Monitor | 80 | None |

### External Ports
Only essential ports are exposed to the internet:

| Port | Service | Purpose |
|------|---------|---------|
| 22 | SSH | Server management |
| 80 | HTTP | Web traffic (redirect to HTTPS) |
| 443 | HTTPS | Secure web traffic |

## Security

### Firewall Configuration
UFW firewall restricts access to essential ports only:

```bash
# Allow SSH
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable
```

### Network Security
- **Isolation**: Services isolated by network
- **Access Control**: Limited access to sensitive services
- **Monitoring**: Network traffic monitoring
- **Encryption**: All external traffic encrypted

### SSL/TLS
- **Automatic**: Let's Encrypt certificates via Caddy
- **Renewal**: Automatic certificate renewal
- **Security**: Strong SSL configurations
- **Redirect**: HTTP to HTTPS redirect

## DNS Configuration

### Domain Records
```
brennan.page        A     159.203.44.169
*.brennan.page      A     159.203.44.169
```

### Subdomain Delegation
All subdomains point to the same IP address, with Caddy handling routing.

## Troubleshooting

### Common Issues

#### Service Not Accessible
```bash
# Check service status
docker ps | grep service_name

# Check logs
docker logs service_name

# Test internal connectivity
docker exec caddy curl -f http://service_name:port
```

#### SSL Certificate Issues
```bash
# Check Caddy logs
docker logs caddy | grep -i ssl

# Check certificate status
curl -I https://subdomain.brennan.page

# Restart Caddy
docker compose restart caddy
```

#### Network Connectivity
```bash
# Test network connectivity
docker exec container1 ping container2

# Check network configuration
docker network inspect network_name

# List networks
docker network ls
```

#### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :port

# Check container ports
docker port container_name

# Find conflicting processes
lsof -i :port
```

### Performance Issues

#### Slow Response Times
```bash
# Check resource usage
docker stats

# Check network latency
ping subdomain.brennan.page

# Analyze request patterns
docker logs caddy | grep -i response
```

#### High Resource Usage
```bash
# Monitor network I/O
docker stats --no-stream | grep -i network

# Check connection counts
docker exec postgres psql -U homelab -c "SELECT count(*) FROM pg_stat_activity;"

# Analyze traffic patterns
docker logs caddy | grep -i request
```

## Monitoring

### Network Monitoring
- **Connection Tracking**: Monitor active connections
- **Bandwidth Usage**: Track network utilization
- **Response Times**: Monitor service response times
- **Error Rates**: Track network errors

### Tools
- **Caddy Logs**: Access logs and error logs
- **Docker Stats**: Container resource usage
- **Netstat**: Network connection monitoring
- **Ping**: Network connectivity testing

## Best Practices

### Network Design
- **Isolation**: Separate networks for different purposes
- **Security**: Limit external access where possible
- **Performance**: Optimize for low latency
- **Scalability**: Design for future growth

### Configuration Management
- **Version Control**: Network configurations in Git
- **Documentation**: Clear network documentation
- **Testing**: Test network changes before deployment
- **Monitoring**: Continuous network monitoring

### Security Practices
- **Least Privilege**: Minimal access required
- **Encryption**: All external traffic encrypted
- **Monitoring**: Security event monitoring
- **Updates**: Regular security updates

## Future Enhancements

### Planned Improvements
- **Load Balancing**: Multiple service instances
- **CDN Integration**: Static content delivery
- **IPv6 Support**: IPv6 connectivity
- **Network Policies**: Advanced network policies

### Scaling Considerations
- **Service Mesh**: Service-to-service communication
- **API Gateway**: Centralized API management
- **Service Discovery**: Dynamic service discovery
- **Traffic Management**: Advanced traffic routing

## References

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Docker Networking](https://docs.docker.com/network/)
- [UFW Firewall](https://help.ubuntu.com/community/UFW)
- [Let's Encrypt](https://letsencrypt.org/)
