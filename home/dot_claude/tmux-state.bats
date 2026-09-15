#!/usr/bin/env bats

setup() {
	SCRIPT="$BATS_TEST_DIRNAME/executable_tmux-state.sh"
	TMUX_LOG="$BATS_TEST_TMPDIR/tmux-args"
	STUB_DIR="$BATS_TEST_TMPDIR/bin"
	mkdir -p "$STUB_DIR"

	cat >"$STUB_DIR/tmux" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TMUX_LOG"
[ -z "$STUB_TMUX_FAILS" ] || exit 1
case "$1" in
display-message) printf '%s\n' "$STUB_WINDOW_ID" ;;
list-panes) printf '%s\n' $STUB_PANE_STATES ;;
esac
exit 0
STUB
	chmod +x "$STUB_DIR/tmux"

	PATH="$STUB_DIR:$PATH"
	export PATH TMUX_LOG
	export TMUX="/tmp/tmux-501/default,1,0"
	export TMUX_PANE="%7"
	export STUB_WINDOW_ID="@3"
	export STUB_PANE_STATES=""
	export STUB_TMUX_FAILS=""
}

logged() {
	grep -qxF "$1" "$TMUX_LOG"
}

window_writes() {
	grep -F -- "-w " "$TMUX_LOG" || true
}

@test "records the state on the pane that claude runs in" {
	STUB_PANE_STATES="blocked" run "$SCRIPT" blocked
	[ "$status" -eq 0 ]
	logged "set-option -q -p -t %7 @claude_pane blocked"
}

@test "aggregates the pane states onto the window" {
	STUB_PANE_STATES="blocked" run "$SCRIPT" blocked
	[ "$status" -eq 0 ]
	logged "set-option -q -w -t @3 @claude blocked"
}

@test "the window shows the most urgent pane when panes disagree" {
	STUB_PANE_STATES="busy idle blocked" run "$SCRIPT" busy
	[ "$status" -eq 0 ]
	logged "set-option -q -w -t @3 @claude blocked"
}

@test "a finished pane outranks a working pane" {
	STUB_PANE_STATES="busy idle busy" run "$SCRIPT" busy
	[ "$status" -eq 0 ]
	logged "set-option -q -w -t @3 @claude idle"
}

@test "off unsets the pane option" {
	STUB_PANE_STATES="" run "$SCRIPT" off
	[ "$status" -eq 0 ]
	logged "set-option -q -p -u -t %7 @claude_pane"
}

@test "off clears the window when no pane is left in a state" {
	STUB_PANE_STATES="" run "$SCRIPT" off
	[ "$status" -eq 0 ]
	logged "set-option -q -w -u -t @3 @claude"
}

@test "off keeps the window flagged while another pane still needs you" {
	STUB_PANE_STATES="blocked" run "$SCRIPT" off
	[ "$status" -eq 0 ]
	logged "set-option -q -w -t @3 @claude blocked"
}

@test "does nothing at all outside tmux" {
	unset TMUX
	run "$SCRIPT" blocked
	[ "$status" -eq 0 ]
	[ ! -f "$TMUX_LOG" ]
}

@test "does nothing when the pane is unknown" {
	unset TMUX_PANE
	run "$SCRIPT" blocked
	[ "$status" -eq 0 ]
	[ ! -f "$TMUX_LOG" ]
}

@test "never fails a claude hook when tmux errors" {
	STUB_TMUX_FAILS=1 run "$SCRIPT" blocked
	[ "$status" -eq 0 ]
}
