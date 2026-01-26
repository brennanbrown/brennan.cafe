# Caddy

**Service**: Caddy Reverse Proxy  
**Version**: Latest  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Reverse proxy with automatic HTTPS  

## Overview

Caddy is the reverse proxy and web server that handles all external traffic for the brennan.page homelab. It provides automatic SSL certificates, HTTP/2 support, and secure reverse proxying to all services.

## Architecture

### Container Configuration
```yaml
services:
  caddy:
    image: caddy:latest
    container_name: caddy
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - caddy_data:/data
      - ./Caddyfile:/etc/caddy/Caddyfile
      - /var/www/brennan.page:/var/www/brennan.page:ro
      - /opt/homelab/wiki:/var/www/brennan.page/wiki:ro
    networks:
      - caddy
    mem_limit: 100m
    mem_reservation: 50m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **External Network**: Direct internet access
- **Internal Network**: Connects to all service containers
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **SSL**: Automatic Let's Encrypt certificates

## Configuration

### Caddyfile Structure
```caddy
# Global options
{
    email admin@brennan.page
    auto_https off
    admin localhost:2019
}

# Compression snippet
(compression) {
    encode zstd gzip
}

# Security headers snippet
(security) {
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Referrer-Policy strict-origin-when-cross-origin
    }
}

# Service configurations
brennan.page {
    import compression
    import security
    
    file_server /var/www/brennan.page {
        root index.html
    }
}

tasks.brennan.page {
    import compression
    import security
    
    reverse_proxy vikunja:3456
    handle_errors {
        respond "Task management service unavailable" 503
    }
}
```

### SSL Configuration
- **Automatic**: Let's Encrypt certificates
- **Renewal**: Automatic renewal 30 days before expiry
- **Security**: Strong SSL configurations
- **Redirect**: HTTP to HTTPS redirect

### Security Headers
All services get consistent security headers:
- **X-Content-Type-Options**: Prevent MIME-type sniffing
- **X-Frame-Options**: Prevent clickjacking
- **X-XSS-Protection**: Enable XSS protection
- **Referrer-Policy**: Control referrer information

## Features

### Automatic HTTPS
- **Let's Encrypt**: Free SSL certificates
- **Auto-renewal**: Automatic certificate renewal
- **OCSP Stapling**: OCSP stapling support
- **HTTP/2**: HTTP/2 protocol support

### Reverse Proxy
- **Load Balancing**: Multiple service instances
- **Health Checks**: Service health monitoring
- **Error Handling**: Graceful error handling
- **Request Routing**: Intelligent request routing

### Performance
- **Compression**: Zstandard and gzip compression
- **Caching**: Response caching
- **HTTP/2**: Multiplexed connections
- **Keep-alive**: Connection reuse

## Service Routing

### Current Routes
| Subdomain | Service | Internal Port | Status |
|-----------|---------|---------------|--------|
| brennan.page | Landing Page | N/A | ✅ Active |
| docker.brennan.page | Portainer | 9000 | ✅ Active |
| monitor.brennan.page | Monitor | 80 | ✅ Active |
| files.brennan.page | FileBrowser | 80 | ✅ Active |
| wiki.brennan.page | Wiki | N/A | ✅ Active |
| tasks.brennan.page | Vikunja | 3456 | ✅ Active |
| notes.brennan.page | HedgeDoc | 3000 | ✅ Active |
| bookmarks.brennan.page | Linkding | 9090 | ✅ Active |
| music.brennan.page | Navidrome | 4533 | ✅ Active |

### Future Routes
| Subdomain | Service | Internal Port | Status |
|-----------|---------|---------------|--------|
| blog.brennan.page | WriteFreely | 80 | 📋 Planned |
| forum.brennan.page | Flarum | 8080 | 📋 Planned |
| rss.brennan.page | FreshRSS | 80 | 📋 Planned |
| share.brennan.page | Plik | 8080 | 📋 Planned |
| poll.brennan.page | Rallly | 3000 | 📋 Planned |

## Management

### Configuration Management
```bash
# Test Caddyfile
caddy validate --config /etc/caddy/Caddyfile

# Reload configuration
caddy reload --config /etc/caddy/Caddyfile

# Check status
caddy list-procs
```

### Certificate Management
```bash
# Check certificates
caddy list-certificates

# Force certificate renewal
caddy reload

# Check certificate details
caddy certificate status brennan.page
```

### Log Management
```bash
# View access logs
tail -f /var/log/caddy/access.log

# View error logs
tail -f /var/log/caddy/error.log

