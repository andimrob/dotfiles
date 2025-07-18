#!/bin/bash
#
# Rob's Dotfiles Bootstrap Script
# One-command installation for a complete development environment
#
# Usage: bootstrap.sh [--interactive] [--dry-run] [--verbose] [--help]
#

set -e

# Configuration
REPO_URL="https://github.com/andimrob/dotfiles.git"
BRANCH="main"
INSTALL_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-bootstrap-backup"

# Colors for output
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    PURPLE=''
    CYAN=''
    NC=''
fi

# Default flags
INTERACTIVE=false
DRY_RUN=false
VERBOSE=false

# Logging functions
log_info() {
    echo -e "${CYAN}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
}

log_debug() {
    [[ $VERBOSE == true ]] || return
    echo -e "${PURPLE}[DEBUG]${NC} $*"
}

# Show help message
show_help() {
    cat << EOF
Rob's Dotfiles Bootstrap Script

DESCRIPTION:
    One-command installation for a complete development environment.
    Downloads and installs Rob's dotfiles with zero-dependency shell installer.

USAGE:
    bootstrap.sh [OPTIONS]

OPTIONS:
    --interactive    Prompt for confirmations before making changes
    --dry-run       Preview what would be done without executing
    --verbose       Show detailed output during installation
    --help          Show this help message

EXAMPLES:
    bootstrap.sh                    # Silent installation
    bootstrap.sh --interactive      # Interactive installation
    bootstrap.sh --dry-run         # Preview changes
    bootstrap.sh --verbose         # Detailed output

WHAT THIS INSTALLS:
    - Shell configuration (zsh with Oh My Zsh integration)
    - Vim/Neovim configuration with plugins
    - Git configuration and tools
    - Development tools and utilities
    - macOS/Linux compatible dotfiles

REQUIREMENTS:
    - macOS or Linux
    - git (for cloning repository)
    - curl (for downloading)
    - bash 3.0+ (for running installer)

MORE INFO:
    Repository: https://github.com/andimrob/dotfiles
    Issues:     https://github.com/andimrob/dotfiles/issues
EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interactive)
                INTERACTIVE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get OS information
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Linux"
    elif [[ "$OSTYPE" == "linux"* ]]; then
        echo "Linux"
    else
        echo "Unknown"
    fi
}

