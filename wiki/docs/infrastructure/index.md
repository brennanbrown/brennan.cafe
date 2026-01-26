# Infrastructure

This section covers the foundational infrastructure components that power the brennan.page homelab.

## Components

### [Docker](docker.md)
Container runtime and orchestration platform that hosts all services.

### [Networking](networking.md)
Network configuration, Docker networks, and connectivity.

### [Security](security.md)
Security measures including firewall, SSH, and access controls.

### [Storage](storage.md)
Storage management, volumes, and data persistence.

## Architecture Overview

The brennan.page homelab runs on a DigitalOcean droplet with the following specifications:

- **Server**: DigitalOcean 2GB RAM, 1 vCPU, 70GB SSD
- **OS**: Ubuntu 24.04 LTS
- **Container Runtime**: Docker with Docker Compose
- **Reverse Proxy**: Caddy with automatic HTTPS
- **Database**: PostgreSQL for service data

## Key Concepts

### Container Orchestration
All services run in Docker containers with proper resource limits and networking isolation.

### Network Segmentation
Services are organized into logical networks:
- `caddy`: External web access
- `internal_db`: Database communication
- `monitoring`: Service monitoring

### Resource Management
Memory limits and reservations are enforced to prevent resource contention.

### Security Layers
Multiple security layers including firewall, SSH key authentication, and container isolation.

## Infrastructure Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    brennan.page Homelab                    │
├─────────────────────────────────────────────────────────────┤
│  Internet                                                     │
│       │                                                       │
│  ┌────▼────┐                                                │
│  │  Caddy   │  ← Reverse Proxy with SSL                      │
│  └────┬────┘                                                │
│       │                                                       │
│  ┌────▼────┐  ┌───────┐  ┌─────────┐  ┌─────────┐        │
│  │Portainer│  │Vikunja│  │HedgeDoc │  │Linkding │        │
│  └─────────┘  └───────┘  └─────────┘  └─────────┘        │
│       │           │           │           │                │
│  ┌────▼────┐  ┌───────┐  ┌─────────┐  ┌─────────┐        │
│  │Monitor  │  │Navidrome││FileBrowser│  │Wiki     │        │
│  └─────────┘  └───────┘  └─────────┘  └─────────┘        │
│       │           │           │           │                │
│  ┌────▼───────────────────────────────────────────────────┐ │
│  │                PostgreSQL Database                        │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Best Practices

### Resource Allocation
- Each service has defined memory limits
- Critical services get higher priority
- Resource usage is monitored continuously

### Security
- All services run as non-root users
- Network isolation between services
- Regular security updates and monitoring

### Backup Strategy
- Database backups automated
- Configuration files version controlled
- Critical data replicated across multiple services

### Monitoring
- System resources monitored
- Service health checks
- Automated alerting for critical issues

## Getting Started

1. Review the [Docker](docker.md) setup
2. Understand the [Networking](networking.md) configuration
3. Follow [Security](security.md) best practices
4. Learn about [Storage](storage.md) management

## Related Topics

- [Services](../services/) - Individual service documentation
- [Configuration](../configuration/) - Configuration management
- [Operations](../operations/) - Operational procedures
