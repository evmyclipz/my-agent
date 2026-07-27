# Orchestrator Mode Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give JZ an additive Orchestrator mode that dispatches guard-railed headless `claude -p` sessions into 4 registered projects, each carrying a committed `SESSION_CONTEXT.md`, plus a weekly self-learning review.

**Architecture:** All control files live in `my-agent/` (persona edits, a project registry, an `orchestrate` skill, a `self-learning` skill). Each of the 4 target projects gets a committed `SESSION_CONTEXT.md` and a `CLAUDE.md` pointer to it. Dispatch is a background `claude -p` per target with `--permission-mode acceptEdits` and an allowlist that makes push/commit/send/trade impossible by construction. JZ surfaces diffs; it never auto-commits.

**Tech Stack:** Markdown persona/skill/config files; the `claude` CLI in headless (`-p`) mode; bash for spawning; git per-repo.

**Spec:** `docs/superpowers/specs/2026-07-21-orchestrator-mode-design.md`

## Global Constraints

- Dispatched agents (and JZ) NEVER: `git push`, `git commit`, send email/messages, or place trades/transactions. Enforced by spawn flags, not trust.
- JZ never auto-commits or auto-pushes results — it surfaces the diff and the user decides. Commits in this plan are explicit, local-repo setup steps done with user awareness.
- JZ only dispatches to projects listed in `projects-registry.md`. Unlisted → ask the user to add first.
- The 3 trading/crypto projects are EXTRA-LOCKED: no live-order/execution code changes without an explicit per-run greenlight.
- Self-learning is propose-only: JZ never silently writes `lessons-learned.md` and never self-applies a lesson.
- Absolute paths everywhere. Registry paths are exactly: `/Users/mrohan/Documents/alpaca-trading-bot`, `/Users/mrohan/Documents/covered-call-income`, `/Users/mrohan/Documents/Quant/cryptoquantproject`, `/Users/mrohan/Documents/my-agent`.

---

### Task 1: Orchestrator persona section in `my-agent/CLAUDE.md`

**Files:**
- Modify: `/Users/mrohan/Documents/my-agent/CLAUDE.md` (append a new top-level section)

**Interfaces:**
- Consumes: nothing.
- Produces: the `## Orchestrator Mode` section that references `projects-registry.md` (Task 2), `skills/orchestrate/SKILL.md` (Task 3), `skills/self-learning/SKILL.md` (Task 4), and the `Last self-review:` marker in `lessons-learned.md` (Task 4).

- [ ] **Step 1: Append the Orchestrator Mode section**

Append verbatim to the end of `CLAUDE.md`:

```markdown
---

## Orchestrator Mode

I have a second operating mode. My email-triage / project-tracking role is unchanged; orchestration is additive.

### Mode routing
- I enter orchestrator mode when a prompt names a registered project (see `projects-registry.md`) or uses dispatch language: "dispatch", "agents", "across projects", "in <project>", "have <project> …".
- Otherwise I behave as the normal email/project assistant.
- When it is ambiguous which project is meant, I ask — I never guess the target.

### Dispatch — see `skills/orchestrate/SKILL.md` for the exact procedure
- I only dispatch to projects listed in `projects-registry.md`. Never to an unlisted project — I ask the user to add it first.
- Extra-locked projects (all trading/crypto) require an explicit per-run greenlight before I spawn.
- Dispatched agents may edit files and run tests. They NEVER push, commit, send, or place trades/transactions — enforced by the spawn flags, not trust.
- I never auto-commit or auto-push results. I surface each run's diff and let the user decide.

### Session-start self-learning check
- At session start I read the `Last self-review:` marker at the top of `lessons-learned.md`.
- If today − that date ≥ 7 days, I run the self-learning review (`skills/self-learning/SKILL.md`) before other work.
- Otherwise I skip it.

### Inheritance
`agent.md` hard-rules bind orchestrator mode with no exceptions: never send, never trade, never push, no batch mutation without an approved list.
```

- [ ] **Step 2: Verify the section is present and well-formed**

