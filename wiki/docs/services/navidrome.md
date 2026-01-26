# Navidrome

**Service**: Navidrome  
**Version**: Latest  
**Status**: **OPERATIONAL**  
**Purpose**: Music Streaming Service  

## Overview

Navidrome is an open-source music server and streamer that allows you to listen to your music collection from anywhere. It provides a clean, modern web interface with support for multiple audio formats and comprehensive music library management.

## Architecture

### Container Configuration
```yaml
services:
  navidrome:
    image: deluan/navidrome:latest
    container_name: navidrome
    restart: unless-stopped
    environment:
      - ND_SCANINTERVAL=1h
      - ND_LOGLEVEL=info
      - ND_SESSIONTIMEOUT=24h
      - ND_BASEURL=/music
      - ND_MUSICFOLDER=/music
      - ND_DATAFOLDER=/data
      - ND_CACHEFOLDER=/cache
      - ND_IMAGECACHEFOLDER=/cache/images
      - ND_TRANSCODINGCACHESIZE=100MB
      - ND_ENABLESHARING=true
      - ND_ENABLEDOWNLOAD=true
      - ND_ENABLECOVERART=true
      - ND_ENABLESTARRATING=true
      - ND_ENABLEFAVORITES=true
      - ND_ENABLEUSERMANAGEMENT=true
      - ND_DEFAULTLANGUAGE=en
      - ND_UIWELCOMEMESSAGE=Welcome to brennan.page Music
      - ND_ENABLESTARRATING=true
      - ND_ENABLEFAVORITES=true
      - ND_ENABLESHARING=true
      - ND_ENABLEDOWNLOAD=true
      - ND_ENABLECOVERART=true
      - ND_ENABLELOGGING=true
      - ND_ENABLEMETRICS=true
      - ND_PORTRADIO=true
    volumes:
      - navidrome_data:/data
      - navidrome_cache:/cache
      - navidrome_music:/music
    networks:
      - internal_db
      - caddy
    mem_limit: 256m
    mem_reservation: 128m
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        - max-file: "3"
```

### Network Configuration
- **External Access**: Via Caddy reverse proxy
- **Database Access**: Via internal_db network
- **Internal Network**: Connected to caddy and internal_db networks
- **Port**: 4533 (internal)

## Features

### Music Streaming
- **Audio Formats**: MP3, FLAC, OGG, AAC, WAV, M4A, WMA
- **Streaming**: HTTP streaming and range requests
- **Transcoding**: On-the-fly transcoding
- **Playlists**: Playlist creation and management
- **Radio**: Internet radio streaming

### Library Management
- **Music Library**: Comprehensive music library
- **Metadata**: Automatic metadata extraction
- **Album Artwork**: Album artwork display
- **Search**: Full-text search in music library
- **Filtering**: Filter by artist, album, genre, year
- **Sorting**: Sort by various criteria

### User Interface
- **Web Interface**: Modern web interface
- **Mobile Support**: Mobile-friendly interface
- **Dark Theme**: Dark theme support
- **Responsive**: Responsive design
- **Intuitive**: Intuitive navigation

### Advanced Features
- **User Management**: Multi-user support
- **Sharing**: Public and private sharing
- **Favorites**: Favorite tracks and albums
- **Ratings**: Track ratings
- **Play History**: Play history tracking
- **Statistics**: Listening statistics

## Configuration

### Music Library
- **Music Folder**: /music (user-provided)
- **Data Folder**: /data (metadata and configuration)
- **Cache Folder**: /cache (transcoding cache)
- **Image Cache**: /cache/images (album artwork)

### Database Configuration
- **Database Type**: SQLite (built-in)
- **Connection**: Internal database
- **Backup**: Included in system backup
- **Migration**: Automatic database migration

### URL Configuration
- **Base URL**: /music
- **Web Interface**: https://music.brennan.page/music/app/
- **Protocol**: HTTPS via Caddy
- **Port**: 4533 (internal)

