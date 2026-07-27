# Orchestrator Mode — Design Spec

**Date:** 2026-07-21 (updated 2026-07-27: registry scope locked; session-context files added)
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
- No cross-project shared state beyond the registry, per-run logs, and each
  project's `SESSION_CONTEXT.md`.
- No auto-commit, auto-push, or auto-merge — ever.
- No full agent personas authored inside the target projects. The only files JZ
  adds to a target project are `SESSION_CONTEXT.md` and (for the two lacking one) a
  **minimal** `CLAUDE.md` that just points to it — not a full persona.

## Architecture

Artifacts in `my-agent/` (persona, registry, dispatch skill), a
`SESSION_CONTEXT.md` in each target project, and a per-run log convention:

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
- **Session-start self-learning check:** at session start JZ reads the last-review
  date and, if ≥ 7 days, runs the self-learning review (see below) before other work.

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

Registry is populated by JZ and **approved row-by-row by the user** before first use.

**Initial scope — locked to 4 active projects:**

| Project | Path | Class | edit-eligible | own CLAUDE.md |
|---------|------|-------|---------------|---------------|
| alpaca-trading-bot | `~/Documents/alpaca-trading-bot` | extra-locked (trading) | yes | yes |
| covered-call-income | `~/Documents/covered-call-income` | extra-locked (trading) | yes | no → add minimal |
| cryptoquantproject | `~/Documents/Quant/cryptoquantproject` | extra-locked (crypto) | yes | no → add minimal |
| my-agent | `~/Documents/my-agent` | self-improve (dispatch-to-self) | yes | yes |

All three trading/crypto projects are **extra-locked**: their live-order / execution
code paths are not to be modified by a spawned agent without an explicit per-run
greenlight from the user, and the standard "no trades/transactions" denial always
applies. `my-agent` is a special case — dispatching there spawns a `claude -p` inside
JZ's own project dir; JZ flags plainly whenever a dispatch targets itself. JZ never
dispatches to a project outside this table without the user first adding it.

### 3. Dispatch skill (`skills/orchestrate/SKILL.md`)

Documents the repeatable dispatch pattern so invocations are consistent, not
improvised. Contains the canonical spawn template (below), the flow, and the
reporting format.

### 4. Per-run logs

Each spawned run streams output to
`<scratchpad>/orchestrate/<timestamp>-<project>.log`. JZ reads these to summarize
results. Logs are ephemeral (scratchpad), not committed.

### 5. Session-context files (`<project>/SESSION_CONTEXT.md`)

One per target project — see the **Session-Context Files** section below.

### 6. Self-learning skill (`skills/self-learning/SKILL.md`)

A weekly review that mines recent work for recurring mistakes and proposes
improvements — see the **Self-Learning Review** section below.

## Session-Context Files

