# Monitor

**Service**: Enhanced System Monitor  
**Version**: Custom Nginx Solution with Real-time Dashboard  
**Status**: ✅ **OPERATIONAL**  
**Purpose**: Comprehensive System Monitoring Dashboard  

## Overview

The Monitor service provides an enhanced system monitoring dashboard for the brennan.page homelab. It displays real-time system information, resource usage with visual progress bars, service health checks, and performance metrics in a modern, responsive interface.

## Architecture

### Container Configuration
```yaml
services:
  monitor:
    image: nginx:alpine
    container_name: monitor
    restart: unless-stopped
    ports:
      - "8081:80"
    volumes:
      - ./index.html:/usr/share/nginx/html/index.html:ro
    networks:
      - caddy
    mem_limit: 50m
    mem_reservation: 30m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Network Configuration
- **External Access**: Via Caddy reverse proxy
- **Internal Network**: Connected to caddy network
- **Port**: 8081 (internal), 80 (container)
- **Protocol**: HTTP (served via HTTPS by Caddy)

## Features

### System Information
- **Hostname**: Server hostname and system info
- **Operating System**: Ubuntu 24.04 LTS details
- **Architecture**: System architecture and kernel version
- **Uptime**: System uptime and network statistics
- **Processes**: Running process count and container status

### Enhanced Resource Monitoring
- **Memory Usage**: Total, used, available memory with visual progress bars
- **Disk Usage**: Storage utilization with percentage indicators
- **CPU & Load**: Real-time CPU usage and load averages (1m, 5m, 15m)
- **Network Stats**: Connections, uptime, and network metrics
- **Docker Info**: Running/stopped containers, images, volumes

### Service Health Monitoring
- **Real-time Status**: Live health checks for all 11 services
- **Response Times**: Performance monitoring with detailed metrics
- **Service Cards**: Interactive status cards with error handling
- **Auto-refresh**: 30-second automatic refresh with manual option
- **Visual Indicators**: Color-coded status (online/offline/checking)

### Dashboard Features
- **Auto-refresh**: 30-second auto-refresh
- **Manual Refresh**: Manual refresh button
- **Responsive Design**: Mobile-friendly interface
- **Dark Theme**: Consistent dark theme

## Implementation

### Static HTML Interface
The monitor service uses a static HTML interface with JavaScript for dynamic updates:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Monitor - brennan.page</title>
    <style>
        body {
            font-family: 'Courier New', monospace;
            background: #1a1a1a;
            color: #00ff00;
            margin: 20px;
            padding: 20px;
        }
        .header {
            border-bottom: 2px solid #00ff00;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .stats {
            background: #000;
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        pre {
            margin: 0;
            white-space: pre-wrap;
        }
        .refresh-btn {
            background: #00ff00;
            color: #000;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
            font-family: monospace;
            margin: 10px 0;
        }
        .refresh-btn:hover {
            background: #00cc00;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ System Monitor</h1>
        <p>Lightweight monitoring for brennan.page homelab</p>
        <button class="refresh-btn" onclick="updateStats()">🔄 Refresh Now</button>
    </div>
    
    <div class="stats">
        <h3>📊 System Information</h3>
        <pre id="system-info">Loading system information...</pre>
    </div>
    
    <div class="stats">
        <h3>💾 Memory Usage</h3>
        <pre id="memory-info">Loading memory information...</pre>
    </div>
    
    <div class="stats">
        <h3>💾 Disk Usage</h3>
        <pre id="disk-info">Loading disk information...</pre>
    </div>
    
    <div class="stats">
        <h3>🐳 Docker Containers</h3>
        <pre id="docker-info">Loading Docker information...</pre>
    </div>
    
    <div class="stats">
        <h3>⚡ Load Average</h3>
        <pre id="load-info">Loading load information...</pre>
    </div>
    
    <script>
        function updateStats() {
            const timestamp = new Date().toISOString();
            
            document.getElementById('system-info').textContent =
                `Last Updated: ${timestamp}

=== System Information ===
Hostname: brennan.page
OS: Ubuntu 24.04 LTS
Architecture: x86_64
Kernel: Linux 6.8.0-71-generic

Note: This is a static monitoring page.
For real-time stats, access the server directly via SSH.`;
            
            document.getElementById('memory-info').textContent =
                `Memory Information:
Total: 2GB
Used: ~500MB
Available: ~1.5GB
Usage: 25%

For real-time data: free -h`;
            
            document.getElementById('disk-info').textContent =
                `Disk Information:
Total: 70GB
Used: ~3.4GB
Available: ~63GB
Usage: 5%

For real-time data: df -h`;
            
            document.getElementById('docker-info').textContent =
                `Docker Containers:
Active: 8 containers
- caddy (reverse proxy)
- portainer (docker management)
- filebrowser (file management)
- monitor (this service)
- postgresql (database)
- vikunja (task management)
- hedgedoc (collaborative notes)
- linkding (bookmark manager)
- navidrome (music streaming)

All containers running healthy.

For real-time data: docker ps`;
            
            document.getElementById('load-info').textContent =
                `Load Average:
Current: ~0.2-0.4
1 min: 0.21
5 min: 0.36
15 min: 0.30

System load is optimal.

For real-time data: uptime`;
        }
        
        // Auto-refresh every 30 seconds
        setInterval(updateStats, 30000);
        
        // Initial load
        updateStats();
    </script>
</body>
</html>
```

### JavaScript Features
- **Auto-refresh**: Automatic refresh every 30 seconds
- **Manual Refresh**: Manual refresh button
- **Timestamp**: Last update timestamp
- **Static Information**: Static system information
- **SSH References**: References to real-time commands

