# .zshrc — настройки интерактивной оболочки

# Промпт
export PS1="%F{cyan}[guix-env]%f %F{green}%~%f %# "

# History
HISTFILE="$HOME/.cache/zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY

# Алиасы
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'

# Подсветка и автодополнение (если пакеты есть в манифесте)
# autoload -Uz compinit && compinit
