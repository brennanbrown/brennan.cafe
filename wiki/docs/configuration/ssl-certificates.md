# SSL Certificates

SSL/TLS certificate management for the brennan.page homelab.

## Overview

SSL certificates enable HTTPS encryption for all homelab services, ensuring secure communication between users and services.

## Certificate Management

### Automatic Certificate Management
- **Provider**: Let's Encrypt
- **Manager**: Caddy Server
- **Renewal**: Automatic (30 days before expiry)
- **Validation**: DNS-01 challenge

### Certificate Types
- **Single Domain**: Individual service certificates
- **Wildcard Certificate**: *.brennan.page (covers all subdomains)
- **Self-Signed**: Internal services (if needed)

## Caddy SSL Configuration

### Global SSL Settings
```caddy
# Global SSL configuration
{
    email admin@brennan.page
    auto_https
    log {
        level INFO
    }
}

# Certificate storage
storage {
    certificates /root/.local/share/caddy
}
```

### SSL/TLS Configuration
```caddy
# SSL/TLS settings
tls {
    protocols tls1.2 tls1.3
    ciphers TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    curves X25519:P-256:P-384:P-521
    alpn h2 http/1.1
}

# OCSP stapling
tls {
    staple
}
```

### Security Headers
```caddy
# Security headers
header {
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    X-XSS-Protection "1; mode=block"
    Referrer-Policy "strict-origin-when-cross-origin"
    Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' https:;"
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
}
```

## Service SSL Configuration

### Standard Service Configuration
```caddy
# Standard service with SSL
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service:port
    handle_errors {
        respond "Service unavailable" 503
    }
}
```

### Custom SSL Configuration
```caddy
# Custom SSL settings
service.brennan.page {
    tls {
        protocols tls1.2 tls1.3
        ciphers TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    }
    
    reverse_proxy service:port
}
```

### Certificate Management
```caddy
# Certificate management
service.brennan.page {
    tls {
        dns cloudflare
        email admin@brennan.page
    }
    
    reverse_proxy service:port
}
```

## Certificate Operations

### Certificate Status
```bash
# Check certificate status
docker exec caddy caddy list-certificates

# Check certificate details
docker exec caddy caddy certificate-info brennan.page

# Check certificate expiry
docker exec caddy caddy certificate-status brennan.page
```

### Certificate Renewal
```bash
# Force certificate renewal
docker exec caddy caddy reload --config /etc/caddy/Caddyfile

# Manual renewal
docker exec caddy caddy reload --force
```

### Certificate Troubleshooting
```bash
# Check certificate logs
docker logs caddy | grep -i certificate

# Test certificate
openssl s_client -connect brennan.page:443 -servername brennan.page

# Check certificate chain
curl -I https://brennan.page
```

## Certificate Storage

### Certificate Location
```bash
# Certificate storage directory
docker exec caddy ls -la /root/.local/share/caddy

# Certificate files
docker exec caddy ls -la /root/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/brennan.page
```

### Certificate Backup
```bash
# Backup certificates
docker exec caddy tar czf /tmp/certificates.tar.gz /root/.local/share/caddy

# Copy certificates to host
docker cp caddy:/tmp/certificates.tar.gz /opt/homelab/backups/

# Extract certificates
tar xzf /opt/homelab/backups/certificates.tar.gz -C /opt/homelab/backups/
```

### Certificate Restoration
```bash
# Restore certificates
docker cp /opt/homelab/backups/certificates.tar.gz caddy:/tmp/

# Extract certificates
docker exec caddy tar xzf /tmp/certificates.tar.gz -C /root/.local/share/caddy/

# Reload Caddy
docker restart caddy
```

## SSL Configuration Files

### Caddyfile SSL Configuration
```caddy
# Caddyfile with SSL
{
    email admin@brennan.page
    auto_https
    log {
        level INFO
        output file /var/log/caddy/access.log
    }
}

# SSL/TLS settings
tls {
    protocols tls1.2 tls1.3
    ciphers TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    curves X25519:P-256:P-384:P-521
    alpn h2 http/1.1
}

# Service configurations
service.brennan.page {
    import compression
    import security
    
    reverse_proxy service:port
}

# Security imports
(compression) {
    encode {
        gzip
        zstd
    }
}

(security) {
    header {
        X-Content-Type-Options nosniff
        X-Frame-Options DENY
        X-XSS-Protection "1; mode=block"
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    }
}
```

