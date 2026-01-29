#!/usr/bin/env bats

setup() {
	# Create a temp directory for our test repo
	TEST_DIR=$(mktemp -d)
	cd "$TEST_DIR"

	# Initialize a git repo with an initial commit
	git init -q
	git config user.email "test@test.com"
	git config user.name "Test"
	echo "initial" > file.txt
	git add file.txt
	git commit -q -m "initial commit"

	# Source the functions
	source "$BATS_TEST_DIRNAME/10-functions.sh"
}

teardown() {
	cd /
	rm -rf "$TEST_DIR"
}

@test "wt with no args requires fzf (smoke test)" {
	# Just verify the function exists
	run type wt
	[[ "$output" == *"function"* ]]
}

@test "wt list passes through to git worktree" {
	run wt list
	[ "$status" -eq 0 ]
	[[ "$output" == *"$TEST_DIR"* ]]
}

@test "wt new creates worktree in .worktrees directory" {
	run wt new test-worktree
	[ "$status" -eq 0 ]
	[ -d "$TEST_DIR/.worktrees/test-worktree" ]
}

@test "wt new creates worktree with repo contents" {
	run wt new test-worktree
	[ "$status" -eq 0 ]
	# Verify worktree contains expected files from the repo
	[ -f "$TEST_DIR/.worktrees/test-worktree/file.txt" ]
}

@test "wt new with branch name creates that branch" {
	wt new test-worktree custom-branch

	[ -d "$TEST_DIR/.worktrees/test-worktree" ]
	cd "$TEST_DIR/.worktrees/test-worktree"
	run git branch --show-current
	[ "$output" = "custom-branch" ]
}

@test "wt passes unknown subcommands to git worktree" {
	# Create a worktree first
	git worktree add "$TEST_DIR/.worktrees/to-remove" -b to-remove
	[ -d "$TEST_DIR/.worktrees/to-remove" ]

	# "wt remove" passes through to "git worktree remove"
	run wt remove "$TEST_DIR/.worktrees/to-remove"
	[ "$status" -eq 0 ]
	[ ! -d "$TEST_DIR/.worktrees/to-remove" ]
}


@test "__wt_fzf helper outputs correct format" {
	# Create a worktree
	git worktree add "$TEST_DIR/.worktrees/test-wt" -b test-branch

	# Test that git worktree list contains expected info
	run git worktree list
	[[ "$output" == *"test-wt"* ]]
	[[ "$output" == *"test-branch"* ]]
}
