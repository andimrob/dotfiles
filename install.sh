#!/bin/bash
#
# Pure Shell Dotfiles Manager
# A zero-dependency replacement for dotbot
#
# Usage: ./install.sh [options]
#
# Options:
#   --dry-run     Preview changes without executing
#   --verbose     Show detailed output
#   --quiet       Minimal output
#   --force       Skip confirmations
#   --config      Specify config file (default: install.conf.sh)
#   --backup-dir  Custom backup directory
#   --help        Show this help message

set -e

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

# Global configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/install.conf.sh"
BACKUP_DIR="$HOME/.dotfiles-backup"
DRY_RUN=false
VERBOSE=false
QUIET=false
FORCE=false
SUCCESS_COUNT=0
ERROR_COUNT=0

# Logging functions
log_info() {
    [[ $QUIET == true ]] && return
    echo -e "${CYAN}[INFO]${NC} $*"
}

log_success() {
    [[ $QUIET == true ]] && return
    echo -e "${GREEN}[SUCCESS]${NC} $*"
    ((SUCCESS_COUNT++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*" >&2
    ((ERROR_COUNT++))
}

log_debug() {
    [[ $VERBOSE == true ]] || return
    echo -e "${PURPLE}[DEBUG]${NC} $*"
}

# Help function
show_help() {
    cat << EOF
Pure Shell Dotfiles Manager

Usage: $0 [options]

Options:
  --dry-run       Preview changes without executing
  --verbose       Show detailed output
  --quiet         Minimal output
  --force         Skip confirmations
  --config FILE   Specify config file (default: install.conf.sh)
  --backup-dir    Custom backup directory
  --help          Show this help message

Examples:
  $0                    # Install dotfiles
  $0 --dry-run         # Preview what would be done
  $0 --verbose         # Show detailed output
  $0 --config my.conf  # Use custom config file
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --quiet)
                QUIET=true
                shift
                ;;
            --force)
                FORCE=true
                shift
                ;;
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --backup-dir)
                BACKUP_DIR="$2"
                shift 2
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Expand environment variables in path
expand_path() {
    local path="$1"
    # Expand ~ to $HOME
    path="${path/#\~/$HOME}"
    # Expand environment variables
    path=$(eval echo "$path")
    echo "$path"
}

