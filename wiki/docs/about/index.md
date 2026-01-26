# About brennan.page

brennan.page is a self-hosted homelab project showcasing backend/cloud development skills while providing personal productivity tools and community-building features.

## Project Overview

### Purpose

The brennan.page homelab demonstrates:
- **Infrastructure as Code**: All configurations tracked in Git
- **Local-First Development**: Changes authored and tested locally
- **Container Orchestration**: Docker-based service deployment
- **Resource Optimization**: Efficient use of limited resources
- **Security Best Practices**: Secure, monitored, and maintained infrastructure

### Architecture

The homelab runs on a DigitalOcean droplet with:
- **Hardware**: 2GB RAM, 1 CPU, 70GB SSD
- **OS**: Ubuntu 24.04 LTS
- **Domain**: brennan.page with automated DNS
- **SSL**: Automatic HTTPS via Let's Encrypt

### Design Principles

- **Minimal Viable**: Start with essential services, expand as needed
- **Resource Conscious**: Optimize for 2GB RAM limit
- **Secure by Default**: Implement security from the ground up
- **Documented**: Comprehensive documentation for all components
- **Maintainable**: Clean, reproducible configurations

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

## Technology Stack

### Core Technologies
- **Containerization**: Docker & Docker Compose
- **Reverse Proxy**: Caddy with automatic HTTPS
- **Database**: PostgreSQL & MariaDB
- **Documentation**: MkDocs with Material theme
- **Monitoring**: Custom monitoring solution

### Development Tools
- **Version Control**: Git
- **Text Editor**: VS Code, micro
- **Shell**: Zsh with custom configurations
- **SSH**: Secure remote access

### Security
- **Firewall**: UFW with minimal open ports
- **Intrusion Prevention**: Fail2Ban for SSH protection
- **Authentication**: SSH key-based authentication
- **SSL/TLS**: Automatic certificate management

## Resource Management

### Memory Allocation
- **Total Available**: 2GB RAM
- **Allocated**: ~1.3GB (65%)
- **Swap**: 4GB configured for burst capacity
- **Monitoring**: Continuous resource tracking

### Storage Usage
- **Total Disk**: 70GB SSD
- **Used**: ~13GB (19%)
- **Available**: ~57GB
- **Backups**: Regular automated backups

### Network Configuration
- **External**: Only ports 80, 443, 22, 2222 exposed
- **Internal**: Isolated Docker networks
- **DNS**: brennan.page with subdomains
- **SSL**: Wildcard certificate for all subdomains

## Development Workflow

### Local Development
1. **Clone Repository**: `git clone https://github.com/brennanbrown/brennan.page.git`
2. **Make Changes**: Edit configuration files locally
3. **Test Locally**: Use Docker for testing when possible
4. **Version Control**: Commit with descriptive messages
5. **Deploy**: Use deployment scripts for server sync

### Deployment Process
1. **Local Testing**: Verify configurations locally
2. **Server Sync**: Use rsync to transfer files
3. **Service Restart**: Restart affected services
4. **Verification**: Test functionality
5. **Documentation**: Update documentation

### Documentation
- **Wiki**: MkDocs-based documentation site
- **Service Docs**: Individual service documentation
- **Operations**: Procedures and maintenance
- **Troubleshooting**: Common issues and solutions

## Security Posture

### Network Security
- **Firewall**: UFW with minimal open ports
- **SSL/TLS**: All web services use HTTPS
- **DNS**: Secure DNS configuration
- **Monitoring**: Continuous security monitoring

### Application Security
- **Container Security**: Non-root processes, resource limits
- **Database Security**: Isolated users, encrypted connections
- **Authentication**: SSH key-based, service-specific auth
- **Access Control**: Principle of least privilege

### Operational Security
- **Backups**: Regular automated backups
- **Updates**: Regular security updates
- **Monitoring**: Log monitoring and alerting
- **Auditing**: Regular security audits

## Performance

### Response Times
- **Target**: <200ms for all services
- **Achieved**: Sub-100ms average
- **Monitoring**: Continuous performance tracking
- **Optimization**: Regular performance tuning

### Resource Efficiency
- **Memory**: Optimized for 2GB limit
- **CPU**: Shared across all services
- **Storage**: Efficient storage usage
- **Network**: Optimized network configuration

### Scalability
- **Horizontal**: Easy service addition
- **Vertical**: Resource limit adjustments
- **Monitoring**: Capacity planning
- **Backup**: Disaster recovery procedures

## Monitoring and Observability

### System Monitoring
- **Dashboard**: Custom monitoring interface
- **Metrics**: CPU, memory, disk, network
- **Alerts**: Automated alerting for critical issues
- **Logs**: Centralized log collection

### Service Monitoring
- **Health Checks**: Service health monitoring
- **Performance**: Response time tracking
- **Availability**: Uptime monitoring
- **Resource Usage**: Per-service resource tracking

### Documentation Monitoring
- **Wiki**: Documentation site monitoring
- **Version Control**: Git repository monitoring
- **Changes**: Change tracking and logging
- **Accuracy**: Regular documentation reviews

## Community and Collaboration

### Open Source
- **Repository**: Public GitHub repository
- **Documentation**: Comprehensive documentation
- **Configuration**: All configurations in Git
- **Best Practices**: Following industry standards

### Knowledge Sharing
- **Wiki**: Detailed documentation and guides
- **Blog**: Technical articles and tutorials
- **Forum**: Community discussion and support
- **RSS**: Content aggregation and sharing

### Contributions
- **Issues**: Bug reports and feature requests
- **Pull Requests**: Code contributions
- **Discussions**: Community discussions
- **Feedback**: User feedback and suggestions

## Future Plans

### Phase 5: Utilities
- **Plik**: Temporary file sharing service
- **Rallly**: Meeting and poll scheduling
- **Service Integrations**: Cross-service functionality

### Long-term Goals
- **Unified Authentication**: SSO/LDAP integration
- **Advanced Monitoring**: Enhanced alerting and metrics
- **Performance Optimization**: Continuous optimization
- **Security Enhancements**: Ongoing security improvements

### Expansion Opportunities
- **Additional Services**: Based on needs and resources
- **Performance Scaling**: Resource scaling as needed
- **Feature Development**: New features and capabilities
- **Community Growth**: Community engagement and growth

## Contact and Support

### Getting Help
- **Documentation**: Start with the wiki documentation
- **Troubleshooting**: Check troubleshooting guides
- **Community**: Join forum discussions
- **Issues**: Report issues on GitHub

### Communication
- **Blog**: Read technical articles and updates
- **Forum**: Join community discussions
- **RSS**: Subscribe to RSS feed
- **Wiki**: Comprehensive documentation

### Social
- **GitHub**: Follow on GitHub for updates
- **Forum**: Join the community forum
- **Blog**: Subscribe to the blog
- **RSS**: Add RSS feed to reader

---

*Last updated: {{ git_revision_date_localized }}*
