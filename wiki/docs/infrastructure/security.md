# Security

Security measures and best practices for the brennan.page homelab.

## Overview

Security is implemented at multiple layers to ensure the homelab remains secure while maintaining functionality.

## Security Layers

### 1. Infrastructure Security
- **OS Security**: Ubuntu 24.04 LTS with security updates
- **Firewall**: UFW with essential ports only
- **SSH Security**: Key-based authentication only
- **User Management**: Limited user accounts

### 2. Network Security
- **Network Isolation**: Docker network segmentation
- **SSL/TLS**: All external traffic encrypted
- **Access Control**: Limited external access
- **Monitoring**: Network traffic monitoring

### 3. Container Security
- **Image Security**: Official images with specific tags
- **Runtime Security**: Non-root users where possible
- **Resource Limits**: Prevent resource exhaustion
- **Isolation**: Container and network isolation

### 4. Application Security
- **Authentication**: Service-specific authentication
- **Authorization**: Proper access controls
- **Data Protection**: Encrypted data storage
- **Audit Logging**: Activity logging

## SSH Security

### Configuration
SSH is configured for secure remote access:

```bash
# /etc/ssh/sshd_config
Port 22
Protocol 2
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
```

### Key Management
- **SSH Keys**: Ed25519 keys for authentication
- **Key Storage**: Secure key storage
- **Key Rotation**: Regular key rotation
- **Access Control**: Limited key distribution

### SSH Best Practices
```bash
# Generate secure SSH key
ssh-keygen -t ed25519 -C "your_email@example.com"

# Copy public key to server
ssh-copy-id -i ~/.ssh/id_ed25519 user@server

# Test SSH connection
ssh -i ~/.ssh/id_ed25519 user@server
```

## Firewall Configuration

### UFW Rules
```bash
# Default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (from specific IPs if possible)
ufw allow 22/tcp

# Allow HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Enable firewall
ufw enable
```

### Advanced Rules
```bash
# Rate limiting
ufw limit 22/tcp

# Allow specific IP ranges
ufw allow from 192.168.1.0/24 to any port 22

# Log denied packets
ufw logging on
```

## Docker Security

### Container Security
```yaml
services:
  service_name:
    image: image:tag
    user: "1000:1000"  # Non-root user
    read_only: true    # Read-only filesystem
    security_opt:
      - no-new-privileges:true
    cap_drop:
      - ALL
    cap_add:
      - CHOWN
      - SETGID
      - SETUID
```

### Image Security
- **Official Images**: Use official images when possible
- **Specific Tags**: Pin to specific versions
- **Scanning**: Regular vulnerability scanning
- **Updates**: Keep images updated

### Runtime Security
```bash
# Run container with limited capabilities
docker run --cap-drop ALL --cap-add CHOWN image

# Use read-only filesystem
docker run --read-only image

# Set user ID
docker run --user 1000:1000 image
```

## SSL/TLS Security

### Certificate Management
- **Automatic**: Let's Encrypt via Caddy
- **Renewal**: Automatic renewal
- **Security**: Strong SSL configurations
- **Monitoring**: Certificate expiration monitoring

### SSL Configuration
```caddy
# Strong SSL configuration
ssl_protocols TLSv1.2 TLSv1.3
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512
ssl_prefer_server_ciphers off
ssl_session_cache shared:SSL:10m
ssl_session_timeout 1d
```

### Security Headers
```caddy
# Security headers
header {
    X-Content-Type-Options nosniff
    X-Frame-Options DENY
    X-XSS-Protection "1; mode=block"
    Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Content-Security-Policy "default-src 'self'"
}
```

## Database Security

### PostgreSQL Security
```sql
-- Create users with limited privileges
CREATE USER service_user WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE service_db TO service_user;
GRANT USAGE ON SCHEMA public TO service_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO service_user;

-- Revoke unnecessary privileges
REVOKE ALL ON SCHEMA public FROM public;
```

### Connection Security
- **Network Isolation**: Database on internal network only
- **Authentication**: Strong password authentication
- **Encryption**: Encrypted connections where supported
- **Access Control**: Limited database access

## Application Security