Run: `grep -n "## Orchestrator Mode" /Users/mrohan/Documents/my-agent/CLAUDE.md`
Expected: one match. Then eyeball that the four references (`projects-registry.md`, `skills/orchestrate/SKILL.md`, `skills/self-learning/SKILL.md`, `Last self-review:`) all appear via: `grep -nE "projects-registry|orchestrate/SKILL|self-learning/SKILL|Last self-review" /Users/mrohan/Documents/my-agent/CLAUDE.md`
Expected: 4 matches.

- [ ] **Step 3: Commit**

```bash
cd /Users/mrohan/Documents/my-agent
git add CLAUDE.md
git commit -m "feat(jz): add Orchestrator Mode section to persona"
```

---

### Task 2: Project registry (`my-agent/projects-registry.md`)

**Files:**
- Create: `/Users/mrohan/Documents/my-agent/projects-registry.md`

**Interfaces:**
- Consumes: nothing.
- Produces: the authoritative registry of 4 projects (dir-name, path, purpose, edit-eligible, guardrails, has-own-claude-md). Consumed by Task 3's dispatch preconditions and by CLAUDE.md mode routing.

- [ ] **Step 1: Create the registry file**

Write to `/Users/mrohan/Documents/my-agent/projects-registry.md`:

```markdown
# Projects Registry

Authoritative map of projects JZ may orchestrate. JZ never dispatches to a project absent from this file. Rows are approved by the user before use.

## Schema

```
### <dir-name>
- path: <absolute path>
- purpose: <one line>
- edit-eligible: yes | no        # no = read/plan only; diffs surfaced, no writes
- guardrails: <per-project notes>
- has-own-claude-md: yes | no
```

---

### alpaca-trading-bot
- path: /Users/mrohan/Documents/alpaca-trading-bot
- purpose: Alpaca-based equities trading bot.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No modification of live-order/execution code paths without an explicit per-run greenlight. Never place trades.
- has-own-claude-md: yes

### covered-call-income
- path: /Users/mrohan/Documents/covered-call-income
- purpose: Covered-call options income strategy.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### cryptoquantproject
- path: /Users/mrohan/Documents/Quant/cryptoquantproject
- purpose: Crypto quant research/trading project.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### my-agent
- path: /Users/mrohan/Documents/my-agent
- purpose: JZ itself — self-improvement target.
- edit-eligible: yes
- guardrails: Dispatch-to-self. JZ flags plainly whenever a dispatch targets its own project.
- has-own-claude-md: yes
```

- [ ] **Step 2: Verify all 4 projects and their exact paths are present**

Run: `grep -cE "^### " /Users/mrohan/Documents/my-agent/projects-registry.md`
Expected: `4`
Run: `grep -c "EXTRA-LOCKED" /Users/mrohan/Documents/my-agent/projects-registry.md`
Expected: `3`

- [ ] **Step 3: Commit**

```bash
cd /Users/mrohan/Documents/my-agent
git add projects-registry.md
git commit -m "feat(jz): add project registry scoped to 4 active projects"
```

---

### Task 3: Dispatch skill (`my-agent/skills/orchestrate/SKILL.md`)

**Files:**
- Create: `/Users/mrohan/Documents/my-agent/skills/orchestrate/SKILL.md`

**Interfaces:**
- Consumes: `projects-registry.md` (Task 2) for preconditions; `SESSION_CONTEXT.md` in each target (Tasks 5–6) as the read-first orientation file.
- Produces: the canonical spawn template + report/after-run procedure that CLAUDE.md's Dispatch section points to.

- [ ] **Step 1: Create the skill file**

Write to `/Users/mrohan/Documents/my-agent/skills/orchestrate/SKILL.md`:

````markdown
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

## Report
When each run finishes, report per project:
- project name + exit status
- summary of what the agent did (from its log)
- the `git diff` it produced (uncommitted)

Never auto-commit or auto-push.

## After the run
- Refresh the project's `SESSION_CONTEXT.md` with new state / next actions drawn from the run. This is an edit surfaced in the diff — not a commit.
- Commit / push / merge / send require explicit user approval, one per action.
````

- [ ] **Step 2: Verify the guardrail flags are literally present**

Run: `grep -c "Bash(git push:\*)" /Users/mrohan/Documents/my-agent/skills/orchestrate/SKILL.md`
Expected: `1`
Run: `grep -c "acceptEdits" /Users/mrohan/Documents/my-agent/skills/orchestrate/SKILL.md`
Expected: `1`

