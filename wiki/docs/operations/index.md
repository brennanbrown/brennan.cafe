# Operations

This section documents the operational procedures for maintaining the brennan.page homelab.

## Overview

The homelab requires regular maintenance to ensure optimal performance, security, and reliability.

## Maintenance Schedule

### Daily Tasks 📅
**Time**: 5 minutes  
**Frequency**: Every day

- **System Health Check**: Quick status verification
- **Log Review**: Check for critical errors
- **Service Monitoring**: Verify service availability

### Weekly Tasks 📅
**Time**: 30 minutes  
**Frequency**: Every Sunday

- **System Updates**: Apply security updates
- **Backup Verification**: Check backup integrity
- **Performance Review**: Monitor resource usage

### Monthly Tasks 📅
**Time**: 1 hour  
**Frequency**: First Sunday of month

- **Security Audit**: Review security settings
- **Performance Optimization**: Clean up resources
- **Documentation Update**: Update documentation

### Quarterly Tasks 📅
**Time**: 2 hours  
**Frequency**: Every quarter

- **Major Updates**: Apply major version updates
- **Capacity Planning**: Review resource usage
- **Disaster Recovery**: Test recovery procedures

## Operational Procedures

### [Wiki Management](wiki-management.md)
Wiki deployment, maintenance, and content management procedures.

### [Deployment](deployment.md)
Service deployment and update procedures.

### [Backups](backups.md)
Backup and recovery procedures.

### [Monitoring](monitoring.md)
System and service monitoring.

### [Maintenance](maintenance.md)
Regular maintenance procedures.

## Quick Commands

### System Status
```bash
# Quick system health check
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== System Status ==='
  docker ps
  echo -e '\n=== Resource Usage ==='
  free -h
  df -h
  echo -e '\n=== Service Health ==='
  curl -I https://brennan.page
"
```

### Service Health
```bash
# Check critical services
curl -I https://docker.brennan.page
curl -I https://monitor.brennan.page
curl -I https://files.brennan.page
```

### Log Review
```bash
# Check for critical errors
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker logs --tail 20 caddy | grep -i error
  docker logs --tail 20 postgres | grep -i error
  journalctl -n 50 --no-pager | grep -i error
"
```

## Emergency Procedures

### Service Outage
1. **Assess Impact**: Check system status
2. **Restart Services**: `docker compose restart`
3. **Check Logs**: Review error logs
4. **Escalate**: Contact support if needed

### Data Recovery
1. **Stop Services**: `docker compose down`
2. **Restore Backup**: Use backup procedures
3. **Verify Data**: Check data integrity
4. **Start Services**: `docker compose up -d`

## Getting Help

### Before Contacting Support
- [ ] Checked system status
- [ ] Reviewed error logs
- [ ] Attempted basic restart
- [ ] Checked documentation

### Information to Include
- System status output
- Error messages
- Recent changes
- Steps already taken

## References

- [Services](../services/) - Service documentation
- [Infrastructure](../infrastructure/) - Infrastructure documentation
- [Configuration](../configuration/) - Configuration management
- [Troubleshooting](../troubleshooting/) - Troubleshooting guides
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  apt update
  apt list --upgradable
"

# Review and apply updates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  apt upgrade -y
  docker system prune -f
"
```

#### Service Updates
```bash
# Update Docker images
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services
  for service in */; do
    echo "Updating \$service"
    cd "\$service"
    docker compose pull
    docker compose up -d
    cd ..
  done
"
```

#### Backup Verification
```bash
# Verify backup integrity
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  ls -la /opt/homelab/backups/
  find /opt/homelab/backups/ -name "*.tar.gz" -mtime +7 -exec ls -la {} \;
"
```

### Monthly Tasks 📅
**Time**: 2 hours  
**Frequency**: First Sunday of month

#### Security Audit
```bash
# Check security logs
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Failed Login Attempts ==='
  grep 'Failed password' /var/log/auth.log | tail -20
  echo -e '\n=== UFW Status ==='
  ufw status numbered
  echo -e '\n=== SSL Certificate Status ==='
  docker exec caddy caddy list-certificates
"
```

#### Performance Review
```bash
# Check resource trends
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Memory Usage Trend ==='
  free -h
  echo -e '\n=== Disk Usage Trend ==='
  df -h
  echo -e '\n=== Docker Resource Usage ==='
  docker stats --no-stream
"
```

#### Database Maintenance
```bash
# Database optimization
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker exec postgres psql -U homelab -d homelab -c 'VACUUM ANALYZE;'
  docker exec postgres psql -U homelab -d vikunja -c 'VACUUM ANALYZE;'
  docker exec postgres psql -U homelab -d hedgedoc -c 'VACUUM ANALYZE;'
  docker exec postgres psql -U homelab -d linkding -c 'VACUUM ANALYZE;'
  docker exec postgres psql -U homelab -d navidrome -c 'VACUUM ANALYZE;'
"
```

## Operational Procedures

### Service Management

#### Starting Services
```bash
# Start single service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/service_name
  docker compose up -d
"

# Start all services
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  docker compose up -d
"
```

#### Stopping Services
```bash
# Stop single service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/service_name
  docker compose down
"

# Stop all services (emergency only)
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  docker compose down
"
```

#### Restarting Services
```bash
# Restart single service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/services/service_name
  docker compose restart
"

