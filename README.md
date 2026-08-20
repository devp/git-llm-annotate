# git-llm-annotate

Utility to annotate git commits to indicate LLM usage, for the purpose of:

- better `git blame` usage
- adding git-trailers that may be useful for code review

Inspired by: [http://gitai.run]. This is a much more modest version that can be adopted as part of your own
workflow without requiring larger change in your codebase or org. It is implemented as simple bash scripts
that should be portable.

## Usage

```
❯ git-llm-annotate --help
Usage: git-llm-annotate [-n, --trailer-name <name>] [-t, --traits <trait,trait,...>] [--allowed-traits <trait,trait,...>] [--commit] [<commit-hash>]
  -n, --trailer-name <name>       Trailer name (default: from git config llm-annotate.trailer-name or 'LLM-Annotate')
  -t, --traits <trait,trait,...>  Comma-separated traits; skips interactive picker
      --allowed-traits <list>     Comma-separated allowed traits (default: from git config llm-annotate.allowed-traits or built-in list)
  --commit                        Create new commit instead of amending
  <commit-hash>                   Commit to annotate (default: HEAD)
```

Usually, once configured, you'll just call `git-llm-annotate` (with no arguments) after you've committed an
LLM-driven change, then pick traits interactively.

## Explanation

Each commit gets a single git-trailer whose body is a comma-separated list of traits describing how the LLM
was involved:

```
LLM-Annotate: LLM-Guided, Human-Author-Reviewed
```

**Traits** must come from an allowed list, so trailers stay consistent and greppable across a repo. The
built-in default list is:

- `LLM-Generated`
- `LLM-Guided`
- `LLM-Reviewed`
- `Human-Author-Skimmed`
- `Human-Author-Reviewed`
- `Human-Reviewer-Approved`

Override it per-repo or globally with `git config llm-annotate.allowed-traits "Trait-A,Trait-B,..."`, or
for a single invocation with `--allowed-traits`.

**Trailer name** defaults to `LLM-Annotate`. Override it with `git config llm-annotate.trailer-name <name>`
or `-n/--trailer-name`.

**Picking traits**: if you don't pass `-t/--traits`, git-llm-annotate opens an interactive picker. It uses
[`zf`](https://github.com/natecraddock/zf) or [`fzf`](https://github.com/junegunn/fzf) (multi-select) if
either is installed, falling back to a plain prompt-in-a-loop otherwise.