A compact, curated living-state doc at each project root, so a fresh session (yours or
a dispatched agent's) orients from one ~1-page read instead of burning tokens
re-exploring the repo. That token save is the entire purpose, so the file is kept
bounded — JZ trims as it grows.

- **Filename / location:** `SESSION_CONTEXT.md` at each project root.
- **Git:** committed to the project repo (durable, travels with the code, history of
  state changes).
- **Maintainer:** JZ owns it. JZ refreshes a project's file (a) after any dispatched
  run to that project, folding in the agent's summary + diff, and (b) on explicit
  request. **Known gap:** if the user works a session directly without telling JZ, the
  file goes stale until JZ next touches it — accepted, given JZ-as-maintainer.
- **Cold-session hook:** `covered-call-income` and `cryptoquantproject` have no
  `CLAUDE.md`, so JZ adds a **minimal** one whose first instruction is "read
  `SESSION_CONTEXT.md` before anything." Projects with an existing `CLAUDE.md`
  (`alpaca-trading-bot`, `my-agent`) get the same one-line pointer added. This makes
  the token-save apply to the user's own manual cold sessions, not just dispatches.

Template:

```markdown
# Session Context — <project>

Path: /Users/mrohan/Documents/<project>
Last updated: <absolute date> by JZ (orchestrator)

## Current state
- <3–6 bullets: where things stand now>

## Active threads / open questions
- <in-flight decisions, blockers>

## Next actions
1. <prioritized>

## Key files / entry points
- `<path>` — <what it is>

## Recent activity
- <date> — <what happened> (last 3–5 entries; older trimmed)
```

## Dispatch Mechanism

For each resolved target project, JZ runs, in the **background** (parallel):

```bash
cd /Users/mrohan/Documents/<project> && \
claude -p "First read ./SESSION_CONTEXT.md for current state. Then: <user prompt>" \
  --permission-mode acceptEdits \
  --allowedTools "Read Edit Write Bash(npm test:*) Bash(npm run build:*) \
                  Bash(pytest:*) Bash(python:*) Bash(cargo test:*) \
                  Bash(git status:*) Bash(git diff:*) Bash(ls:*) Bash(cat:*)" \
  --disallowedTools "Bash(git push:*) Bash(git commit:*) mcp__gmail__send_email" \
  --append-system-prompt "You are a dispatched sub-agent. NEVER git push, NEVER \
    commit, NEVER send email or messages, NEVER place trades/orders or move money. \
    Make edits and run tests only. Leave changes uncommitted for review." \
  --output-format stream-json --verbose \
  > <scratchpad>/orchestrate/<ts>-<project>.log 2>&1
```

> Note: `--verbose` is required — `--print` + `--output-format stream-json` errors without it (caught in end-to-end verification).

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
6. JZ refreshes that project's `SESSION_CONTEXT.md` with the new state / next actions
   drawn from the run. (This is a write JZ makes to the target project; it is not a
   commit — the updated file is surfaced in the diff for the user like any other edit.)
7. State-mutating follow-ups (commit, push, merge, send) require explicit user
   approval, **one per action**, per the existing hard-rules.

## Self-Learning Review

A recurring review so JZ improves from past mistakes instead of repeating them. Builds
on the existing `lessons-learned.md` propose→confirm flow — it does not bypass it.

- **Cadence:** weekly.
- **Trigger:** session-start staleness check (no daemon, consistent with the non-goals).
  JZ stores the last-review date as a `Last self-review: <date>` marker at the top of
  `lessons-learned.md`. At session start, if today − marker ≥ 7 days, JZ runs the
  review before other work; otherwise it does nothing.
- **Inputs (mistake signals):** recent memory entries, corrections the user gave in
  recent sessions, dispatch outcomes (denied-tool hits, failed/aborted runs, diffs the
  user rejected), and existing `lessons-learned.md` entries (to spot repeats).
- **Output:** JZ proposes new `lessons-learned.md` entries (`Status: Proposed`) using
  the file's existing entry format. Where a lesson is really a process fix, JZ may also
  propose a specific edit to `CLAUDE.md`, `agent.md`, or a skill — as a diff, never
  applied unilaterally.
- **Confirmation:** JZ presents proposals and waits. Per the existing hard-rule, JZ
  never silently updates `lessons-learned.md` and never self-applies a lesson. After
  running (whether or not anything was proposed), JZ updates the `Last self-review`
  marker to today's date so the cadence resets.
- **Scope guard:** the review proposes; it never edits persona/skills or dispatches
  agents on its own. It is a reflection step, not an action step.
- **Non-zero exit / timeout:** surface the tail of the log; do not retry silently.
- **Agent hit a denied tool:** expected for push/send/trade attempts; report that the
  sub-agent stopped there and leave it to the user.
- **Partial batch:** report each project independently; a failure in one never blocks
  reporting the others.

## Testing / Verification

- Dry-run: dispatch a trivial read-only prompt ("summarize this repo") to `my-agent`
  (the only non-trading project in scope) and confirm log capture + reporting format.
- Guardrail test: dispatch a prompt that would tempt a push/commit and confirm the
  sub-agent is denied and JZ reports the denial rather than the action succeeding.
- Registry gate: confirm a prompt naming an unregistered project results in JZ
  refusing to dispatch and asking to register first.
- Session-context read: confirm a dispatched agent reads `SESSION_CONTEXT.md` first
  (visible in its log) rather than re-exploring the repo.
- Session-context write: confirm JZ updates the project's `SESSION_CONTEXT.md` after a
  run and surfaces it in the diff rather than committing it.
- Cold-session hook: confirm the minimal `CLAUDE.md` added to `covered-call-income` and
  `cryptoquantproject` points a fresh manual session to `SESSION_CONTEXT.md`.
- Self-learning staleness: with a `Last self-review` marker ≥ 7 days old, confirm JZ
  runs the review at session start; with a recent marker, confirm it does not.
- Self-learning propose-only: confirm the review proposes `lessons-learned.md` entries
  (and any persona/skill diffs) and waits — never self-applies — then updates the marker.

## Open Items Resolved at Implementation Time

- Exact per-project allowlisted Bash commands (stack-dependent).
- Whether to pass `--add-dir` for any project that needs sibling access (default: no).
