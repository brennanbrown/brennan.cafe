# ~/.bash_aliases - Command shortcuts for brennan.cafe homelab
# Organized by category for easy maintenance

# ============================================================================
# NAVIGATION
# ============================================================================

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# Quick navigation to homelab directories
alias homelab='cd $HOMELAB_ROOT'
alias cdhl='cd $HOMELAB_ROOT'
alias cddocs='cd $HOMELAB_ROOT/docs'
alias cddocker='cd $HOMELAB_DOCKER'
alias cdscripts='cd $HOMELAB_SCRIPTS'
alias cdbackups='cd $HOMELAB_BACKUPS'

# ============================================================================
# LISTING & FILES
# ============================================================================

# Enhanced ls commands
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -lhF'
alias la='ls -lAhF'
alias l='ls -CF'
alias lt='ls -lhFt'  # Sort by time
alias lsize='ls -lhFS'  # Sort by size

# Tree with sensible defaults
alias tree='tree -C --dirsfirst'
alias tree1='tree -L 1'
alias tree2='tree -L 2'
alias tree3='tree -L 3'

# ============================================================================
# GREP & SEARCH
# ============================================================================

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Search in files
alias search='grep -rnw . -e'

# ============================================================================
# SYSTEM MANAGEMENT
# ============================================================================

# System info
alias sysinfo='inxi -F'
alias temp='check_temp'
alias cpu='top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk "{print 100 - \$1\"%\"}"'
alias mem='free -h'
alias disk='df -h'
alias ports='netstat -tuln'

# Process management
alias psg='ps aux | grep -v grep | grep -i -e VSZ -e'
alias memhog='ps aux --sort=-%mem | head -n 10'
alias cpuhog='ps aux --sort=-%cpu | head -n 10'

# Service management
alias services='systemctl list-units --type=service --state=running'
alias restart-network='sudo systemctl restart NetworkManager'

# ============================================================================
# PACKAGE MANAGEMENT (APT)
# ============================================================================

alias apt-update='sudo apt update'
alias apt-upgrade='sudo apt upgrade -y'
alias apt-full='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias apt-search='apt search'
alias apt-install='sudo apt install'
alias apt-remove='sudo apt remove'
alias apt-clean='sudo apt autoremove -y && sudo apt autoclean'

# ============================================================================
# DOCKER COMMANDS
# ============================================================================

# Docker basics
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dexec='docker exec -it'
alias dinspect='docker inspect'

# Docker Compose shortcuts
alias dcup='docker compose up -d'
alias dcdown='docker compose down'
alias dcrestart='docker compose restart'
alias dcps='docker compose ps'
alias dclogs='docker compose logs'
alias dclogsf='docker compose logs -f'
alias dcpull='docker compose pull'
alias dcbuild='docker compose build'

# Docker cleanup
alias docker-clean='docker system prune -af --volumes'
alias docker-stop-all='docker stop $(docker ps -q)'
alias docker-rm-all='docker rm $(docker ps -aq)'
alias docker-rmi-dangling='docker rmi $(docker images -f "dangling=true" -q)'

# Quick service access
alias cafe-up='cd $HOMELAB_DOCKER && docker compose up -d'
alias cafe-down='cd $HOMELAB_DOCKER && docker compose down'
alias cafe-restart='cd $HOMELAB_DOCKER && docker compose restart'
alias cafe-logs='cd $HOMELAB_DOCKER && docker compose logs -f'

# ============================================================================
# GIT COMMANDS
# ============================================================================

alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'
alias gco='git checkout'
alias gb='git branch'
alias gclean='git clean -fd'

# GitHub specific (since you use GitHub)
alias gl='git pull origin main'
alias gph='git push origin main'

# ============================================================================
# EDITORS
# ============================================================================

# Use micro as default
alias edit='micro'
alias e='micro'

# Sublime Text (when in GUI)
if command -v subl &> /dev/null; then
    alias s='subl'
    alias subl='subl'
fi

# Geany backup
if command -v geany &> /dev/null; then
    alias geany='geany'
fi

# ============================================================================
# SSH & NETWORKING
# ============================================================================

# SSH shortcuts
alias ssh-config='micro ~/.ssh/config'
alias ssh-keys='ls -la ~/.ssh/'

# Network diagnostics
alias ping='ping -c 5'
alias myip='curl -s ifconfig.me'
alias localip='hostname -I | cut -d" " -f1'
alias openports='sudo ss -tulanp'

# ============================================================================
# MONITORING & LOGS
# ============================================================================

# System logs
alias logs='sudo journalctl -xe'
alias logsf='sudo journalctl -f'
alias syslog='sudo tail -f /var/log/syslog'
alias authlog='sudo tail -f /var/log/auth.log'

# Service-specific logs
alias caddy-logs='docker logs -f caddy'
alias nextcloud-logs='docker logs -f nextcloud'
alias jellyfin-logs='docker logs -f jellyfin'

# ============================================================================
# BACKUP & MAINTENANCE
# ============================================================================

# Backup shortcuts
alias backup-now='$HOMELAB_SCRIPTS/maintenance/backup.sh'
alias backup-status='restic snapshots'

# System maintenance
alias clean-system='sudo apt autoremove -y && sudo apt autoclean && docker system prune -af'
alias update-all='$HOMELAB_SCRIPTS/maintenance/update-system.sh'

# ============================================================================
# CLOUDFLARE TUNNEL
# ============================================================================

alias tunnel-status='sudo systemctl status cloudflared'
alias tunnel-restart='sudo systemctl restart cloudflared'
alias tunnel-logs='sudo journalctl -u cloudflared -f'

# ============================================================================
# HOMELAB SPECIFIC SCRIPTS
# ============================================================================

# Quick access to custom scripts
alias check-services='$HOMELAB_SCRIPTS/monitoring/check-services.sh'
alias deploy-site='$HOMELAB_SCRIPTS/deployment/deploy-site.sh'
alias restart-all='$HOMELAB_SCRIPTS/deployment/restart-services.sh'

# ============================================================================
# SAFETY & CONFIRMATION
# ============================================================================

# Confirm before overwriting
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# More descriptive
alias mkdir='mkdir -pv'

# ============================================================================
# MISCELLANEOUS
# ============================================================================

# Quick reference
alias aliases='micro ~/.bash_aliases'
alias bashrc='micro ~/.bashrc'
alias reload='source ~/.bashrc && echo "Bashrc reloaded!"'

# Date & time
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias timestamp='date +"%Y%m%d_%H%M%S"'

# Weather (optional - requires curl)
alias weather='curl wttr.in/Calgary'

# Quick notes (using micro)
alias note='micro ~/quick-notes.txt'

# ============================================================================
# INDIEWEB / PERSONAL
# ============================================================================

# Quick access to your sites
alias my-sites='echo -e "🌻 Your Sites:\n- brennan.day (main blog)\n- brennan.cafe (homelab)\n- berryhouse.ca (business)\n- brennan.omg.lol (profile)"'

# ============================================================================
# FUN
# ============================================================================

# Because why not
alias please='sudo'
alias fucking='sudo'
alias yeet='rm -rf'  # Use with extreme caution!

# ============================================================================
# NOTES
# ============================================================================

# These aliases prioritize:
# - Quick navigation and productivity
# - Safe defaults (confirmations on destructive operations)
# - Docker-first workflow
# - GitHub integration (not GitLab)
# - Privacy and ethical computing
# - Accessibility and simplicity
#
# Remember: With great power comes great responsibility.
# Always double-check before running destructive commands!