- [ ] **Step 3: Commit**

```bash
cd /Users/mrohan/Documents/my-agent
git add skills/orchestrate/SKILL.md
git commit -m "feat(jz): add orchestrate dispatch skill"
```

---

### Task 4: Self-learning skill + `lessons-learned.md` marker

**Files:**
- Create: `/Users/mrohan/Documents/my-agent/skills/self-learning/SKILL.md`
- Modify: `/Users/mrohan/Documents/my-agent/lessons-learned.md` (add a `Last self-review:` marker near the top)

**Interfaces:**
- Consumes: `lessons-learned.md` entry format + the `Last self-review:` marker; memory dir; dispatch logs.
- Produces: the review procedure CLAUDE.md's session-start check invokes.

- [ ] **Step 1: Add the `Last self-review` marker to `lessons-learned.md`**

Insert this line immediately after the first `---` separator in `/Users/mrohan/Documents/my-agent/lessons-learned.md` (before the `## Entry Format` heading):

```markdown
**Last self-review:** none yet
```

- [ ] **Step 2: Create the self-learning skill file**

Write to `/Users/mrohan/Documents/my-agent/skills/self-learning/SKILL.md`:

````markdown
---
name: self-learning
description: Use at session start when lessons-learned.md's Last self-review marker is >=7 days old, or when the user asks — mines recent mistakes and proposes lessons-learned entries and persona/skill fixes for confirmation. Propose-only, never self-applies.
---

# Self-Learning Review

A weekly reflection so JZ improves from past mistakes instead of repeating them. Builds on the `lessons-learned.md` propose→confirm flow; it does not bypass it.

## When
- Session start, if the `**Last self-review:**` marker in `lessons-learned.md` is `none yet` or ≥ 7 days ago.
- Or on explicit user request.

## Procedure
1. Gather mistake signals:
   - Recent memory entries (`~/.claude/projects/-Users-mrohan-Documents-my-agent/memory/`).
   - Corrections the user gave in recent sessions.
   - Dispatch outcomes: denied-tool hits, failed/aborted runs, diffs the user rejected.
   - Existing `lessons-learned.md` entries (to spot repeats).
2. Identify recurring patterns worth a behavioral correction.
3. For each, draft a `lessons-learned.md` entry in the file's existing format with `Status: Proposed`.
4. Where a lesson is really a process fix, also draft a specific diff to `CLAUDE.md`, `agent.md`, or a skill.
5. Present all proposals to the user and wait. Never silently write `lessons-learned.md`; never self-apply a lesson.
6. After presenting — whether or not anything was proposed — update the `**Last self-review:**` marker in `lessons-learned.md` to today's date.

## Guard
This skill proposes. It never edits persona/skills or dispatches agents on its own — it is a reflection step, not an action step.
````

- [ ] **Step 3: Verify**

Run: `grep -n "Last self-review" /Users/mrohan/Documents/my-agent/lessons-learned.md`
Expected: one match with value `none yet`.
Run: `test -f /Users/mrohan/Documents/my-agent/skills/self-learning/SKILL.md && echo ok`
Expected: `ok`

- [ ] **Step 4: Commit**

```bash
cd /Users/mrohan/Documents/my-agent
git add skills/self-learning/SKILL.md lessons-learned.md
git commit -m "feat(jz): add weekly self-learning review skill + review marker"
```

---

### Task 5: Session-context for `my-agent` (template + own file + pointer)

**Files:**
- Create: `/Users/mrohan/Documents/my-agent/SESSION_CONTEXT.md`
- Modify: `/Users/mrohan/Documents/my-agent/CLAUDE.md` (add one-line session-start pointer)

**Interfaces:**
- Consumes: nothing.
- Produces: the `SESSION_CONTEXT.md` shape reused by Task 6, and proves the cold-session pointer pattern in a repo that already has a CLAUDE.md.

- [ ] **Step 1: Create `my-agent/SESSION_CONTEXT.md`**

Read `README`/`CLAUDE.md` and the last 10 commits (`git -C /Users/mrohan/Documents/my-agent log --oneline -10`) to fill the sections with real content. Use this exact structure:

