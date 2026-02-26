#!/bin/bash
input=$(cat)

# Parse fields from JSON stdin
MODEL=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
WINDOW_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // ""')

# Format duration as Xm Ys
DURATION_SEC=$((DURATION_MS / 1000))
MINS=$((DURATION_SEC / 60))
SECS=$((DURATION_SEC % 60))

# Format cost to 2 decimal places
COST_FMT=$(printf '%.2f' "$COST")

# Format token count in 1K increments
TOKENS=$((PCT * WINDOW_SIZE / 100))
if [ "$TOKENS" -lt 1000 ]; then
  TOKEN_FMT="<1K"
else
  TOKEN_FMT="$((TOKENS / 1000))K"
fi

# Progress bar with color based on context usage
BAR_WIDTH=10
FILLED=$((PCT * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

RESET="\033[0m"
if [ "$PCT" -ge 80 ]; then
  COLOR="\033[31m"
elif [ "$PCT" -ge 60 ]; then
  COLOR="\033[33m"
else
  COLOR="\033[32m"
fi

FILLED_STR=$(printf "%${FILLED}s" | tr ' ' '▓')
EMPTY_STR=$(printf "%${EMPTY}s" | tr ' ' '░')
BAR=$(printf "%b" "${COLOR}[${FILLED_STR}${RESET}${EMPTY_STR}] ${PCT}% ${TOKEN_FMT}")

# Git branch (cached for 5s to avoid lag)
BRANCH=""
CACHE="/tmp/.claude_statusline_git"
if [ -n "$DIR" ] && [ -d "$DIR/.git" ]; then
  if [ -f "$CACHE" ] && [ $(($(date +%s) - $(stat -f %m "$CACHE" 2>/dev/null || echo 0))) -lt 5 ]; then
    BRANCH=$(cat "$CACHE")
  else
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    echo "$BRANCH" > "$CACHE"
  fi
fi

# Assemble status line with emoji
CYAN="\033[36m"
STATUS=$(printf "%b" "🤖 ${CYAN}${MODEL}${RESET} │ 📊 ${BAR} │ 💰 \$${COST_FMT} │ ⏱️ ${MINS}m${SECS}s")
[ -n "$BRANCH" ] && STATUS=$(printf "%b" "${STATUS} │ 🌿 ${CYAN}${BRANCH}${RESET}")

echo "$STATUS"
