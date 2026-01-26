# Troubleshooting

This section provides comprehensive troubleshooting guides for common issues with the brennan.page homelab.

## Quick Diagnosis

### System Status Check
```bash
# Quick system health check
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== System Status ==='
  docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
  echo -e '\n=== Resource Usage ==='
  free -h | head -2
  df -h | head -2
  echo -e '\n=== Network Status ==='
  curl -I https://brennan.page
"
```

### Service Health Check
```bash
# Check all critical services
services=("docker.brennan.page" "monitor.brennan.page" "files.brennan.page" "wiki.brennan.page")
for service in "${services[@]}"; do
  echo "Checking $service..."
  curl -s -o /dev/null -w "%{http_code} $service\n" "https://$service"
done
```

## Common Issues

### Service Not Starting
- **Symptoms**: Service shows as "Exited" or "Restarting", HTTP 502/503 errors
- **Quick Fix**: `docker compose restart` or `docker compose down && docker compose up -d`
- **Details**: See [Service Issues](service-issues/)

### Database Connection Issues
- **Symptoms**: Service can't connect to database, connection timeouts
- **Quick Fix**: `docker restart postgresql`
- **Details**: See [Database Issues](database-issues/)

### SSL/TLS Certificate Issues
- **Symptoms**: HTTPS not working, certificate errors
- **Quick Fix**: `docker restart caddy`
- **Details**: See [Network Issues](network-issues/)

### Performance Issues
- **Symptoms**: Slow response times, high resource usage
- **Quick Fix**: `docker system prune -f`
- **Details**: See [Performance Issues](performance-issues/)

## Service-Specific Troubleshooting

### Phase 1 Services
- [Portainer](../services/portainer/)
- [Monitor](../services/monitor/)
- [Files](../services/filebrowser/)

### Phase 2 Services
- [Wiki](../services/wiki/)

### Phase 3 Services
- [Tasks](../services/vikunja/)
- [Notes](../services/hedgedoc/)
- [Bookmarks](../services/linkding/)
- [Music](../services/navidrome/)

### Phase 4 Services
- [WriteFreely Blog](phase4/writefreely/)
- [Flarum Forum](phase4/flarum/)
- [FreshRSS](phase4/freshrss/)

## Emergency Procedures

### Complete System Outage
1. **Assess Impact**: Check system status
2. **Restart Services**: `docker compose restart`
3. **Check Connectivity**: `ping -c 4 8.8.8.8`

### Data Recovery
- **Database Recovery**: See [Database Issues](database-issues/)
- **File Recovery**: See [Service Issues](service-issues/)

## Getting Help

### Before Opening Support Ticket
- [ ] Checked system status
- [ ] Reviewed service logs
- [ ] Tested basic connectivity
- [ ] Attempted basic restarts

### Information to Include
- System status output
- Complete error messages
- Recent changes
- Steps already taken

## References

- [Services](../services/) - Service-specific troubleshooting
- [Operations](../operations/) - Operational procedures
- [Infrastructure](../infrastructure/) - Infrastructure documentation