```markdown
# Session Context — my-agent

Path: /Users/mrohan/Documents/my-agent
Last updated: <today's absolute date> by JZ (orchestrator)

## Current state
- <3–6 bullets: where JZ development stands now>

## Active threads / open questions
- <in-flight decisions, blockers>

## Next actions
1. <prioritized>

## Key files / entry points
- `CLAUDE.md` — JZ persona + orchestrator mode
- `agent.md` — canonical hard-rules
- `projects-registry.md` — orchestration targets
- `skills/` — orchestrate, self-learning, email-*

## Recent activity
- <today's date> — Orchestrator mode + session-context + self-learning implemented (last 3–5 entries; older trimmed)
```

- [ ] **Step 2: Add the session-start pointer to `my-agent/CLAUDE.md`**

Insert near the top of `CLAUDE.md` (immediately after the first heading block), verbatim:

```markdown
> **Session start:** read `SESSION_CONTEXT.md` first for current state and next actions.
```

- [ ] **Step 3: Verify**

Run: `test -f /Users/mrohan/Documents/my-agent/SESSION_CONTEXT.md && grep -q "Session start:" /Users/mrohan/Documents/my-agent/CLAUDE.md && echo ok`
Expected: `ok`

- [ ] **Step 4: Commit**

```bash
cd /Users/mrohan/Documents/my-agent
git add SESSION_CONTEXT.md CLAUDE.md
git commit -m "feat(jz): add own SESSION_CONTEXT.md + session-start pointer"
```

---

### Task 6: Session-context + CLAUDE.md pointer for the 3 external projects

**Files (each in its own repo):**
- Create: `/Users/mrohan/Documents/alpaca-trading-bot/SESSION_CONTEXT.md`
- Modify: `/Users/mrohan/Documents/alpaca-trading-bot/CLAUDE.md` (add pointer line)
- Create: `/Users/mrohan/Documents/covered-call-income/SESSION_CONTEXT.md`
- Create: `/Users/mrohan/Documents/covered-call-income/CLAUDE.md` (minimal, with pointer)
- Create: `/Users/mrohan/Documents/Quant/cryptoquantproject/SESSION_CONTEXT.md`
- Create: `/Users/mrohan/Documents/Quant/cryptoquantproject/CLAUDE.md` (minimal, with pointer)

**Interfaces:**
- Consumes: the `SESSION_CONTEXT.md` structure from Task 5.
- Produces: a read-first context file + cold-session hook in each external target.

- [ ] **Step 1: Create each project's `SESSION_CONTEXT.md`**

For each of the 3 projects, read its `README`/`CLAUDE.md` and `git -C <path> log --oneline -10`, then write `<path>/SESSION_CONTEXT.md` using the Task 5 structure with the project's real name, path, and first-pass current state. Keep it ~1 page.

- [ ] **Step 2: Add/create the CLAUDE.md pointer in each project**

For `alpaca-trading-bot` (has an existing CLAUDE.md) — insert near the top, verbatim:

```markdown
> **Session start:** read `SESSION_CONTEXT.md` first for current state and next actions.
```

For `covered-call-income` and `cryptoquantproject` (no CLAUDE.md) — create `<path>/CLAUDE.md` with exactly:

```markdown
# CLAUDE.md

> **Session start:** read `SESSION_CONTEXT.md` first for current state and next actions.

This project is orchestrated by JZ (see `~/Documents/my-agent`). It is EXTRA-LOCKED: no live-order/execution code changes without an explicit per-run greenlight, and never place trades.
```

- [ ] **Step 3: Verify all three**

Run:
```bash
for p in /Users/mrohan/Documents/alpaca-trading-bot /Users/mrohan/Documents/covered-call-income /Users/mrohan/Documents/Quant/cryptoquantproject; do
  test -f "$p/SESSION_CONTEXT.md" && grep -q "Session start:" "$p/CLAUDE.md" && echo "$p ok" || echo "$p MISSING";
done
```
Expected: three `... ok` lines.

- [ ] **Step 4: Commit in each repo (local, with user awareness)**

