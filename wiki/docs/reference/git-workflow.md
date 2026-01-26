# Git Workflow

This reference covers the Git workflow used for managing the brennan.page homelab infrastructure.

## Repository Structure

### Local Repository

```text
brennan.page/
├── .git/                 # Git metadata
├── .gitignore           # Files to ignore
├── README.md             # Project overview
├── CHANGELOG.md          # Change history
├── TODO.md              # Task list
├── caddy/               # Reverse proxy configuration
├── services/            # Service configurations
├── scripts/             # Management scripts
├── wiki/                # Documentation source
├── docs/                # Project documentation
└── favicon/             # Site assets
```

### Remote Repository

```bash
# Remote origin
origin: https://github.com/brennanbrown/brennan.page.git

# Main branch
main: Production-ready code
```

## Basic Git Commands

### Repository Operations

```bash
# Initialize repository
git init

# Clone repository
git clone https://github.com/brennanbrown/brennan.page.git

# Add remote repository
git remote add origin https://github.com/brennanbrown/brennan.page.git

# Check remote repositories
git remote -v

# Check repository status
git status
```

### File Operations

```bash
# Add files to staging
git add file.txt

# Add all files
git add .

# Add specific directory
git add services/

# Remove file from repository
git rm file.txt

# Remove file but keep locally
git rm --cached file.txt

# Move/rename file
git mv old_name.txt new_name.txt
```

### Commit Operations

```bash
# Commit with message
git commit -m "Add new service configuration"

# Commit with detailed message
git commit -m "Add Vikunja task management

- Added docker-compose.yml
- Configured environment variables
- Set up database connection
- Added service documentation"

# Commit all changes
git commit -am "Quick commit message"

# Amend last commit
git commit --amend -m "Updated commit message"
```

### Branch Operations

```bash
# List branches
git branch

# Create new branch
git branch feature/new-service

# Switch to branch
git checkout feature/new-service

# Create and switch to branch
git checkout -b feature/new-service

# Merge branch
git merge feature/new-service

# Delete branch
git branch -d feature/new-service

# Force delete branch
git branch -D feature/new-service
```

### Remote Operations

```bash
# Push to remote
git push origin main

# Push new branch
git push -u origin feature/new-service

# Pull from remote
git pull origin main

# Fetch from remote
git fetch origin

# Pull with rebase
git pull --rebase origin main
```

## Homelab Workflow

### Development Workflow

```bash
# 1. Update local repository
git pull origin main

# 2. Create feature branch
git checkout -b feature/add-new-service

# 3. Make changes
# Edit files, add configurations, etc.

# 4. Stage changes
git add services/new-service/
git add wiki/docs/services/new-service.md

# 5. Commit changes
git commit -m "Add new-service: Initial configuration

- Added docker-compose.yml
- Configured environment variables
- Set up database connection
- Added service documentation"

# 6. Push branch
git push -u origin feature/add-new-service

# 7. Merge to main
git checkout main
git merge feature/add-new-service

# 8. Push to main
git push origin main

# 9. Delete feature branch
git branch -d feature/add-new-service
git push origin --delete feature/add-new-service
```

### Deployment Workflow

```bash
# 1. Update local repository
git pull origin main

# 2. Deploy changes
./scripts/deploy-service.sh service_name

# 3. Test deployment
curl -I https://service.brennan.page

# 4. Update documentation
cd wiki
mkdocs build --clean
./deploy-wiki.sh

# 5. Commit deployment changes
git add .
git commit -m "Deploy service-name: Update configuration and documentation"
git push origin main
```

## Git Configuration

### User Configuration

```bash
# Set user name
git config --global user.name "Brennan Brown"

# Set user email
git config --global user.email "brennan@brennan.page"

# Set default editor
git config --global core.editor "nano"

# Set default branch name
git config --global init.defaultBranch main

# View configuration
git config --list
```

### Repository Configuration

```bash
# Set repository-specific user
git config user.name "Brennan Brown"
git config user.email "brennan@brennan.page"

# Set repository-specific editor
git config core.editor "nano"

# View repository configuration
git config --list
```

## .gitignore

### Homelab .gitignore

```gitignore
# Environment files
.env
.env.local
.env.production

# Passwords and secrets
passwords/
*.key
*.pem
*.crt

# Temporary files
*.tmp
*.log
.DS_Store

# Backup files
*.backup
*.bak

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS files
Thumbs.db
.DS_Store

# Docker volumes
data/
volumes/

# Node modules
node_modules/

# Python cache
__pycache__/
*.pyc
*.pyo

# Build artifacts
build/
dist/
site/

# Logs
logs/
*.log
```

## Branching Strategy

### Main Branch

