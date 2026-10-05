#!/usr/bin/env bats

setup() {
	SCRIPT="$BATS_TEST_DIRNAME/executable_tmux-piserv1"
	TMUX_LOG="$BATS_TEST_TMPDIR/tmux-args"
	STUB_DIR="$BATS_TEST_TMPDIR/bin"
	mkdir -p "$STUB_DIR"

	cat >"$STUB_DIR/tmux" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TMUX_LOG"
case "$1" in
has-session) [ -n "$STUB_SESSION_EXISTS" ] ;;
esac
STUB
	chmod +x "$STUB_DIR/tmux"

	PATH="$STUB_DIR:$PATH"
	export PATH TMUX_LOG
	export STUB_SESSION_EXISTS=""
}

logged() {
	grep -qxF "$1" "$TMUX_LOG"
}

@test "creates the piserv1 session with a claude window" {
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	logged "new-session -d -s piserv1 -n claude -c $HOME"
}

@test "runs claude rc with subscription auth inside a shell in the claude window" {
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	logged "send-keys -t piserv1:claude env -u ANTHROPIC_API_KEY claude rc C-m"
}

@test "adds a shell window" {
	run "$SCRIPT"
	[ "$status" -eq 0 ]
	logged "new-window -d -t piserv1 -n shell -c $HOME"
}

@test "leaves an existing session untouched" {
	STUB_SESSION_EXISTS=1 run "$SCRIPT"
	[ "$status" -eq 0 ]
	[ "$(cat "$TMUX_LOG")" = "has-session -t piserv1" ]
}