```bash
cd /Users/mrohan/Documents/alpaca-trading-bot && git add SESSION_CONTEXT.md CLAUDE.md && git commit -m "chore: add SESSION_CONTEXT.md + session-start pointer for JZ orchestration"
cd /Users/mrohan/Documents/covered-call-income && git add SESSION_CONTEXT.md CLAUDE.md && git commit -m "chore: add SESSION_CONTEXT.md + minimal CLAUDE.md for JZ orchestration"
cd /Users/mrohan/Documents/Quant/cryptoquantproject && git add SESSION_CONTEXT.md CLAUDE.md && git commit -m "chore: add SESSION_CONTEXT.md + minimal CLAUDE.md for JZ orchestration"
```

---

### Task 7: End-to-end verification (the real behavior tests)

**Files:** none created. This task runs the spec's verification scenarios against the built system.

**Interfaces:**
- Consumes: Tasks 1–6.
- Produces: evidence the guardrails and flows work. No commit.

- [ ] **Step 1: Dry-run dispatch to `my-agent` (safe, non-trading)**

Run (foreground for the test; real dispatch backgrounds it):
```bash
mkdir -p "$SCRATCH/orchestrate"
cd /Users/mrohan/Documents/my-agent && \
claude -p "First read ./SESSION_CONTEXT.md for current state. Then: in one paragraph, summarize this repo. Do not edit anything." \
  --permission-mode plan \
  --allowedTools "Read Bash(git status:*) Bash(git diff:*) Bash(ls:*) Bash(cat:*)" \
  --output-format stream-json --verbose \
  > "$SCRATCH/orchestrate/dryrun-my-agent.log" 2>&1; echo "exit=$?"
```
Expected: `exit=0`, and the log shows the agent read `SESSION_CONTEXT.md` before summarizing.

- [ ] **Step 2: Confirm the session-context read happened**

Run: `grep -i "SESSION_CONTEXT" "$SCRATCH/orchestrate/dryrun-my-agent.log" | head`
Expected: at least one line referencing the file being read.

- [ ] **Step 3: Guardrail test — a push must be denied**

Run:
```bash
cd /Users/mrohan/Documents/my-agent && \
claude -p "Run: git push origin master. If that is not permitted, say 'PUSH DENIED' and stop." \
  --permission-mode acceptEdits \
  --allowedTools "Read Bash(git status:*)" \
  --disallowedTools "Bash(git push:*) Bash(git commit:*)" \
  --output-format stream-json --verbose \
  > "$SCRATCH/orchestrate/guardrail.log" 2>&1; echo "exit=$?"
grep -i "denied\|not permitted\|cannot\|PUSH DENIED" "$SCRATCH/orchestrate/guardrail.log" | head
```
Expected: output shows the push was refused; confirm with `git -C /Users/mrohan/Documents/my-agent status` that nothing was pushed/committed by the run.

- [ ] **Step 4: Registry-gate check (behavioral, in this session)**

Confirm by inspection: a prompt naming a project NOT in `projects-registry.md` (e.g. "dispatch to Wellfleet") must make JZ refuse and ask to register it first. Verify the registry lists only the 4 approved projects:
Run: `grep -E "^### " /Users/mrohan/Documents/my-agent/projects-registry.md`
Expected: exactly `alpaca-trading-bot`, `covered-call-income`, `cryptoquantproject`, `my-agent`.

- [ ] **Step 5: Self-learning staleness check (behavioral)**

Confirm by inspection: with `**Last self-review:** none yet`, JZ runs the review at the next session start; after a review it stamps today's date. Verify the marker exists:
Run: `grep -n "Last self-review" /Users/mrohan/Documents/my-agent/lessons-learned.md`
Expected: one match.

- [ ] **Step 6: Report results**

Summarize pass/fail for each check above to the user. Do not commit anything in this task.

---

## Notes for the executor

- Steps that say "read the README / last 10 commits and fill sections" (Tasks 5–6) produce project-specific content that cannot be pre-written here; the structure is fixed, the content is derived at execution time. This is the one place the plan is intentionally generative rather than literal.
- Task 7's `claude -p` runs cost tokens and take time; run them once and capture logs.
- If any external repo (Task 6) has a dirty tree, surface it and ask before committing — do not sweep unrelated changes into these setup commits.
