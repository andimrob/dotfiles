#!/usr/bin/env bats

setup() {
	printf '[data]\nwork = true\npersonal = false\n' >"$BATS_TEST_TMPDIR/chezmoi.toml"
	CODEX_RULES="$BATS_TEST_TMPDIR/claude.rules"
}

render() {
	chezmoi -c "$BATS_TEST_TMPDIR/chezmoi.toml" --config-format=toml \
		--source "$BATS_TEST_DIRNAME/.." --destination "$BATS_TEST_TMPDIR/home" \
		execute-template --with-stdin --file "$BATS_TEST_DIRNAME/$1"
}

render_rules() {
	[ -f "$BATS_TEST_DIRNAME/rules/claude.rules.tmpl" ]
	render rules/claude.rules.tmpl </dev/null >"$CODEX_RULES"
}

decision() {
	codex execpolicy check --rules "$CODEX_RULES" -- "$@" |
		python3 -c 'import json, sys; print(json.load(sys.stdin).get("decision", "unmatched"))'
}

@test "shared development commands are allowed by Codex" {
	render_rules
	for command in 'npm run lint' 'yarn install' 'pnpm run build' 'bundle install' 'rubocop app.rb' 'prettier --check .' 'eslint .' 'git status' 'git diff HEAD' 'git log -5' 'git branch --show-current' 'pytest tests' 'rspec spec' 'jest' 'vitest run'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = allow ]
	done
}

@test "work rules allow commits, direct pnpm tasks, searches, and RTK commands" {
	render_rules
	for command in 'git commit -m example' 'pnpm test --run' 'pnpm lint' 'pnpm typecheck' 'rtk grep pattern' 'rtk git show HEAD' 'rtk gh pr view 123' 'rtk gh api repos/owner/repo' 'rg pattern' 'find . -name README.md'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = allow ]
	done
}

@test "push, infrastructure, and recursive removal require approval" {
	render_rules
	for command in 'git push origin main' 'git push --force origin main' 'git force-push origin main' 'docker ps' 'kubectl get pods' 'rm -rf build'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = prompt ]
	done
}

@test "wildcard arguments and unrelated commands never become blanket allows" {
	render_rules
	for command in 'pnpm --dir app test' 'pnpm --filter app test' 'pnpm --dir app exec arbitrary' 'pnpm publish' 'git reset --hard' 'rtk git reset --hard' 'bash -c arbitrary'; do
		read -r -a args <<<"$command"
		[ "$(decision "${args[@]}")" = unmatched ]
	done
}

@test "personal rules retain shared permissions without work-only allows" {
	printf '[data]\nwork = false\npersonal = true\n' >"$BATS_TEST_TMPDIR/chezmoi.toml"
	render_rules
	[ "$(decision npm run lint)" = allow ]
	[ "$(decision git push origin main)" = prompt ]
	[ "$(decision git commit -m example)" = unmatched ]
	[ "$(decision rtk gh api repos/owner/repo)" = unmatched ]
}
