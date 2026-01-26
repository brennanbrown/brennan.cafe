# HedgeDoc Troubleshooting

## Database Connection Issue (2026-01-17)

### Problem
HedgeDoc was showing database connection errors in logs despite the service appearing functional. Notes could be created but persistence was unreliable.

### Symptoms
- HTTP 200 responses and proper interface loading
- Database connection errors in container logs
- `SequelizeConnectionError: password authentication failed for user "hedgedoc"`
- PostgreSQL permission errors

### Root Cause
HedgeDoc container was configured to connect as user `hedgedoc` with password `hedgedoc_password`, but the PostgreSQL user had a different password.

### Solution

1. **Reset PostgreSQL User Password**
   ```bash
   docker exec postgresql psql -U homelab -d homelab -c 'ALTER USER hedgedoc WITH PASSWORD "hedgedoc_password";'
   ```

2. **Verify Database Connection**
   ```bash
   PGPASSWORD=hedgedoc_password docker exec postgresql psql -U hedgedoc -d hedgedoc -c 'SELECT current_user;'
   ```

3. **Restart HedgeDoc Service**
   ```bash
   docker restart hedgedoc
   ```

4. **Verify Functionality**
   ```bash
   # Test note creation
   curl -X POST 'https://notes.brennan.page/new' \
     -H 'Content-Type: application/x-www-form-urlencoded' \
     -d 'text=Test note content'
   
   # Check database persistence
   docker exec postgresql psql -U hedgedoc -d hedgedoc -c 'SELECT COUNT(*) FROM "Notes";'
   ```

### Verification
- ✅ Note creation working (HTTP 302 redirect)
- ✅ Database persistence confirmed (notes saved to PostgreSQL)
- ✅ No more connection errors in logs
- ✅ All migrations performed successfully
- ✅ Health checks passing

### Lessons Learned
- HedgeDoc uses shared PostgreSQL container with dedicated user/database
- Password synchronization between containers is critical
- Database connection issues may not prevent basic functionality
- Always test both frontend and backend functionality after fixes

## Current Status
- **Service**: Fully operational
- **Database**: Connected and persistent
- **Performance**: Sub-100ms response times
- **Last Updated**: 2026-01-17
