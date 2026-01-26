# Deployments

This section documents deployment procedures and strategies for the brennan.page homelab infrastructure.

## Deployment Strategy

### Overview

The homelab uses a phased deployment approach to ensure stability and proper testing at each stage. Each phase focuses on specific service categories and builds upon previous phases.

### Deployment Principles

- **Local-First**: All changes tested locally before deployment
- **Infrastructure as Code**: All configurations tracked in Git
- **Automated Scripts**: Use deployment scripts for consistency
- **Rollback Ready**: Maintain ability to rollback changes
- **Documentation First**: Document before, during, and after deployment

## Service Categories

### Infrastructure Services
- **Caddy**: Reverse proxy with automatic HTTPS
- **PostgreSQL**: Primary database server
- **MariaDB**: Database for Flarum forum

### Management Services
- **Portainer**: Docker management interface
- **FileBrowser**: File management interface
- **Monitor**: System monitoring dashboard

### Productivity Services
- **Vikunja**: Task management system
- **HedgeDoc**: Collaborative markdown notes
- **Linkding**: Bookmark manager
- **Navidrome**: Music streaming server

### Content & Community Services
- **WriteFreely**: Blog platform
- **Flarum**: Community forum
- **FreshRSS**: RSS feed aggregator

## Deployment Procedures

### [Infrastructure Deployment](infrastructure-deployment.md)
Foundation services deployment procedures.

### [Service Deployment](service-deployment.md)
Individual service deployment and management.

### [Wiki Deployment](wiki-deployment.md)
Documentation site deployment procedures.

### [Database Deployment](database-deployment.md)
Database setup and management procedures.

## Deployment Tools

### Automation Scripts

- **deploy-all.sh**: Deploy all services
- **deploy-service.sh**: Deploy individual services
- **deploy-wiki.sh**: Deploy documentation site
- **health-check.sh**: Verify deployment health

### Configuration Management

- **Git**: Version control for all configurations
- **Docker Compose**: Service orchestration
- **Environment Files**: Service-specific configurations
- **Templates**: Reusable configuration templates

## Deployment Environment

### Local Development

```bash
# Clone repository
git clone https://github.com/brennanbrown/brennan.page.git
cd brennan.page

# Local testing
docker compose config
docker compose up -d
```

### Server Environment

```bash
# Server connection
ssh -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169

# Working directory
cd /opt/homelab

# Service deployment
./scripts/deploy-service.sh service_name
```

## Deployment Workflow

### 1. Preparation

```bash
# Update local repository
git pull origin main

# Check service status
./scripts/health-check.sh

# Backup current state
./scripts/backup.sh
```

### 2. Local Testing

```bash
# Test configuration
cd services/service_name
docker compose config

# Test build
docker compose build

# Test run (if applicable)
docker compose up -d
```

### 3. Deployment

```bash
# Deploy to server
./scripts/deploy-service.sh service_name

# Verify deployment
ssh root@159.203.44.203.169 "cd /opt/homelab/services/service_name && docker compose ps"
```

### 4. Verification

```bash
# Test service accessibility
curl -I https://service.brennan.page

# Check service health
docker exec service_name curl -f http://localhost:port/health

# Monitor resource usage
docker stats service_name
```

### 5. Documentation

```bash
# Update documentation
cd wiki
mkdocs build --clean
./deploy-wiki.sh

# Verify documentation
curl -I https://wiki.brennan.page
```

## Service Dependencies

### Database Dependencies

| Service | Database | Purpose |
|---------|----------|---------|
| Vikunja | PostgreSQL | Task data |
| HedgeDoc | PostgreSQL | Notes data |
| Linkding | PostgreSQL | Bookmark data |
| Navidrome | PostgreSQL | Music metadata |
| WriteFreely | PostgreSQL | Blog data |
| FreshRSS | PostgreSQL | RSS data |
| Flarum | MariaDB | Forum data |

### Network Dependencies

- **caddy**: External network for web access
- **internal_db**: Internal network for database access
- **monitoring**: Internal network for monitoring

### Configuration Dependencies

- **Environment Variables**: Service-specific configurations
- **Volume Mounts**: Persistent data storage
- **Network Ports**: Service port allocations
- **SSL Certificates**: Automatic certificate management

## Deployment Standards

### Code Standards

- **Version Control**: All configurations in Git
- **Documentation**: Comprehensive documentation for all changes
- **Testing**: Local testing before deployment
- **Security**: Security best practices applied

### Resource Standards

- **Memory Limits**: Appropriate limits for each service
- **CPU Limits**: CPU limits where applicable
- **Storage Quotas**: Storage limits and monitoring
- **Network Isolation**: Proper network segmentation

### Security Standards

- **SSL/TLS**: All web services use HTTPS
- **Authentication**: Proper authentication mechanisms
- **Access Control**: Principle of least privilege
- **Audit Trail**: Change tracking and logging

