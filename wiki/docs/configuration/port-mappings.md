# Port Mappings

Service port configurations and mappings.

## Overview

Port mappings control how services are accessed and communicate within the homelab infrastructure.

## Port Mapping Strategy

### Internal vs External Ports
- **Internal Ports**: Ports used within Docker containers
- **External Ports**: Ports exposed to the host system
- **Proxy Ports**: Ports used by Caddy reverse proxy

### Recommended Approach
- **Use Caddy Proxy**: Most services should use Caddy for external access
- **Limit Direct Port Exposure**: Only expose ports when necessary
- **Use Standard Ports**: Use standard port ranges when possible

## Service Port Configurations

### Core Services

#### Caddy
```yaml
# No port mapping needed (uses host network)
# Caddy handles all external traffic
ports: []
# Uses ports 80 (HTTP) and 443 (HTTPS) on host
```

#### PostgreSQL
```yaml
# Internal only, no external access
ports: []
# Internal port: 5432
# Access via internal_db network only
```

### Management Services

#### Portainer
```yaml
# Direct access for Docker management
ports:
  - "9000:9000"
# Internal port: 9000
# External access: https://docker.brennan.page (via Caddy)
# Direct access: http://localhost:9000
```

#### Monitor (Enhanced Monitor)
```yaml
# Direct access for system monitoring
ports:
  - "61208:61208"
# Internal port: 61208
# External access: https://monitor.brennan.page (via Caddy)
# Direct access: http://localhost:61208
```

#### FileBrowser
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 80
# External access: https://files.brennan.page (via Caddy)
```

### Productivity Services

#### Vikunja
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 80
# External access: https://tasks.brennan.page (via Caddy)
```

#### HedgeDoc
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 3000
# External access: https://notes.brennan.page (via Caddy)
```

#### Linkding
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 9090
# External access: https://bookmarks.brennan.page (via Caddy)
```

#### Navidrome
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 4533
# External access: https://music.brennan.page/music/app/ (via Caddy)
```

### Phase 4 Services

#### WriteFreely
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 8080
# External access: https://blog.brennan.page (via Caddy)
```

#### Flarum
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 8888
# External access: https://forum.brennan.page (via Caddy)
```

#### FreshRSS
```yaml
# No port mapping (uses Caddy proxy)
ports: []
# Internal port: 80
# External access: https://rss.brennan.page (via Caddy)
```

## Port Mapping Examples

### Direct Port Access
```yaml
# When direct access is needed
services:
  service_name:
    image: service:latest
    ports:
      - "8080:80"  # Host port 8080 -> Container port 80
      - "8443:443" # Host port 8443 -> Container port 443
```

### No Port Mapping (Proxy Only)
```yaml
# When using Caddy proxy
services:
  service_name:
    image: service:latest
    ports: []  # No direct port access
    networks:
      - caddy  # Only accessible via Caddy
```

### Host Network
```yaml
# When container needs host network
services:
  service_name:
    image: service:latest
    network_mode: host  # Uses host network
    ports: []  # No port mapping needed
```

## Port Allocation

### Standard Port Ranges
- **8000-8999**: Development services
- **9000-9999**: Management services
- **10000-10999**: Specialized services

### Current Port Usage
```bash
# Check port usage
netstat -tulpn | grep -E ":80|:443|:5432|:9000|:61208|:8080|:8888"

# Docker port mappings
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

### Port Conflicts
```bash
# Check for port conflicts
ss -tulpn | grep ":8080"

# Find available ports
netstat -tulpn | grep ":808[0-9]"
```

## Caddy Proxy Configuration

### Service Proxy Configuration
```caddy
# Standard service proxy
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service:internal_port
    handle_errors {
        respond "Service unavailable" 503
    }
}

# Service with specific path
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service:internal_port {
        /api/* service:internal_port
        /static/* service:internal_port
    }
}
```

### Internal Port Mapping
```caddy
# WriteFreely (internal port 8080)
blog.brennan.page {
    reverse_proxy writefreely:8080
}

# Flarum (internal port 8888)
forum.brennan.page {
    reverse_proxy flarum:8888
}

# FreshRSS (internal port 80)
rss.brennan.page {
    reverse_proxy freshrss:80
}
```

## Port Management

### Checking Port Usage
```bash
# Check all listening ports
netstat -tulpn

# Check Docker port mappings
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Check specific port
netstat -tulpn | grep ":8080"
```

### Finding Available Ports
```bash
# Find available port in range
for port in {8080..8090}; do
    if ! netstat -tulpn | grep -q ":$port "; then
        echo "Port $port is available"
        break
    fi
done
```

### Resolving Port Conflicts
```bash
# Find process using port
lsof -i :8080

# Kill process if necessary
kill -9 <PID>

# Or change service port
# Edit docker-compose.yml
ports:
  - "8081:80"  # Use different host port
```

## Security Considerations

### Port Exposure
```yaml
# Limit port exposure
services:
  service_name:
    ports:
      - "127.0.0.1:8080:80"  # Only localhost
      - "10.0.0.0:8080:80"    # Only internal network
```

### Firewall Configuration
```bash
# UFW firewall rules
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 22/tcp    # SSH
ufw deny 8080/tcp   # Block direct access
ufw deny 9000/tcp   # Block direct access
```

### Network Isolation
```yaml
# Use internal networks
networks:
  caddy:
    external: true
  internal_db:
    external: true
  service_network:
    driver: bridge
    internal: true  # No external access
```

## Port Configuration Templates

### Web Service Template
```yaml
services:
  web_service:
    image: service:latest
    ports: []  # No direct access
    networks:
      - caddy  # Only via proxy
```

### Management Service Template
```yaml
services:
  management_service:
    image: service:latest
    ports:
      - "9000:9000"  # Direct access
    networks:
      - caddy
      - management
```

### Database Service Template
```yaml
services:
  database_service:
    image: postgres:14
    ports: []  # No external access
    networks:
      - internal_db  # Only internal access
```

## Troubleshooting

### Port Not Accessible
```bash
# Check if port is listening
netstat -tulpn | grep ":8080"

# Check Docker port mapping
docker port service_name

# Check Caddy configuration
docker exec caddy cat /etc/caddy/Caddyfile | grep service_name
```

### Proxy Issues
```bash
# Test direct service access
curl -I http://localhost:8080

# Test proxy access
curl -I https://service.brennan.page

# Check Caddy logs
docker logs caddy | grep service_name
```

### Port Conflicts
```bash
# Find conflicting process
lsof -i :8080

# Check Docker containers using port
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep 8080

# Resolve conflict
docker stop conflicting_container
# or change port mapping
```

## Best Practices

### Port Management
- Use Caddy proxy for web services when possible
- Limit direct port exposure to management services only
- Use standard port ranges for consistency
- Document all port mappings

### Security
- Use firewall to restrict port access
- Limit port exposure to localhost when possible
- Use internal networks for database access
- Regularly audit port usage

### Performance
- Avoid port conflicts with proper planning
- Use load balancing for high-traffic services
- Monitor port usage and performance
- Use connection pooling for database connections

## Getting Help

### Before Reporting Issues
- [ ] Checked port usage
- [ ] Verified port mappings
- [ ] Tested direct access
- [ ] Checked proxy configuration

### Information to Include
- Port usage output
- Docker port mappings
- Caddy configuration
- Error messages
- Network configuration
