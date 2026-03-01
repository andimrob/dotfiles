#!/bin/bash

# Reads PostToolUse hook input from stdin.
# If the written file is a Claude plan, creates a named symlink
# in the Obsidian vault's 0-Agent Workbench/ folder.
#
# Requires: OBSIDIAN_VAULT_PATH env var

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

# Only process plan files
[[ "$file_path" =~ \.claude/plans/ ]] || exit 0

if [[ -z "$OBSIDIAN_VAULT_PATH" ]]; then
  echo "[symlink-plan] Warning: OBSIDIAN_VAULT_PATH is not set — skipping plan symlink" >&2
  exit 0
fi

if [[ ! -d "$OBSIDIAN_VAULT_PATH" ]]; then
  echo "[symlink-plan] Warning: Obsidian vault not found at $OBSIDIAN_VAULT_PATH — skipping plan symlink" >&2
  exit 0
fi

WORKBENCH="$OBSIDIAN_VAULT_PATH/0-Agent Workbench"

# Ensure workbench exists
mkdir -p "$WORKBENCH"

# Extract a name from the first markdown heading, falling back to filename
name=$(grep -m1 '^#' "$file_path" | sed 's/^#\+ *//' | tr '/' '-')
if [[ -z "$name" ]]; then
  name=$(basename "$file_path" .md)
fi

# Clean the name for filesystem use
name=$(echo "$name" | sed 's/[:]/ -/g' | sed 's/[*?"<>|]//g' | xargs)

symlink="$WORKBENCH/$name.md"

# If a symlink with this name already points to the same file, nothing to do
if [[ -L "$symlink" && "$(readlink "$symlink")" == "$file_path" ]]; then
  exit 0
fi

# Create or update the symlink
ln -sf "$file_path" "$symlink"
