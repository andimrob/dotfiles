#!/usr/bin/env bats

render_init() {
	printf '[data]\nname = "Test"\nemail = "%s"\ngithubUsername = "test"\n' "$1" \
		>"$BATS_TEST_TMPDIR/chezmoi.toml"
	chezmoi -c "$BATS_TEST_TMPDIR/chezmoi.toml" --config-format=toml \
		execute-template --init <"$BATS_TEST_DIRNAME/.chezmoi.toml.tmpl"
}

data_flag() {
	render_init "$2" | sed -n "s/^[[:space:]]*$1 = \(.*\)$/\1/p"
}

@test "a betterment email marks the machine as work whatever its hostname is" {
	[ "$(data_flag work robert.white@betterment.com)" = "true" ]
}

@test "a non betterment email leaves the machine personal" {
	[ "$(data_flag work rob@personal.example)" = "false" ]
}

@test "a work machine is never granted personal secrets" {
	[ "$(data_flag personal robert.white@betterment.com)" = "false" ]
}

@test "the rendered config is valid toml" {
	run render_init robert.white@betterment.com
	[ "$status" -eq 0 ]
	echo "$output" | python3 -c 'import sys, tomllib; tomllib.loads(sys.stdin.read())'
}
