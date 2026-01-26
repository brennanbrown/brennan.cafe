# Basic Server Information

## Server Specifications
- **Provider**: DigitalOcean
- **Hostname**: page
- **Region**: TOR1 (Toronto)
- **OS**: Ubuntu 24.04 LTS x64
- **CPU**: 1 vCPU Intel
- **RAM**: 2 GB
- **Disk**: 70 GB SSD
- **Created**: 2026-01-16
- **Credits Expire**: ~January 2027

## Network Configuration
### IPv4
- **Public IP**: 159.203.44.169
- **Gateway**: 159.203.32.1
- **Subnet Mask**: 255.255.240.0
- **Reserved IP**: 209.38.12.120

### IPv6
- **Public IP**: 2604:a880:cad:d0:0:1:3fc5:3001
- **Gateway**: 2604:a880:cad:d0::1
- **Address Range**: 2604:a880:cad:d0:0:1:3fc5:3000 - 2604:a880:cad:d0:0:1:3fc5:300f

## Access Information
### SSH
- **Primary User**: root (initial)
- **Non-root User**: brennan [to be created]
- **SSH Key Location**: ~/.omg-lol-keys/id_ed25519
- **SSH Ports**: 22 (primary), 2222 (backup - to be configured)
- **Connection Command**: `ssh -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169`
- **Key Fingerprint**: [run: ssh-keygen -lf ~/.omg-lol-keys/id_ed25519.pub]

## Domain Information
- **Domain**: brennan.page
- **Registrar**: Porkbun
- **Nameservers**: ns1.porkbun.com, ns2.porkbun.com
- **Renewal Date**: 2027-01-16

### DNS Records (to be configured)
```
A       brennan.page        → 159.203.44.169
AAAA    brennan.page        → 2604:a880:cad:d0:0:1:3fc5:3001
A       *.brennan.page      → 159.203.44.169
AAAA    *.brennan.page      → 2604:a880:cad:d0:0:1:3fc5:3001
```

## Security
- **UFW Status**: [to be configured]
- **Fail2ban Status**: [to be installed]
- **SSH Key Auth**: Enabled
- **Password Auth**: [to be disabled]
- **Root Login**: [to be disabled after non-root user created]

## Storage
- **Filesystem**: [check with: df -T]
- **Initial Free Space**: ~70 GB
- **Swap**: [to be configured - 4GB]

## Credentials & Secrets
- **Password Storage**: /opt/homelab/shared/passwords/ (gitignored)
- **Environment Files**: .env files per service (gitignored)
- **DO API Token**: [if generated]

## Backup Configuration
- **Local Backups**: /opt/homelab/backups/data/
- **DO Snapshots**: disabled
- **Snapshot Schedule**: N/A
- **Last Backup**: [to be tracked]

## Maintenance
- **Timezone**: [check with: timedatectl]
- **Last OS Update**: [track with each update]
- **Uptime Since**: [track after each reboot]

## Notes
- GitHub Student Developer Pack credit: $200/year
- Cost: $16/month
- Expected runtime: ~12 months until credit exhaustion