```bash
main
├── Production-ready code
├── Stable and tested
└── Always deployable
```

### Feature Branches

```bash
feature/add-vikunja
feature/update-caddy-config
feature/fix-database-connection
feature/add-monitoring-dashboard
```

### Release Branches

```bash
release/v1.0.0
release/v1.1.0
release/v2.0.0
```

### Hotfix Branches

```bash
hotfix/critical-security-patch
hotfix/fix-database-leak
hotfix/resolve-ssl-issue
```

## Commit Messages

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

### Examples

```bash
# Feature commit
git commit -m "feat(services): Add Vikunja task management

- Added docker-compose.yml configuration
- Configured PostgreSQL database connection
- Set up environment variables
- Added service documentation"

# Bug fix commit
git commit -m "fix(caddy): Resolve SSL certificate renewal issue

- Updated Caddyfile configuration
- Fixed certificate path
- Added automatic renewal"

# Documentation commit
git commit -m "docs(wiki): Update service documentation

- Added Vikunja service page
- Updated services index
- Fixed broken links"
```

## History and Log

### Viewing History

```bash
# View commit history
git log

# View commit history with graph
git log --graph --oneline

# View commit history for specific file
git log --oneline services/vikunja/docker-compose.yml

# View commit details
git show <commit-hash>

# View file changes
git show <commit-hash>:services/vikunja/docker-compose.yml
```

### Searching History

```bash
# Search commits by message
git log --grep="Vikunja"

# Search commits by author
git log --author="Brennan Brown"

# Search commits by date
git log --since="2026-01-01"

# Search commits by content
git log -p -S "database"
```

## Diff and Changes

### Viewing Differences

```bash
# View unstaged changes
git diff

# View staged changes
git diff --staged

# View changes between commits
git diff HEAD~1 HEAD

# View changes for specific file
git diff services/vikunja/docker-compose.yml

# View changes with statistics
git diff --stat
```

### Applying Changes

```bash
# Apply patch
git apply patch-file.patch

# Apply patch with commit
git am < patch-file.patch

# Cherry-pick commit
git cherry-pick <commit-hash>

# Revert commit
git revert <commit-hash>
```

## Stashing

### Stash Operations

```bash
# Stash current changes
git stash

# Stash with message
git stash save "Work in progress on Vikunja"

# List stashes
git stash list

# Apply stash
git stash apply

# Apply specific stash
git stash apply stash@{1}

# Drop stash
git stash drop

# Pop stash (apply and remove)
git stash pop
```

## Tagging

### Tag Operations

```bash
# Create lightweight tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0"

# Push tags
git push --tags

# Push specific tag
git push origin v1.0.0

# List tags
git tag

# Show tag details
git show v1.0.0

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

## Troubleshooting

### Common Issues

```bash
# Undo local changes
git checkout -- services/vikunja/docker-compose.yml

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Fix detached HEAD
git checkout main

# Resolve merge conflicts
git add .
git commit -m "Resolve merge conflicts"

# Remove untracked files
git clean -fd
```

### Recovery

```bash
# Find lost commits
git reflog

# Restore lost commit
git checkout <commit-hash>

# Reset to specific commit
git reset --hard <commit-hash>

# Create branch from commit
git branch recovery <commit-hash>
```

## Integration with Homelab

### Deployment Integration

```bash
# Deploy after commit
git add .
git commit -m "Update service configuration"
git push origin main
./scripts/deploy-all.sh
```

### Backup Integration

```bash
# Backup repository
git bundle create backup.bundle --all

# Restore from backup
git clone backup.bundle restored-repo
```

### Monitoring Integration

```bash
# Check repository status
git status

# Check for uncommitted changes
git diff --name-only

# Check last deployment
git log --oneline -1
```

## Best Practices

### Commit Practices

- **Atomic commits**: One logical change per commit
- **Clear messages**: Descriptive commit messages
- **Regular commits**: Commit often, commit early
- **Test before commit**: Ensure code works before committing

### Branch Practices

- **Feature branches**: Separate branch for each feature
- **Clean main**: Keep main branch stable
- **Regular merges**: Merge feature branches regularly
- **Delete merged branches**: Clean up after merging

### Workflow Practices

- **Pull before push**: Always pull before pushing
- **Resolve conflicts early**: Don't let conflicts accumulate
- **Review changes**: Review changes before committing
- **Document changes**: Update documentation with code changes

## References

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Documentation](https://docs.github.com/)
- [Pro Git Book](https://git-scm.com/book)
- [Git Cheat Sheet](https://education.github.com/git-cheat-sheet-education.pdf)
- [Services Documentation](../services/)
- [Operations Documentation](../operations/)
