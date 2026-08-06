#!/usr/bin/env bats

render() {
	printf '[data]\nwork = %s\n' "${1:-true}" >"$BATS_TEST_TMPDIR/chezmoi.toml"
	chezmoi -c "$BATS_TEST_TMPDIR/chezmoi.toml" --config-format=toml \
		execute-template <"$BATS_TEST_DIRNAME/config.toml.tmpl"
}

declaration_line() {
	local match
	match="$(render | grep --line-number --extended-regexp "^$1[[:space:]]+=")"
	printf '%s' "${match%%:*}"
}

@test "npm is declared before node so mise orders its bin dir first on PATH" {
	local npm_line node_line
	npm_line="$(declaration_line npm)"
	node_line="$(declaration_line node)"
	[ -n "$npm_line" ]
	[ -n "$node_line" ]
	[ "$npm_line" -lt "$node_line" ]
}

@test "the github cli tracks latest rather than a pinned version" {
	render | grep --quiet --extended-regexp '^github-cli[[:space:]]+= "latest"'
}

@test "tool installs are gated behind a minimum release age" {
	render | grep --quiet --fixed-strings 'minimum_release_age = "7d"'
}

@test "a work machine takes the bootstrap postinstall hook" {
	render true | grep --quiet --fixed-strings '.bootstrap/resources/mise_hooks/postinstall'
}

@test "a personal machine takes its own hook and is never pointed at bootstrap" {
	run render false
	[ "$status" -eq 0 ]
	[[ "$output" == *".config/mise/hooks/postinstall.sh"* ]]
	[[ "$output" != *".bootstrap"* ]]
}

@test "the rendered config is valid toml" {
	run render
	[ "$status" -eq 0 ]
	echo "$output" | python3 -c 'import sys, tomllib; tomllib.loads(sys.stdin.read())'
}
