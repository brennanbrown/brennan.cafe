# SSL Certificate Issues

This guide covers common SSL/TLS issues and their solutions for brennan.page infrastructure.

## 🔧 Common SSL Issues

### SSL_ERROR_INTERNAL_ERROR_ALERT

**Symptoms**: Browser shows "SSL_ERROR_INTERNAL_ERROR_ALERT" when accessing HTTPS sites

**Root Cause**: Outdated or incorrect Caddyfile configuration on the server

**Solution**:
```bash
# 1. Check current Caddyfile on server
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker exec caddy cat /etc/caddy/Caddyfile
"

# 2. Compare with local repository
diff ./caddy/Caddyfile <(ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "docker exec caddy cat /etc/caddy/Caddyfile")

# 3. Upload correct configuration if different
scp -i ~/.omg-lol-keys/id_ed25519 ./caddy/Caddyfile root@159.203.44.169:/opt/homelab/caddy/Caddyfile

# 4. Reload Caddy configuration
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/caddy
  docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
"

# 5. Verify the fix
curl -I https://brennan.page
```

### Certificate Not Found

**Symptoms**: Site loads but shows invalid or self-signed certificate

**Solution**:
```bash
# Check certificate status
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker exec caddy ls -la /data/caddy/certificates/acme-v02.api.letsencrypt.org-directory/
"

# Force certificate renewal if needed
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/caddy
  docker compose restart caddy
"
```

### Mixed Content Errors

**Symptoms**: HTTPS site loads but some resources are blocked

**Solution**: Ensure all URLs in HTML/CSS/JS use HTTPS protocol

## 🚨 Prevention Checklist

### Before Making Caddyfile Changes

1. **Always validate locally first**:
   ```bash
   cd caddy
   docker compose config
   ```

2. **Test syntax**:
   ```bash
   docker compose exec caddy caddy validate --config /etc/caddy/Caddyfile
   ```

3. **Backup current configuration**:
   ```bash
   scp -i ~/.omg-lol-keys/id_ed25519 root@159.203.44.169:/opt/homelab/caddy/Caddyfile ./Caddyfile.backup
   ```

### After Deploying Changes

1. **Reload Caddy gracefully**:
   ```bash
   ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
     cd /opt/homelab/caddy
     docker compose exec caddy caddy reload --config /etc/caddy/Caddyfile
   "
   ```

2. **Verify all domains**:
   ```bash
   # Test critical domains
   curl -I https://brennan.page
   curl -I https://wiki.brennan.page
   curl -I https://docker.brennan.page
   ```

3. **Check certificate status**:
   ```bash
   ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
     docker logs caddy --tail 10 | grep -i 'certificate\|tls\|ssl'
   "
   ```

## 🔍 Diagnostic Commands

### Quick SSL Health Check

```bash
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  echo '=== Caddy Status ==='
  docker compose ps caddy
  
  echo -e '\n=== Certificate Status ==='
  docker exec caddy find /data -name '*.crt' | wc -l
  
  echo -e '\n=== Recent SSL Logs ==='
  docker logs caddy 2>&1 | grep -i 'certificate\|tls\|ssl' | tail -5
  
  echo -e '\n=== Domain Resolution ==='
  nslookup brennan.page
"
```

### Detailed Certificate Inspection

```bash
# Check specific certificate details
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker exec caddy openssl x509 -in /data/caddy/certificates/acme-v02.api.letsencrypt.org-directory/brennan.page/brennan.page.crt -text -noout | grep -E 'Subject:|Not Before:|Not After:'
"
```

## 📋 Monitoring SSL Certificates

### Certificate Expiry Monitoring

```bash
# Check all certificate expiry dates
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  for cert in \$(docker exec caddy find /data -name '*.crt'); do
    echo \"=== \$(basename \$cert) ===\"
    docker exec caddy openssl x509 -in \$cert -noout -dates
    echo
  done
"
```

### Automated Health Check Script

Create `scripts/ssl-health-check.sh`:
```bash
#!/bin/bash
# SSL Certificate Health Check

echo "=== SSL Certificate Health Check ==="
echo "Date: $(date)"
echo

# Check critical domains
domains=("brennan.page" "wiki.brennan.page" "docker.brennan.page")

for domain in "${domains[@]}"; do
  echo "Checking $domain..."
  if curl -s --connect-timeout 5 "https://$domain" > /dev/null; then
    echo "✅ $domain - OK"
  else
    echo "❌ $domain - FAILED"
  fi
  echo
done
```

## 🆘 Emergency Recovery

### Complete SSL Reset

If all SSL certificates are corrupted:

```bash
# 1. Stop Caddy
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/caddy
  docker compose stop caddy
"

# 2. Clear certificate storage
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  docker volume rm caddy_caddy_data
  docker volume create caddy_caddy_data
"

# 3. Restart Caddy
ssh -i ~/.omg-lol-keys/id_ed25519 -T -o BatchMode=yes root@159.203.44.169 "
  cd /opt/homelab/caddy
  docker compose up -d caddy
"

# 4. Verify new certificates
sleep 30
curl -I https://brennan.page
```

## 📚 Related Documentation

- [SSH Commands Reference](../reference/ssh-commands.md)
- [Caddy Service Configuration](../services/caddy.md)
- [Deployment Guide](../operations/deployment.md)
- [Network Issues](network-issues.md)

---

**Last Updated**: 2026-01-20  
**Severity**: High  
**Impact**: Site accessibility