# Validate environment and dependencies
check_environment() {
    log_debug "Checking environment and dependencies..."
    
    local os_type
    os_type=$(detect_os)
    
    # Check supported OS
    if [[ "$os_type" != "macOS" && "$os_type" != "Linux" ]]; then
        log_error "Unsupported operating system: $OSTYPE"
        log_error "This script supports macOS and Linux only."
        exit 1
    fi
    
    log_debug "Operating system: $os_type"
    
    # Check required commands
    local missing_commands=()
    
    if ! command_exists git; then
        missing_commands+=("git")
    fi
    
    if ! command_exists curl; then
        missing_commands+=("curl")
    fi
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        echo
        echo "Install missing dependencies:"
        
        if [[ "$os_type" == "macOS" ]]; then
            echo "  xcode-select --install"
        elif command_exists apt-get; then
            echo "  sudo apt-get update && sudo apt-get install git curl"
        elif command_exists yum; then
            echo "  sudo yum install git curl"
        elif command_exists dnf; then
            echo "  sudo dnf install git curl"
        elif command_exists pacman; then
            echo "  sudo pacman -S git curl"
        else
            echo "  Install git and curl using your system's package manager"
        fi
        
        echo
        echo "Then run this script again."
        exit 1
    fi
    
    # Check git version
    local git_version
    git_version=$(git --version | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    log_debug "Git version: $git_version"
    
    # Check bash version
    log_debug "Bash version: $BASH_VERSION"
    
    # Check write permissions to home directory
    if [[ ! -w "$HOME" ]]; then
        log_error "Cannot write to home directory: $HOME"
        log_error "Check permissions and try again."
        exit 1
    fi
    
    # Test network connectivity
    log_debug "Testing network connectivity to GitHub..."
    if ! curl -s --connect-timeout 10 https://api.github.com/repos/andimrob/dotfiles >/dev/null; then
        log_warning "Cannot connect to GitHub. Check your internet connection."
        if [[ $INTERACTIVE == true ]]; then
            echo -n "Continue anyway? (y/N): "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled."
                exit 0
            fi
        else
            log_error "Network connectivity required for installation."
            exit 1
        fi
    fi
    
    log_debug "Environment validation complete"
}

# Show welcome banner
show_banner() {
    if [[ $DRY_RUN == true ]]; then
        echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo
    fi
    
    echo -e "${CYAN}Rob's Dotfiles Bootstrap${NC}"
    echo -e "${CYAN}========================${NC}"
    echo
    echo "This will install a complete development environment including:"
    echo "  • Shell configuration (zsh + Oh My Zsh)"
    echo "  • Vim/Neovim configuration with plugins"
    echo "  • Git configuration and tools"
    echo "  • Development utilities and aliases"
    echo
    
    if [[ $INTERACTIVE == true ]]; then
        echo -n "Continue with installation? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            log_info "Installation cancelled."
            exit 0
        fi
        echo
    fi
}

# Create timestamped backup
create_backup() {
    local source="$1"
    local backup_name
    backup_name="$(basename "$source")_$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Would backup '$source' to '$backup_path'"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    if mv "$source" "$backup_path"; then
        log_info "Backed up existing '$source' to '$backup_path'"
        return 0
    else
        log_error "Failed to backup '$source'"
        return 1
    fi
}

# Prepare for installation
prepare_installation() {
    log_info "Preparing for installation..."
    
    # Handle existing dotfiles directory
    if [[ -e "$INSTALL_DIR" ]]; then
        log_warning "Existing dotfiles found at $INSTALL_DIR"
        
        if [[ $INTERACTIVE == true ]]; then
            echo -n "Backup and replace existing dotfiles? (y/N): "
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                log_info "Installation cancelled."
                exit 0
            fi
        fi
        
        if ! create_backup "$INSTALL_DIR"; then
            exit 1
        fi
    fi
    
    log_debug "Installation preparation complete"
}

# Clone the dotfiles repository
clone_repository() {
    log_info "Downloading dotfiles from GitHub..."
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Would clone $REPO_URL to $INSTALL_DIR"
        return 0
    fi
    
    log_debug "Cloning $REPO_URL (branch: $BRANCH) to $INSTALL_DIR"
    
    if git clone -b "$BRANCH" "$REPO_URL" "$INSTALL_DIR"; then
        log_success "Successfully downloaded dotfiles"
    else
        log_error "Failed to clone repository"
        log_error "Check your internet connection and try again."
        exit 1
    fi
}

# Run the dotfiles installer
run_installer() {
    log_info "Running dotfiles installer..."
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Would run: cd $INSTALL_DIR && ./install.sh"
        return 0
    fi
    
    cd "$INSTALL_DIR" || {
        log_error "Failed to change to dotfiles directory"
        exit 1
    }
    
    if [[ ! -x "./install.sh" ]]; then
        log_error "install.sh not found or not executable"
        exit 1
    fi
    
    local install_args=""
    [[ $VERBOSE == true ]] && install_args="--verbose"
    
    log_debug "Running: ./install.sh $install_args"
    
    if ./install.sh $install_args; then
        log_success "Dotfiles installation completed successfully"
    else
        log_error "Dotfiles installation failed"
        exit 1
    fi
}

# Restart the shell
restart_shell() {
    if [[ $DRY_RUN == true ]]; then
        log_info "Would restart shell: exec $SHELL"
        return 0
    fi
    
    log_success "Installation complete!"
    echo
    echo "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Install applications: brew bundle install --global"
    echo "  3. Configure any personal settings"
    echo
    
    if [[ $INTERACTIVE == true ]]; then
        echo -n "Restart shell now? (Y/n): "
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            log_info "Shell restart skipped. Run 'exec \$SHELL' to restart manually."
            return 0
        fi
    fi
    
    log_info "Restarting shell..."
    exec "$SHELL"
}

# Cleanup on error
cleanup_on_error() {
    local exit_code=$?
    
    if [[ $exit_code -ne 0 && $DRY_RUN == false ]]; then
        log_error "Installation failed. Cleaning up..."
        
        # Remove partial installation
        if [[ -d "$INSTALL_DIR" ]]; then
            log_info "Removing partial installation: $INSTALL_DIR"
            rm -rf "$INSTALL_DIR"
        fi
        
        log_info "Cleanup complete. Backups preserved in: $BACKUP_DIR"
    fi
    
    exit $exit_code
}

# Main installation function
main() {
    # Set error trap
    trap cleanup_on_error EXIT
    
    # Parse command line arguments
    parse_arguments "$@"
    
    # Show banner and get confirmation
    show_banner
    
    # Validate environment
    check_environment
    
    # Prepare for installation
    prepare_installation
    
    # Download dotfiles
    clone_repository
    
    # Run installer
    run_installer
    
    # Restart shell
    restart_shell
    
    # Clear error trap on successful completion
    trap - EXIT
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi