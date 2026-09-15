### Installation

If this is a fresh MacOS installation first we need Xcode:

```bash
# If this is a fresh MacOS installation first we need Xcode:
sudo xcode-select --install
chezmoi init
brew bundle
eval $(op signin)
chezmoi apply
```

### Codex permissions

[Claude-to-Codex permissions](codex-permissions.md) are generated from the shared
Claude settings template and applied at the user level with chezmoi.
