#!/bin/bash
#
# Dotfiles Configuration
# Shell-based configuration for pure shell dotfiles manager
#
# This file replaces the YAML configuration used by dotbot
# and provides the same functionality using pure shell arrays
#

# Global Settings
DOTFILES_RELINK=true           # Remove existing symlinks before creating new ones
DOTFILES_CREATE_DIRS=true     # Create parent directories as needed
DOTFILES_BACKUP_DIR="$HOME/.dotfiles-backup"  # Backup directory for replaced files

# Symlinks to create
# Format: "target:source" or "target:source:create"
# - target: where the symlink should be created (supports ~ and environment variables)
# - source: path to the file in the dotfiles directory (relative to script location)
# - create: optional flag to create parent directories for this link
DOTFILES_LINKS=(
    # Root dotfiles symlink (points to the dotfiles directory itself)
    "$HOME/.dotfiles:."
    
    # Shell configuration
    "$HOME/.bash_profile:bash_profile.sh"
    "$HOME/.bashrc:bashrc.sh"
    
    # Homebrew
    "$HOME/.Brewfile:Brewfile"
    
    # Editor configuration
    "$HOME/.editorconfig:editorconfig"
    
    # GPG configuration
    "$HOME/.gnupg/gpg-agent.conf:gpg-agent.conf:create"
    
    # Git configuration
    "$HOME/.gitconfig:git/gitconfig"
    "$HOME/.gitprompt:git/gitprompt.sh"
    
    # Ruby and Rails
    "$HOME/.gemrc:gemrc"
    "$HOME/.pryrc:pryrc.rb"
    "$HOME/.railsrc:railsrc"
    
    # Shell and terminal
    "$HOME/.inputrc:inputrc.sh"
    "$HOME/.psqlrc:psqlrc"
    
    # Configuration files that need parent directories created
    "$HOME/.config/starship.toml:config/starship.toml:create"
    "$HOME/.config/nvim/init.vim:config/nvim/init.vim:create"
    "$HOME/.config/archey4/config.json:config/archey4/config.json:create"
    
    # Vim configuration
    "$HOME/.vim:vim"
    "$HOME/.vimrc:vimrc.vim"
    
    # Zsh configuration
    "$HOME/.zlogin:zsh/zlogin.sh"
    "$HOME/.zprofile:zsh/zprofile.sh"
    "$HOME/.zshrc:zsh/zshrc.sh"
)

# Directories to create
# These directories will be created if they don't exist
DOTFILES_DIRS=(
    "$HOME/src"
    "$HOME/.config"
    "$HOME/.gnupg"
)

# Directories to clean of broken symlinks
# The installer will remove any broken symlinks in these directories
DOTFILES_CLEAN_DIRS=(
    "$HOME"
)

# Shell commands to execute
# Format: "command" or "command:description"
# - command: the shell command to execute
# - description: optional human-readable description
DOTFILES_COMMANDS=(
    "git submodule update --init --recursive:Installing submodules"
)

# Advanced Configuration (optional)
# Uncomment and modify these if you need custom behavior

# Custom backup directory with timestamp
# DOTFILES_BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d)"

# Disable automatic parent directory creation
# DOTFILES_CREATE_DIRS=false

# Disable relinking (fail if symlink already exists with different target)
# DOTFILES_RELINK=false

# Environment-specific configurations
# You can use conditionals to customize behavior based on the environment

# Example: Different configurations for different machines
# if [[ "$(hostname)" == "work-laptop" ]]; then
#     DOTFILES_LINKS+=(
#         "$HOME/.work-config:work/config"
#     )
# fi

# Example: Platform-specific configurations
# if [[ "$OSTYPE" == "darwin"* ]]; then
#     # macOS specific
#     DOTFILES_LINKS+=(
#         "$HOME/.macos-config:macos/config"
#     )
# elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
#     # Linux specific
#     DOTFILES_LINKS+=(
#         "$HOME/.linux-config:linux/config"
#     )
# fi

# Example: User-specific configurations
# if [[ "$USER" == "rob" ]]; then
#     DOTFILES_COMMANDS+=(
#         "echo 'Welcome back, Rob!'"
#     )
# fi