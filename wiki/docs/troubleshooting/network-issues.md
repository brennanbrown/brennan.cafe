# Network Issues

Network-related problems and their solutions.

## SSL/TLS Certificate Issues

### Certificate Problems

**Symptoms:**
- HTTPS not working
- Certificate errors in browser
- Mixed content warnings
- Certificate expired

**Diagnosis:**
```bash
# Check certificate status
docker exec caddy caddy list-certificates

# Check Caddy logs
docker logs caddy --tail 50 | grep -i cert

# Test certificate
openssl s_client -connect brennan.page:443 -servername brennan.page

# Check certificate validity
curl -I https://brennan.page 2>&1 | grep -i ssl
```

**Solutions:**

#### Reload Caddy
```bash
# Reload Caddy configuration
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Restart Caddy
docker restart caddy
```

#### Force Certificate Renewal
```bash
# Force certificate renewal
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Check certificate status
docker exec caddy caddy list-certificates
```

#### Check DNS Configuration
```bash
# Check DNS resolution
dig brennan.page
dig A brennan.page
dig MX brennan.page

# Check domain points to correct IP
nslookup brennan.page
```

### Mixed Content Issues

**Symptoms:**
- Mixed content warnings in browser
- Some resources load over HTTP
- Security padlock not shown

**Solutions:**

#### Update Resource URLs
```bash
# Check for HTTP resources
curl -s https://service.brennan.page | grep -o 'http://[^"]*' | head -5

# Update Caddyfile to handle mixed content
# Add header to force HTTPS
header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
}
```

#### Fix Internal Links
```bash
# Update service configuration
# Ensure all internal links use HTTPS
# Update base URLs in service configs
```

## Proxy Issues

### Caddy Proxy Problems

**Symptoms:**
- Services not accessible via domain
- HTTP 502/503 errors
- Wrong service responding

**Diagnosis:**
```bash
# Check Caddy status
docker ps | grep caddy

# Check Caddy configuration
docker exec caddy cat /etc/caddy/Caddyfile

# Test direct service access
curl -I http://localhost:port

# Check port mapping
docker port service_name
```

**Solutions:**

#### Update Caddyfile
```bash
# Check service port
docker exec service_name netstat -tlnp | grep :port

# Update Caddyfile with correct port
service.brennan.page {
    reverse_proxy service_name:correct_port
}

# Reload Caddy
docker restart caddy
```

#### Network Connectivity
```bash
# Check if services can communicate
docker exec service_name ping other_service

# Check network configuration
docker network ls
docker network inspect network_name

# Reconnect to network
docker network connect network_name service_name
```

### Service Discovery

**Symptoms:**
- Services can't find each other
- DNS resolution failures
- Connection timeouts

**Solutions:**

#### Use Service Names
```bash
# Test service name resolution
docker exec service_name nslookup postgresql

# Use container names for communication
# Instead of IP addresses, use service names
```

#### Check Network Configuration
```bash
# List networks
docker network ls

# Inspect network
docker network inspect caddy

# Connect service to network
docker network connect caddy service_name
```

## Performance Issues

### Slow Response Times

**Symptoms:**
- High latency
- Slow page loads
- Timeout errors

**Diagnosis:**
```bash
# Test network latency
ping -c 4 brennan.page

# Check DNS resolution time
dig brennan.page | grep "Query time"

# Test service response time
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://service.brennan.page
```

**Solutions:**

#### Optimize Caddy Configuration
```bash
# Enable compression
encode {
    gzip
    zstd
}

# Enable HTTP/2
{
    protocols h1 h2 h3
}

# Set timeouts
timeouts {
    read 30s
    write 30s
    idle 60s
}
```

#### Enable Caching
```bash
# Add caching headers
header {
    Cache-Control "public, max-age=3600"
    X-Content-Type-Options nosniff
}
```

### High Bandwidth Usage

**Symptoms:**
- High data transfer costs
- Slow downloads
- Bandwidth throttling

**Solutions:**

#### Enable Compression
```bash
# Enable gzip compression
encode gzip

# Test compression
curl -H "Accept-Encoding: gzip" -I https://service.brennan.page
```

#### Optimize Assets
```bash
# Minimize CSS/JS files
# Use efficient image formats
# Enable browser caching
```

## Security Issues

### SSL/TLS Configuration

**Symptoms:**
- Weak ciphers
- Outdated protocols
- Security warnings

**Solutions:**

#### Update Caddy Configuration
```bash
# Use strong TLS configuration
tls {
    protocols tls1.2 tls1.3
    ciphers TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
}

# Enable HSTS
header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
}
```

### Access Control

**Symptoms:**
- Unauthorized access
- Brute force attempts
- Security breaches

**Solutions:**

#### Rate Limiting
```bash
# Add rate limiting
rate_limit {
    zone static_files {
        key {remote_ip}
        events 100
        window 1m
    }
}

# Apply rate limiting
handle /static/* {
    rate_limit static_files
}
```

#### IP Blocking
```bash
# Block suspicious IPs
# Add to Caddyfile
@blocked {
    remote_ip 192.168.1.100
}

handle {
    route @blocked {
        respond 403 "Forbidden"
    }
}
```

## Troubleshooting Tools

### Network Diagnostics
```bash
# Full network test
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Network Tests ==='
  ping -c 4 brennan.page
  curl -I https://brennan.page
  nslookup brennan.page
  echo -e '\n=== Port Status ==='
  netstat -tulpn | grep ':80\|:443\|:22'
  echo -e '\n=== Docker Networks ==='
  docker network ls
  docker network inspect caddy
"
```

### SSL/TLS Testing
```bash
# Test SSL certificate
openssl s_client -connect brennan.page:443 -servername brennan.page

# Check certificate details
curl -I https://brennan.page 2>&1 | grep -E "SSL|TLS|certificate"

# Test SSL Labs rating
curl -s "https://www.ssllabs.com/ssltest/analyze.html?d=brennan.page&hideResults=on"
```

### Performance Testing
```bash
# Test response time
curl -w "DNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" -o /dev/null -s https://brennan.page

# Test multiple endpoints
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page")
for service in "${services[@]}"; do
  echo "Testing $service..."
  curl -w "$service: %{time_total}s\n" -o /dev/null -s "https://$service"
done
```

## Prevention

### Regular Monitoring
- [ ] Monitor SSL certificate expiry
- [ ] Check network performance
- [ ] Review access logs
- [ ] Test service availability

### Best Practices
- Use HTTPS everywhere
- Enable HSTS
- Implement rate limiting
- Monitor bandwidth usage
- Keep software updated

### Security Hardening
```bash
# Security headers
header {
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    X-XSS-Protection "1; mode=block"
    Referrer-Policy "strict-origin-when-cross-origin"
    Content-Security-Policy "default-src 'self'"
}

# Hide server information
{
    hide_server
    hide_version
}
```

## Getting Help

### Before Reporting Issues
- [ ] Tested direct service access
- [ ] Verified DNS configuration
- [ ] Checked SSL certificate
- [ ] Tested network connectivity

### Information to Include
- Network test results
- SSL certificate details
- Caddy configuration
- Error messages
- Performance metrics