# Get relative path from script directory
get_source_path() {
    local source="$1"
    if [[ "$source" == /* ]]; then
        echo "$source"
    else
        echo "$SCRIPT_DIR/$source"
    fi
}

# Check if path exists
path_exists() {
    local path="$1"
    [[ -e "$path" ]] || [[ -L "$path" ]]
}

# Create backup of existing file/directory
create_backup() {
    local target="$1"
    local backup_name="$(basename "$target")"
    local timestamp="$(date +%Y%m%d_%H%M%S)"
    local backup_path="$BACKUP_DIR/${backup_name}_${timestamp}"
    
    if [[ $DRY_RUN == true ]]; then
        log_info "Would backup '$target' to '$backup_path'"
        return 0
    fi
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Move existing file/directory to backup
    if mv "$target" "$backup_path"; then
        log_debug "Backed up '$target' to '$backup_path'"
        return 0
    else
        log_error "Failed to backup '$target'"
        return 1
    fi
}

# Load configuration file
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    log_debug "Loading configuration from: $CONFIG_FILE"
    
    # Source the configuration file
    # shellcheck source=/dev/null
    source "$CONFIG_FILE"
    
    # Initialize arrays if not defined
    DOTFILES_LINKS=${DOTFILES_LINKS:-()}
    DOTFILES_DIRS=${DOTFILES_DIRS:-()}
    DOTFILES_CLEAN_DIRS=${DOTFILES_CLEAN_DIRS:-()}
    DOTFILES_COMMANDS=${DOTFILES_COMMANDS:-()}
    
    # Set defaults
    DOTFILES_RELINK=${DOTFILES_RELINK:-true}
    DOTFILES_CREATE_DIRS=${DOTFILES_CREATE_DIRS:-true}
    DOTFILES_BACKUP_DIR=${DOTFILES_BACKUP_DIR:-"$HOME/.dotfiles-backup"}
    
    # Override backup directory if specified
    if [[ -n "$DOTFILES_BACKUP_DIR" ]]; then
        BACKUP_DIR="$DOTFILES_BACKUP_DIR"
    fi
    
    log_debug "Configuration loaded successfully"
}

# Validate configuration
validate_config() {
    log_debug "Validating configuration"
    
    # Check if arrays are properly defined
    if [[ -z "${DOTFILES_LINKS[*]}" ]] && [[ -z "${DOTFILES_DIRS[*]}" ]] && [[ -z "${DOTFILES_COMMANDS[*]}" ]]; then
        log_warning "No links, directories, or commands defined in configuration"
    fi
    
    # Validate backup directory is writable
    local backup_parent="$(dirname "$BACKUP_DIR")"
    if [[ ! -w "$backup_parent" ]]; then
        log_error "Cannot write to backup directory parent: $backup_parent"
        return 1
    fi
    
    log_debug "Configuration validation complete"
}

# Create a symlink
create_link() {
    local target="$1"
    local source="$2"
    local create_parent="$3"
    
    # Expand paths
    target=$(expand_path "$target")
    source=$(get_source_path "$source")
    
    log_debug "Processing link: $target -> $source"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_error "Source file does not exist: $source"
        return 1
    fi
    
    # Create parent directory if needed
    if [[ "$create_parent" == "create" ]] || [[ "$DOTFILES_CREATE_DIRS" == true ]]; then
        local parent_dir="$(dirname "$target")"
        if [[ ! -d "$parent_dir" ]]; then
            if [[ $DRY_RUN == true ]]; then
                log_info "Would create directory: $parent_dir"
            else
                if mkdir -p "$parent_dir"; then
                    log_debug "Created directory: $parent_dir"
                else
                    log_error "Failed to create directory: $parent_dir"
                    return 1
                fi
            fi
        fi
    fi
    
    # Handle existing target
    if path_exists "$target"; then
        if [[ -L "$target" ]]; then
            # It's a symlink
            local current_target="$(readlink "$target")"
            if [[ "$current_target" == "$source" ]]; then
                log_debug "Link already exists and is correct: $target"
                return 0
            elif [[ "$DOTFILES_RELINK" == true ]]; then
                if [[ $DRY_RUN == true ]]; then
                    log_info "Would remove existing symlink: $target"
                else
                    if rm "$target"; then
                        log_debug "Removed existing symlink: $target"
                    else
                        log_error "Failed to remove existing symlink: $target"
                        return 1
                    fi
                fi
            else
                log_warning "Link exists but points to different target: $target -> $current_target"
                return 1
            fi
        else
            # It's a regular file or directory
            if [[ $DRY_RUN == true ]]; then
                log_info "Would backup and replace: $target"
            else
                if ! create_backup "$target"; then
                    return 1
                fi
            fi
        fi
    fi
    
    # Create the symlink
    if [[ $DRY_RUN == true ]]; then
        log_info "Would create symlink: $target -> $source"
    else
        if ln -s "$source" "$target"; then
            log_success "Created symlink: $target -> $source"
        else
            log_error "Failed to create symlink: $target -> $source"
            return 1
        fi
    fi
}

# Process all links
process_links() {
    if [[ ${#DOTFILES_LINKS[@]} -eq 0 ]]; then
        log_debug "No links to process"
        return 0
    fi
    
    log_info "Processing symlinks..."
    
    for link_spec in "${DOTFILES_LINKS[@]}"; do
        # Parse link specification: "target:source" or "target:source:create"
        IFS=':' read -r target source create_parent <<< "$link_spec"
        
        if [[ -z "$target" || -z "$source" ]]; then
            log_error "Invalid link specification: $link_spec"
            continue
        fi
        
        create_link "$target" "$source" "$create_parent"
    done
}

# Create directories
create_directories() {
    if [[ ${#DOTFILES_DIRS[@]} -eq 0 ]]; then
        log_debug "No directories to create"
        return 0
    fi
    
    log_info "Creating directories..."
    
    for dir_spec in "${DOTFILES_DIRS[@]}"; do
        local dir_path
        dir_path=$(expand_path "$dir_spec")
        
        if [[ -d "$dir_path" ]]; then
            log_debug "Directory already exists: $dir_path"
            continue
        fi
        
        if [[ $DRY_RUN == true ]]; then
            log_info "Would create directory: $dir_path"
        else
            if mkdir -p "$dir_path"; then
                log_success "Created directory: $dir_path"
            else
                log_error "Failed to create directory: $dir_path"
            fi
        fi
    done
}

# Clean broken symlinks
clean_broken_links() {
    if [[ ${#DOTFILES_CLEAN_DIRS[@]} -eq 0 ]]; then
        log_debug "No directories to clean"
        return 0
    fi
    
    log_info "Cleaning broken symlinks..."
    
    for dir_spec in "${DOTFILES_CLEAN_DIRS[@]}"; do
        local dir_path
        dir_path=$(expand_path "$dir_spec")
        
        if [[ ! -d "$dir_path" ]]; then
            log_warning "Directory does not exist: $dir_path"
            continue
        fi
        
        log_debug "Cleaning directory: $dir_path"
        
        # Find broken symlinks
        while IFS= read -r -d '' broken_link; do
            if [[ $DRY_RUN == true ]]; then
                log_info "Would remove broken symlink: $broken_link"
            else
                if rm "$broken_link"; then
                    log_success "Removed broken symlink: $broken_link"
                else
                    log_error "Failed to remove broken symlink: $broken_link"
                fi
            fi
        done < <(find "$dir_path" -maxdepth 1 -type l ! -exec test -e {} \; -print0 2>/dev/null)
    done
}

# Execute shell commands
execute_commands() {
    if [[ ${#DOTFILES_COMMANDS[@]} -eq 0 ]]; then
        log_debug "No commands to execute"
        return 0
    fi
    
    log_info "Executing shell commands..."
    
    for cmd_spec in "${DOTFILES_COMMANDS[@]}"; do
        # Parse command specification: "command" or "command:description"
        IFS=':' read -r command description <<< "$cmd_spec"
        
        if [[ -z "$command" ]]; then
            log_error "Empty command specification: $cmd_spec"
            continue
        fi
        
        # Use description if provided, otherwise use command
        local display_desc="${description:-$command}"
        
        if [[ $DRY_RUN == true ]]; then
            log_info "Would execute: $display_desc"
        else
            log_info "Executing: $display_desc"
            
            if [[ $VERBOSE == true ]]; then
                if eval "$command"; then
                    log_success "Command completed: $display_desc"
                else
                    log_error "Command failed: $display_desc"
                fi
            else
                if eval "$command" >/dev/null 2>&1; then
                    log_success "Command completed: $display_desc"
                else
                    log_error "Command failed: $display_desc"
                fi
            fi
        fi
    done
}

# Main installation function
main() {
    local start_time
    start_time=$(date +%s)
    
    # Parse command line arguments
    parse_args "$@"
    
    # Show banner
    if [[ $QUIET == false ]]; then
        echo -e "${BLUE}Pure Shell Dotfiles Manager${NC}"
        echo -e "${BLUE}============================${NC}"
        if [[ $DRY_RUN == true ]]; then
            echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        fi
        echo
    fi
    
    # Load and validate configuration
    if ! load_config; then
        exit 1
    fi
    
    if ! validate_config; then
        exit 1
    fi
    
    # Execute installation steps
    create_directories
    process_links
    clean_broken_links
    execute_commands
    
    # Show summary
    if [[ $QUIET == false ]]; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        echo
        echo -e "${BLUE}Installation Summary${NC}"
        echo -e "${BLUE}===================${NC}"
        echo -e "Success: ${GREEN}$SUCCESS_COUNT${NC} operations"
        echo -e "Errors:  ${RED}$ERROR_COUNT${NC} operations"
        echo -e "Time:    ${CYAN}${duration}s${NC}"
        
        if [[ $DRY_RUN == true ]]; then
            echo -e "${YELLOW}Note: This was a dry run. No changes were made.${NC}"
        fi
        
        if [[ $ERROR_COUNT -gt 0 ]]; then
            echo -e "${RED}Installation completed with errors.${NC}"
            exit 1
        else
            echo -e "${GREEN}Installation completed successfully!${NC}"
        fi
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi