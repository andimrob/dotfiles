#!/bin/sh
# Bootstrap script for andimrob/dotfiles
# Usage: sh -c "$(curl -fsSL https://raw.githubusercontent.com/andimrob/dotfiles/main/install.sh)"
set -e

# ── Colors (disabled when not a TTY) ──────────────────────────────────

if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    RESET=''
fi

# ── Logging ───────────────────────────────────────────────────────────

info()  { printf "${BLUE}[info]${RESET}  %s\n" "$1"; }
ok()    { printf "${GREEN}[ok]${RESET}    %s\n" "$1"; }
warn()  { printf "${YELLOW}[warn]${RESET}  %s\n" "$1"; }
error() { printf "${RED}[error]${RESET} %s\n" "$1" >&2; }

# ── OS Detection ──────────────────────────────────────────────────────

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "unknown" ;;
    esac
}

# ── Command helpers ───────────────────────────────────────────────────

has() { command -v "$1" >/dev/null 2>&1; }

# ── macOS: Xcode CLI Tools ───────────────────────────────────────────

ensure_xcode_cli_tools() {
    if xcode-select -p >/dev/null 2>&1; then
        ok "Xcode CLI tools already installed"
        return
    fi
    info "Installing Xcode CLI tools..."
    xcode-select --install
    # Wait for installation to complete
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done
    ok "Xcode CLI tools installed"
}

# ── macOS: Homebrew ──────────────────────────────────────────────────

ensure_homebrew() {
    if has brew; then
        ok "Homebrew already installed"
        return
    fi
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew to PATH for the rest of this script
    if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    ok "Homebrew installed"
}

# ── Linux: System dependencies ───────────────────────────────────────

ensure_linux_deps() {
    deps_needed=""
    for dep in curl git; do
        if ! has "$dep"; then
            deps_needed="$deps_needed $dep"
        fi
    done

    if [ -z "$deps_needed" ]; then
        ok "System dependencies (curl, git) already installed"
        return
    fi

    info "Installing system dependencies:$deps_needed"
    # shellcheck disable=SC2086  # intentional word splitting for package list
    if has apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq $deps_needed
    elif has dnf; then
        sudo dnf install -y -q $deps_needed
    elif has yum; then
        sudo yum install -y -q $deps_needed
    elif has pacman; then
        sudo pacman -S --noconfirm --needed $deps_needed
    else
        error "No supported package manager found (apt, dnf, yum, pacman)"
        exit 1
    fi
    ok "System dependencies installed"
}

# ── chezmoi ──────────────────────────────────────────────────────────

ensure_chezmoi() {
    if has chezmoi; then
        ok "chezmoi already installed"
        return
    fi
    info "Installing chezmoi to ~/.local/bin..."
    mkdir -p "$HOME/.local/bin"
    sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$HOME/.local/bin"
    export PATH="$HOME/.local/bin:$PATH"
    ok "chezmoi installed"
}

# ── chezmoi init & apply ─────────────────────────────────────────────

apply_dotfiles() {
    info "Initializing and applying dotfiles..."
    chezmoi init --apply andimrob
    ok "Dotfiles applied"
}

# ── Brewfile bundle ──────────────────────────────────────────────────

run_brew_bundle() {
    if ! has brew; then
        warn "Homebrew not available, skipping brew bundle"
        return
    fi
    if [ ! -f "$HOME/.Brewfile" ]; then
        warn "$HOME/.Brewfile not found, skipping brew bundle"
        return
    fi
    info "Running brew bundle --global..."
    brew bundle --global
    ok "Brew bundle complete"
}

# ── Orchestrator ─────────────────────────────────────────────────────

main() {
    printf "\n%s\n\n" "${BLUE}==> andimrob/dotfiles bootstrap${RESET}"

    os=$(detect_os)
    info "Detected OS: $os"

    case "$os" in
        macos)
            ensure_xcode_cli_tools
            ensure_homebrew
            ;;
        linux)
            ensure_linux_deps
            ;;
        *)
            error "Unsupported OS: $(uname -s)"
            exit 1
            ;;
    esac

    ensure_chezmoi
    apply_dotfiles
    run_brew_bundle

    printf "\n%s\n" "${GREEN}==> All done! Restart your shell to pick up changes.${RESET}"
}

main "$@"
