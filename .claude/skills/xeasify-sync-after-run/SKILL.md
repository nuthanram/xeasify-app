---
name: xeasify-sync-after-run
description: After ANY run in this Xeasify repo (install, build, test, lint, dev server, scripts, codegen, migrations), check git for resulting changes. Push the diff to main if it is required; if a changed/untracked file is not required in the repo, add it to .gitignore instead of committing it.
---

# Xeasify: sync the diff after every run

Applies to every Xeasify repo (xeasify-app, xeasify-core, xeasify-infra, xeasify-web). Works together with `xeasify-main-only` — follow its branch rule and changelog format.

## After any run

"Run" means anything that can change the working tree: install, build, test, lint, formatters, dev server, scripts, code generation, migrations.

1. Run `git status --short` and review the diff (`git diff`, plus the contents of new untracked files).
2. Triage every changed or untracked file:
   - **Required** (source, config, lockfiles, tests, docs, CHANGELOG.md) → keep it for the commit.
   - **Not required** (build output, caches, virtualenvs, test/coverage reports, logs, IDE/OS files, local data, anything generated or machine-specific) → do **not** commit it. Add a pattern for it to `.gitignore` (create `.gitignore` if the repo has none). If it is already tracked, untrack it with `git rm --cached <path>` and commit that removal.
   - **Secrets** (`.env`, keys, tokens, credentials) → never commit; make sure they are in `.gitignore`.
3. Prefer a precise pattern in `.gitignore` (e.g. `playwright-report/`) over ignoring broad directories. Don't ignore a file that other contributors need to build or run the project.
4. If a file is unclear (required or not), ask the user instead of guessing.

## Then push

1. Confirm the branch is `main` (`git branch --show-current`).
2. Append an entry to the top of `CHANGELOG.md` for the change, per `xeasify-main-only`. Mention any new `.gitignore` entries there.
3. Stage the required files and the `.gitignore` update, commit with the user's own git identity (no Claude co-author trailer), then `git push origin main`.
4. If the push is rejected, `git pull --rebase origin main`, then push again. Never force-push, never push other branches.
5. If the run produced no required changes, do nothing — no empty commits, no changelog entry.
6. Finish by checking `git status -sb` shows a clean tree in sync with `origin/main`.
