---
name: write-commit
description: Inspect a provided diff or the current Git working tree and draft a clear commit message plus a copy-ready commit description. Use when the user asks to write, suggest, improve, or review a commit message or commit description, including requests such as "write me commit message and description of this diff". Do not create the commit unless the user explicitly asks to commit.
---

# Write Commit

Draft an accurate commit message and description from the actual changes. Describe intent and user-visible impact without inventing behavior, tests, or issue references.

## Workflow

1. Determine the source of truth:
   - Analyze a diff supplied by the user when present.
   - Otherwise, inspect `git status --short`, `git diff --cached`, and `git diff`.
   - Prefer the staged diff when staged changes exist. Clearly state when the output covers staged changes only.
   - Inspect relevant untracked files before including them; `git diff` does not show their contents.
2. Check recent commit subjects with `git log -10 --oneline` and follow the repository's established language and convention when it is consistent.
3. Identify the primary change, its scope, and why it matters. Distinguish behavioral changes from refactors, formatting, tests, and configuration.
4. If the diff contains unrelated changes, flag that briefly and propose separate commit messages. Do not stage, edit, discard, or commit files unless explicitly requested.
5. Produce concise, copy-ready output.

## Message Guidelines

- Use Conventional Commits when the repository already uses them: `<type>(<scope>): <summary>`.
- Choose the narrowest accurate type, such as `feat`, `fix`, `refactor`, `test`, `docs`, `build`, `chore`, or `style`.
- Use an imperative, specific subject without a trailing period.
- Keep the subject near 72 characters when practical.
- Focus the description on the reason and meaningful effects, not a file-by-file inventory.
- Wrap description lines for readability when practical.
- Never claim that checks passed unless they were actually run successfully.
- Mention breaking changes only when the diff demonstrates one.

## Output Format

Return this structure unless the user requests another format:

```text
Commit message
<one-line subject>

Description
- <meaningful change or motivation>
- <meaningful effect or implementation detail>
```

When one short paragraph communicates the description better than bullets, use a paragraph. Add a brief note outside the copy-ready block only for important scope concerns, such as unrelated changes or an incomplete diff.
