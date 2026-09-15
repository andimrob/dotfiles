#!/usr/bin/env bash
set -uo pipefail

[ -n "${TMUX:-}" ] || exit 0
[ -n "${TMUX_PANE:-}" ] || exit 0

readonly PANE_OPTION="@claude_pane"
readonly WINDOW_OPTION="@claude"

state_rank() {
  case "$1" in
  blocked) echo 3 ;;
  idle) echo 2 ;;
  busy) echo 1 ;;
  *) echo 0 ;;
  esac
}

most_urgent_pane_state() {
  local window="$1"
  local pane_state rank best="" best_rank=0

  while IFS= read -r pane_state; do
    [ -n "$pane_state" ] || continue
    rank=$(state_rank "$pane_state")
    if [ "$rank" -gt "$best_rank" ]; then
      best_rank="$rank"
      best="$pane_state"
    fi
  done < <(tmux list-panes -t "$window" -F "#{${PANE_OPTION}}" 2>/dev/null)

  printf '%s' "$best"
}

if [ "${1:-}" = off ]; then
  tmux set-option -q -p -u -t "$TMUX_PANE" "$PANE_OPTION" 2>/dev/null
else
  tmux set-option -q -p -t "$TMUX_PANE" "$PANE_OPTION" "${1:-}" 2>/dev/null
fi

window=$(tmux display-message -p -t "$TMUX_PANE" '#{window_id}' 2>/dev/null)
[ -n "$window" ] || exit 0

window_state=$(most_urgent_pane_state "$window")
if [ -n "$window_state" ]; then
  tmux set-option -q -w -t "$window" "$WINDOW_OPTION" "$window_state" 2>/dev/null
else
  tmux set-option -q -w -u -t "$window" "$WINDOW_OPTION" 2>/dev/null
fi

exit 0
