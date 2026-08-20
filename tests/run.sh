#!/bin/bash
# Test suite for git-llm-annotate. Run with: tests/run.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SCRIPT="$SCRIPT_DIR/../git-llm-annotate"

pass_count=0
fail_count=0

repo=""
cleanup() {
    [[ -n "$repo" && -d "$repo" ]] && rm -rf "$repo"
}
trap cleanup EXIT

new_repo() {
    cleanup
    repo=$(mktemp -d)
    cd "$repo"
    git init -q
    git config user.name "Test User"
    git config user.email "test@example.com"
    echo "content" > f.txt
    git add f.txt
    git commit -qm "init"
}

stage_change() {
    echo "more" >> f.txt
    git add f.txt
}

last_commit_body() {
    git log -1 --format="%B"
}

assert_eq() {
    local desc="$1" expected="$2" actual="$3"
    if [[ "$expected" == "$actual" ]]; then
        pass_count=$((pass_count + 1))
    else
        fail_count=$((fail_count + 1))
        echo "FAIL: $desc"
        echo "  expected: $expected"
        echo "  actual:   $actual"
    fi
}

assert_contains() {
    local desc="$1" haystack="$2" needle="$3"
    if [[ "$haystack" == *"$needle"* ]]; then
        pass_count=$((pass_count + 1))
    else
        fail_count=$((fail_count + 1))
        echo "FAIL: $desc"
        echo "  expected to contain: $needle"
        echo "  actual: $haystack"
    fi
}

# --- tests ---

test_default_trailer_amend() {
    new_repo
    "$SCRIPT" -t "LLM-Guided, Human-Author-Reviewed" >/dev/null
    assert_contains "default trailer name, amend" "$(last_commit_body)" "LLM-Annotate: LLM-Guided, Human-Author-Reviewed"
}

test_invalid_trait_rejected() {
    new_repo
    out=$("$SCRIPT" -t "Not-A-Trait" 2>&1)
    code=$?
    assert_eq "invalid trait exits 1" "1" "$code"
    assert_contains "invalid trait error names the bad trait" "$out" "'Not-A-Trait' is not an allowed trait"
}

test_custom_trailer_name_and_allowed_traits() {
    new_repo
    stage_change
    "$SCRIPT" -n "AI" --allowed-traits "Foo,Bar" -t "Foo" --commit >/dev/null
    assert_contains "custom trailer name + allowed-traits" "$(last_commit_body)" "AI: Foo"
}

test_trait_outside_custom_allowed_list_rejected() {
    new_repo
    stage_change
    out=$("$SCRIPT" --allowed-traits "Foo,Bar" -t "LLM-Generated" --commit 2>&1)
    code=$?
    assert_eq "trait outside custom allowed list exits 1" "1" "$code"
    assert_contains "custom allowed-traits error names bad trait" "$out" "'LLM-Generated' is not an allowed trait"
}

test_git_config_defaults() {
    new_repo
    git config llm-annotate.trailer-name "AI-Annotate"
    git config llm-annotate.allowed-traits "X,Y,Z"
    stage_change
    "$SCRIPT" -t "X, Z" --commit >/dev/null
    assert_contains "git config trailer-name and allowed-traits honored" "$(last_commit_body)" "AI-Annotate: X, Z"
}

test_fallback_loop_no_picker() {
    new_repo
    stage_change
    out=$(printf "LLM-Generated\nbogus\nLLM-Reviewed\n\n" | PATH=/usr/bin:/bin "$SCRIPT" --commit 2>&1)
    assert_contains "fallback loop rejects invalid entry" "$out" "'bogus' is not an allowed trait"
    assert_contains "fallback loop accepts valid entries" "$(last_commit_body)" "LLM-Annotate: LLM-Generated, LLM-Reviewed"
}

test_no_traits_selected_errors() {
    new_repo
    out=$("$SCRIPT" -t "" 2>&1)
    code=$?
    assert_eq "empty traits exits 1" "1" "$code"
    assert_contains "empty traits error message" "$out" "no traits selected"
}

test_non_head_commit_creates_empty_commit() {
    new_repo
    target=$(git rev-parse HEAD)
    stage_change
    git commit -qm "second"
    "$SCRIPT" -t "LLM-Generated" "$target" >/dev/null 2>&1
    assert_contains "non-HEAD commit creates empty annotate commit" "$(last_commit_body)" "git-llm-annotate for $target"
    assert_contains "non-HEAD commit still carries trailer" "$(last_commit_body)" "LLM-Annotate: LLM-Generated"
}

test_help_exits_nonzero() {
    new_repo
    out=$("$SCRIPT" --help 2>&1)
    code=$?
    assert_eq "--help exits 1" "1" "$code"
    assert_contains "--help prints usage" "$out" "Usage:"
}

test_default_trailer_amend
test_invalid_trait_rejected
test_custom_trailer_name_and_allowed_traits
test_trait_outside_custom_allowed_list_rejected
test_git_config_defaults
test_fallback_loop_no_picker
test_no_traits_selected_errors
test_non_head_commit_creates_empty_commit
test_help_exits_nonzero

cleanup
trap - EXIT

echo ""
echo "passed: $pass_count, failed: $fail_count"
[[ "$fail_count" -eq 0 ]]
