# Local Configuration

This directory contains templates and examples for machine-specific configurations.

## Setup

When setting up dotfiles on a new machine:

1. Copy this template directory to create your local configs:
   ```bash
   cp -r local.template local
   ```

2. Edit the files in `local/` to add your machine-specific settings

3. The `local/` directory is gitignored, so your local configs won't be committed

## Structure

- **aliases.sh** - Machine-specific aliases (work shortcuts, project paths, etc.)
- **exports.sh** - Machine-specific environment variables and paths
- **functions.sh** - Machine-specific shell functions
- **secrets.sh** - Secrets and API keys (never commit!)

## Examples

See the `.example.sh` files in this directory for common patterns:

- `aliases.example.sh` - Work-specific aliases and shortcuts
- `exports.example.sh` - Custom paths and environment setup
- `functions.example.sh` - Helper functions for specific workflows

## Loading Order

Local configs are loaded **after** the base portable configs, so you can:

1. Override any base configuration
2. Add machine-specific settings
3. Keep work and personal machines separate

## Tips

- Use separate files for different concerns (work.sh, personal.sh, etc.)
- Keep secrets in `secrets.sh` - it's already in .gitignore at the root level
- You can source other files (like `~/.bootstrap/env.sh` for work setups)
