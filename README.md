# git-llm-annotate

Bash utility that adds a git-trailer to commits describing LLM involvement for code review
and provenance transparency.

Adds a trailer like:

```
LLM-Annotate: LLM-Guided, Human-Author-Reviewed
```

## Usage

```
❯ git-llm-annotate --help
Usage: git-llm-annotate [-n, --trailer-name <name>] [-t, --traits <trait,trait,...>|REMOVE] [--allowed-traits <trait,trait,...>] [--commit] [<commit-hash>]
  -n, --trailer-name <name>       Trailer name (default: from git config llm-annotate.trailer-name or 'LLM-Annotate')
  -t, --traits <trait,trait,...>  Comma-separated traits; skips interactive picker. 'REMOVE' deletes the existing trailer
      --allowed-traits <list>     Comma-separated allowed traits (default: from git config llm-annotate.allowed-traits or built-in list)
  --commit                        Create new commit instead of amending
  <commit-hash>                   Commit to amend (default: HEAD); rebases descendants if not HEAD
```

Usually you just run `git-llm-annotate` after committing an LLM-driven change, then pick traits
interactively. Picker uses [`zf`](https://github.com/natecraddock/zf) or
[`fzf`](https://github.com/junegunn/fzf) if installed, else a plain prompt loop.

## Traits

Must come from an allowed list (stays greppable). Built-in default:

`LLM-Generated`, `LLM-Guided`, `LLM-Reviewed`, `Human-Author-Skimmed`, `Human-Author-Reviewed`,
`Human-Reviewer-Approved`

Override via `git config llm-annotate.allowed-traits "Trait-A,Trait-B,..."` or `--allowed-traits`.
Trailer name defaults to `LLM-Annotate`; override via `git config llm-annotate.trailer-name <name>` or
`-n/--trailer-name`.

## Notes

- **Removing a trailer**: `-t REMOVE`, or pick the `(remove annotation...)` entry in the interactive
  picker when a trailer already exists on the target commit.
- **Non-HEAD `<commit-hash>`**: must be an ancestor of HEAD, working tree must be clean. Descendants get
  rebased onto the amended commit (trees untouched, hashes change). Commit count printed before rewriting.
  - **Warning: rebase at your own risk!!**

## Credits

- Inspired by to [http://gitai.run], thank you!