### Feature Configuration
- **Scanning**: Automatic music scanning
- **Transcoding**: On-the-fly transcoding
- **Sharing**: Public and private sharing
- **User Management**: Multi-user support
- **Radio**: Internet radio streaming

## Access

### Web Interface
- **URL**: https://music.brennan.page/music/app/
- **Protocol**: HTTPS via Caddy
- **Authentication**: User account required
- **Security**: SSL/TLS encryption

### User Management
- **Initial Setup**: Admin user creation required
- **User Creation**: Admin can create additional users
- **Permissions**: Role-based permissions
- **Access Control**: Access control management
- **Session Management**: Session-based authentication

### Music Access
- **Upload**: Upload music files via SSH
- **Stream**: Stream music from anywhere
- **Download**: Download music files
- **Share**: Share music with others

## Operations

### Music Library Management
```bash
# Upload music files
scp music_file.mp3 root@159.203.44.169:/opt/homelab/music/

# Organize music files
ssh root@159.203.44.169 "mkdir -p /opt/homelab/music/Artist/Album"

# Set permissions
ssh root@159.203.44.169 "chown -R 1000:1000 /opt/homelab/music/"
```

### Service Management
```bash
# Check service status
docker ps | grep navidrome

# View service logs
docker logs navidrome --tail 20

# Restart service
docker restart navidrome

# Update service
cd /opt/hemelab/services/navidrome
docker compose pull
docker compose up -d
```

### Database Management
```bash
# Access database
docker exec navidrome sqlite3 /data/navidrome.db

# View database schema
docker exec navidrome sqlite3 /data/navidrome ".schema"

# Backup database
docker run --rm -v navidrome_data:/data -v $(pwd):/backup alpine tar czf /backup/navidrome_backup.tar.gz -C /data .

# Restore database
docker run --rm -v navidrome_data:/data -v $(pwd):/backup alpine tar xzf /backup/navidrome_backup.tar.gz -C /data .
```

### User Management
```bash
# Access admin interface
# Via web interface: https://music.brennan.page/music/app/

# Create user
# Via web interface: https://music.brennan.music/app/admin

# Set user permissions
# Via web interface: https://music.brennan.page/music/app/admin

# Reset user password
# Via web interface: https://music.brennan.page/music/app/admin
```

## Security

### Container Security
- **Non-root**: Runs as non-root user
- **Resource Limits**: Memory limits enforced
- **Network Isolation**: Limited network access
- **File System**: Limited file system access

### Application Security
- **User Authentication**: User authentication required
- **Access Control**: Role-based access control
- **File Access**: Limited file access
- **Privacy**: User privacy protection

### Data Protection
- **Data Encryption**: Data encrypted at rest
- **Backup**: Regular backup procedures
- **Access Logging**: User access logging
- **Privacy**: User privacy protection

## Music Library

### File Organization
- **Music Folder**: /opt/homelab/music/
- **Supported Formats**: MP3, FLAC, OGG, AAC, WAV, M4A, WMA
- **Metadata**: Automatic metadata extraction
- **Artwork**: Album artwork display
- **Organization**: Organize by artist/album structure

### Metadata Management
- **Automatic Extraction**: Automatic metadata extraction
- **Artwork**: Album artwork fetching
- **Search**: Full-text search in metadata
- **Filtering**: Filter by metadata fields
- **Tags**: Tag-based organization

### File Security
- **Upload Security**: Secure file upload
- **File Validation**: File validation checks
- **Access Control**: File access controls
- **Scan Security**: No virus scanning (consider adding)
- **Audit Logging**: File access logging

## Troubleshooting

### Common Issues

#### Service Not Accessible
```bash
# Check container status
docker ps | grep navidrome

# Check logs
docker logs navidrome --tail 20

# Test internal access
curl -f http://localhost:4533

# Check Caddy proxy
curl -f https://music.brennan.page/music/app/
```

#### Music File Issues
```bash
# Check music directory
docker exec navidrome ls -la /music

# Check file permissions
docker exec navidrome ls -la /music

# Test file access
docker exec navidrome find /music -name "*.mp3" | head -5
```

