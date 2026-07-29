#!/usr/bin/env bats

WORK_ONLY_PATTERNS="runlayer aiwatch aicodemetricsd betterment-tools circleci atlassian"

render() {
	printf '[data]\nwork = %s\n' "$1" >"$BATS_TEST_TMPDIR/chezmoi.toml"
	chezmoi -c "$BATS_TEST_TMPDIR/chezmoi.toml" --config-format=toml \
		execute-template <"$BATS_TEST_DIRNAME/private_settings.json.tmpl"
}

count_matches() {
	grep -ci "$1" <<<"$2" || true
}

@test "personal profile excludes every work-only tool" {
	run render false
	[ "$status" -eq 0 ]

	local leaked=""
	for pattern in $WORK_ONLY_PATTERNS; do
		if [ "$(count_matches "$pattern" "$output")" -ne 0 ]; then
			leaked="$leaked $pattern"
		fi
	done
	[ -z "$leaked" ] || {
		echo "personal profile leaked:$leaked"
		false
	}
}

@test "personal profile keeps the rtk and symlink hooks" {
	run render false
	[ "$status" -eq 0 ]
	[ "$(count_matches "rtk-rewrite.sh" "$output")" -eq 1 ]
	[ "$(count_matches "symlink-plan.sh" "$output")" -eq 1 ]
}

@test "work profile registers aiwatch on every hook event" {
	run render true
	[ "$status" -eq 0 ]
	[ "$(count_matches "runlayer/aiwatch/aiwatch" "$output")" -eq 16 ]
}

@test "work profile registers the dx code metrics hooks" {
	run render true
	[ "$status" -eq 0 ]
	[ "$(count_matches "aicodemetricsd" "$output")" -eq 5 ]

	local events
	events=$(python3 -c '
import json, sys
cfg = json.load(sys.stdin)
print(" ".join(sorted(
    event
    for event, entries in cfg["hooks"].items()
    for entry in entries
    for hook in entry["hooks"]
    if "aicodemetricsd" in hook["command"]
)))' <<<"$output")
	[ "$events" = "PostToolUse PreCompact PreToolUse SessionEnd SessionStart" ]
}

@test "work profile matches dx edit hooks to write tools only" {
	run render true
	[ "$status" -eq 0 ]

	local matchers
	matchers=$(python3 -c '
import json, sys
cfg = json.load(sys.stdin)
pairs = []
for event, entries in sorted(cfg["hooks"].items()):
    for entry in entries:
        for hook in entry["hooks"]:
            if "aicodemetricsd" in hook["command"]:
                pairs.append(event + "=" + entry.get("matcher", "-"))
print(" ".join(pairs))' <<<"$output")
	[ "$matchers" = "PostToolUse=Write|Edit|MultiEdit PreCompact=- PreToolUse=Write|Edit|MultiEdit SessionEnd=- SessionStart=-" ]
}

@test "work profile keeps betterment plugins and circleci access" {
	run render true
	[ "$status" -eq 0 ]
	[ "$(count_matches "betterment-tools" "$output")" -eq 4 ]
	[ "$(count_matches "circleci" "$output")" -eq 4 ]
}

@test "sandbox paths are absolute so claude code cannot rewrite them" {
	run render true
	[ "$status" -eq 0 ]

	local paths
	paths=$(python3 -c '
import json, sys
cfg = json.load(sys.stdin)
sandbox = cfg["sandbox"]
print("\n".join(sandbox["network"]["allowUnixSockets"] + sandbox["filesystem"]["allowWrite"]))' <<<"$output")
	[ -n "$paths" ]
	[ "$(grep -c '^/' <<<"$paths")" -eq "$(wc -l <<<"$paths" | tr -d ' ')" ]
}

@test "both profiles render valid json" {
	for profile in true false; do
		run render "$profile"
		[ "$status" -eq 0 ]
		echo "$output" | python3 -m json.tool >/dev/null
	done
}
