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
Usage: git-llm-annotate [-l, --llm-name <llm-name>] [-M, --mode <mode-string>] [--commit] [<commit-hash>]
  -l, --llm-name <llm-name>    LLM name (default: from git config llm.name or 'LLM')
  -M, --mode <mode-string>     Optional mode string
  --commit                     Create new commit instead of amending
  <commit-hash>                Commit to annotate (default: HEAD)
```

Usually, once configured, you'll just call `git-llm-annotate` (with no arguments) after you've committed an
LLM-driven change.

## Explanation

**`llm-name`** indicates which model you are using, or just that you were using an LLM at all. It retains your ownership,
but changes the author to `LLM Name <your.email@gmail.com>`. This changes which name is showed in `git blame`.

It also saved as the git-trailer:

```
AI-Generated: LLM Name
```

You can define it at the command-line, or define it per-repo or globally in your git config.

**`mode`** optionally indicates some other useful string about your LLM-driven workflow.
For example: `unreviewed`, `reviewed`, `modified`.

It is saved as the git-trailer:

```
AI-Generated-Mode: reviewed
```