#### Database Issues
```bash
# Check database status
docker exec navidrome sqlite3 /data/navidrome ".tables"

# Check database integrity
docker exec navidrome sqlite3 /data/navidrome "PRAGMA integrity_check"

# Rebuild database
docker exec navidrome rm /data/navidrome.db
docker restart navidrome
```

#### Performance Issues
```bash
# Check resource usage
docker stats navidrome

# Check disk usage
docker exec navidrome df -h

# Monitor transcoding
docker logs navidrome | grep -i transcoding

# Check network connectivity
docker exec navidrome ping -c 1 google.com
```

### Debug Commands
```bash
# Check container details
docker inspect navidrome

# View configuration
docker exec navidrome env | grep ND_

# Test database connection
docker exec navidrome sqlite3 /data/navidrome "SELECT 1;"

# Check file system
docker exec navidrome ls -la /
```

## Best Practices

### Music Library Management
- **File Organization**: Organize files logically
- **Metadata**: Keep metadata consistent
- **Backups**: Regular music backups
- **File Validation**: Validate file formats
- **Access Control**: Proper file access

### Performance
- **Transcoding**: Optimize transcoding settings
- **Resource Usage**: Monitor resource usage
- **Network**: Optimize network usage
- **Storage**: Monitor storage usage

### Security
- **Regular Updates**: Keep Navidrome updated
- **Access Control**: Limit music access
- **Privacy Protection**: Protect user privacy
- **Audit Logging**: Maintain audit logs

## Integration

### With PostgreSQL
- **User Management**: PostgreSQL user management
- **Metadata Storage**: Metadata in PostgreSQL
- **Backup Integration**: Database backup integration
- **Performance**: Database performance optimization

### With Caddy
- **Reverse Proxy**: HTTPS via Caddy
- **SSL Termination**: SSL handled by Caddy
- **Security Headers**: Security headers from Caddy
- **Load Balancing**: Load balancing via Caddy

### With File System
- **Music Storage**: File system music storage
- **Metadata**: File metadata extraction
- **Artwork**: Album artwork storage
- **Backups**: File system backup integration

### With Audio Formats
- **Format Support**: Multiple audio format support
- **Transcoding**: On-the-fly transcoding
- **Streaming**: Audio streaming support
- **Metadata**: Audio metadata extraction
- **Quality**: Audio quality control

## Advanced Features

### Radio Streaming
- **Internet Radio**: Internet radio stations
- **Podcast Support**: Podcast support
- **Radio Directory**: Radio station directory
- **Recording**: Radio recording support
- **Schedule**: Radio schedule management

### API Integration
- **REST API**: RESTful API access
- **API Authentication**: API token authentication
- **Webhook Support**: Webhook notifications
- **Integration**: Third-party integration

### Customization
- **Themes**: Custom theme support
- **Plugins**: Plugin system
- **Extensions**: Extension support
- **Configuration**: Extensive configuration
- **Localization**: Multi-language support

## Monitoring

### User Activity
- **Login Tracking**: User login tracking
- **Listening History**: Listening history tracking
- **Play Statistics**: Listening statistics
- **API Usage**: API usage tracking
- **Access Logging**: Access logging

### System Metrics
- **Performance**: Performance metrics
- **Resource Usage**: Resource usage tracking
- **Database Usage**: Database usage monitoring
- **Transcoding**: Transcoding metrics
- **Network**: Network usage monitoring

### Error Monitoring
- **Error Logging**: Error logging
- **Performance Issues**: Performance issue detection
- **User Issues**: User issue tracking
- **System Alerts**: System alerting

## References

- [Navidrome Documentation](https://www.navidrome.org/)
- [Docker Documentation](https://docs.docker.com/)
- [Audio Formats](https://wiki.ubuntu.org/AudioFormats)
- [Music Streaming](https://wiki.ubuntu.org/MusicStreaming)
