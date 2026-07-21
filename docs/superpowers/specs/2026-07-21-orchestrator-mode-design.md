# Orchestrator Mode — Design Spec

**Date:** 2026-07-21
**Status:** Approved (design), pending implementation plan

## Summary

JZ gains a second operating mode, **Orchestrator**, layered on top of the existing
email-triage / project-tracking persona. In orchestrator mode, JZ (running in the
`my-agent` project) dispatches headless `claude -p` sessions into other project
directories under `~/Documents`, so the user can remote-control multi-project work
from a single session. The email/triage/project-tracking role is retained unchanged;
orchestration is additive.

## Decisions (locked)

| Dimension | Decision |
|-----------|----------|
| Agent mechanism | Spawn headless `claude -p` sessions, one per target project dir |
| Control channel | This Claude Code session (user types prompts directly) |
| Concurrency | Parallel — background runs, results collected as they finish |
| Permission posture | Edit + run tests; **never** git push, send, or place trades/transactions |
| Role scope | Additive — orchestration on top of existing JZ persona |

## Non-Goals (YAGNI)

- No Discord / queue / file-watch control channel (this session only).
- No always-on daemon or scheduler.
- No cross-project shared state beyond the registry + per-run logs.
- No auto-commit, auto-push, or auto-merge — ever.
- No new agent personas authored inside the target projects; each project uses its
  own existing `CLAUDE.md` (or none).

## Architecture

Three artifacts in `my-agent/`, plus a per-run log convention:

### 1. Orchestrator persona (`CLAUDE.md`)

Add a top-level **Orchestrator Mode** section to `my-agent/CLAUDE.md`:

- **Mode routing:** A prompt triggers orchestrator mode when it names another
  registered project, or uses dispatch language ("dispatch", "agents", "across
  projects", "in <project>"). Otherwise JZ behaves as the existing email/project
  assistant. When ambiguous which project is meant, JZ asks (consistent with the
  existing "ambiguous scope → ask" rule).
- **Inheritance:** `agent.md` hard-rules bind both modes. Orchestrator mode adds
  no exceptions to them — never send, never trade, never push, no batch mutation
  without an approved list.

### 2. Project registry (`projects-registry.md`)

The authoritative map of orchestratable projects. JZ never dispatches to a project
absent from this file. One entry per project:

```
### <dir-name>
- path: /Users/mrohan/Documents/<dir-name>
- purpose: <one line>
- edit-eligible: yes | no        # no = read/plan only, diffs surfaced but no writes
- guardrails: <per-project notes; e.g. "extra-locked: no live-trade code paths">
- has-own-claude-md: yes | no
```

Registry is populated by JZ from the Documents dirs and **approved row-by-row by the
user** before first use. The two trading projects (`alpaca-trading-bot`,
`covered-call-income`) are marked **extra-locked**: their live-order / execution code
paths are not to be modified by a spawned agent without an explicit per-run greenlight
from the user, and the standard "no trades/transactions" denial always applies.

### 3. Dispatch skill (`skills/orchestrate/SKILL.md`)

Documents the repeatable dispatch pattern so invocations are consistent, not
improvised. Contains the canonical spawn template (below), the flow, and the
reporting format.

### 4. Per-run logs

Each spawned run streams output to
`<scratchpad>/orchestrate/<timestamp>-<project>.log`. JZ reads these to summarize
results. Logs are ephemeral (scratchpad), not committed.

## Dispatch Mechanism

For each resolved target project, JZ runs, in the **background** (parallel):

```bash
cd /Users/mrohan/Documents/<project> && \
claude -p "<user prompt>" \
  --permission-mode acceptEdits \
  --allowedTools "Read Edit Write Bash(npm test:*) Bash(npm run build:*) \
                  Bash(pytest:*) Bash(python:*) Bash(cargo test:*) \
                  Bash(git status:*) Bash(git diff:*) Bash(ls:*) Bash(cat:*)" \
  --disallowedTools "Bash(git push:*) Bash(git commit:*) mcp__gmail__send_email" \
  --append-system-prompt "You are a dispatched sub-agent. NEVER git push, NEVER \
    commit, NEVER send email or messages, NEVER place trades/orders or move money. \
    Make edits and run tests only. Leave changes uncommitted for review." \
  --output-format stream-json \
  > <scratchpad>/orchestrate/<ts>-<project>.log 2>&1
```

Notes:
- `acceptEdits` auto-approves file edits; in headless mode any tool not allowlisted
  is auto-denied — so push/commit/send/trade are denied by construction. The
  `--disallowedTools` and appended system prompt are defense-in-depth, not the sole
  guard.
- The exact allowlisted Bash set is tuned per project stack at implementation time
  (Python vs Node vs Rust). Registry `edit-eligible: no` projects are spawned with
  `--permission-mode plan` (or Write/Edit removed) so they only produce proposals.
- Concrete flag names verified on this machine (`claude --help`): `-p`,
  `--permission-mode`, `--allowedTools`, `--disallowedTools`, `--append-system-prompt`,
  `--add-dir`, `--output-format`.

## Flow

1. User sends a project-scoped prompt in this session.
2. JZ resolves target project(s) against `projects-registry.md`. Ambiguous → ask.
3. JZ confirms the dispatch plan (which projects, what each will be asked to do).
   For extra-locked projects, JZ requires explicit greenlight before spawning.
4. JZ fans out background `claude -p` runs, one per target, logging each.
5. As each run finishes, JZ reports: project, exit status, summary of what it did,
   and the resulting `git diff`. JZ **never** auto-commits or pushes.
6. State-mutating follow-ups (commit, push, merge, send) require explicit user
   approval, **one per action**, per the existing hard-rules.

## Error Handling

- **Spawn failure** (bad dir, CLI error): report per-project, don't abort the batch.
- **Non-zero exit / timeout:** surface the tail of the log; do not retry silently.
- **Agent hit a denied tool:** expected for push/send/trade attempts; report that the
  sub-agent stopped there and leave it to the user.
- **Partial batch:** report each project independently; a failure in one never blocks
  reporting the others.

## Testing / Verification

- Dry-run: dispatch a trivial read-only prompt ("summarize this repo") to one
  non-trading project and confirm log capture + reporting format.
- Guardrail test: dispatch a prompt that would tempt a push/commit and confirm the
  sub-agent is denied and JZ reports the denial rather than the action succeeding.
- Registry gate: confirm a prompt naming an unregistered project results in JZ
  refusing to dispatch and asking to register first.

## Open Items Resolved at Implementation Time

- Exact per-project allowlisted Bash commands (stack-dependent).
- Whether to pass `--add-dir` for any project that needs sibling access (default: no).
