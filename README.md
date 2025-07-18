# 🚀 My Dotfiles

*A zero-dependency, one-command development environment that doesn't suck.*

## ⚡ Quick Start

**TL;DR**: Copy, paste, enjoy your new superpowers.

```bash
curl -fsSL https://raw.githubusercontent.com/andimrob/dotfiles/main/bootstrap.sh | bash
```

**Want to be cautious?** (Recommended for the first time)
```bash
curl -fsSL https://raw.githubusercontent.com/andimrob/dotfiles/main/bootstrap.sh | bash -s -- --interactive
```

## 🎯 What You Get

This isn't just another dotfiles repo. It's a carefully curated development environment that includes:

- **🐚 Shell Mastery**: Zsh + Oh My Zsh with smart aliases and functions
- **⚡ Fuzzy Everything**: FZF integration for lightning-fast navigation
- **🎨 Vim/Neovim Setup**: Pre-configured with essential plugins
- **🔧 Git Wizardry**: Aliases, hooks, and configs that make git fun
- **🍺 Homebrew Bundle**: All your favorite apps and tools
- **🌈 Terminal Aesthetics**: Starship prompt + 100+ iTerm color schemes
- **🔒 Security First**: GPG, SSH, and secrets management

## 🛠️ Installation Methods

### The "I Trust You" Method
```bash
curl -fsSL https://raw.githubusercontent.com/andimrob/dotfiles/main/bootstrap.sh | bash
```

### The "Let Me Think About It" Method
```bash
# Download and inspect first
curl -fsSL https://raw.githubusercontent.com/andimrob/dotfiles/main/bootstrap.sh > bootstrap.sh
less bootstrap.sh

# Run when ready
bash bootstrap.sh
```

### The "I Like Control" Method
```bash
git clone https://github.com/andimrob/dotfiles.git
cd dotfiles
./install.sh --dry-run  # See what would happen
./install.sh            # Do the thing
```

## 🎮 Features That'll Make You Smile

### Smart Aliases
- `..` `...` `....` - Navigate up directories like a ninja
- `ll` `la` - List files with style
- `g` - Because typing `git` is for chumps
- `be` `bx` - Bundle exec shortcuts for Ruby devs

### FZF Superpowers
- `ff` - Find files faster than spotlight
- `fh` - Search command history like a time traveler
- `fco` - Git branch switching with fuzzy search

### Git Shortcuts
- `git lg` - Beautiful log visualization
- `git undo` - Undo last commit (safely)
- `git wip` - Quick work-in-progress commits

## 📋 Requirements

- **macOS** or **Linux** (Windows users: WSL2 recommended)
- **Git** (usually pre-installed)
- **Curl** (definitely pre-installed)
- **Internet connection** (shocking, I know)

*No Python, no Ruby, no Node.js required for installation!*

## 🔧 Customization

This is *your* development environment. Here's how to make it yours:

### Personal Secrets
Create `~/.dotfiles/secrets.sh` for private configs:
```bash
export GITHUB_TOKEN="your_token_here"
export OPENAI_API_KEY="sk-..."
```

### Machine-Specific Configs
The installer respects existing configs and creates backups. Customize after installation:
- Git config: `~/.gitconfig`
- SSH config: `~/.ssh/config`
- Vim config: `~/.vimrc`

## 🧪 Testing & Safety

### Dry Run Everything
```bash
# See what the bootstrap would do
bootstrap.sh --dry-run --verbose

# See what the installer would do
./install.sh --dry-run --verbose
```

### Automatic Backups
- Bootstrap creates: `~/.dotfiles-bootstrap-backup/`
- Installer creates: `~/.dotfiles-backup/`

Nothing gets lost. Promise.

## 🚨 Troubleshooting

### "Command not found: git"
```bash
# macOS
xcode-select --install

# Ubuntu/Debian
sudo apt-get update && sudo apt-get install git curl

# CentOS/RHEL
sudo yum install git curl
```

### "Installation failed"
1. Check internet connection
2. Run with `--verbose` flag
3. Check backup directories for your old configs
4. [Open an issue](https://github.com/andimrob/dotfiles/issues) with the error

### "I want my old setup back"
```bash
# Your backups are safe
ls ~/.dotfiles-backup/
ls ~/.dotfiles-bootstrap-backup/

# Restore manually or git reset
cd ~/dotfiles && git log --oneline
```

## 🎭 Philosophy

**Opinionated but not obnoxious.** These configs represent years of refinement, but they're designed to be:

- **🏃‍♂️ Fast**: Optimized for quick startup and efficient workflows
- **🔧 Modular**: Easy to understand and modify
- **🛡️ Safe**: Backups and dry-run modes everywhere
- **📱 Portable**: Works across machines and environments
- **🎨 Beautiful**: Because aesthetics matter

## 📜 License

MIT License - Use it, abuse it, make it better.

## 🙏 Acknowledgments

Standing on the shoulders of giants:
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) - OG inspiration
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Starship](https://starship.rs/) - Cross-shell prompt
- The entire open source community

---

*Made with ☕ and 🎵 somewhere on Earth*