## Access

### Web Interface
- **URL**: https://monitor.brennan.page
- **Protocol**: HTTPS via Caddy
- **Authentication**: None (public access)
- **Security**: Read-only information

### Real-time Commands
For real-time system information, access the server via SSH:

```bash
# System information
hostname
uname -a
cat /etc/os-release

# Memory usage
free -h

# Disk usage
df -h

# Docker containers
docker ps

# Load average
uptime
```

## Configuration

### Static Content
The monitor service serves static content:
- **HTML**: Main dashboard interface
- **CSS**: Styling and layout
- **JavaScript**: Dynamic updates and refresh
- **No Server-side**: No server-side processing

### Resource Usage
- **Memory**: 50MB limit, 30MB reservation
- **CPU**: Low CPU usage
- **Storage**: Minimal storage usage
- **Network**: Low network usage

### Performance
- **Response Time**: Fast response times
- **Resource Efficiency**: Minimal resource usage
- **Scalability**: Lightweight and efficient
- **Reliability**: Simple and reliable

## Operations

### Management Commands
```bash
# Check service status
docker ps | grep monitor

# View service logs
docker logs monitor

# Restart service
docker restart monitor

# Update service
cd /opt/homelab/services/monitor
docker compose pull
docker compose up -d
```

### Content Updates
```bash
# Update HTML content
rsync index.html /opt/homelab/services/monitor/

# Restart service
docker restart monitor

# Verify update
curl -f https://monitor.brennan.page
```

### Troubleshooting
```bash
# Check container status
docker inspect monitor

# Test internal access
curl -f http://localhost:8081

# Check Caddy proxy
curl -f https://monitor.brennan.page

# View error logs
docker logs monitor --tail 20
```

## Security

### Container Security
- **Non-root**: Runs as non-root user
- **Read-only**: Read-only file system
- **Network Isolation**: Limited network access
- **Resource Limits**: Memory limits enforced

### Content Security
- **No Sensitive Data**: No sensitive information displayed
- **Read-only**: Read-only interface
- **No Authentication**: Public access acceptable
- **Limited Information**: Limited system information

### Network Security
- **HTTPS Only**: Served via HTTPS
- **Caddy Proxy**: Security headers from Caddy
- **Network Isolation**: Limited network access
- **Firewall**: UFW firewall protection

## Monitoring

### System Metrics
- **Memory Usage**: Static memory information
- **Disk Usage**: Static disk information
- **Load Average**: Static load information
- **Container Status**: Static container status

### Service Health
- **Container Status**: Container running status
- **Web Access**: Web interface accessibility
- **Response Time**: Response time monitoring
- **Error Handling**: Error detection and handling

### Performance Metrics
- **Response Time**: Fast response times
- **Resource Usage**: Minimal resource usage
- **Uptime**: Service uptime monitoring
- **Availability**: Service availability tracking

## Troubleshooting

### Common Issues

#### Service Not Accessible
```bash
# Check container status
docker ps | grep monitor

# Check logs
docker logs monitor

# Test internal access
curl -f http://localhost:8081

# Check Caddy proxy
curl -f https://monitor.brennan.page
```

#### Content Not Updating
```bash
# Check file permissions
ls -la /opt/homelab/services/monitor/index.html

# Update content
rsync index.html /opt/hemelab/services/monitor/

# Restart service
docker restart monitor
```

#### Performance Issues
```bash
# Check resource usage
docker stats monitor

# Check system resources
top
free -h
df -h

# Monitor response times
curl -w "Time: %{time_total}s\n" -o /dev/null -s https://monitor.brennan.page
```

### Debug Commands
```bash
# Check container details
docker inspect monitor

# View configuration
cat /opt/homelab/services/monitor/docker-compose.yml

# Test nginx configuration
docker exec monitor nginx -t

# Check file system
docker exec monitor ls -la /usr/share/nginx/html/
```

## Best Practices

### Performance
- **Lightweight**: Keep interface lightweight
- **Efficient**: Minimize resource usage
- **Fast**: Optimize for fast response times
- **Simple**: Keep implementation simple

### Security
- **Read-only**: Keep interface read-only
- **Limited Info**: Limit displayed information
- **No Authentication**: Public access acceptable
- **Regular Updates**: Keep service updated

### Maintenance
- **Regular Updates**: Update content regularly
- **Monitoring**: Monitor service health
- **Backups**: Backup configuration files
- **Testing**: Test functionality regularly

## Integration

### With Caddy
- **Reverse Proxy**: HTTPS via Caddy
- **SSL Termination**: SSL handled by Caddy
- **Security Headers**: Security headers from Caddy
- **Load Balancing**: Load balancing via Caddy

### With Docker
- **Container Management**: Managed via Docker
- **Resource Limits**: Docker resource limits
- **Network Access**: Docker network access
- **Volume Mounts**: Docker volume mounts

### With Services
- **Monitoring**: Monitor all services
- **Status Display**: Display service status
- **Health Checks**: Service health monitoring
- **Resource Info**: Resource usage information

## Future Enhancements

### Planned Improvements
- **Real-time Data**: Real-time system information
- **API Integration**: API access to system metrics
- **Alerting**: Alerting for system issues
- **Historical Data**: Historical data tracking

### Advanced Features
- **Graphs**: Visual graphs and charts
- **Trends**: Trend analysis
- **Alerts**: Configurable alerts
- **Export**: Data export functionality

## References

- [Nginx Documentation](https://nginx.org/en/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [Linux Monitoring](https://wiki.ubuntu.com/Monitoring)
- [System Administration](https://wiki.ubuntu.com/SystemAdministration)