# Rotate logs
logrotate /etc/logrotate.d/caddy
```

## Performance

### Resource Usage
- **Memory**: 100MB limit, 50MB reservation
- **CPU**: Low CPU usage
- **Storage**: ~10MB for certificates and logs
- **Network**: High network I/O

### Optimization
- **Compression**: Response compression
- **Caching**: Response caching
- **HTTP/2**: Multiplexed connections
- **Keep-alive**: Connection reuse

### Monitoring
```bash
# Check resource usage
docker stats caddy

# Check connection count
netstat -an | grep :443 | wc -l

# Monitor response times
curl -w "@curl-format.txt" -o /dev/null -s https://brennan.page
```

## Security

### SSL/TLS Security
- **Strong Ciphers**: Modern cipher suites
- **Perfect Forward Secrecy**: PFS support
- **HSTS**: HTTP Strict Transport Security
- **OCSP Stapling**: OCSP stapling support

### Application Security
- **Security Headers**: Consistent security headers
- **Rate Limiting**: Request rate limiting
- **Access Control**: IP-based access control
- **Error Handling**: Secure error handling

### Network Security
- **Firewall**: UFW firewall protection
- **Isolation**: Container network isolation
- **Monitoring**: Network traffic monitoring
- **Updates**: Regular security updates

## Troubleshooting

### Common Issues

#### Certificate Issues
```bash
# Check certificate status
caddy certificate status

# Force certificate renewal
caddy reload

# Check ACME challenges
caddy list-certificates
```

#### Service Not Accessible
```bash
# Check Caddy logs
docker logs caddy --tail 20

# Test service connectivity
docker exec caddy curl -f http://service_name:port

# Check configuration
caddy validate --config /etc/caddy/Caddyfile
```

#### Performance Issues
```bash
# Check resource usage
docker stats caddy

# Monitor response times
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://brennan.page

# Check connection count
ss -tuln | grep :443
```

#### Configuration Issues
```bash
# Validate configuration
caddy validate --config /etc/caddy/Caddyfile

# Check syntax errors
caddy adapt /etc/caddy/Caddyfile

# Test configuration
caddy reload --config /etc/caddy/Caddyfile
```

### Debug Commands
```bash
# Enable debug mode
caddy run --config /etc/caddy/Caddyfile --debug

# Check process status
caddy list-procs

# View detailed logs
docker logs caddy --tail 50
```

## Maintenance

### Regular Tasks
- **Certificate Renewal**: Automatic, but monitor
- **Log Rotation**: Configure log rotation
- **Configuration Updates**: Update as needed
- **Security Updates**: Keep Caddy updated

### Backup Procedures
```bash
# Backup configuration
tar czf caddy_config_backup.tar.gz /opt/homelab/caddy/

# Backup certificates
tar czf caddy_certs_backup.tar.gz /data/caddy/

# Backup logs
tar czf caddy_logs_backup.tar.gz /var/log/caddy/
```

### Update Process
```bash
# Update Caddy image
cd /opt/homelab/caddy
docker compose pull
docker compose up -d

# Update configuration
rsync Caddyfile /opt/homelab/caddy/Caddyfile
docker compose restart
```

## Integration

### With Services
- **Reverse Proxy**: Proxies to all services
- **SSL Termination**: Handles SSL for all services
- **Load Balancing**: Can load balance multiple instances
- **Health Checks**: Monitors service health

### With Docker
- **Container Networking**: Connects to service containers
- **Volume Mounts**: Mounts configuration and data
- **Process Management**: Manages Caddy process
- **Resource Limits**: Enforces resource limits

### With Let's Encrypt
- **ACME Protocol**: Automated certificate issuance
- **DNS Challenge**: DNS-based domain validation
- **Renewal**: Automatic certificate renewal
- **Revocation**: Certificate revocation support

## Best Practices

### Configuration
- **Version Control**: Store Caddyfile in Git
- **Testing**: Test configuration changes
- **Validation**: Validate configuration syntax
- **Documentation**: Document configuration changes

### Security
- **Regular Updates**: Keep Caddy updated
- **Security Headers**: Use security headers
- **Rate Limiting**: Implement rate limiting
- **Monitoring**: Monitor security events

### Performance
- **Compression**: Enable response compression
- **Caching**: Implement response caching
- **HTTP/2**: Use HTTP/2 where possible
- **Monitoring**: Monitor performance metrics

## References

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddyfile Reference](https://caddyserver.com/docs/caddyfile/)
- [Let's Encrypt](https://letsencrypt.org/)
- [HTTP/2 Specification](https://tools.ietf.org/html/rfc7540)
