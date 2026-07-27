---
name: orchestrate
description: Use when dispatching work to another registered project from JZ orchestrator mode — spawns a headless claude -p session with edit-but-no-push/send/trade guardrails, reads SESSION_CONTEXT.md first, and reports the uncommitted diff.
---

# Orchestrate

Procedure for dispatching a headless agent into a registered project.

## Preconditions
1. Target is in `projects-registry.md`. If not, stop and ask the user to add it.
2. If the target is EXTRA-LOCKED (trading/crypto), get an explicit per-run greenlight before spawning.
3. If the target is `my-agent`, state plainly that this is a dispatch-to-self.

## Spawn template
`$SCRATCH` = this session's scratchpad directory. Run one per target, in the background, so targets run in parallel:

```bash
mkdir -p "$SCRATCH/orchestrate"
cd /Users/mrohan/Documents/<project> && \
claude -p "First read ./SESSION_CONTEXT.md for current state. Then: <user prompt>" \
  --permission-mode acceptEdits \
  --allowedTools "Read Edit Write <stack-safe-bash>" \
  --disallowedTools "Bash(git push:*) Bash(git commit:*) mcp__gmail__send_email" \
  --append-system-prompt "You are a dispatched sub-agent. NEVER git push, NEVER commit, NEVER send email/messages, NEVER place trades/orders or move money. Make edits and run tests only. Leave changes uncommitted for review." \
  --output-format stream-json --verbose \
  > "$SCRATCH/orchestrate/$(date +%Y%m%d-%H%M%S)-<project>.log" 2>&1
```

- `<project>` path: use the exact path from `projects-registry.md`.
- Registry `edit-eligible: no` → use `--permission-mode plan` and drop `Write Edit` from `--allowedTools` (proposals only).
- `<stack-safe-bash>` by stack:
  - Python: `Bash(pytest:*) Bash(python:*) Bash(python3:*) Bash(ruff:*)`
  - Node: `Bash(npm test:*) Bash(npm run build:*) Bash(node:*)`
  - Always add: `Bash(git status:*) Bash(git diff:*) Bash(ls:*) Bash(cat:*)`
- Why this is safe: in headless mode any tool not on the allowlist is auto-denied, so push/commit/send/trade cannot run. `--disallowedTools` + the system prompt are defense-in-depth.
- `--verbose` is REQUIRED: `--print` + `--output-format stream-json` errors out without it. Do not remove it.

## Report
When each run finishes, report per project:
- project name + exit status
- summary of what the agent did (from its log)
- the `git diff` it produced (uncommitted)

Never auto-commit or auto-push.

## After the run
- Refresh the project's `SESSION_CONTEXT.md` with new state / next actions drawn from the run. This is an edit surfaced in the diff — not a commit.
- Commit / push / merge / send require explicit user approval, one per action.
