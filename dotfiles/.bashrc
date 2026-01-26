# ~/.bashrc - Brennan's homelab bash configuration
# brennan.cafe ThinkPad W520 Server
# User: brennan | Hostname: thinkpad

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ============================================================================
# HISTORY CONFIGURATION
# ============================================================================

# Don't put duplicate lines or lines starting with space in history
HISTCONTROL=ignoreboth

# Append to history file, don't overwrite
shopt -s histappend

# History size
HISTSIZE=10000
HISTFILESIZE=20000

# Timestamp format in history
HISTTIMEFORMAT="%F %T "

# ============================================================================
# SHELL OPTIONS
# ============================================================================

# Check window size after each command
shopt -s checkwinsize

# Enable recursive globbing with **
shopt -s globstar

# Correct minor directory spelling errors
shopt -s cdspell

# ============================================================================
# PROMPT CONFIGURATION
# ============================================================================

# Color definitions
RESET='\[\033[0m\]'
BOLD='\[\033[1m\]'
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BLUE='\[\033[0;34m\]'
PURPLE='\[\033[0;35m\]'
CYAN='\[\033[0;36m\]'

# Git branch in prompt (optional - install git-prompt first)
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    BRANCH='$(__git_ps1 " (%s)")'
else
    BRANCH=''
fi

# Custom prompt: [user@host:dir] (git-branch) $
PS1="${BOLD}${CYAN}[${GREEN}\u${RESET}${BOLD}${CYAN}@${PURPLE}\h${RESET}${BOLD}${CYAN}:${YELLOW}\w${CYAN}]${YELLOW}${BRANCH}${RESET}\$ "

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

# Default editor (micro preferred, fallback to vim)
if command -v micro &> /dev/null; then
    export EDITOR='micro'
    export VISUAL='micro'
else
    export EDITOR='vim'
    export VISUAL='vim'
fi

# Pager
export PAGER='less'

# Less options
export LESS='-R -i -M -S -x4'

# Path additions
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Docker buildkit
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# Homelab specific
export HOMELAB_ROOT="$HOME/brennan.cafe"
export HOMELAB_DOCKER="$HOMELAB_ROOT/docker"
export HOMELAB_SCRIPTS="$HOMELAB_ROOT/scripts"
export HOMELAB_BACKUPS="$HOMELAB_ROOT/backups"

# ============================================================================
# COMPLETION
# ============================================================================

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Docker completion
if [ -f /usr/share/bash-completion/completions/docker ]; then
    . /usr/share/bash-completion/completions/docker
fi

# ============================================================================
# ALIASES & FUNCTIONS
# ============================================================================

# Load aliases from separate file
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Load functions from separate file
if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# ============================================================================
# GREETING
# ============================================================================

# Show system info on login (only for interactive shells)
if [ -n "$PS1" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  🌻 brennan.cafe homelab | thinkpad"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Uptime: $(uptime -p | sed 's/up //')"
    echo "  Load: $(uptime | awk -F'load average:' '{print $2}')"
    
    # Show disk usage
    echo "  Disk: $(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 " used)"}')"
    
    # Show Docker status if available
    if command -v docker &> /dev/null; then
        CONTAINERS=$(docker ps -q | wc -l)
        echo "  Docker: $CONTAINERS containers running"
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
fi

# ============================================================================
# TEMPERATURE MONITORING (for thermal management)
# ============================================================================

# Function to check CPU temperature
check_temp() {
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        TEMP_C=$((TEMP / 1000))
        echo "CPU Temperature: ${TEMP_C}°C"
        
        # Warn if temperature is high (over 80°C)
        if [ $TEMP_C -gt 80 ]; then
            echo "⚠️  WARNING: High temperature! Consider reducing load."
        fi
    fi
}

# ============================================================================
# LAND ACKNOWLEDGMENT
# ============================================================================

# Respect for Treaty 7 territory (Calgary/Mohkínstsis)
# This homelab operates on traditional Indigenous lands
# See: https://brennan.day for full acknowledgment

# ============================================================================
# NOTES
# ============================================================================

# This configuration prioritizes:
# - Simplicity and readability
# - Performance on older hardware
# - Accessibility and progressive enhancement
# - Privacy and ethical computing
# - IndieWeb and FOSS principles

# For more info: https://brennan.cafe
