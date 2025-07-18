# Migration from Dotbot to Pure Shell Installer

This document explains how to migrate from the Python-based dotbot system to the new pure shell installer.

## Overview

The new shell-based installer (`install.sh`) provides the same functionality as dotbot but with zero external dependencies. It works on any system with a POSIX-compliant shell.

## Key Changes

### Configuration Format
- **Old**: YAML configuration in `install.conf.yaml`
- **New**: Shell configuration in `install.conf.sh`

### Installation Command
- **Old**: `./install` (which calls dotbot)
- **New**: `./install.sh` (pure shell script)

## Configuration Migration

### Links Section
**Old (YAML):**
```yaml
- link:
    ~/.dotfiles: ''
    ~/.bash_profile: 'bash_profile.sh'
    ~/.config/starship.toml:
      create: true
      path: 'config/starship.toml'
```

**New (Shell):**
```bash
DOTFILES_LINKS=(
    "$HOME/.dotfiles:."
    "$HOME/.bash_profile:bash_profile.sh"
    "$HOME/.config/starship.toml:config/starship.toml:create"
)
```

### Create Section
**Old (YAML):**
```yaml
- create:
    - ~/src
    - ~/.config
```

**New (Shell):**
```bash
DOTFILES_DIRS=(
    "$HOME/src"
    "$HOME/.config"
)
```

### Clean Section
**Old (YAML):**
```yaml
- clean: ['~']
```

**New (Shell):**
```bash
DOTFILES_CLEAN_DIRS=(
    "$HOME"
)
```

### Shell Section
**Old (YAML):**
```yaml
- shell:
  - [git submodule update --init --recursive, Installing submodules]
```

**New (Shell):**
```bash
DOTFILES_COMMANDS=(
    "git submodule update --init --recursive:Installing submodules"
)
```

## New Features

### Command Line Options
The new installer supports several command-line options:

```bash
./install.sh --dry-run      # Preview changes without executing
./install.sh --verbose     # Show detailed output
./install.sh --quiet       # Minimal output
./install.sh --force       # Skip confirmations
./install.sh --help        # Show help message
```

### Automatic Backups
The installer automatically backs up existing files before replacing them:
- Backup location: `~/.dotfiles-backup/`
- Timestamped backups prevent overwrites
- Easy rollback if needed

### Better Error Handling
- Detailed error messages with context
- Colored output for better readability
- Operation summary at completion

## Migration Steps

1. **Test the new installer** with dry-run mode:
   ```bash
   ./install.sh --dry-run --verbose
   ```

2. **Review the configuration** in `install.conf.sh` and make any needed adjustments

3. **Run the installer**:
   ```bash
   ./install.sh
   ```

4. **Verify everything works** as expected

5. **Optional**: Remove the old dotbot directory and `install.conf.yaml`:
   ```bash
   rm -rf dotbot/
   rm install.conf.yaml
   rm install  # old install script
   ```

## Advantages of the Shell Version

### Zero Dependencies
- No Python required
- No YAML parser needed
- Works on minimal systems

### Better Performance
- Faster startup (no Python interpreter)
- Direct shell execution
- Minimal overhead

### Enhanced Portability
- Works on any POSIX-compliant system
- No version dependencies
- Self-contained script

### Improved Debugging
- Pure shell is easier to troubleshoot
- Verbose mode shows exactly what's happening
- Standard Unix tools for all operations

## Compatibility

The shell installer provides 100% feature compatibility with your existing dotbot configuration:

- ✅ Symlink creation with relink support
- ✅ Directory creation
- ✅ Broken symlink cleaning
- ✅ Shell command execution
- ✅ Environment variable expansion
- ✅ Parent directory creation

## Rollback

If you need to rollback to the old system:

1. The original `install` script and `install.conf.yaml` are preserved
2. Your backups are stored in `~/.dotfiles-backup/`
3. You can restore manually or use the original dotbot installer

## Support

The new installer has been tested to provide identical functionality to your existing dotbot setup. If you encounter any issues:

1. Try running with `--verbose` to see detailed output
2. Use `--dry-run` to preview changes safely
3. Check the backup directory for any replaced files
4. Review the configuration in `install.conf.sh`

## Example Usage

```bash
# Preview what would be done
./install.sh --dry-run

# Install with detailed output
./install.sh --verbose

# Quiet installation for automation
./install.sh --quiet

# Use custom configuration
./install.sh --config my-config.sh

# Custom backup directory
./install.sh --backup-dir /tmp/my-backups
```