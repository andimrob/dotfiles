#     _    _ _
#    / \  | (_) __ _ ___  ___  ___
#   / _ \ | | |/ _` / __|/ _ \/ __|
#  / ___ \| | | (_| \__ \  __/\__ \
# /_/   \_\_|_|\__,_|___/\___||___/

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ~='cd ~' # `cd` is probably faster to type though
alias -- -='cd -'

# Shortcuts
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias proj='cd ~/src'
alias g='git'
alias gwcd='cd $(git worktree list | fzf | awk "{print \$1}")'
alias attach='tmux attach-session'
alias h='history'

# Always enable colored `grep` output
# Note: `GREP_OPTIONS="--color=auto"` is deprecated, hence the alias usage.
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable aliases to be sudo'ed
alias sudo='sudo '

# Get week number
alias week='date +%V'

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Canonical hex dump; some systems have this symlinked
command -v hd >/dev/null || alias hd="hexdump -C"

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum >/dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum >/dev/null || alias sha1sum="shasum"

# URL-encode strings
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]));"'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

# reload zsh profile
alias reload='clear; source ~/.zshrc'

# ls command implementations
# -F includes a slash for directories.
alias ls='ls -AF'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'

# tree sane defaults
alias tree='tree -Ca --noreport'

# list load path
alias path='echo $PATH | tr ":" "\n"'

# ruby bundler shortcut
alias bx='bundle exec'
alias bxr='bundle exec rspec'
alias bxrf='bundle exec rspec $(fzf --layout=reverse --height=1% --min-height=12)'
alias bxg='bundle exec guard'
alias bxrc='bundle exec rails console'
alias bxrs='bundle exec rails server'
alias bxcop='bundle exec rubocop'
alias rbcop="git ls-files -m | xargs ls -1 2>/dev/null | grep '\.rb'"
# [F]ind [F]ile
alias ff='fzf --layout=reverse --height=1% --min-height=12'
# [F] and [P]review
alias fp="fzf --layout=reverse  --preview 'bat --style=numbers --color=always {}'"

# edit shortcut
alias edit="${EDITOR:-vi}"
alias cur='cursor'

alias dot="${EDITOR:-vi} ~/.dotfiles"

# Use nvim as vim if available
command -v nvim >/dev/null && alias vim="nvim"

# Claude AI
alias cl='claude --ide'