### Authentication
- **Strong Passwords**: Minimum password requirements
- **Multi-Factor**: Where supported
- **Session Management**: Secure session handling
- **Account Lockout**: After failed attempts

### Authorization
- **Principle of Least Privilege**: Minimal required access
- **Role-Based Access**: Role-based permissions
- **Access Reviews**: Regular access reviews
- **Audit Logging**: Access attempt logging

### Data Protection
- **Encryption**: Sensitive data encryption
- **Backup Security**: Encrypted backups
- **Data Retention**: Appropriate data retention
- **Privacy**: Privacy by design

## Monitoring and Logging

### Security Monitoring
```bash
# Monitor failed SSH attempts
grep "Failed password" /var/log/auth.log

# Monitor suspicious activity
tail -f /var/log/syslog | grep -i security

# Monitor Docker events
docker events --filter event=die
```

### Log Management
- **Centralized Logging**: Centralized log collection
- **Log Rotation**: Regular log rotation
- **Log Analysis**: Security event analysis
- **Alerting**: Security event alerting

### Intrusion Detection
- **Fail2Ban**: SSH and service protection
- **Tripwire**: File integrity monitoring
- **AIDE**: Advanced Intrusion Detection
- **Custom Scripts**: Custom security monitoring

## Backup Security

### Backup Encryption
```bash
# Encrypt backups with GPG
gpg --symmetric --cipher-algo AES256 --output backup.gpg backup.sql

# Decrypt backup
gpg --output backup.sql --decrypt backup.gpg
```

### Backup Storage
- **Secure Storage**: Encrypted backup storage
- **Off-site**: Off-site backup copies
- **Access Control**: Limited backup access
- **Verification**: Regular backup verification

## Security Policies

### Password Policy
- **Complexity**: Minimum 12 characters
- **Complexity**: Include uppercase, lowercase, numbers, symbols
- **Rotation**: Regular password rotation
- **Storage**: Secure password storage

### Access Policy
- **Need-to-Know**: Access based on need
- **Regular Review**: Regular access reviews
- **Termination**: Prompt access termination
- **Documentation**: Access documentation

### Incident Response
- **Detection**: Security incident detection
- **Response**: Incident response procedures
- **Recovery**: System recovery procedures
- **Post-Mortem**: Incident analysis

## Security Tools

### Essential Tools
- **Fail2Ban**: Intrusion prevention
- **ClamAV**: Antivirus scanning
- **AIDE**: File integrity monitoring
- **Lynis**: Security auditing

### Monitoring Tools
- **OSSEC**: Host-based intrusion detection
- **Suricata**: Network intrusion detection
- **ELK Stack**: Log analysis
- **Prometheus**: Metrics monitoring

## Compliance

### Security Standards
- **OWASP**: Web application security
- **NIST**: Security framework
- **ISO 27001**: Information security
- **GDPR**: Data protection compliance

### Auditing
- **Regular Audits**: Security audits
- **Vulnerability Scanning**: Regular scans
- **Penetration Testing**: Security testing
- **Compliance Checks**: Compliance verification

## Troubleshooting

### Security Issues

#### SSH Issues
```bash
# Check SSH configuration
sshd -T

# Test SSH connection
ssh -v user@server

# Check authentication logs
grep "sshd" /var/log/auth.log
```

#### Certificate Issues
```bash
# Check certificate status
openssl x509 -in cert.pem -text -noout

# Test SSL configuration
sslscan server:port

# Check certificate expiration
openssl s_client -connect server:443 2>/dev/null | openssl x509 -noout -dates
```

#### Firewall Issues
```bash
# Check firewall status
ufw status verbose

# Test firewall rules
ufw status numbered

# Check blocked connections
dmesg | grep -i firewall
```

## Best Practices

### Regular Maintenance
- **Updates**: Regular security updates
- **Patches**: Security patch management
- **Reviews**: Regular security reviews
- **Testing**: Security testing

### Security Awareness
- **Training**: Security awareness training
- **Documentation**: Security documentation
- **Procedures**: Security procedures
- **Communication**: Security communication

## References

- [Ubuntu Security Guide](https://ubuntu.com/security)
- [Docker Security](https://docs.docker.com/engine/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
