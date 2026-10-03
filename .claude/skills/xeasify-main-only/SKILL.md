---
name: xeasify-main-only
description: Mandatory workflow for ANY change in this Xeasify repo — editing files, committing, or pushing. Read CHANGELOG.md before making a change, push only to the main branch (never create or push other branches), and append an entry to CHANGELOG.md for every change.
---

# Xeasify: main-only pushes + changelog

Applies to every Xeasify repo (xeasify-app, xeasify-core, xeasify-infra, xeasify-web).

## Before making any change

1. Read `CHANGELOG.md` at the repo root in full, so the change builds on what was already done and doesn't repeat or contradict it.
2. Confirm the current branch is `main` (`git branch --show-current`). If not, switch to `main` and pull (`git pull origin main`) before editing.

## Branch rule

- Push changes **only to `main`**: `git push origin main`.
- Do **not** create, push, or open PRs from other branches, even for dummy/test changes.
- Do not force-push. If the push is rejected, `git pull --rebase origin main`, then push again.

## After making a change

1. Append an entry to the **top** of `CHANGELOG.md` (newest first), in this format:

   ```
   ## YYYY-MM-DD — <short title>
   - What changed: <files / behaviour>
   - Why: <reason>
   ```

2. Include `CHANGELOG.md` in the same commit as the change.
3. Commit, then `git push origin main`.