# Graceful restart of all services
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  docker compose restart
"
```

### Backup Operations

#### Manual Backup
```bash
# Create full backup
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  ./scripts/backup.sh
"

# Backup specific service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  ./scripts/backup-service.sh service_name
"
```

#### Restore Operations
```bash
# Restore from backup
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  ./scripts/restore.sh backup_file.tar.gz
"

# Restore specific service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab
  ./scripts/restore-service.sh service_name backup_file.tar.gz
"
```

### Monitoring Operations

#### Health Checks
```bash
# Check all services
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  ./scripts/health-check.sh
"

# Check specific service
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  curl -f https://service.brennan.page || echo 'Service DOWN'
"
```

#### Performance Monitoring
```bash
# Real-time monitoring
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker stats
"

# Historical performance
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}'
"
```

## Incident Response

### Incident Classification

#### Critical (P1)
- Service completely down
- Data corruption or loss
- Security breach
- System unavailable

#### High (P2)
- Service degradation
- Performance issues
- Partial functionality loss
- Backup failures

#### Medium (P3)
- Minor bugs
- UI issues
- Documentation errors
- Non-critical features

#### Low (P4)
- Cosmetic issues
- Typos
- Minor improvements
- Feature requests

### Response Procedures

#### P1 - Critical Response
1. **Immediate Action** (5 minutes)
   ```bash
   # Assess impact
   docker ps
   docker logs --tail 50 service_name
   curl -I https://service.brennan.page
   ```

2. **Stabilization** (15 minutes)
   ```bash
   # Restart affected services
   docker compose restart
   # If needed, restore from backup
   ./scripts/restore.sh latest_backup.tar.gz
   ```

3. **Communication** (30 minutes)
   - Document incident
   - Update status page
   - Notify stakeholders

#### P2 - High Response
1. **Assessment** (30 minutes)
   ```bash
   # Investigate issue
   docker logs service_name --tail 100
   docker exec service_name ps aux
   docker stats service_name
   ```

2. **Resolution** (2 hours)
   ```bash
   # Apply fix
   docker compose pull
   docker compose up -d
   # Verify resolution
   curl -I https://service.brennan.page
   ```

#### P3 - Medium Response
1. **Investigation** (4 hours)
   - Review logs
   - Test in staging
   - Plan fix

2. **Implementation** (1 day)
   - Deploy fix
   - Test thoroughly
   - Update documentation

#### P4 - Low Response
1. **Planning** (1 week)
   - Add to backlog
   - Prioritize
   - Schedule

2. **Implementation** (2 weeks)
   - Implement during regular maintenance
   - Test and deploy

## Operational Metrics

### Key Performance Indicators
- **Uptime**: Target > 99.5%
- **Response Time**: Target < 2 seconds
- **Backup Success**: Target 100%
- **Security Incidents**: Target 0

### Monitoring Dashboards
- **System Overview**: https://monitor.brennan.page
- **Service Status**: https://brennan.page
- **Documentation**: https://wiki.brennan.page

### Reporting
- **Daily**: Health check summary
- **Weekly**: Performance report
- **Monthly**: Executive summary
- **Quarterly**: Strategic review

## Operational Tools

### Automation Scripts
- **backup.sh**: Automated backup procedures
- **health-check.sh**: Service health monitoring
- **deploy-service.sh**: Service deployment
- **restore.sh**: Disaster recovery

### Monitoring Tools
- **Enhanced Monitor**: System monitoring
- **Docker**: Container monitoring
- **Caddy**: Web server logs
- **PostgreSQL**: Database monitoring

### Management Tools
- **Portainer**: Docker management
- **SSH**: Remote management
- **Git**: Configuration management
- **Wiki**: Documentation

## Operational Security

### Access Control
- **SSH Keys**: Key-based authentication only
- **User Accounts**: Minimal user accounts
- **Sudo**: Limited sudo access
- **Audit Trail**: All actions logged

### Security Procedures
- **Password Management**: Regular password rotation
- **Certificate Management**: Automated SSL renewal
- **Firewall Rules**: Regular review and updates
- **Security Updates**: Prompt security patching

### Backup Security
- **Encryption**: Backup encryption
- **Offsite**: Offsite backup storage
- **Testing**: Regular backup testing
- **Retention**: Backup retention policy

## Operational Documentation

### Required Documentation
- **Runbooks**: Step-by-step procedures
- **Service Docs**: Service-specific documentation
- **Network Diagrams**: Infrastructure documentation
- **Contact Lists**: Emergency contact information

### Documentation Standards
- **Version Control**: All docs in Git
- **Review Process**: Regular doc reviews
- **Accessibility**: Easy to find and use
- **Accuracy**: Regular updates

## Training and Knowledge

### Operator Training
- **System Overview**: Understanding the architecture
- **Service Management**: Service operations
- **Troubleshooting**: Problem resolution
- **Emergency Procedures**: Incident response

### Knowledge Sharing
- **Wiki**: Central knowledge base
- **Runbooks**: Operational procedures
- **Best Practices**: Lessons learned
- **Incident Reviews**: Post-incident analysis

## References

- [Services](../services/) - Service documentation
- [Infrastructure](../infrastructure/) - Infrastructure documentation
- [Troubleshooting](../troubleshooting/) - Troubleshooting guides
- [Configuration](../configuration/) - Configuration management