### Environment Variables
```yaml
# SSL environment variables
services:
  caddy:
    image: caddy:latest
    environment:
      - CADDY_INGRESS_PORTS=80:443
      - CADDY_TLS_EMAIL=admin@brennan.page
      - CADDY_TLS_ALPN=h2 http/1.1
```

## Certificate Monitoring

### Certificate Expiry Monitoring
```bash
# Check certificate expiry
openssl s_client -connect brennan.page:443 -servername brennan.page 2>/dev/null | openssl x509 -noout -dates | grep notAfter

# Check all certificates
for domain in brennan.page *.brennan.page; do
    echo "Checking $domain..."
    openssl s_client -connect $domain:443 -servername $domain 2>/dev/null | openssl x509 -noout -dates | grep notAfter
done
```

### Certificate Monitoring Script
```bash
#!/bin/bash
# cert-monitor.sh

# Check certificate expiry
DOMAIN="brennan.page"
EXPIRY=$(openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -dates | grep notAfter | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))

if [ $DAYS_LEFT -lt 30 ]; then
    echo "Certificate expires in $DAYS_LEFT days"
    echo "Subject: Certificate Alert: $DOMAIN expires in $DAYS_LEFT days" | mail -s "SSL Certificate Alert" admin@brennan.page
else
    echo "Certificate is valid for $DAYS_LEFT days"
fi
```

### Automated Monitoring
```bash
# Add to crontab
crontab -e

# Certificate monitoring (daily at 9 AM)
0 9 * * * /opt/homelab/scripts/cert-monitor.sh >> /opt/homelab/logs/cert-monitor.log 2>&1
```

## SSL Troubleshooting

### Certificate Issues
```bash
# Check certificate status
docker exec caddy caddy list-certificates

# Check certificate logs
docker logs caddy | grep -i certificate

# Test certificate
curl -I https://brennan.page

# Check certificate chain
openssl s_client -connect brennan.page:443 -servername brennan.page -showcerts
```

### DNS Issues
```bash
# Check DNS resolution
nslookup brennan.page
dig brennan.page

# Check DNS propagation
dig +trace brennan.page

# Check DNS records
dig brennan.page A
dig brennan.page TXT
```

### SSL Configuration Issues
```bash
# Validate Caddyfile
docker exec caddy caddy validate --config /etc/caddy/Caddyfile

# Check Caddy logs
docker logs caddy | grep -i error

# Test SSL configuration
curl -I https://brennan.page 2>&1 | grep -i ssl
```

### Certificate Renewal Issues
```bash
# Force certificate renewal
docker exec caddy caddy reload --force

# Check ACME challenge
docker logs caddy | grep -i acme

# Manual renewal
docker exec caddy caddy reload --config /etc/caddy/Caddyfile
```

## Advanced SSL Configuration

### Multiple Certificates
```caddy
# Multiple certificates for different domains
service1.brennan.page {
    tls {
        dns cloudflare
    }
    reverse_proxy service1:port
}

service2.brennan.page {
    tls {
        dns route53
    }
    reverse_proxy service2:port
}
```

### Certificate Chains
```caddy
# Certificate chain configuration
service.brennan.page {
    tls {
        load /path/to/certificate.crt
        load /path/to/private.key
        load /path/to/chain.crt
    }
    reverse_proxy service:port
}
```

### OCSP Stapling
```caddy
# OCSP stapling
tls {
    staple
    ocsp_stapling
}
```

## Security Best Practices

### Certificate Security
```bash
# Secure certificate storage
chmod 600 /root/.local/share/caddy/certificates
chown root:root /root/.local/share/caddy/certificates

# Regular certificate monitoring
# Set up automated expiry alerts
```

### SSL Configuration Security
```caddy
# Secure SSL configuration
tls {
    protocols tls1.2 tls1.3
    ciphers TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    curves X25519:P-256:P-384:P-521
    alpn h2 http/1.1
    min_version 1.2
}

# Security headers
header {
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    X-XSS-Protection "1; mode=block"
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
}
```

### Certificate Management
```bash
# Regular certificate backup
tar czf /opt/homelab/backups/certificates-$(date +%Y%m%d).tar.gz /root/.local/share/caddy/certificates

# Certificate rotation
# Keep old certificates for 30 days
find /opt/homelab/backups -name "certificates-*.tar.gz" -mtime +30 -delete
```

## Getting Help

### Before Reporting Issues
- [ ] Checked certificate status
- [ ] Verified DNS configuration
- [ ] Tested SSL connectivity
- [ ] Reviewed Caddy logs

### Information to Include
- Certificate status output
- DNS configuration
- SSL test results
- Caddy logs
- Error messages
- Recent changes
