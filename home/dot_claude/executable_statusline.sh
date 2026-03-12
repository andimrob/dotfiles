#!/bin/bash
input=$(cat)

# Parse all fields from JSON stdin in a single jq call
IFS=$'\t' read -r MODEL PCT WINDOW_SIZE COST DURATION_MS DIR < <(
  echo "$input" | jq -r '[
    .model.display_name // "Unknown",
    (.context_window.used_percentage // 0 | floor),
    .context_window.context_window_size // 200000,
    .cost.total_cost_usd // 0,
    .cost.total_duration_ms // 0,
    .workspace.current_dir // ""
  ] | @tsv'
)

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

# Moon phase emoji based on context usage percentage (new → full)
if [ "$PCT" -le 20 ]; then
  MOON="🌑"
elif [ "$PCT" -le 40 ]; then
  MOON="🌒"
elif [ "$PCT" -le 60 ]; then
  MOON="🌓"
elif [ "$PCT" -le 80 ]; then
  MOON="🌔"
else
  MOON="🌕"
fi

RESET="\033[0m"
CYAN="\033[36m"
YELLOW="\033[33m"
CTX="${MOON} ${PCT}% ${TOKEN_FMT}"

# Git branch and worktree detection
BRANCH=""
WORKTREE=""
if [ -n "$DIR" ] && git -C "$DIR" rev-parse --git-dir &>/dev/null; then
  BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
  TOPLEVEL=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
  MAIN_TREE=$(git -C "$DIR" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2; exit}')
  [ -n "$MAIN_TREE" ] && [ "$MAIN_TREE" != "$TOPLEVEL" ] && WORKTREE=$(basename "$TOPLEVEL")
fi

# Assemble status line
STATUS=$(printf "%b" "🤖 ${CYAN}${MODEL}${RESET} │ ${CTX} │ 💰 \$${COST_FMT} │ ⏱️ ${MINS}m${SECS}s")
if [ -n "$WORKTREE" ]; then
  STATUS=$(printf "%b" "${STATUS} │ 🌿 ${CYAN}${BRANCH}${RESET} ${YELLOW}[${WORKTREE}]${RESET}")
elif [ -n "$BRANCH" ]; then
  STATUS=$(printf "%b" "${STATUS} │ 🌿 ${CYAN}${BRANCH}${RESET}")
fi

echo "$STATUS"