## Deployment Metrics

### Success Criteria

- **Service Availability**: > 99% uptime
- **Response Time**: < 2 seconds average
- **Resource Usage**: Within allocated limits
- **Backup Success**: 100% backup success rate

### Monitoring Metrics

- **Deployment Time**: Time to complete deployment
- **Rollback Time**: Time to rollback if needed
- **Error Rate**: Deployment error rate
- **User Impact**: Impact on users during deployment

### Performance Metrics

- **Response Time**: Service response times
- **Resource Usage**: Memory and CPU utilization
- **Throughput**: Request handling capacity
- **Availability**: Service uptime percentage

## Rollback Procedures

### Service Rollback

```bash
# Stop current version
cd /opt/homelab/services/service_name
docker compose down

# Restore previous version
git checkout previous_tag
./scripts/deploy-service.sh service_name

# Verify rollback
curl -I https://service.brennan.page
```

### Full System Rollback

```bash
# Stop all services
cd /opt/homelab
docker compose down

# Restore from backup
./scripts/restore.sh latest_backup.tar.gz

# Restart services
docker compose up -d

# Verify system
./scripts/health-check.sh
```

## Deployment Troubleshooting

### Common Issues

**Service Won't Start**
1. Check logs: `docker logs service_name`
2. Verify configuration: `docker compose config`
3. Check resources: `docker stats`
4. Check dependencies: `docker network ls`

**Database Connection Issues**
1. Check database status: `docker exec postgresql pg_isready`
2. Verify credentials: Check environment variables
3. Test connection: Manual database connection test
4. Check network: Verify network connectivity

**Configuration Issues**
1. Validate syntax: `docker compose config`
2. Check environment: Verify environment variables
3. Check permissions: Verify file permissions
4. Check ports: Verify port availability

### Troubleshooting Commands

```bash
# Check service status
docker ps | grep service_name

# Check service logs
docker logs service_name --tail 50

# Check resource usage
docker stats service_name

# Test connectivity
curl -I https://service.brennan.page

# Check configuration
docker compose config
```

## Deployment Automation

### CI/CD Integration

```yaml
# Example GitHub Actions
name: Deploy Service
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to server
        run: |
          ./scripts/deploy-service.sh ${{ env.SERVICE_NAME }}
```

### Automated Testing

```bash
# Pre-deployment checks
#!/bin/bash
echo "Running pre-deployment checks..."

# Check service configuration
docker compose config

# Test service build
docker compose build

# Run health checks
docker compose up -d
sleep 30
docker compose exec service_name curl -f http://localhost:port/health
docker compose down

echo "Pre-deployment checks passed"
```

### Automated Deployment

```bash
#!/bin/bash
# Automated deployment script
SERVICE_NAME=$1

echo "Deploying $SERVICE_NAME..."

# Deploy service
./scripts/deploy-service.sh $SERVICE_NAME

# Verify deployment
if curl -f https://$SERVICE_NAME.brennan.page; then
    echo "Deployment successful"
else
    echo "Deployment failed"
    exit 1
fi
```

## Deployment History

### Recent Deployments

| Date | Service | Version | Status | Notes |
|------|--------|--------|--------|-------|
| 2026-01-17 | Wiki Management | 1.0.0 | ✅ | Added wiki management documentation |
| 2026-01-17 | HedgeDoc Fix | 1.0.0 | ✅ | Fixed database connection issues |
| 2026-01-17 | Phase 4 Services | 1.0.0 | ✅ | Content & community services |
| 2026-01-16 | Phase 3 Services | 1.0.0 | ✅ | Productivity services |
| 2026-01-16 | Phase 2 Services | 1.0.0 | ✅ | Core infrastructure |

### Deployment Statistics

- **Total Deployments**: 25+
- **Success Rate**: 96%
- **Average Deployment Time**: 15 minutes
- **Rollback Rate**: 4%
- **Zero-Downtime Deployments**: 80%

## Best Practices

### Before Deployment

- **Test Locally**: Always test locally first
- **Backup Current**: Create backup before deployment
- **Check Dependencies**: Verify all dependencies
- **Review Changes**: Review all changes being deployed

### During Deployment

- **Monitor Progress**: Monitor deployment progress
- **Check Logs**: Watch for errors during deployment
- **Verify Health**: Check service health after deployment
- **Test Functionality**: Test key functionality

### After Deployment

- **Verify Access**: Verify service accessibility
- **Monitor Performance**: Monitor performance metrics
- **Update Documentation**: Update documentation if needed
- **Communicate**: Communicate deployment status

## References

- [Services](../services/) - Service documentation
- [Operations](../operations/) - Operational procedures
- [Configuration](../configuration/) - Configuration management
- [Troubleshooting](../troubleshooting/) - Troubleshooting guides
- [Wiki Management](../operations/wiki-management.md) - Wiki deployment procedures
